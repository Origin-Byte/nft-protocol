/// Module of `UnprotectedSafe` type.
///
/// `UnprotectedSafe` is an abstraction meant to hold NFTs in it.
/// A user that transfers its NFTs to its Safe is able to delegate the power
/// of transferability.
/// One typical issue with on-chain trading is that by sending one's assets
/// to a shared object (the trading primitive), one looses the ability to
/// see them in their wallet, even though one has still technical ownership
/// of such assets, until a trade is effectively executed.
/// To solve for this, we use `UnprotectedSafe` to hold the user's assets
/// and then instead of transferring the assets to the shared object
/// (trading primitive), the user transfers a `TransferCap`
/// `TransferCap` is an object that delegates the ability to transfer a
/// given NFT out of the seller's `Safe`.
///
/// The ownership model of the `Safe` relies on the object `OwnerCap` whose
/// holder is the effective owner of the `Safe` and subsequently the owner of
/// the assets within it.
///
/// # Two NFT kinds
/// We support two kinds of NFTs in this safe implementation.
/// 1. Our protocol `nft_protocol::nft::Nft` which is guarded with allowlist.
/// This enables creators to have certain guarantees around royalty
/// enforcement.
/// 2. Arbitrary type of NFTs.
/// Those are not guarded with allowlist.
/// They can be freely transferred between users and safes.
module nft_protocol::unprotected_safe {
    use nft_protocol::err;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::transfer_allowlist::Allowlist;
    use nft_protocol::utils;

    use sui::event;
    use sui::object::{Self, ID, UID};
    use sui::transfer::{share_object, transfer};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};
    use sui::dynamic_object_field::{Self as dof};

    struct UnprotectedSafe has key, store {
        id: UID,
        /// Accounting for deposited NFTs. Each NFT in the object bag is
        /// represented in this map.
        refs: VecMap<ID, NftRef>,
    }

    /// Keeps info about an NFT which enables us to issue transfer caps etc.
    struct NftRef has store, copy, drop {
        /// Is generated a new every time a counter is incremented from zero to
        /// one.
        ///
        /// We don't use monotonically increasing integer so that we can remove
        /// withdrawn NFTs from the map.
        version: ID,
        /// How many transfer caps are there for this version.
        transfer_cap_counter: u64,
        /// Only one `TransferCap` of the latest version can exist.
        /// An exclusively listed NFT cannot have its `TransferCap` revoked.
        is_exclusively_listed: bool,
        /// Signalizes whether given NFT is wrapped in our NFT type (nft::Nft)
        /// or whether it's a 3rd party type.
        ///
        /// This has implications on how the NFT is transferred.
        is_generic: bool,
    }

    /// Whoever owns this object can perform some admin actions against the
    /// `Safe` shared object with the corresponding id.
    struct OwnerCap has key, store {
        id: UID,
        safe: ID,
    }

    /// Enables the owner to transfer given NFT out of the `Safe`.
    struct TransferCap has key, store {
        id: UID,
        safe: ID,
        nft: ID,
        version: ID,
        /// If set to true, only one `TransferCap` can be issued for this NFT.
        /// It also cannot be revoked without burning this object.
        ///
        /// This is useful for trading flows that cannot guarantee that the NFT
        /// is claimed atomically.
        ///
        /// If an NFT is listed exclusively, it cannot be revoked without
        /// burning the `TransferCap` first.
        is_exclusive: bool,
        /// Signalizes whether given NFT is wrapped in our NFT type (nft::Nft)
        /// or whether it's a 3rd party type.
        ///
        /// This has implications on how the NFT is transferred.
        is_generic: bool,
    }

    struct DepositEvent has copy, drop {
        safe: ID,
        nft: ID,
    }

    struct TransferEvent has copy, drop {
        safe: ID,
        nft: ID,
    }

    public fun new(ctx: &mut TxContext): (UnprotectedSafe, OwnerCap) {
        let safe = UnprotectedSafe {
            id: object::new(ctx),
            refs: vec_map::empty(),
        };

        let cap = OwnerCap {
            id: object::new(ctx),
            safe: object::id(&safe),
        };

        (safe, cap)
    }

    /// Instantiates a new shared object `Safe` and transfer `OwnerCap` to the
    /// tx sender.
    public entry fun create_for_sender(ctx: &mut TxContext) {
        let (safe, cap) = new(ctx);
        share_object(safe);

        transfer(cap, tx_context::sender(ctx));
    }

    /// Creates a new `Safe` shared object and returns the authority capability
    /// that grants authority over this safe.
    public fun create_safe(ctx: &mut TxContext): OwnerCap {
        let (safe, cap) = new(ctx);
        share_object(safe);

        cap
    }

    /// Creates a `TransferCap` which must be claimed atomically.
    ///
    /// Otherwise, there's a risk of a race condition as multiple non-exclusive
    /// transfer caps can be created.
    public fun create_transfer_cap(
        nft: ID,
        owner_cap: &OwnerCap,
        safe: &mut UnprotectedSafe,
        ctx: &mut TxContext,
    ): TransferCap {
        assert_owner_cap(owner_cap, safe);
        assert_has_nft(&nft, safe);

        let safe_id = object::id(safe);
        let ref = vec_map::get_mut(&mut safe.refs, &nft);
        assert_not_exclusively_listed_internal(ref);
        ref.transfer_cap_counter = ref.transfer_cap_counter + 1;
        if (ref.transfer_cap_counter == 1) {
            ref.version = new_id(ctx);
        };

        TransferCap {
            id: object::new(ctx),
            is_exclusive: false,
            nft: nft,
            safe: safe_id,
            version: ref.version,
            is_generic: ref.is_generic,
        }
    }

    /// Creates an irrevocable and exclusive transfer cap.
    ///
    /// Useful for trading contracts which cannot claim an NFT atomically.
    public fun create_exclusive_transfer_cap(
        nft: ID,
        owner_cap: &OwnerCap,
        safe: &mut UnprotectedSafe,
        ctx: &mut TxContext,
    ): TransferCap {
        assert_owner_cap(owner_cap, safe);
        assert_has_nft(&nft, safe);

        let safe_id = object::id(safe);
        let ref = vec_map::get_mut(&mut safe.refs, &nft);
        assert_not_exclusively_listed_internal(ref);

        ref.transfer_cap_counter = 1;
        ref.is_exclusively_listed = true;
        ref.version = new_id(ctx);

        TransferCap {
            id: object::new(ctx),
            is_exclusive: true,
            nft: nft,
            safe: safe_id,
            version: ref.version,
            is_generic: ref.is_generic,
        }
    }

    /// Transfer an NFT into the `Safe`.
    public entry fun deposit_nft<T>(
        nft: Nft<T>,
        safe: &mut UnprotectedSafe,
        ctx: &mut TxContext,
    ) {
        let is_generic = false;
        deposit_nft_(nft, is_generic, safe, ctx);
    }

    /// Transfer an NFT into the `Safe`.
    ///
    /// The type T here can refer to any object, not just the NFT protocol's
    /// exported NFT type.
    public entry fun deposit_generic_nft<T: key + store>(
        nft: T,
        safe: &mut UnprotectedSafe,
        ctx: &mut TxContext,
    ) {
        let is_generic = !utils::is_nft_protocol_nft_type<T>();
        deposit_nft_(nft, is_generic, safe, ctx);
    }

    /// Use a transfer cap to get an NFT out of the `Safe`.
    ///
    /// If the NFT is not exclusively listed, it can happen that the transfer
    /// cap is no longer valid. The NFT could've been traded or the trading cap
    /// revoked.
    public fun transfer_nft_to_recipient<T, Auth: drop>(
        transfer_cap: TransferCap,
        recipient: address,
        authority: Auth,
        allowlist: &Allowlist,
        safe: &mut UnprotectedSafe,
    ) {
        let nft = get_nft_for_transfer_<T>(transfer_cap, safe);

        nft::transfer(nft, recipient, authority, allowlist);
    }

    public fun transfer_generic_nft_to_recipient<T: key + store>(
        transfer_cap: TransferCap,
        recipient: address,
        safe: &mut UnprotectedSafe,
    ) {
        utils::assert_not_nft_protocol_type<T>();

        let nft = get_generic_nft_for_transfer_<T>(transfer_cap, safe);

        transfer(nft, recipient)
    }

    /// Use a transfer cap to get an NFT out of source `Safe` and deposit it
    /// to the target `Safe`. The recipient address should match the owner of
    /// the target `Safe`.
    ///
    /// If the NFT is not exclusively listed, it can happen that the transfer
    /// cap is no longer valid. The NFT could've been traded or the trading cap
    /// revoked.
    public fun transfer_nft_to_safe<T, Auth: drop>(
        transfer_cap: TransferCap,
        recipient: address,
        authority: Auth,
        allowlist: &Allowlist,
        source: &mut UnprotectedSafe,
        target: &mut UnprotectedSafe,
        ctx: &mut TxContext,
    ) {
        let nft = get_nft_for_transfer_<T>(transfer_cap, source);

        nft::change_logical_owner(&mut nft, recipient, authority, allowlist);
        deposit_nft(nft, target, ctx);
    }

    public fun transfer_generic_nft_to_safe<T: key + store>(
        transfer_cap: TransferCap,
        source: &mut UnprotectedSafe,
        target: &mut UnprotectedSafe,
        ctx: &mut TxContext,
    ) {
        utils::assert_not_nft_protocol_type<T>();

        let nft = get_generic_nft_for_transfer_<T>(transfer_cap, source);

        deposit_generic_nft(nft, target, ctx);
    }

    /// Destroys given transfer cap. This is mainly useful for exclusively listed
    /// NFTs.
    public entry fun burn_transfer_cap(
        transfer_cap: TransferCap,
        safe: &mut UnprotectedSafe,
    ) {
        assert_transfer_cap_of_safe(&transfer_cap, safe);

        let TransferCap {
            id,
            is_exclusive: _,
            nft,
            safe: _,
            version,
            is_generic: _,
        } = transfer_cap;
        object::delete(id);

        let ref = vec_map::get_mut(&mut safe.refs, &nft);
        if (ref.version == version) {
            ref.transfer_cap_counter = ref.transfer_cap_counter - 1;
            if (ref.transfer_cap_counter == 0) {
                ref.is_exclusively_listed = false;
            };
        }
    }

    /// Changes the transfer ref version, thereby invalidating all existing
    /// `TransferCap` objects.
    ///
    /// Can happen only if the NFT is not listed exclusively.
    public entry fun delist_nft(
        nft: ID,
        owner_cap: &OwnerCap,
        safe: &mut UnprotectedSafe,
        ctx: &mut TxContext,
    ) {
        assert_owner_cap(owner_cap, safe);
        assert_has_nft(&nft, safe);

        let ref = vec_map::get_mut(&mut safe.refs, &nft);
        assert_not_exclusively_listed_internal(ref);

        ref.version = new_id(ctx);
        ref.transfer_cap_counter = 0;
    }

    // === Private functions ===

    /// Generates a unique ID.
    fun new_id(ctx: &mut TxContext): ID {
        let new_uid = object::new(ctx);
        let new_id = object::uid_to_inner(&new_uid);
        object::delete(new_uid);
        new_id
    }

    fun deposit_nft_<T: key + store>(
        nft: T,
        is_generic: bool,
        safe: &mut UnprotectedSafe,
        ctx: &mut TxContext,
    ) {
        let nft_id = object::id(&nft);

        vec_map::insert(&mut safe.refs, nft_id, NftRef {
            version: new_id(ctx),
            transfer_cap_counter: 0,
            is_exclusively_listed: false,
            is_generic,
        });

        dof::add(&mut safe.id, nft_id, nft);

        event::emit(
            DepositEvent {
                safe: object::id(safe),
                nft: nft_id,
            }
        );
    }

    fun get_nft_for_transfer_<T>(
        transfer_cap: TransferCap,
        safe: &mut UnprotectedSafe,
    ): Nft<T> {
        get_generic_nft_for_transfer_(transfer_cap, safe)
    }

    fun get_generic_nft_for_transfer_<T: key + store>(
        transfer_cap: TransferCap,
        safe: &mut UnprotectedSafe,
    ): T {
        let nft_id = transfer_cap.nft;

        event::emit(
            TransferEvent {
                safe: object::id(safe),
                nft: nft_id,
            }
        );

        assert_transfer_cap_of_safe(&transfer_cap, safe);
        assert_nft_of_transfer_cap(&nft_id, &transfer_cap);
        assert_has_nft(&nft_id, safe);

        let (_, ref) = vec_map::remove(&mut safe.refs, &nft_id);
        assert_version_match(&ref, &transfer_cap);

        let TransferCap {
            id,
            safe: _,
            nft: _,
            version: _,
            is_exclusive: _,
            is_generic: _,
        } = transfer_cap;
        object::delete(id);

        dof::remove<ID, T>(&mut safe.id, nft_id)
    }

    // === Getters ===

    public fun has_nft<C>(nft: ID, safe: &UnprotectedSafe): bool {
        dof::exists_with_type<ID, Nft<C>>(&safe.id, nft)
    }

    public fun has_generic_nft<T: key + store>(nft: ID, safe: &UnprotectedSafe): bool {
        dof::exists_with_type<ID, T>(&safe.id, nft)
    }

    public fun owner_cap_safe(cap: &OwnerCap): ID {
        cap.safe
    }

    public fun transfer_cap_safe(cap: &TransferCap): ID {
        cap.safe
    }

    public fun transfer_cap_nft(cap: &TransferCap): ID {
        cap.nft
    }

    public fun transfer_cap_version(cap: &TransferCap): ID {
        cap.version
    }

    public fun transfer_cap_is_exclusive(cap: &TransferCap): bool {
        cap.is_exclusive
    }

    public fun transfer_cap_is_nft_generic(cap: &TransferCap): bool {
        cap.is_generic
    }

    // === Assertions ===

    public fun assert_owner_cap(cap: &OwnerCap, safe: &UnprotectedSafe) {
        assert!(cap.safe == object::id(safe), err::safe_cap_mismatch());
    }

    public fun assert_transfer_cap_of_safe(cap: &TransferCap, safe: &UnprotectedSafe) {
        assert!(cap.safe == object::id(safe), err::safe_cap_mismatch());
    }

    public fun assert_nft_of_transfer_cap(nft: &ID, cap: &TransferCap) {
        assert!(&cap.nft == nft, err::transfer_cap_nft_mismatch());
    }

    public fun assert_has_nft(nft: &ID, safe: &UnprotectedSafe) {
        assert!(
            vec_map::contains(&safe.refs, nft), err::safe_does_not_contain_nft()
        );
    }

    public fun assert_not_exclusively_listed(cap: &TransferCap) {
        assert!(!cap.is_exclusive, err::nft_exclusively_listed());
    }

    public fun assert_id(safe: &UnprotectedSafe, id: ID) {
        assert!(object::id(safe) == id, err::safe_id_mismatch());
    }

    public fun assert_transfer_cap_exclusive(cap: &TransferCap) {
        assert!(cap.is_exclusive, err::nft_not_exclusively_listed());
    }

    public fun assert_transfer_cap_of_native_nft(cap: &TransferCap) {
        assert!(!cap.is_generic, err::nft_is_generic());
    }

    fun assert_version_match(ref: &NftRef, cap: &TransferCap) {
        assert!(ref.version == cap.version, err::transfer_cap_expired());
    }

    fun assert_not_exclusively_listed_internal(ref: &NftRef) {
        assert!(!ref.is_exclusively_listed, err::nft_exclusively_listed());
    }
}
