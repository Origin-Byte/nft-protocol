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
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap, uid_mut as ext};
    use sui::object::{Self, ID, UID, uid_to_address};
    use sui::coin;
    use sui::table::{Self, Table};
    use sui::transfer::{transfer, public_share_object, public_transfer};
    use sui::tx_context::{Self, TxContext, sender};
    use sui::vec_set::{Self, VecSet};

    use ob_request::transfer_request::{Self, TransferRequest};
    use ob_request::withdraw_request::{Self, WithdrawRequest};
    use ob_request::borrow_request::{Self, BorrowRequest, BORROW_REQ};
    use ob_request::request::{Self, Policy, RequestBody, WithNft};
    use ob_kiosk::kiosk::KIOSK;

    // Track the current version of the module
    const VERSION: u64 = 1;

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

    /// Creates a new Kiosk in the OB ecosystem.
    /// By default, all deposits are allowed permissionlessly.
    ///
    /// The scope of deposits can be controlled with
    /// - `restrict_deposits` to allow only owner to deposit;
    /// - `enable_any_deposit` to again set deposits to be permissionless;
    /// - `disable_deposits_of_collection` to prevent specific collection to
    ///     deposit (ignored if all deposits enabled)
    /// - `enable_deposits_of_collection` to again specific collection to deposit
    ///     (useful in conjunction with restricting all deposits)
    ///
    /// Note that those collections which have restricted deposits will NOT be
    /// allowed to be transferred to the kiosk even on trades.
    public fun new(ctx: &mut TxContext): (Kiosk, ID) {
        new_for_address(tx_context::sender(ctx), ctx)
    }

    /// Calls `new` and shares the kiosk
    public fun create_for_sender(ctx: &mut TxContext): (ID, ID) {
        let (kiosk, token_id) = new(ctx);
        let kiosk_id = object::id(&kiosk);

        public_share_object(kiosk);
        (kiosk_id, token_id)
    }

    public entry fun init_for_sender(ctx: &mut TxContext) {
        create_for_sender(ctx);
    }

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

    public fun create_for_address(owner: address, ctx: &mut TxContext): (ID, ID) {
        let (kiosk, token_id) = new_for_address(owner, ctx);
        let kiosk_id = object::id(&kiosk);

        public_share_object(kiosk);
        (kiosk_id, token_id)
    }

    public entry fun init_for_address(owner: address, ctx: &mut TxContext) {
        create_for_address(owner, ctx);
    }

    /// All functions which would normally verify that the owner is the signer
    /// are callable.
    /// This means that the kiosk MUST be wrapped.
    /// Otherwise, anyone could call those functions.
    public fun new_permissionless(ctx: &mut TxContext): Kiosk {
        new_(PermissionlessAddr, ctx)
    }

    public fun create_permissionless(ctx: &mut TxContext): ID {
        let kiosk = new_permissionless(ctx);
        let kiosk_id = object::id(&kiosk);

        public_share_object(kiosk);
        kiosk_id
    }

    public entry fun init_permissionless(ctx: &mut TxContext) {
        create_permissionless(ctx);
    }

    /// Changes the owner of a kiosk to the given address.
    /// This is only possible if the kiosk is currently permissionless.
    /// Ie. the old owner is `PermissionlessAddr`.
    ///
    /// Note that we don't support changing ownership of a kiosk that's not
    /// permissionless.
    /// The address that is set as the owner of the kiosk is the address that
    /// will remain the owner forever.
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

    /// Always works if the sender is the owner.
    /// Fails if permissionless deposits are not enabled for `T`.
    /// See `DepositSetting`.
    public entry fun deposit<T: key + store>(
        self: &mut Kiosk, nft: T, ctx: &mut TxContext,
    ) {
        assert_version(ext(self));
        assert_can_deposit<T>(self, ctx);

        // inner accounting
        let nft_id = object::id(&nft);
        let refs = nft_refs_mut(self);
        table::add(refs, nft_id, NftRef {
            auths: vec_set::empty(),
            is_exclusively_listed: false,
        });

        // place underlying NFT to kiosk
        let cap = pop_cap(self);
        kiosk::place(self, &cap, nft);
        set_cap(self, cap);
    }

    public fun deposit_batch<T: key + store>(
        self: &mut Kiosk, nfts: vector<T>, ctx: &mut TxContext,
    ) {
        assert_version(ext(self));
        assert_can_deposit<T>(self, ctx);

        let cap = pop_cap(self);
        let len = vector::length(&nfts);

        while (len > 0) {
            let nft = vector::pop_back(&mut nfts);

            // inner accounting
            let nft_id = object::id(&nft);
            let refs = nft_refs_mut(self);
            table::add(refs, nft_id, NftRef {
                auths: vec_set::empty(),
                is_exclusively_listed: false,
            });

            // place underlying NFT to kiosk
            kiosk::place(self, &cap, nft);

            len = len - 1;
        };

        vector::destroy_empty(nfts);
        set_cap(self, cap);
    }

    // === Withdraw from the Kiosk ===

    /// Authorizes given entity to take given NFT out.
    /// The entity must prove with their `&UID` in `transfer_delegated` or
    /// must be the signer in `transfer_signed`.
    ///
    /// Use the `object::id_to_address` to authorize entities which only live
    /// on chain.
    public fun auth_transfer(
        self: &mut Kiosk,
        nft_id: ID,
        entity: address,
        ctx: &mut TxContext,
    ) {
        assert_version(ext(self));
        assert_permission(self, ctx);

        let refs = nft_refs_mut(self);
        let ref = table::borrow_mut(refs, nft_id);
        assert_ref_not_exclusively_listed(ref);
        vec_set::insert(&mut ref.auths, entity);
    }

    /// Authorizes ONLY given entity to take given NFT out.
    /// No one else (including the owner) can perform a transfer.
    ///
    /// The entity must prove with their `&UID` in `transfer_delegated`.
    ///
    /// Only the given entity can then delist their listing.
    /// This is a dangerous action to be used only with audited contracts
    /// because the NFT is locked until given entity agrees to release it.
    public fun auth_exclusive_transfer(
        self: &mut Kiosk,
        nft_id: ID,
        entity_id: &UID,
        ctx: &mut TxContext,
    ) {
        assert_version(ext(self));
        assert_permission(self, ctx);

        let refs = nft_refs_mut(self);
        let ref = table::borrow_mut(refs, nft_id);
        assert_ref_not_listed(ref);
        vec_set::insert(&mut ref.auths, uid_to_address(entity_id));
        ref.is_exclusively_listed = true;
    }

    /// This function is exposed only to the client side, therefore
    /// if allows NFT owners to perform transfers from Kiosk to Kiosk without
    /// having to pay royalties.
    ///
    /// This will always work if the signer is the owner of the kiosk.
    entry fun p2p_transfer<T: key + store>(
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_version(ext(source));
        assert_permission(source, ctx);

        let refs = df::borrow_mut(ext(source), NftRefsDfKey {});
        let ref = table::remove(refs, nft_id);
        assert_ref_not_exclusively_listed(&ref);

        let cap = pop_cap(source);
        let nft = kiosk::take<T>(source, &cap, nft_id);
        set_cap(source, cap);

        deposit(target, nft, ctx);
    }

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

    /// Can be called by an entity that has been authorized by the owner to
    /// withdraw given NFT.
    ///
    /// Returns a builder to the calling entity.
    /// The entity then populates it with trade information of which fungible
    /// tokens were paid.
    ///
    /// The builder then _must_ be transformed into a hot potato `TransferRequest`
    /// which is then used by logic that has access to `TransferPolicy`.
    ///
    /// Can only be called on kiosks in the OB ecosystem.
    ///
    /// We adhere to the deposit rules of the target kiosk.
    /// If we didn't, it'd be pointless to even have them since a spammer
    /// could simply simulate a transfer and select any target.
    public fun transfer_delegated<T: key + store>(
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        entity_id: &UID,
        price: u64,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        assert_version(ext(source));

        let (nft, req) = transfer_nft_(source, nft_id, uid_to_address(entity_id), price, ctx);
        deposit(target, nft, ctx);
        req
    }

    /// Similar to `transfer_delegated` but instead of proving origin with
    /// `&UID` we check that the entity is the signer.
    ///
    /// This will always work if the signer is the owner of the kiosk.
    public fun transfer_signed<T: key + store>(
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        price: u64,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        assert_version(ext(source));

        let (nft, req) = transfer_nft_(source, nft_id, sender(ctx), price, ctx);
        deposit(target, nft, ctx);
        req
    }

    public fun transfer_locked_nft<T: key + store>(
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        entity_id: &UID,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        assert_version(ext(source));

        check_entity_and_pop_ref(source, uid_to_address(entity_id), nft_id, ctx);

        let cap = pop_cap(source);
        kiosk::list<T>(source, &cap, nft_id, 0);
        set_cap(source, cap);

        let (nft, req) = kiosk::purchase<T>(source, nft_id, coin::zero(ctx));
        deposit(target, nft, ctx);

        let req = transfer_request::from_sui<T>(req, nft_id, uid_to_address(entity_id), ctx);

        req
    }

    /// We allow withdrawing NFTs for some use cases.
    /// If an NFT leaves our kiosk ecosystem, we can no longer guarantee
    /// royalty enforcement.
    /// Therefore, creators might not allow entities which enable withdrawing
    /// NFTs to trade their collection.
    ///
    /// You almost certainly want to use `transfer_delegated`.
    ///
    /// Handy for migrations.
    public fun withdraw_nft<T: key + store>(
        self: &mut Kiosk,
        nft_id: ID,
        entity_id: &UID,
        ctx: &mut TxContext,
    ): (T, WithdrawRequest<T>) {
        assert_version(ext(self));

        withdraw_nft_(self, nft_id, uid_to_address(entity_id), ctx)
    }

    /// Similar to `withdraw_nft` but the entity is a signer instead of UID.
    /// The owner can always initiate a withdraw.
    ///
    /// A withdraw can be prevented with an allowlist.
    public fun withdraw_nft_signed<T: key + store>(
        self: &mut Kiosk,
        nft_id: ID,
        ctx: &mut TxContext,
    ): (T, WithdrawRequest<T>) {
        assert_version(ext(self));

        withdraw_nft_(self, nft_id, sender(ctx), ctx)
    }

    /// If both kiosks are owned by the same user, then we allow free transfer.
    public fun transfer_between_owned<T: key + store>(
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_version(ext(source));
        assert_permission(source, ctx);
        // could result in a royalty free trading by everyone wrapping over our
        // kiosk
        assert!(kiosk::owner(source) != PermissionlessAddr, ENotAuthorized);
        // both kiosks are owned by the same user
        assert!(kiosk::owner(source) == kiosk::owner(target), ENotOwner);

        let refs = df::borrow_mut(ext(source), NftRefsDfKey {});
        let ref = table::remove(refs, nft_id);
        assert_ref_not_exclusively_listed(&ref);

        let cap = pop_cap(source);
        let nft = kiosk::take<T>(source, &cap, nft_id);
        set_cap(source, cap);

        deposit(target, nft, ctx);
    }

    // === Kiosk Interoperability ===

    public entry fun install_extension(
        self: &mut Kiosk,
        kiosk_cap: KioskOwnerCap,
        ctx: &mut TxContext,
    ) {
        let kiosk_ext = ext(self);

        df::add(kiosk_ext, VersionDfKey {}, VERSION);
        df::add(kiosk_ext, KioskOwnerCapDfKey {}, kiosk_cap);
        df::add(kiosk_ext, NftRefsDfKey {}, table::new<ID, NftRef>(ctx));
        df::add(kiosk_ext, DepositSettingDfKey {}, DepositSetting {
            enable_any_deposit: true,
            collections_with_enabled_deposits: vec_set::empty(),
        });

        transfer(OwnerToken {
            id: object::new(ctx),
            kiosk: object::id(self),
            owner: sender(ctx),
        }, sender(ctx));
    }

    public entry fun uninstall_extension(
        self: &mut Kiosk,
        owner_token: OwnerToken,
        ctx: &mut TxContext,
    ) {
        assert_version(ext(self));
        assert!(owner_token.kiosk == object::id(self), EIncorrectOwnerToken);
        assert_owner_address(self, sender(ctx));

        let kiosk_ext = ext(self);

        let refs = df::borrow(kiosk_ext, NftRefsDfKey {});
        assert!(table::is_empty<ID, NftRef>(refs), ECannotUninstallWithCurrentBookeeping);

        let owner_cap = df::remove<KioskOwnerCapDfKey, KioskOwnerCap>(kiosk_ext, KioskOwnerCapDfKey {});

        // They should only be able to remove the vevrsion if they completely
        // remove the NftRefs so it's safe to discard Version
        df::remove<VersionDfKey, u64>(kiosk_ext, VersionDfKey {});

        let refs = df::remove<NftRefsDfKey, Table<ID, NftRef>>(kiosk_ext, NftRefsDfKey {});
        table::destroy_empty(refs);
        df::remove<DepositSettingDfKey, DepositSetting>(kiosk_ext, DepositSettingDfKey {});

        let OwnerToken { id, kiosk: _, owner: _} = owner_token;
        object::delete(id);

        public_transfer(owner_cap, sender(ctx));
    }

    public entry fun register_nft<T: key>(
        self: &mut Kiosk,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_version(ext(self));
        assert_permission(self, ctx);

        // Assert that Kiosk has NFT
        assert_has_nft(self, nft_id);
        assert!(!kiosk::is_listed(self, nft_id), ENftIsListedInBaseKiosk);

        // Assert that Kiosk has no NftRef, which means the NFT was
        // placed in the Kiosk before installing the OB extension
        let refs = nft_refs_mut(self);
        assert_missing_ref(refs, nft_id);

        table::add(refs, nft_id, NftRef {
            auths: vec_set::empty(),
            is_exclusively_listed: false,
        });
    }

    // === Private Functions ===

    /// After authorization that the call is permitted, gets the NFT.
    fun transfer_nft_<T: key + store>(
        self: &mut Kiosk,
        nft_id: ID,
        originator: address,
        price: u64,
        ctx: &mut TxContext,
    ): (T, TransferRequest<T>) {
        let nft = get_nft(self, nft_id, originator, ctx);

        (nft, transfer_request::new(nft_id, originator, object::id(self), price, ctx))
    }

    /// After authorization that the call is permitted, gets the NFT.
    fun withdraw_nft_<T: key + store>(
        self: &mut Kiosk,
        nft_id: ID,
        originator: address,
        ctx: &mut TxContext,
    ): (T, WithdrawRequest<T>) {
        let nft = get_nft(self, nft_id, originator, ctx);

        (nft, withdraw_request::new(originator, ctx))
    }

    fun get_nft<T: key + store>(
        self: &mut Kiosk,
        nft_id: ID,
        originator: address,
        ctx: &mut TxContext,
    ): T {
        check_entity_and_pop_ref(self, originator, nft_id, ctx);

        let cap = pop_cap(self);
        let nft = kiosk::take<T>(self, &cap, nft_id);
        set_cap(self, cap);

        nft
    }

    fun new_(owner: address, ctx: &mut TxContext): Kiosk {
        let (kiosk, kiosk_cap) = kiosk::new(ctx);
        kiosk::set_owner_custom(&mut kiosk, &kiosk_cap, owner);
        let kiosk_ext = ext(&mut kiosk);

        df::add(kiosk_ext, VersionDfKey {}, VERSION);
        df::add(kiosk_ext, KioskOwnerCapDfKey {}, kiosk_cap);
        df::add(kiosk_ext, NftRefsDfKey {}, table::new<ID, NftRef>(ctx));
        df::add(kiosk_ext, DepositSettingDfKey {}, DepositSetting {
            enable_any_deposit: true,
            collections_with_enabled_deposits: vec_set::empty(),
        });

        kiosk
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

    /// Removes _all_ entities from access to the NFT.
    /// Cannot be performed if the NFT is exclusively listed.
    public fun delist_nft_as_owner(
        self: &mut Kiosk, nft_id: ID, ctx: &mut TxContext,
    ) {
        assert_version(ext(self));
        assert_permission(self, ctx);

        let refs = nft_refs_mut(self);
        let ref = table::borrow_mut(refs, nft_id);
        assert_ref_not_exclusively_listed(ref);
        ref.auths = vec_set::empty();
    }

    /// Removes a specific NFT from access to the NFT.
    /// Cannot be performed if the NFT is exclusively listed.
    public fun remove_auth_transfer_as_owner(
        self: &mut Kiosk, nft_id: ID, entity: address, ctx: &mut TxContext,
    ) {
        assert_version(ext(self));
        assert_permission(self, ctx);

        let refs = nft_refs_mut(self);
        let ref = table::borrow_mut(refs, nft_id);
        assert_ref_not_exclusively_listed(ref);
        vec_set::remove(&mut ref.auths, &entity);
    }

    /// This is the only path to delist an exclusively listed NFT.
    public fun remove_auth_transfer(
        self: &mut Kiosk, nft_id: ID, entity: &UID,
    ) {
        assert_version(ext(self));

        let entity = uid_to_address(entity);

        let refs = nft_refs_mut(self);
        let ref = table::borrow_mut(refs, nft_id);
        vec_set::remove(&mut ref.auths, &entity);
        ref.is_exclusively_listed = false; // no-op if it wasn't
    }

    // === Configure deposit settings ===

    /// Only owner or allowlisted collections can deposit.
    public entry fun restrict_deposits(
        self: &mut Kiosk, ctx: &mut TxContext,
    ) {
        assert_version(ext(self));
        assert_permission(self, ctx);

        let settings = deposit_setting_mut(self);
        settings.enable_any_deposit = false;
    }

    /// No restriction on deposits.
    public entry fun enable_any_deposit(
        self: &mut Kiosk, ctx: &mut TxContext,
    ) {
        assert_version(ext(self));
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
        assert_version(ext(self));
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
        assert_version(ext(self));

        let settings = deposit_setting_mut(self);
        let col_type = type_name::get<C>();
        vec_set::insert(&mut settings.collections_with_enabled_deposits, col_type);
    }

    // === NFT Accessors ===

    public fun borrow_nft_mut<T: key + store>(
        self: &mut Kiosk,
        nft_id: ID,
        field: Option<TypeName>,
        ctx: &mut TxContext,
    ): BorrowRequest<Witness, T> {
        assert_version(ext(self));
        assert_not_listed(self, nft_id);

        let cap = pop_cap(self);
        let (nft, promise) = kiosk::borrow_val(self, &cap, nft_id);
        // let nft = kiosk::take<T>(self, &cap, nft_id);
        set_cap(self, cap);

        borrow_request::new(Witness {}, nft, sender(ctx), field, promise, ctx)
    }

    public fun return_nft<OTW: drop, T: key + store>(
        self: &mut Kiosk,
        borrowed_nft: BorrowRequest<Witness, T>,
        policy: &Policy<WithNft<T, BORROW_REQ>>
    ) {
        assert_version(ext(self));

        let (nft, promise) = borrow_request::confirm(Witness {}, borrowed_nft, policy);

        let cap = pop_cap(self);
        kiosk::return_val(self, nft, promise);
        set_cap(self, cap);
    }

    // === Assertions and getters ===

    public fun is_ob_kiosk(self: &mut Kiosk): bool {
        df::exists_(ext(self), NftRefsDfKey {})
    }

    /// Either sender is owner or permissionless deposits of `T` enabled.
    public fun can_deposit<T>(self: &mut Kiosk, ctx: &mut TxContext): bool {
        sender(ctx) == kiosk::owner(self) || can_deposit_permissionlessly<T>(self)
    }

    public fun can_deposit_permissionlessly<T>(self: &mut Kiosk): bool {
        if (kiosk::owner(self) == PermissionlessAddr) {
            return true
        };

        let settings = deposit_setting_mut(self);
        settings.enable_any_deposit ||
            vec_set::contains(
                &settings.collections_with_enabled_deposits,
                &type_name::get<T>(),
            )
    }

    public fun assert_nft_type<T: key + store>(self: &Kiosk, nft_id: ID) {
        assert!(kiosk::has_item_with_type<T>(self, nft_id), ENftTypeMismatch);
    }

    public fun assert_can_deposit<T>(self: &mut Kiosk, ctx: &mut TxContext) {
        assert!(can_deposit<T>(self, ctx), ECannotDeposit);
    }

    public fun assert_can_deposit_permissionlessly<T>(self: &mut Kiosk) {
        assert!(can_deposit_permissionlessly<T>(self), EPermissionlessDepositsDisabled);
    }

    public fun assert_owner_address(self: &Kiosk, owner: address) {
        assert!(kiosk::owner(self) == owner, ENotOwner);
    }

    /// Either the kiosk is permissionless, or the sender is the owner.
    public fun assert_permission(self: &Kiosk, ctx: &mut TxContext) {
        let owner = kiosk::owner(self);
        assert!(owner == PermissionlessAddr || owner == sender(ctx), ENotOwner);
    }

    public fun assert_has_nft(self: &Kiosk, nft_id: ID) {
        assert!(kiosk::has_item(self, nft_id), EMissingNft)
    }

    public fun assert_missing_ref(refs: &Table<ID, NftRef>, nft_id: ID) {
        assert!(!table::contains(refs, nft_id), EMissingNft)
    }

    public fun assert_not_exclusively_listed(
        self: &mut Kiosk, nft_id: ID
    ) {
        let refs = df::borrow(ext(self), NftRefsDfKey {});
        let ref = table::borrow(refs, nft_id);
        assert_ref_not_exclusively_listed(ref);
    }

    public fun assert_not_listed(self: &mut Kiosk, nft_id: ID) {
        let refs = df::borrow(ext(self), NftRefsDfKey {});
        let ref = table::borrow(refs, nft_id);
        assert_ref_not_listed(ref);
    }

    public fun assert_is_ob_kiosk(self: &mut Kiosk) {
        assert!(is_ob_kiosk(self), EKioskNotOriginByteVersion);
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

    fun check_entity_and_pop_ref(
        self: &mut Kiosk, entity: address, nft_id: ID, ctx: &mut TxContext
    ) {
        let refs = nft_refs_mut(self);
        // NFT is being transferred - destroy the ref
        let ref: NftRef = table::remove(refs, nft_id);
        // sender is signer
        // OR
        // entity MUST be included in the map
        assert!(
            sender(ctx) == kiosk::owner(self) || vec_set::contains(&ref.auths, &entity),
            ENotAuthorized,
        );
    }

    fun deposit_setting_mut(self: &mut Kiosk): &mut DepositSetting {
        df::borrow_mut(ext(self), DepositSettingDfKey {})
    }

    fun nft_refs_mut(self: &mut Kiosk): &mut Table<ID, NftRef> {
        df::borrow_mut(ext(self), NftRefsDfKey {})
    }

    fun pop_cap(self: &mut Kiosk): kiosk::KioskOwnerCap {
        df::remove(ext(self), KioskOwnerCapDfKey {})
    }

    fun set_cap(self: &mut Kiosk, cap: kiosk::KioskOwnerCap) {
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
    public fun nft_refs(self: &mut Kiosk): &Table<ID, NftRef> {
        df::borrow(ext(self), NftRefsDfKey {})
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
        let refs = df::borrow(ext(self), NftRefsDfKey {});
        let ref = table::borrow<ID, NftRef>(refs, nft_id);
        assert!(vec_set::size(&ref.auths) > 0, 0);
    }

    #[test_only]
    public fun assert_exclusively_listed(
        self: &mut Kiosk, nft_id: ID
    ) {
        let refs = df::borrow(ext(self), NftRefsDfKey {});
        let ref = table::borrow<ID, NftRef>(refs, nft_id);
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
