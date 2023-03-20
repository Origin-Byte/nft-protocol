module nft_protocol::ob_kiosk {
    use std::option::{Self, Option};
    use std::type_name::{Self, TypeName};

    use sui::dynamic_object_field::{Self as dof};
    use sui::dynamic_field::{Self as df};
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::table::{Self, Table};
    use sui::vec_map::{Self, VecMap};
    use sui::vec_set::{Self, VecSet};

    use nft_protocol::package::{Self, Publisher};
    use nft_protocol::transfer_policy::{Self, TransferRequest};
    use nft_protocol::kiosk::{Self, Kiosk, KioskOwnerCap};

    /// Trying to withdraw profits and sender is not owner.
    const ENotOwner: u64 = 0;

    /// Trying to access an NFT that is not in the kiosk.
    const EMissingNft: u64 = 1;

    /// NFT is already listed exclusively
    const ENftAlreadyExclusivelyListed: u64 = 2;

    /// NFT is already listed
    const ENftAlreadyListed: u64 = 3;

    /// Trying to withdraw profits and sender is not owner.
    const EPermissionlessDepositsDisabled: u64 = 4; // TODO: bump



    struct OwnerCap has key {
        // We wrap KioskOwnerCap in a key-only object to prevent transfers
        // The easiest way is to add the KioskOwnerCap inside the Kiosk as a dynamic field
        // TODO: Consider using TypedID
        // TODO: Consider using some ID that is a Hash from the ID and the Owner
        // so we can perform only one assertion on perfomance sensitive calls
        kiosk: ID,
    }

    struct BackupCap has key {
        kiosk: ID,
    }

    struct InnerKiosk has store {
        kiosk_cap: KioskOwnerCap,
        owner: address,
        backup: Option<address>,
        permissionless_deposits: bool,
        refs: Table<ID, NftRef>,
    }

    /// Inner accounting type.
    ///
    /// Holds info about NFT listing which is used to determine if an entity
    /// is allowed to redeem the NFT.
    struct NftRef has store, drop {
        // TODO: Consider using address instead of ID
        /// Entities which can use their `&UID` to redeem the NFT.
        auths: VecSet<ID>,
        /// If set to true, then `listed_with` must have length of 1 and
        /// listed_for must be "none".
        is_exclusively_listed: bool,
        /// How much is the NFT _publicly_ listed for.
        ///
        /// Anyone can come to the safe and buy the NFT for this price.
        listed_for: Option<u64>,
    }

    /// Instantiates a new shared object `Safe<OriginByte>` and transfer
    /// `OwnerCap` to the tx sender.
    public entry fun create_for_sender(
        backup: Option<address>,
        ctx: &mut TxContext,
    ) {
        let owner_cap = create_kiosk(backup, ctx);
        transfer::transfer(owner_cap, tx_context::sender(ctx));
    }

    /// Creates a new `Safe<OriginByte>` shared object and returns the authority capability
    /// that grants authority over this safe.
    public fun create_kiosk(
        backup: Option<address>,
        ctx: &mut TxContext
    ): OwnerCap {
        let (kiosk, kiosk_cap) = kiosk::new(ctx);

        let inner_kiosk = InnerKiosk {
            kiosk_cap,
            owner: tx_context::sender(ctx),
            backup,
            permissionless_deposits: false,
            refs: table::new(ctx),
        };

        df::add(kiosk::uid_mut(&mut kiosk), type_name::get<InnerKiosk>(), inner_kiosk);

        let owner_cap = OwnerCap { kiosk: object::id(&kiosk) };

        transfer::share_object(kiosk);
        owner_cap
    }

    /// Unpacks and destroys a Kiosk returning the profits (even if "0").
    /// Can only be performed by the bearer of the `KioskOwnerCap` in the
    /// case where there's no items inside and a `Kiosk` is not shared.
    public entry fun close_and_withdraw(
        self: Kiosk, cap: OwnerCap, ctx: &mut TxContext
    ) {
        // Check if OwnerCap matches Kiosk
        assert_owner_cap(&self, &cap);

        // Pop InnerKiosk, keep KioskOwnerCap and drop the rest
        let inner = df::remove<TypeName, InnerKiosk>(
            kiosk::uid_mut(&mut self),
            type_name::get<InnerKiosk>()
        );

        let InnerKiosk {
            kiosk_cap,
            owner: _,
            backup: _,
            permissionless_deposits: _,
            refs,
        } = inner;

        table::drop(refs);

        // Close the kiosk and send profits to the tx sender
        let profits = kiosk::close_and_withdraw(self, kiosk_cap, ctx);
        transfer::transfer(profits, tx_context::sender(ctx));
    }

    // === Backup functions ===

    public entry fun add_backup() {}
    public entry fun freeze_kiosk() {}
    public entry fun allow_recovery() {}
    public entry fun recover_kiosk() {}

    // === Deposit to the Kiosk ===

    /// Place any object into a Kiosk.
    /// Performs an authorization check to make sure only owner can do that.
    public entry fun deposit<T: key + store>(
        self: &mut Kiosk, nft: T
    ) {
        let inner = df::borrow_mut<TypeName, InnerKiosk>(
            kiosk::uid_mut(self),
            type_name::get<InnerKiosk>()
        );

        assert!(
            inner.permissionless_deposits == true, EPermissionlessDepositsDisabled
        );

        let nft_id = object::id(&nft);

        // Add NFT reference to the inner kiosk
        table::add(&mut inner.refs, nft_id, NftRef {
            auths: vec_set::empty(),
            is_exclusively_listed: false,
            listed_for: option::none(),
        });

        let kiosk_cap_ref = &inner.kiosk_cap;
        kiosk::place(self, kiosk_cap_ref, nft);
    }

    /// Place any object into a Kiosk.
    /// Performs an authorization check to make sure only owner can do that.
    public entry fun deposit_as_owner<T: key + store>(
        self: &mut Kiosk, cap: &OwnerCap, nft: T
    ) {
        // Check if OwnerCap matches Kiosk
        assert_owner_cap(self, cap);

        let inner = df::borrow_mut<TypeName, InnerKiosk>(
            kiosk::uid_mut(self),
            type_name::get<InnerKiosk>()
        );

        let nft_id = object::id(&nft);

        // Add NFT reference to the inner kiosk
        table::add(&mut inner.refs, nft_id, NftRef {
            auths: vec_set::empty(),
            is_exclusively_listed: false,
            listed_for: option::none(),
        });

        let kiosk_cap_ref = &inner.kiosk_cap;
        kiosk::place(self, kiosk_cap_ref, nft);
    }

    // === Withdraw from the Kiosk ===

    public fun auth_transfer(
        self: &mut Kiosk,
        owner_cap: &OwnerCap,
        nft_id: ID,
        entity_id: ID,
        // _authority: Auth,
        // _allowlist: &Allowlist,
    ) {
        assert_owner_cap(self, owner_cap);
        assert_has_nft(self, nft_id);

        let inner = df::borrow_mut<TypeName, InnerKiosk>(
            kiosk::uid_mut(self),
            type_name::get<InnerKiosk>()
        );

        let ref = table::borrow_mut(&mut inner.refs, nft_id);
        assert_ref_not_exclusively_listed(ref);

        vec_set::insert(&mut ref.auths, entity_id);
    }

    public fun auth_exclusive_transfer() {}

    public fun transfer() {}
    public fun delegated_transfer() {}



    // === Assertions ===

    public fun assert_owner_cap(self: &Kiosk, cap: &OwnerCap) {
        assert!(object::id(self) == cap.kiosk, ENotOwner);
    }

    public fun assert_has_nft(self: &Kiosk, nft_id: ID) {
        assert!(kiosk::has_item(self, nft_id), EMissingNft)
    }

    public fun assert_not_exclusively_listed<I: key + store>(
        self: &InnerKiosk, nft_id: ID
    ) {
        let ref = table::borrow(&self.refs, nft_id);
        assert_ref_not_exclusively_listed(ref);
    }

    fun assert_ref_not_exclusively_listed(ref: &NftRef) {
        assert!(!ref.is_exclusively_listed, ENftAlreadyExclusivelyListed);
    }

    fun assert_not_listed(ref: &NftRef) {
        assert!(vec_set::size(&ref.auths) == 0, ENftAlreadyListed);
        assert!(option::is_none(&ref.listed_for), ENftAlreadyListed);
    }

}
