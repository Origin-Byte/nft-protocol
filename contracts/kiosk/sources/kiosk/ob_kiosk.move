/// We publish our extension to `sui::kiosk::Kiosk` object.
/// We extend the functionality of the base object with the aim to provide
/// better client experience and royalty enforcement.
/// This module closely co-operates with `ob_transfer_request` module.
///
/// When working with this module, you use the base type in your function
/// signatures but call functions in this module to access the functionality.
/// We hide the `sui::kiosk::KioskOwnerCap` type, it cannot be accessed.
///
/// Differences over the base object:
/// - Once a OB `Kiosk` is owned by a user address, it can never change owner.
/// This mitigates royalty enforcement avoidance by trading `KioskOwnerCap`s.
/// - Authorization with `tx_context::sender` rather than an `OwnerCap`.
/// This means one less object to keep track of.
/// - Permissionless deposits configuration.
/// This means deposits can be made without the owner signature.
/// - NFTs can be optionally always live in `Kiosk`, hence creating an option
/// for a bullet proof royalty enforcement.
/// While the base type attempts to replicate this functionality, due to the
/// necessity of using `KioskOwnerCap` for deposits, it is not possible to
/// use it in context of trading where seller is the one matching the trade.
/// - NFTs can be listed for a specific entity, be it a smart contract or a user.
/// Only allowed entities (by the owner) can withdraw NFTs.
/// - There is no `sui::kiosk::PurchaseCap` for exclusive listings.
/// We provide a unified interface for exclusive and non-exclusive listing.
/// Also, once less object to keep track of.
/// - We don't have functionality to list NFTs within the `Kiosk` itself.
/// Rather, clients are encouraged to use the liquidity layer.
/// - Permissionless `Kiosk` needs to signer, apps don't have to wrap both
/// the `KioskOwnerCap` and the `Kiosk` in a smart contract.
module ob_kiosk::ob_kiosk {
    use std::option::Option;
    use std::string::utf8;
    use std::vector;
    use std::type_name::{Self, TypeName};

    use sui::display;
    use sui::package::{Self, Publisher};
    use sui::dynamic_field::{Self as df};
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap, uid, uid_mut as ext};
    use sui::object::{Self, ID, UID, uid_to_address};
    use sui::coin::{Self, Coin};
    use sui::table::{Self, Table};
    use sui::transfer::{transfer, public_share_object, public_transfer};
    use sui::tx_context::{Self, TxContext, sender};
    use sui::vec_set::{Self, VecSet};

    use ob_permissions::witness::Witness as DelegatedWitness;
    use ob_request::transfer_request::{Self, TransferRequest};
    use ob_request::withdraw_request::{Self, WithdrawRequest};
    use ob_request::borrow_request::{Self, BorrowRequest, BORROW_REQ};
    use ob_request::request::{Self, Policy, RequestBody, WithNft};
    use ob_kiosk::kiosk::KIOSK;

    // Track the current version of the module
    const VERSION: u64 = 3;

    const EDeprecatedApi: u64 = 998;
    const ENotUpgraded: u64 = 999;
    const EWrongVersion: u64 = 1000;

    struct VersionDfKey has copy, store, drop {}

    // === Errors ===

    /// Trying to access an NFT that is not in the kiosk
    const EMissingNft: u64 = 1;
    /// NFT is already listed exclusively
    const ENftAlreadyExclusivelyListed: u64 = 2;
    /// NFT is already listed
    const ENftAlreadyListed: u64 = 3;
    /// Trying to withdraw profits and sender is not owner
    const EPermissionlessDepositsDisabled: u64 = 4;
    /// The provided Kiosk is not an OriginByte extension
    const EKioskNotOriginByteVersion: u64 = 5;
    /// The ID provided does not match the Kiosk
    const EIncorrectKioskId: u64 = 6;
    /// Trying to withdraw profits and sender is not owner
    const ENotOwner: u64 = 7;
    /// The transfer is not authorized for the given entity
    const ENotAuthorized: u64 = 8;
    /// Error for operations which demand that the kiosk owner is set to
    /// `PermissionlessAddr`
    const EKioskNotPermissionless: u64 = 9;
    /// The NFT type does not match the desired type
    const ENftTypeMismatch: u64 = 10;
    /// Permissionless deposits are not enabled and sender is not the owner
    const ECannotDeposit: u64 = 11;
    /// To register an NFT in the OB extension, it cannot be already listed in the
    /// base Kiosk
    const ENftIsListedInBaseKiosk: u64 = 12;
    /// The token provided does not correspond to the Kiosk
    const EIncorrectOwnerToken: u64 = 13;
    /// You're trying to uninstall the OriginByte extension but there are still
    /// entries in the `NftRefs` table
    const ECannotUninstallWithCurrentBookeeping: u64 = 14;
    /// The provided Kiosk is already OriginByte extension
    const EKioskOriginByteVersion: u64 = 15;

    // === Constants ===

    /// If the owner of the kiosk is set to this address, all methods which
    /// would normally verify that the owner is the signer are permissionless.
    ///
    /// This is useful for wrapping kiosk functionality in a smart contract.
    /// Create a new permissionless kiosk with `new_permissionless`.
    const PermissionlessAddr: address = @0xb;

    // === Structs ===

    /// In the context of Originbyte, we use this type to prove module access.
    /// Only this module can instantiate this type.
    struct Witness has drop {}

    /// Only OB kiosks owned by actual users (not permissionless) have this
    /// honorary token.
    ///
    /// Is created when a kiosk is assigned to a user.
    /// It cannot be transferred and has no meaning in the context of on-chain
    /// logic.
    /// It serves purely as a discovery mechanism for off-chain clients.
    /// They get query objects with filter by this type, owned by a specific
    /// address.
    struct OwnerToken has key {
        id: UID,
        kiosk: ID,
        owner: address,
    }

    /// Inner accounting type.
    /// Stored under `NftRefsDfKey` as a dynamic field.
    ///
    /// Holds info about NFT listing which is used to determine if an entity
    /// is allowed to redeem the NFT.
    struct NftRef has store, drop {
        /// Entities which can use their `&UID` to redeem the NFT.
        ///
        /// We use address to be more versatile since `ID` can be converted to
        /// address.
        /// This way we support signers to be auths.
        auths: VecSet<address>,
        /// If set to true, then `listed_with` must have length of 1 and
        /// listed_for must be "none".
        is_exclusively_listed: bool,
    }

    /// Configures how deposits without owner signing are limited
    /// Stored under `DepositSettingDfKey` as a dynamic field.
    struct DepositSetting has store, drop {
        /// Enables depositing any collection, bypassing enabled deposits
        enable_any_deposit: bool,
        /// Collections which can be deposited into the `Kiosk`
        collections_with_enabled_deposits: VecSet<TypeName>,
    }

    // === Dynamic field keys ===

    /// For `Kiosk::id` value `Table<ID, NftRef>`
    struct NftRefsDfKey has store, copy, drop {}
    /// For `Kiosk::id` value `KioskOwnerCap`
    struct KioskOwnerCapDfKey has store, copy, drop {}
    /// For `Kiosk::id` value `DepositSetting`
    struct DepositSettingDfKey has store, copy, drop {}
    /// For `TransferRequest::metadata` value `TypeName`
    struct AuthTransferRequestDfKey has store, copy, drop {}

    // === Instantiators ===

    /// Creates a new `Kiosk` for the transaction sender
    ///
    /// A `Kiosk` object will be created and a corresponding `OwnerToken` is
    /// deposited in the sender's address.
    ///
    /// All deposits are allowed permissionlessly by default, to restrict
    /// deposits, see `restrict_deposits`.
    public fun new(ctx: &mut TxContext): (Kiosk, ID) {
        new_for_address(tx_context::sender(ctx), ctx)
    }

    /// Create a new `Kiosk` for the provided address
    ///
    /// A `Kiosk` object will be created and a corresponding `OwnerToken`
    /// is deposited in the address.
    ///
    /// All deposits are allowed permissionlessly by default, to restrict
    /// deposits, see `restrict_deposits`.
    public fun new_for_address(owner: address, ctx: &mut TxContext): (Kiosk, ID) {
        let kiosk = new_(owner, ctx);

        let token_uid = object::new(ctx);
        let token_id = object::uid_to_inner(&token_uid);

        transfer(
            OwnerToken {
                id: token_uid,
                kiosk: object::id(&kiosk),
                owner,
            },
            owner,
        );

        (kiosk, token_id)
    }

    /// Creates a new `Kiosk` for the transaction sender and shares it
    ///
    ///  A shared `Kiosk` object will be created and a corresponding
    /// `OwnerToken` deposited in the sender's address.
    ///
    /// All deposits are allowed permissionlessly by default, to restrict
    /// deposits, see `restrict_deposits`.
    public fun create_for_sender(ctx: &mut TxContext): (ID, ID) {
        create_for_address(tx_context::sender(ctx), ctx)
    }

    /// Creates a new `Kiosk` for the provided address and shares it
    ///
    ///  A shared `Kiosk` object will be created and a corresponding
    /// `OwnerToken` deposited in the address.
    ///
    /// All deposits are allowed permissionlessly by default, to restrict
    /// deposits, see `restrict_deposits`.
    public fun create_for_address(owner: address, ctx: &mut TxContext): (ID, ID) {
        let (kiosk, token_id) = new_for_address(owner, ctx);
        let kiosk_id = object::id(&kiosk);

        public_share_object(kiosk);
        (kiosk_id, token_id)
    }

    /// Creates a new `Kiosk` for the transaction sender and shares it
    ///
    /// See `create_for_sender`.
    public entry fun init_for_sender(ctx: &mut TxContext) {
        create_for_sender(ctx);
    }


    /// Creates a new `Kiosk` for the provided address and shares it
    ///
    /// See `create_for_address`.
    public entry fun init_for_address(owner: address, ctx: &mut TxContext) {
        create_for_address(owner, ctx);
    }

    /// Create a new OriginByte `Kiosk`
    fun new_(owner: address, ctx: &mut TxContext): Kiosk {
        let (kiosk, kiosk_cap) = kiosk::new(ctx);

        kiosk::set_owner_custom(&mut kiosk, &kiosk_cap, owner);
        install_extension_(&mut kiosk, kiosk_cap, ctx);

        kiosk
    }

    /// Create a new permissionless `Kiosk`
    ///
    /// A `Kiosk` object will be created with all functions that would normally
    /// verify that the transaction sender is the owner being freely callable.
    ///
    /// All deposits are allowed permissionlessly by default, to restrict
    /// deposits, see `restrict_deposits`.
    public fun new_permissionless(ctx: &mut TxContext): Kiosk {
        new_(PermissionlessAddr, ctx)
    }

    /// Create a new permissionless `Kiosk` and share it
    ///
    /// A `Kiosk` object will be created with all functions that would normally
    /// verify that the transaction sender is the owner being freely callable.
    ///
    /// All deposits are allowed permissionlessly by default, to restrict
    /// deposits, see `restrict_deposits`.
    public fun create_permissionless(ctx: &mut TxContext): ID {
        let kiosk = new_permissionless(ctx);
        let kiosk_id = object::id(&kiosk);

        public_share_object(kiosk);
        kiosk_id
    }

    /// Create a new permissionless `Kiosk` and share it
    ///
    /// See `create_permissionless`.
    public entry fun init_permissionless(ctx: &mut TxContext) {
        create_permissionless(ctx);
    }

    /// Changes the owner of a `Kiosk` to the given address.
    ///
    /// The address that is set as the owner of the kiosk is the address that
    /// will remain the owner forever.
    ///
    /// #### Panics
    ///
    /// Panics if the `Kiosk` is not permissionless.
    public entry fun set_permissionless_to_permissioned(
        self: &mut Kiosk, user: address, ctx: &mut TxContext
    ) {
        assert!(kiosk::owner(self) == PermissionlessAddr, EKioskNotPermissionless);

        let cap = pop_cap(self);
        kiosk::set_owner_custom(self, &cap, user);
        set_cap(self, cap);

        transfer(OwnerToken {
            id: object::new(ctx),
            kiosk: object::id(self),
            owner: user,
        }, user);
    }

    // === Deposit to the Kiosk ===

    /// Deposit NFT within `Kiosk`
    ///
    /// Deposits can be restricted by the `Kiosk` owner to avoid spam NFTs
    /// being deposited.
    ///
    /// #### Panics
    ///
    /// Panics if permissionless deposits are not enabled for `T` and
    /// transaction sender is not the `Kiosk` owner.
    public entry fun deposit<T: key + store>(
        self: &mut Kiosk,
        nft: T,
        ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(ext(self));
        assert_can_deposit<T>(self, ctx);

        let nft_id = object::id(&nft);

        let cap = pop_cap(self);
        kiosk::place(self, &cap, nft);
        register_nft_(self, nft_id);
        set_cap(self, cap);
    }

    /// Deposit batch of NFTs within `Kiosk`
    ///
    /// Deposits can be restricted by the `Kiosk` owner to avoid spam NFTs
    /// being deposited.
    ///
    /// #### Panics
    ///
    /// Panics if permissionless deposits are not enabled for `T` and
    /// transaction sender is not the `Kiosk` owner.
    public fun deposit_batch<T: key + store>(
        self: &mut Kiosk,
        nfts: vector<T>,
        ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(ext(self));
        assert_can_deposit<T>(self, ctx);

        let cap = pop_cap(self);
        while (!vector::is_empty(&nfts)) {
            let nft = vector::pop_back(&mut nfts);
            let nft_id = object::id(&nft);
            kiosk::place(self, &cap, nft);
            register_nft_(self, nft_id);
        };

        vector::destroy_empty(nfts);
        set_cap(self, cap);
    }

    /// Deposit an NFT and lock it within the `Kiosk`
    ///
    /// NFTs deposited using `deposit_locked` must use `transfer_locked_nft` to
    /// transfer the NFT.
    ///
    /// Useful for interacting with non-OB collections.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not owner or `Kiosk` is not
    /// permissionless.
    public fun deposit_locked<T: key + store>(
        self: &mut Kiosk,
        policy: &sui::transfer_policy::TransferPolicy<T>,
        nft: T,
        ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(ext(self));
        assert_can_deposit<T>(self, ctx);

        let nft_id = object::id(&nft);

        let cap = pop_cap(self);
        kiosk::lock(self, &cap, policy, nft);
        register_nft_(self, nft_id);
        set_cap(self, cap);
    }

    // === Withdraw from the Kiosk ===

    /// Authorizes non-exclusively the given entity to take the NFT out of the
    /// `Kiosk`.
    ///
    /// Entity address can be derived from the `UID` of an object or from the
    /// address of a user. The entity must prove with their `&UID` in
    /// `transfer_delegated` or must be the signer in `transfer_signed`.
    ///
    /// #### Panics
    ///
    /// - Transaction sender is not `Kiosk` owner
    /// - NFT does not exist
    /// - NFT is already exclusively locked
    public fun auth_transfer(
        self: &mut Kiosk,
        nft_id: ID,
        entity: address,
        ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(ext(self));
        assert_permission(self, ctx);

        let ref = nft_ref_mut(self, nft_id);
        assert_ref_not_exclusively_listed(ref);

        vec_set::insert(&mut ref.auths, entity);
    }

    /// Authorizes exclusively the given entity to take the NFT out of the
    /// `Kiosk`.
    ///
    /// Entity address can be derived from the `UID` of an object or from the
    /// address of a user. The entity must prove with their `&UID` in
    /// `transfer_delegated` or must be the signer in `transfer_signed`.
    ///
    /// Non-exclusive locks for the NFT are removed from the `Kiosk`.
    ///
    /// #### Panics
    ///
    /// - Transaction sender is not `Kiosk` owner
    /// - NFT does not exist
    /// - NFT is already exclusively locked
    public fun auth_exclusive_transfer(
        self: &mut Kiosk,
        nft_id: ID,
        entity_id: &UID,
        ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(ext(self));
        assert_permission(self, ctx);

        // Check that NFT is not exclusively listed before overwriting all
        // previous authorities to replace with new exclusive authority
        let ref = nft_ref_mut(self, nft_id);
        assert_ref_not_exclusively_listed(ref);

        ref.auths = vec_set::singleton(uid_to_address(entity_id));
        ref.is_exclusively_listed = true;
    }

    public fun delegate_auth(
        self: &mut Kiosk,
        nft_id: ID,
        old_entity: &UID,
        new_entity: address,
    ) {
        assert_version_and_upgrade(ext(self));

        let refs = nft_refs_mut(self);
        let ref = table::borrow_mut(refs, nft_id);

        assert!(
            vec_set::contains(&ref.auths, &uid_to_address(old_entity)),
            ENotAuthorized,
        );

        vec_set::remove(&mut ref.auths, &uid_to_address(old_entity));
        vec_set::insert(&mut ref.auths, new_entity);
    }

    /// Transfer NFTs between kiosks
    ///
    /// This method cannot be called from within a smart contract since
    /// royalties do not have to be paid.
    ///
    /// #### Panics
    ///
    /// - Transaction sender is not owner of `Kiosk`
    /// - NFT does not exist
    /// - Source or target `Kiosk` are not OriginByte kiosks
    entry fun p2p_transfer<T: key + store>(
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(ext(source));
        assert_permission(source, ctx);

        let ref = deregister_nft_(source, nft_id);
        assert_ref_not_exclusively_listed(&ref);

        let cap = pop_cap(source);
        let nft = kiosk::take<T>(source, &cap, nft_id);
        set_cap(source, cap);

        deposit(target, nft, ctx);
    }

    /// Transfer NFTs to address and create new `Kiosk`
    ///
    /// Helper method for the case where receiving address does not already
    /// have a corresponding `Kiosk`.
    ///
    /// This method cannot be called from within a smart contract since
    /// royalties do not have to be paid.
    ///
    /// #### Panics
    ///
    /// - Transaction sender is not owner of `Kiosk`
    /// - NFT does not exist
    /// - Source is not OriginByte `Kiosk`
    entry fun p2p_transfer_and_create_target_kiosk<T: key + store>(
        source: &mut Kiosk,
        target: address,
        nft_id: ID,
        ctx: &mut TxContext,
    ): (ID, ID) {
        // Version is asserted in `p2p_transfer`
        // Permission is asserted in `p2p_transfer`

        let (target_kiosk, target_token) = new_for_address(target, ctx);
        let target_kiosk_id = object::id(&target_kiosk);

        p2p_transfer<T>(source, &mut target_kiosk, nft_id, ctx);
        public_share_object(target_kiosk);

        (target_kiosk_id, target_token)
    }

    /// Transfer NFT out of Kiosk that has been previously delegated
    ///
    /// NFT will not be locked in the target `Kiosk`.
    ///
    /// Requires that address of sender was previously passed to
    /// `auth_transfer`.
    ///
    /// #### Panics
    ///
    /// - Entity `UID` was not previously authorized for transfer
    /// - NFT does not exist
    /// - Target `Kiosk` deposit conditions were not met, see `deposit` method
    /// - Source or target `Kiosk` are not OriginByte kiosks
    public fun transfer_delegated<T: key + store>(
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        entity_id: &UID,
        price: u64,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        assert_version_and_upgrade(ext(source));

        let (nft, req) = transfer_nft_(source, nft_id, uid_to_address(entity_id), price, ctx);
        deposit(target, nft, ctx);
        req
    }

    /// Transfer NFT out of Kiosk that has been previously delegated
    ///
    /// NFT will be locked in the target `Kiosk`.
    ///
    /// Requires that address of sender was previously passed to
    /// `auth_transfer`.
    ///
    /// #### Panics
    ///
    /// - Entity `UID` was not previously authorized for transfer
    /// - NFT does not exist
    /// - Target `Kiosk` deposit conditions were not met, see `deposit` method
    /// - Source or target `Kiosk` are not OriginByte kiosks
    public fun transfer_delegated_locked<T: key + store>(
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        entity_id: &UID,
        price: u64,
        transfer_policy: &sui::transfer_policy::TransferPolicy<T>,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        assert_version_and_upgrade(ext(source));

        let (nft, req) = transfer_nft_(source, nft_id, uid_to_address(entity_id), price, ctx);
        deposit_locked(target, transfer_policy, nft, ctx);
        req
    }

    /// Transfer NFT out of Kiosk that has been previously delegated
    ///
    /// Requires that address of sender was previously passed to
    /// `auth_transfer` or transaction sender is `Kiosk` owner.
    ///
    /// Will always work if transaction sender is the `Kiosk` owner.
    ///
    /// #### Panics
    ///
    /// - Sender was not previously authorized for transfer or is not owner
    /// - NFT does not exist
    /// - Target `Kiosk` deposit conditions were not met, see `deposit` method
    /// - Source or target `Kiosk` are not OriginByte kiosks
    public fun transfer_signed<T: key + store>(
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        price: u64,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        assert_version_and_upgrade(ext(source));
        // Exclusive transfers need to be settled via `transfer_delegated`
        // otherwise it's possible to create dangling locks
        assert_not_exclusively_listed(source, nft_id);

        let (nft, req) = transfer_nft_(source, nft_id, sender(ctx), price, ctx);
        deposit(target, nft, ctx);
        req
    }

    /// Transfer locked NFT out of Kiosk that has been previously delegated to
    /// a base Sui `Kiosk`
    ///
    /// The transferred NFT is immediately locked in the target `Kiosk`.
    ///
    /// Requires that `UID` of sender was previously passed to either
    /// `auth_transfer` or `auth_exclusive_transfer`.
    ///
    /// Will always work if transaction sender is the `Kiosk` owner.
    ///
    /// #### Panics
    ///
    /// - Sender was not previously authorized for transfer or is not owner
    /// - NFT does not exist
    /// - Source is not an OriginByte `Kiosk`
    public fun transfer_locked<T: key + store>(
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        entity_id: &UID,
        paid: Coin<sui::sui::SUI>,
        transfer_policy: &sui::transfer_policy::TransferPolicy<T>,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        assert_version_and_upgrade(ext(source));

        let (nft, req) = transfer_locked_nft_(
            source, nft_id, uid_to_address(entity_id), paid, ctx,
        );
        deposit_locked(target, transfer_policy, nft, ctx);
        req
    }

    /// Transfer locked NFT out of Kiosk that has been previously delegated to
    /// a base Sui `Kiosk`
    ///
    /// The transferred NFT is not locked in the target `Kiosk`.
    ///
    /// Requires that `UID` of sender was previously passed to either
    /// `auth_transfer` or `auth_exclusive_transfer`.
    ///
    /// Will always work if transaction sender is the `Kiosk` owner.
    ///
    /// #### Panics
    ///
    /// - Sender was not previously authorized for transfer or is not owner
    /// - NFT does not exist
    /// - Source is not an OriginByte `Kiosk`
    public fun transfer_unlocked<T: key + store>(
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        entity_id: &UID,
        paid: Coin<sui::sui::SUI>,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        assert_version_and_upgrade(ext(source));

        let (nft, req) = transfer_locked_nft_(
            source, nft_id, uid_to_address(entity_id), paid, ctx,
        );
        deposit(target, nft, ctx);
        req
    }

    /// Deprecated, use `transfer_locked` instead
    public fun transfer_locked_nft<T: key + store>(
        _source: &mut Kiosk,
        _target: &mut Kiosk,
        _nft_id: ID,
        _entity_id: &UID,
        _ctx: &mut TxContext,
    ): TransferRequest<T> {
        abort(EDeprecatedApi)
    }

    /// Withdraw NFT from `Kiosk` without returning it
    ///
    /// Requires that `UID` of sender was previously passed to either
    /// `auth_transfer` or `auth_exclusive_transfer`.
    ///
    /// Requires that collection contracts explicitly define an withdrawal
    /// policy, since if an NFT leaves `Kiosk` ecosystem, we can no longer
    /// guarantee royalty enforcement.
    ///
    /// Useful for use-cases where an NFT is not expected to be returned to a
    /// `Kiosk` such as when it is composed into another.
    ///
    /// #### Panics
    ///
    /// - Sender was not previously authorized for transfer or is not owner
    /// - NFT does not exist
    /// - Source is not an OriginByte `Kiosk`
    public fun withdraw_nft<T: key + store>(
        self: &mut Kiosk,
        nft_id: ID,
        entity_id: &UID,
        ctx: &mut TxContext,
    ): (T, WithdrawRequest<T>) {
        assert_version_and_upgrade(ext(self));

        withdraw_nft_(self, nft_id, uid_to_address(entity_id), ctx)
    }

    /// Withdraw NFT from `Kiosk` without returning it
    ///
    /// Requires that address of sender was previously passed to
    /// `auth_transfer` or transaction sender is `Kiosk` owner.
    ///
    /// Requires that collection contracts explicitly define an withdrawal
    /// policy, since if an NFT leaves `Kiosk` ecosystem, we can no longer
    /// guarantee royalty enforcement.
    ///
    /// Useful for use-cases where an NFT is not expected to be returned to a
    /// `Kiosk` such as when it is composed into another.
    ///
    /// #### Panics
    ///
    /// - Sender was not previously authorized for transfer or is not owner
    /// - NFT does not exist
    /// - Source is not an OriginByte `Kiosk`
    public fun withdraw_nft_signed<T: key + store>(
        self: &mut Kiosk,
        nft_id: ID,
        ctx: &mut TxContext,
    ): (T, WithdrawRequest<T>) {
        assert_version_and_upgrade(ext(self));
        // Delegated withdraws need to be settled via `withdraw_nft`
        // otherwise it's possible to create dangling locks
        assert_not_exclusively_listed(self, nft_id);

        withdraw_nft_(self, nft_id, sender(ctx), ctx)
    }

    /// Transfer between two Kiosks owned by the same address
    ///
    /// #### Panics
    ///
    /// - Transaction sender is not owner of source `Kiosk`
    /// - Source `Kiosk` is permissionlesss, this is enforced to prevent
    /// royalty-free trading by wrapping over `Kiosk`
    /// - Source and target `Kiosk` don't have the same owner
    /// - NFT does not exist or is exclusively locked
    public fun transfer_between_owned<T: key + store>(
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_permission(source, ctx);
        transfer_between_owned_<T>(source, target, nft_id, ctx)
    }

    /// Transfer between two Kiosks owned by the same address using witness
    ///
    /// Endpoint is permissionless to always allow third-party contracts to
    /// organise their types within user Kiosks.
    ///
    /// #### Panics
    ///
    /// - Source `Kiosk` is permissionlesss, this is enforced to prevent
    /// royalty-free trading by wrapping over `Kiosk`
    /// - Source and target `Kiosk` don't have the same owner
    /// - NFT does not exist or is exclusively locked
    public fun transfer_between_owned_with_witness<T: key + store>(
        _witness: DelegatedWitness<T>,
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        transfer_between_owned_<T>(source, target, nft_id, ctx)
    }

    /// Transfer NFT between two owned Kiosks
    ///
    /// ### Panics
    ///
    /// - Source `Kiosk` is permissionlesss, this is enforced to prevent
    /// royalty-free trading by wrapping over `Kiosk`
    /// - Source and target `Kiosk` don't have the same owner
    /// - NFT does not exist or is exclusively locked
    fun transfer_between_owned_<T: key + store>(
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(ext(source));

        // Prevent royalty-free trading
        assert!(kiosk::owner(source) != PermissionlessAddr, ENotAuthorized);
        assert!(kiosk::owner(source) == kiosk::owner(target), ENotOwner);

        let ref = deregister_nft_(source, nft_id);
        assert_ref_not_exclusively_listed(&ref);

        let cap = pop_cap(source);
        let nft = kiosk::take<T>(source, &cap, nft_id);
        set_cap(source, cap);

        deposit(target, nft, ctx);
    }

    // === Kiosk Interoperability ===

    /// Install OriginByte extension onto base `Kiosk`
    ///
    /// #### Panics
    ///
    /// Panics if `Kiosk` is already an OriginByte `Kiosk` or if
    /// `KioskOwnerCap` does not match `Kiosk`.
    public entry fun install_extension(
        self: &mut Kiosk,
        kiosk_cap: KioskOwnerCap,
        ctx: &mut TxContext,
    ) {
        install_extension_(self, kiosk_cap, ctx);

        transfer(
            OwnerToken {
                id: object::new(ctx),
                kiosk: object::id(self),
                owner: sender(ctx),
            },
            sender(ctx),
        );
    }

    /// Uninstall OriginByte extension from base `Kiosk`
    ///
    /// #### Panics
    ///
    /// - `Kiosk` is not an OriginByte `Kiosk`
    /// - If there are any NFTs still present which are tracked by the
    /// OriginByte extension
    /// - `OwnerToken` does not match `Kiosk`
    public entry fun uninstall_extension(
        self: &mut Kiosk,
        owner_token: OwnerToken,
        ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(ext(self));

        assert!(owner_token.kiosk == object::id(self), EIncorrectOwnerToken);

        // Proof of ownership
        assert_owner_address(self, sender(ctx));

        // Additionally asserts that `Kiosk` is an OB `Kiosk`
        let refs = nft_refs(self);
        assert!(table::is_empty<ID, NftRef>(refs), ECannotUninstallWithCurrentBookeeping);

        let kiosk_ext = ext(self);
        let owner_cap: KioskOwnerCap = df::remove(kiosk_ext, KioskOwnerCapDfKey {});

        let refs: Table<ID, NftRef> = df::remove(kiosk_ext, NftRefsDfKey {});
        table::destroy_empty(refs);

        df::remove<VersionDfKey, u64>(kiosk_ext, VersionDfKey {});
        df::remove<DepositSettingDfKey, DepositSetting>(kiosk_ext, DepositSettingDfKey {});

        let OwnerToken { id, kiosk: _, owner: _} = owner_token;
        object::delete(id);

        public_transfer(owner_cap, sender(ctx));
    }

    /// Installs extension fields into `Kiosk`
    ///
    /// #### Panics
    ///
    /// Panics if `Kiosk` is already an OriginByte `Kiosk` or if
    /// `KioskOwnerCap` does not match `Kiosk`.
    fun install_extension_(
        self: &mut Kiosk,
        kiosk_cap: KioskOwnerCap,
        ctx: &mut TxContext,
    ) {
        assert!(kiosk::has_access(self, &kiosk_cap), ENotOwner);
        assert!(!is_ob_kiosk(self), EKioskOriginByteVersion);

        // Ensure that `uid_mut` will work
        kiosk::set_allow_extensions(self, &kiosk_cap, true);
        let kiosk_ext = ext(self);

        df::add(kiosk_ext, VersionDfKey {}, VERSION);
        df::add(kiosk_ext, KioskOwnerCapDfKey {}, kiosk_cap);
        df::add(kiosk_ext, NftRefsDfKey {}, table::new<ID, NftRef>(ctx));
        df::add(kiosk_ext, DepositSettingDfKey {}, DepositSetting {
            enable_any_deposit: true,
            collections_with_enabled_deposits: vec_set::empty(),
        });
    }

    /// Registers NFT with OriginByte extension
    ///
    /// If an NFT was present in `Kiosk` before OriginByte extension was
    /// installed it will not be tracked by the extension and needs to be
    /// manually setup.
    ///
    /// #### Panics
    ///
    /// - Transaction sender is not `Kiosk` owner
    /// - NFT does not exist in the base `Kiosk`
    /// - NFT is listed for sale in the base `Kiosk`
    public entry fun register_nft<T: key>(
        self: &mut Kiosk,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(ext(self));
        assert_permission(self, ctx);

        register_nft_(self, nft_id);
    }

    /// Create an `NftRef` entry for the NFT
    ///
    /// #### Panics
    ///
    /// Panics if `NftRef` already exists
    fun register_nft_(
        self: &mut Kiosk,
        nft_id: ID,
    ) {
        assert_has_nft(self, nft_id);
        assert!(!kiosk::is_listed(self, nft_id), ENftIsListedInBaseKiosk);

        let refs = nft_refs_mut(self);
        assert_missing_ref(refs, nft_id);

        table::add(refs, nft_id, NftRef {
            auths: vec_set::empty(),
            is_exclusively_listed: false,
        });
    }

    /// Pop `NftRef` entry for the NFT
    ///
    /// #### Panics
    ///
    /// Panics if `NftRef` does not exist
    fun deregister_nft_(
        self: &mut Kiosk,
        nft_id: ID,
    ): NftRef {
        let refs = nft_refs_mut(self);
        assert!(table::contains(refs, nft_id), EMissingNft);
        table::remove(refs, nft_id)
    }

    // === Private Functions ===

    /// Initializes a transfer transaction
    ///
    /// #### Panics
    ///
    /// - Originator is not authorized to withdraw and transaction sender is
    /// not owner.
    /// - NFT does not exist
    /// - NFT is locked
    fun transfer_nft_<T: key + store>(
        self: &mut Kiosk,
        nft_id: ID,
        originator: address,
        price: u64,
        ctx: &mut TxContext,
    ): (T, TransferRequest<T>) {
        let nft = remove_nft(self, nft_id, originator, ctx);
        (nft, transfer_request::new(nft_id, originator, object::id(self), price, ctx))
    }

    /// Initializes a transfer transaction for locked NFT
    ///
    /// #### Panics
    ///
    /// - Originator is not authorized to withdraw and transaction sender is
    /// not owner.
    /// - NFT does not exist
    /// - NFT is not locked
    fun transfer_locked_nft_<T: key + store>(
        self: &mut Kiosk,
        nft_id: ID,
        originator: address,
        paid: Coin<sui::sui::SUI>,
        ctx: &mut TxContext,
    ): (T, TransferRequest<T>) {
        // TODO: Merge with `transfer_nft_`
        let (nft, req) = remove_locked_nft(self, nft_id, originator, paid, ctx);
        (nft, transfer_request::from_sui<T>(req, nft_id, originator, ctx))
    }

    /// Initializes a withdrawal transaction
    ///
    /// #### Panics
    ///
    /// - Originator is not authorized to withdraw and transaction sender is
    /// not owner.
    /// - NFT does not exist
    /// - NFT is locked
    fun withdraw_nft_<T: key + store>(
        self: &mut Kiosk,
        nft_id: ID,
        originator: address,
        ctx: &mut TxContext,
    ): (T, WithdrawRequest<T>) {
        let nft = remove_nft(self, nft_id, originator, ctx);
        (nft, withdraw_request::new(originator, ctx))
    }

    /// Checks that originator is authorized to withdraw NFT and returns the
    /// NFT
    ///
    /// #### Panics
    ///
    /// - Originator is not authorized to withdraw and transaction sender is
    /// not owner.
    /// - NFT does not exist
    /// - NFT is locked
    fun remove_nft<T: key + store>(
        self: &mut Kiosk,
        nft_id: ID,
        originator: address,
        ctx: &mut TxContext,
    ): T {
        assert_can_transfer(self, nft_id, originator, ctx);
        deregister_nft_(self, nft_id);

        let cap = pop_cap(self);
        let nft = kiosk::take<T>(self, &cap, nft_id);
        set_cap(self, cap);

        nft
    }

    /// Checks that originator is authorized to withdraw NFT and returns the
    /// NFT
    ///
    /// #### Panics
    ///
    /// - Originator is not authorized to withdraw and transaction sender is
    /// not owner.
    /// - NFT does not exist
    /// - NFT is not locked
    fun remove_locked_nft<T: key + store>(
        self: &mut Kiosk,
        nft_id: ID,
        originator: address,
        paid: Coin<sui::sui::SUI>,
        ctx: &mut TxContext
    ): (T, sui::transfer_policy::TransferRequest<T>) {
        assert_can_transfer(self, nft_id, originator, ctx);
        deregister_nft_(self, nft_id);

        let cap = pop_cap(self);
        kiosk::list<T>(self, &cap, nft_id, coin::value(&paid));
        set_cap(self, cap);

        kiosk::purchase<T>(self, nft_id, paid)
    }

    // === Request Auth ===

    /// Proves access to given type `Auth`.
    /// Useful in conjunction with witness-like types.
    /// Trading contracts proves themselves with `Auth` instead of UID.
    /// This makes it easier to implement allowlists since we can globally
    /// allow a contract to trade.
    /// Allowlist could also be implemented with a UID but that would require
    /// that the trading contracts maintain a global object.
    /// In some cases this is doable, in other it's inconvenient.
    public fun set_transfer_request_auth<T, Auth>(
        req: &mut TransferRequest<T>, _auth: &Auth,
    ) {
        let metadata = transfer_request::metadata_mut(req);
        df::add(metadata, AuthTransferRequestDfKey {}, type_name::get<Auth>());
    }

    public fun set_transfer_request_auth_<T, P, Auth>(
        req: &mut RequestBody<WithNft<T, P>>, _auth: &Auth,
    ) {
        let metadata = request::metadata_mut(req);
        df::add(metadata, AuthTransferRequestDfKey {}, type_name::get<Auth>());
    }

    /// What's the authority that created this request?
    public fun get_transfer_request_auth<T>(req: &TransferRequest<T>): &TypeName {
        let metadata = transfer_request::metadata(req);
        df::borrow(metadata, AuthTransferRequestDfKey {})
    }

    /// What's the authority that created this request?
    public fun get_transfer_request_auth_<T, P>(
        req: &RequestBody<WithNft<T, P>>,
    ): &TypeName {
        let metadata = request::metadata(req);
        df::borrow(metadata, AuthTransferRequestDfKey {})
    }

    // === De-listing of NFTs ===


    /// Removes all non-exclusive locks for the NFT in a `Kiosk`
    ///
    /// #### Panics
    ///
    /// - Transaction sender is not `Kiosk` owner
    /// - NFT does not exist
    /// - NFT is exclusively listed
    public fun delist_nft_as_owner(
        self: &mut Kiosk, nft_id: ID, ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(ext(self));
        assert_permission(self, ctx);

        let ref = nft_ref_mut(self, nft_id);
        assert_ref_not_exclusively_listed(ref);
        ref.auths = vec_set::empty();
    }

    /// Removes specific non-exclusive lock for the NFT in a `Kiosk`
    ///
    /// #### Panics
    ///
    /// - Transaction sender is not `Kiosk` owner
    /// - NFT does not exist
    /// - NFT is exclusively listed
    /// - Provided address is not a non-exclusive authority
    public fun remove_auth_transfer_as_owner(
        self: &mut Kiosk,
        nft_id: ID,
        entity: address,
        ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(ext(self));
        assert_permission(self, ctx);

        let ref = nft_ref_mut(self, nft_id);
        assert_ref_not_exclusively_listed(ref);
        vec_set::remove(&mut ref.auths, &entity);
    }

    /// Removes non-exclusive or exclusive lock placed by an object entity
    ///
    /// #### Panics
    ///
    /// - Entity `UID` is not a transfer authority for the given NFT
    /// - NFT does not exist
    public fun remove_auth_transfer(
        self: &mut Kiosk,
        nft_id: ID,
        entity: &UID,
    ) {
        assert_version_and_upgrade(ext(self));

        let entity = uid_to_address(entity);

        let ref = nft_ref_mut(self, nft_id);
        vec_set::remove(&mut ref.auths, &entity);
        ref.is_exclusively_listed = false; // no-op if it wasn't
    }

    /// Removes non-exclusive lock placed by an object entity
    ///
    /// #### Panics
    ///
    /// - Transaction sender is not a transfer authority for the given NFT
    /// - NFT does not exist
    /// - NFT was listed exclusively
    public fun remove_auth_transfer_signed(
        self: &mut Kiosk,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(ext(self));
        let entity = tx_context::sender(ctx);

        let ref = nft_ref_mut(self, nft_id);
        assert_ref_not_exclusively_listed(ref);
        vec_set::remove(&mut ref.auths, &entity);
    }

    // === Configure deposit settings ===

    /// Only owner or allowlisted collections can deposit.
    public entry fun restrict_deposits(
        self: &mut Kiosk, ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(ext(self));
        assert_permission(self, ctx);

        let settings = deposit_setting_mut(self);
        settings.enable_any_deposit = false;
    }

    /// No restriction on deposits.
    public entry fun enable_any_deposit(
        self: &mut Kiosk, ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(ext(self));
        assert_permission(self, ctx);

        let settings = deposit_setting_mut(self);
        settings.enable_any_deposit = true;
    }

    /// The owner can restrict deposits into the `Kiosk` from given
    /// collection.
    ///
    /// However, if the flag `DepositSetting::enable_any_deposit` is set to
    /// true, then it takes precedence.
    public entry fun disable_deposits_of_collection<C>(
        self: &mut Kiosk, ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(ext(self));
        assert_permission(self, ctx);

        let settings = deposit_setting_mut(self);
        let col_type = type_name::get<C>();
        vec_set::remove(&mut settings.collections_with_enabled_deposits, &col_type);
    }

    /// The owner can enable deposits into the `Kiosk` from given
    /// collection.
    ///
    /// However, if the flag `Kiosk::enable_any_deposit` is set to
    /// true, then it takes precedence anyway.
    public entry fun enable_deposits_of_collection<C>(
        self: &mut Kiosk, ctx: &mut TxContext,
    ) {
        assert_permission(self, ctx);
        assert_version_and_upgrade(ext(self));

        let settings = deposit_setting_mut(self);
        let col_type = type_name::get<C>();
        vec_set::insert(&mut settings.collections_with_enabled_deposits, col_type);
    }

    // === NFT Accessors ===

    public fun borrow_nft<T: key + store>(
        self: &Kiosk,
        nft_id: ID,
    ): &T {
        assert_version(uid(self));
        let cap = borrow_cap(self);
        kiosk::borrow<T>(self, cap, nft_id)
    }

    public fun borrow_nft_mut<T: key + store>(
        self: &mut Kiosk,
        nft_id: ID,
        field: Option<TypeName>,
        ctx: &mut TxContext,
    ): BorrowRequest<Witness, T> {
        assert_version_and_upgrade(ext(self));

        let cap = pop_cap(self);
        let (nft, promise) = kiosk::borrow_val(self, &cap, nft_id);
        set_cap(self, cap);

        borrow_request::new(Witness {}, nft, sender(ctx), field, promise, ctx)
    }

    public fun return_nft<OTW: drop, T: key + store>(
        self: &mut Kiosk,
        borrowed_nft: BorrowRequest<Witness, T>,
        policy: &Policy<WithNft<T, BORROW_REQ>>
    ) {
        assert_version_and_upgrade(ext(self));

        let (nft, promise) = borrow_request::confirm(Witness {}, borrowed_nft, policy);

        let cap = pop_cap(self);
        kiosk::return_val(self, nft, promise);
        set_cap(self, cap);
    }

    // === Getters ===

    /// Returns whether `Kiosk` is permissionless or address is the owner
    public fun is_owner(self: &Kiosk, address: address): bool {
        let owner = kiosk::owner(self);
        owner == PermissionlessAddr || owner == address
    }

    /// Returns whether `Kiosk` is permissionless
    public fun is_permissionless(self: &Kiosk): bool {
        kiosk::owner(self) == PermissionlessAddr
    }

    /// Returns whether `Kiosk` is OriginByte `Kiosk`
    //
    // TODO: Deprecate mutable API
    public fun is_ob_kiosk(self: &mut Kiosk): bool {
        df::exists_(uid(self), NftRefsDfKey {})
    }

    fun is_ob_kiosk_imut(self: &Kiosk): bool {
        df::exists_(uid(self), NftRefsDfKey {})
    }

    /// Returns whether the current transaction sender can deposit into `Kiosk`
    ///
    /// Either sender is owner or permissionless deposits of `T` enabled.
    public fun can_deposit<T>(self: &mut Kiosk, ctx: &mut TxContext): bool {
        sender(ctx) == kiosk::owner(self) || can_deposit_permissionlessly<T>(self)
    }

    /// Returns whether `DepositSettings` allow for permissionless deposits.
    ///
    /// Either `Kiosk` is permissionless, any deposits are allowed, or `T` was
    /// explicitly whitelisted.
    ///
    /// If `Kiosk` is not an OriginByte `Kiosk` then we assume that
    /// permissionless deposits are allowed and trust that the base `Kiosk`
    /// manages this itself.
    public fun can_deposit_permissionlessly<T>(self: &mut Kiosk): bool {
        if (!is_ob_kiosk(self) || is_permissionless(self)) {
            return true
        };

        let settings = deposit_setting(self);
        settings.enable_any_deposit ||
            vec_set::contains(
                &settings.collections_with_enabled_deposits,
                &type_name::get<T>(),
            )
    }

    /// Borrow `NftRef` accounting structure
    ///
    /// #### Panics
    ///
    /// Panics if `Kiosk` is not OriginByte `Kiosk`
    //
    // TODO: Replace with immutable API
    public fun nft_refs(self: &Kiosk): &Table<ID, NftRef> {
        is_ob_kiosk_imut(self);
        df::borrow(uid(self), NftRefsDfKey {})
    }

    /// Borrow `NftRef` for NFT with given ID
    ///
    /// #### Panics
    ///
    /// Panics if `Kiosk` is not OriginByte `Kiosk` or if NFT does not exist.
    //
    // TODO: Consider making it public
    fun nft_ref(self: &Kiosk, nft_id: ID): &NftRef {
        let refs = nft_refs(self);

        assert!(table::contains(refs, nft_id), EMissingNft);
        table::borrow(refs, nft_id)
    }

    // === Assertions ===

    /// Asserts that `Kiosk` is permissionless
    ///
    /// #### Panics
    ///
    /// Panics if `Kiosk` is not permissionless
    public fun assert_is_permissionless(self: &Kiosk) {
        assert!(is_permissionless(self), EKioskNotPermissionless);
    }

    /// Asserts that the transaction sender may deposit into `Kiosk`
    ///
    /// #### Panics
    ///
    /// Panics if sender is not owner or `Kiosk` is not permissionless.
    public fun assert_can_deposit<T>(self: &mut Kiosk, ctx: &mut TxContext) {
        assert!(can_deposit<T>(self, ctx), ECannotDeposit);
    }

    public fun assert_can_deposit_permissionlessly<T>(self: &mut Kiosk) {
        assert!(can_deposit_permissionlessly<T>(self), EPermissionlessDepositsDisabled);
    }

    /// Asserts that current transaction sender may transfer an NFT out of `Kiosk`
    fun assert_can_transfer(
        self: &Kiosk,
        nft_id: ID,
        entity: address,
        ctx: &mut TxContext
    ) {
        let ref = nft_ref(self, nft_id);
        assert!(
            is_owner(self, tx_context::sender(ctx)) || vec_set::contains(&ref.auths, &entity),
            ENotAuthorized,
        );
    }

    /// Asserts that owner is provided address
    ///
    /// #### Panics
    ///
    /// Panics if address is not `Kiosk` owner
    public fun assert_owner_address(self: &Kiosk, owner: address) {
        assert!(kiosk::owner(self) == owner, ENotOwner);
    }

    /// Asserts that `Kiosk` is permissionless or transaction sender is owner
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not owner nor `Kiosk` is permissionless
    public fun assert_permission(self: &Kiosk, ctx: &mut TxContext) {
        assert!(is_owner(self, sender(ctx)), ENotOwner);
    }

    public fun assert_has_nft(self: &Kiosk, nft_id: ID) {
        assert!(kiosk::has_item(self, nft_id), EMissingNft)
    }

    public fun assert_nft_type<T: key + store>(self: &Kiosk, nft_id: ID) {
        assert!(kiosk::has_item_with_type<T>(self, nft_id), ENftTypeMismatch);
    }

    public fun assert_missing_ref(refs: &Table<ID, NftRef>, nft_id: ID) {
        assert!(!table::contains(refs, nft_id), EMissingNft)
    }

    public fun assert_not_exclusively_listed(
        self: &mut Kiosk, nft_id: ID
    ) {
        assert_ref_not_exclusively_listed(nft_ref(self, nft_id));
    }

    public fun assert_not_listed(self: &mut Kiosk, nft_id: ID) {
        assert_ref_not_listed(nft_ref(self, nft_id));
    }

    /// Asserts that `Kiosk` is OriginByte `Kiosk`
    ///
    /// #### Panics
    ///
    /// Panics if `Kiosk` is not OriginByte Kiosk
    //
    // TODO: Deprecate mutable API
    public fun assert_is_ob_kiosk(self: &mut Kiosk) {
        assert!(is_ob_kiosk(self), EKioskNotOriginByteVersion);
    }

    fun assert_is_ob_kiosk_imut(self: &Kiosk) {
        assert!(is_ob_kiosk_imut(self), EKioskNotOriginByteVersion);
    }

    public fun assert_kiosk_id(self: &Kiosk, id: ID) {
        assert!(object::id(self) == id, EIncorrectKioskId);
    }

    fun assert_ref_not_exclusively_listed(ref: &NftRef) {
        assert!(!ref.is_exclusively_listed, ENftAlreadyExclusivelyListed);
    }

    fun assert_ref_not_listed(ref: &NftRef) {
        assert!(vec_set::size(&ref.auths) == 0, ENftAlreadyListed);
    }

    /// Borrow `DepositSetting` field
    ///
    /// #### Panics
    ///
    /// Panics if `Kiosk` is not OriginByte `Kiosk`
    //
    // TODO: Replace with immutable API
    fun deposit_setting(self: &mut Kiosk): &DepositSetting {
        assert_is_ob_kiosk(self);
        df::borrow(uid(self), DepositSettingDfKey {})
    }

    /// Mutably borrow `DepositSetting` field
    ///
    /// #### Panics
    ///
    /// Panics if `Kiosk` is not OriginByte `Kiosk`
    fun deposit_setting_mut(self: &mut Kiosk): &mut DepositSetting {
        assert_is_ob_kiosk(self);
        df::borrow_mut(ext(self), DepositSettingDfKey {})
    }

    /// Mutably borrow `NftRef` accounting structure
    ///
    /// #### Panics
    ///
    /// Panics if `Kiosk` is not OriginByte `Kiosk`
    fun nft_refs_mut(self: &mut Kiosk): &mut Table<ID, NftRef> {
        assert_is_ob_kiosk(self);
        df::borrow_mut(ext(self), NftRefsDfKey {})
    }

    /// Borrow `NftRef` for NFT with given ID
    ///
    /// #### Panics
    ///
    /// Panics if `Kiosk` is not OriginByte `Kiosk` or if NFT does not exist.
    fun nft_ref_mut(self: &mut Kiosk, nft_id: ID): &mut NftRef {
        let refs = nft_refs_mut(self);

        assert!(table::contains(refs, nft_id), EMissingNft);
        table::borrow_mut(refs, nft_id)
    }

    /// Borrow `KioskOwnerCap` immutably
    fun borrow_cap(self: &Kiosk): &KioskOwnerCap {
        df::borrow(uid(self), KioskOwnerCapDfKey {})
    }

    /// Pop `KioskOwnerCap` from within the `Kiosk`
    fun pop_cap(self: &mut Kiosk): KioskOwnerCap {
        df::remove(ext(self), KioskOwnerCapDfKey {})
    }

    /// Return `KioskOwnerCap` to the `Kiosk`
    fun set_cap(self: &mut Kiosk, cap: KioskOwnerCap) {
        df::add(ext(self), KioskOwnerCapDfKey {}, cap);
    }

    // === Display standard ===

    struct OB_KIOSK has drop {}

    fun init(otw: OB_KIOSK, ctx: &mut TxContext) {
        let publisher = package::claim(otw, ctx);
        let display = display::new<OwnerToken>(&publisher, ctx);

        display::add(&mut display, utf8(b"name"), utf8(b"Originbyte Kiosk"));
        display::add(&mut display, utf8(b"link"), utf8(b"https://docs.originbyte.io"));
        display::add(&mut display, utf8(b"owner"), utf8(b"{owner}"));
        display::add(&mut display, utf8(b"kiosk"), utf8(b"{kiosk}"));
        display::add(
            &mut display,
            utf8(b"description"),
            utf8(b"Stores NFTs, manages listings, sales and more!"),
        );

        display::update_version(&mut display);
        public_transfer(display, tx_context::sender(ctx));
        package::burn_publisher(publisher);
    }

    // === Upgradeability ===

    fun assert_version(kiosk_uid: &UID) {
        let version = df::borrow<VersionDfKey, u64>(kiosk_uid, VersionDfKey {});
        assert!(*version == VERSION, EWrongVersion);
    }

    // TODO: Add test
    fun assert_version_and_upgrade(kiosk_uid: &mut UID) {
        let version = df::borrow_mut<VersionDfKey, u64>(kiosk_uid, VersionDfKey {});

        if (*version < VERSION) {
            *version = VERSION;
        };
        assert_version(kiosk_uid);
    }

    // Migrate as owner
    entry fun migrate(self: &mut Kiosk, ctx: &mut TxContext) {
        assert_permission(self, ctx);
        let kiosk_ext = ext(self);

        let version = df::borrow_mut<VersionDfKey, u64>(kiosk_ext, VersionDfKey {});

        assert!(*version < VERSION, ENotUpgraded);
        *version = VERSION;
    }

    entry fun migrate_as_pub(self: &mut Kiosk, pub: &Publisher) {
        assert!(package::from_package<KIOSK>(pub), 0);

        let kiosk_ext = ext(self);
        let version = df::borrow_mut<VersionDfKey, u64>(kiosk_ext, VersionDfKey {});

        assert!(*version < VERSION, ENotUpgraded);
        *version = VERSION;
    }

    // === Test-only accessors ===

    #[test_only]
    public fun assert_kiosk_owner_cap(self: &mut Kiosk) {
        let owner_cap = df::remove(ext(self), KioskOwnerCapDfKey {});

        assert!(kiosk::has_access(self, &owner_cap), 0);

        df::add(ext(self), KioskOwnerCapDfKey {}, owner_cap);
    }

    #[test_only]
    public fun assert_deposit_setting_permissionless(self: &mut Kiosk) {
        let settings = df::borrow<DepositSettingDfKey, DepositSetting>(
            ext(self), DepositSettingDfKey {}
        );

        assert!(settings.enable_any_deposit == true, 0);
    }

    #[test_only]
    public fun assert_listed(self: &mut Kiosk, nft_id: ID) {
        let ref = nft_ref(self, nft_id);
        assert!(vec_set::size(&ref.auths) > 0, 0);
    }

    #[test_only]
    public fun assert_exclusively_listed(
        self: &mut Kiosk,
        nft_id: ID
    ) {
        let ref = nft_ref(self, nft_id);
        assert!(ref.is_exclusively_listed, 0);
    }

    // Helper for testing entry function
    #[test_only]
    public fun p2p_transfer_test<T: key + store>(
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        p2p_transfer<T>(source, target, nft_id, ctx);
    }

    // Helper for testing entry function
    #[test_only]
    public fun p2p_transfer_and_create_target_kiosk_test<T: key + store>(
        source: &mut Kiosk,
        target: address,
        nft_id: ID,
        ctx: &mut TxContext,
    ): (ID, ID) {
        p2p_transfer_and_create_target_kiosk<T>(source, target, nft_id, ctx)
    }

    #[test_only]
    use sui::test_scenario::{Self, ctx};

    #[test]
    public fun assert_version_test() {
        let scenario = test_scenario::begin(@0x2);
        let kiosk = new_permissionless(ctx(&mut scenario));
        assert_version(ext(&mut kiosk));
        public_share_object(kiosk);
        test_scenario::end(scenario);
    }
}
