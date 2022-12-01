module nft_protocol::safe {
    use nft_protocol::err;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::transfer_whitelist::Whitelist;
    use std::type_name::{Self, TypeName};
    use sui::event;
    use sui::object;
    use sui::object::{ID, UID};
    use sui::transfer::{share_object, transfer};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};
    use sui::vec_set::{Self, VecSet};
    use sui::dynamic_object_field::{Self as dof};

    struct Safe has key {
        id: UID,
        /// Accounting for deposited Nfts. Each NFT in the object bag is
        /// represented in this map.
        refs: VecMap<ID, NftRef>,
        /// If set to false, the owner can select which collections can be
        /// deposited to the safe.
        enable_any_deposit: bool,
        /// If the flag `enable_any_deposit` is set to false, then we check
        /// whether a collection is stored in this set.
        ///
        /// Enables more granular control over NFTs to combat spam.
        collections_with_enabled_deposits: VecSet<TypeName>,
    }

    /// Keeps info about an NFT which enables us to issue transfer caps etc.
    struct NftRef has store, copy, drop {
        /// Is generated anew every time a counter is incremented from zero to
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
    }

    struct DepositEvent has copy, drop {
        safe: ID,
        nft: ID,
    }

    struct TransferEvent has copy, drop {
        safe: ID,
        nft: ID,
    }

    /// Instantiates a new shared object `Safe` and transfer `OwnerCap` to the
    /// tx sender.
    public entry fun create_for_sender(ctx: &mut TxContext) {
        transfer(create_safe_(ctx), tx_context::sender(ctx));
    }

    /// Creates a new `Safe` shared object and returns the authority capability
    /// that grants authority over this safe.
    public fun create_safe(ctx: &mut TxContext): OwnerCap {
        create_safe_(ctx)
    }

    /// Creates a `TransferCap` which must be claimed atomically.
    ///
    /// Otherwise, there's a risk of a race condition as multiple non-exclusive
    /// transfer caps can be created.
    public fun create_transfer_cap(
        nft: ID,
        owner_cap: &OwnerCap,
        safe: &mut Safe,
        ctx: &mut TxContext,
    ): TransferCap {
        assert_owner_cap(owner_cap, safe);
        assert_contains_nft(&nft, safe);

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
        }
    }

    /// Creates an irrevocable and exclusive transfer cap.
    ///
    /// Useful for trading contracts which cannot claim an NFT atomically.
    public fun create_exclusive_transfer_cap(
        nft: ID,
        owner_cap: &OwnerCap,
        safe: &mut Safe,
        ctx: &mut TxContext,
    ): TransferCap {
        assert_owner_cap(owner_cap, safe);
        assert_contains_nft(&nft, safe);

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
        }
    }

    /// Only owner or whitelisted collections can deposit.
    public entry fun restrict_deposits(
        owner_cap: &OwnerCap,
        safe: &mut Safe,
    ) {
        assert_owner_cap(owner_cap, safe);

        safe.enable_any_deposit = false;
    }
    /// No restriction on deposits.
    public entry fun enable_any_deposit(
        owner_cap: &OwnerCap,
        safe: &mut Safe,
    ) {
        assert_owner_cap(owner_cap, safe);

        safe.enable_any_deposit = true;
    }

    /// The owner can restrict deposits into the `Safe` from given collection.
    ///
    /// However, if the flag `Safe::enable_any_deposit` is set to true, then
    /// it takes precedence.
    public entry fun disable_deposits_of_collection<C>(
        owner_cap: &OwnerCap,
        safe: &mut Safe,
    ) {
        assert_owner_cap(owner_cap, safe);

        let col_type = type_name::get<C>();
        vec_set::remove(&mut safe.collections_with_enabled_deposits, &col_type);
    }
    /// The owner can enable deposits into the `Safe` from given collection.
    ///
    /// However, if the flag `Safe::enable_any_deposit` is set to true, then
    /// it takes precedence anyway.
    public entry fun enable_deposits_of_collection<C>(
        owner_cap: &OwnerCap,
        safe: &mut Safe,
    ) {
        assert_owner_cap(owner_cap, safe);

        let col_type = type_name::get<C>();
        vec_set::insert(&mut safe.collections_with_enabled_deposits, col_type);
    }

    /// Transfer an NFT into the `Safe`.
    ///
    /// Requires that `enable_any_deposit` flag is set to true, or that the
    /// `Safe` owner enabled NFTs of given collection to be inserted.
    public entry fun deposit_nft<T>(
        nft: Nft<T>,
        safe: &mut Safe,
        ctx: &mut TxContext,
    ) {
        assert_can_deposit<T>(safe);

        deposit_nft_(nft, safe, ctx);
    }

    /// Transfer an NFT from owner to the `Safe`.
    public entry fun deposit_nft_priviledged<T>(
        nft: Nft<T>,
        owner_cap: &OwnerCap,
        safe: &mut Safe,
        ctx: &mut TxContext,
    ) {
        assert_owner_cap(owner_cap, safe);

        deposit_nft_(nft, safe, ctx);
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
        whitelist: &Whitelist,
        safe: &mut Safe,
    ) {
        let nft = get_nft_for_transfer_<T>(transfer_cap, safe);

        nft::transfer(nft, recipient, authority, whitelist);
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
        whitelist: &Whitelist,
        source: &mut Safe,
        target: &mut Safe,
        ctx: &mut TxContext,
    ) {
        let nft = get_nft_for_transfer_<T>(transfer_cap, source);

        nft::change_logical_owner(&mut nft, recipient, authority, whitelist);
        deposit_nft(nft, target, ctx);
    }

    /// Destroys given transfer cap. This is mainly useful for exclusively listed
    /// NFTs.
    public entry fun burn_transfer_cap(
        transfer_cap: TransferCap,
        safe: &mut Safe,
    ) {
        assert_transfer_cap_of_safe(&transfer_cap, safe);

        let TransferCap {
            id,
            is_exclusive: _,
            nft,
            safe: _,
            version,
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
        safe: &mut Safe,
        ctx: &mut TxContext,
    ) {
        assert_owner_cap(owner_cap, safe);
        assert_contains_nft(&nft, safe);

        let ref = vec_map::get_mut(&mut safe.refs, &nft);
        assert_not_exclusively_listed_internal(ref);

        ref.version = new_id(ctx);
        ref.transfer_cap_counter = 0;
    }

    fun create_safe_(ctx: &mut TxContext): OwnerCap {
        let safe = Safe {
            id: object::new(ctx),
            refs: vec_map::empty(),
            enable_any_deposit: true,
            collections_with_enabled_deposits: vec_set::empty(),
        };
        let cap = OwnerCap {
            id: object::new(ctx),
            safe: object::id(&safe),
        };

        share_object(safe);
        cap
    }

    /// Generates a unique ID.
    fun new_id(ctx: &mut TxContext): ID {
        let new_uid = object::new(ctx);
        let new_id = object::uid_to_inner(&new_uid);
        object::delete(new_uid);
        new_id
    }

    fun deposit_nft_<T>(
        nft: Nft<T>,
        safe: &mut Safe,
        ctx: &mut TxContext,
    ) {
        let nft_id = object::id(&nft);

        vec_map::insert(&mut safe.refs, nft_id, NftRef {
            version: new_id(ctx),
            transfer_cap_counter: 0,
            is_exclusively_listed: false,
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
        safe: &mut Safe,
    ): Nft<T> {
        let nft_id = transfer_cap.nft;

        event::emit(
            TransferEvent {
                safe: object::id(safe),
                nft: nft_id,
            }
        );

        assert_transfer_cap_of_safe(&transfer_cap, safe);
        assert_nft_of_transfer_cap(&nft_id, &transfer_cap);
        assert_contains_nft(&nft_id, safe);

        let (_, ref) = vec_map::remove(&mut safe.refs, &nft_id);
        assert_version_match(&ref, &transfer_cap);

        let TransferCap {
            id,
            safe: _,
            nft: _,
            version: _,
            is_exclusive: _,
        } = transfer_cap;
        object::delete(id);

        dof::remove<ID, Nft<T>>(&mut safe.id, nft_id)
    }

    // === Getters ===

    public fun has_nft<C>(nft: ID, safe: &Safe): bool {
        dof::exists_with_type<ID, Nft<C>>(&safe.id, nft)
    }

    public fun owner_cap_safe(cap: &OwnerCap): ID {
        cap.safe
    }

    public fun are_all_deposits_enabled(safe: &Safe): bool {
        safe.enable_any_deposit
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

    // === Assertions ===

    public fun assert_owner_cap(cap: &OwnerCap, safe: &Safe) {
        assert!(cap.safe == object::id(safe), err::safe_cap_mismatch());
    }

    public fun assert_transfer_cap_of_safe(cap: &TransferCap, safe: &Safe) {
        assert!(cap.safe == object::id(safe), err::safe_cap_mismatch());
    }

    public fun assert_nft_of_transfer_cap(nft: &ID, cap: &TransferCap) {
        assert!(&cap.nft == nft, err::transfer_cap_nft_mismatch());
    }

    public fun assert_contains_nft(nft: &ID, safe: &Safe) {
        assert!(
            vec_map::contains(&safe.refs, nft), err::safe_does_not_contain_nft()
        );
    }

    public fun assert_not_exclusively_listed(cap: &TransferCap) {
        assert!(!cap.is_exclusive, err::nft_exclusively_listed());
    }

    public fun assert_version_match(ref: &NftRef, cap: &TransferCap) {
        assert!(ref.version == cap.version, err::transfer_cap_expired());
    }

    public fun assert_can_deposit<T>(safe: &Safe) {
        if (!safe.enable_any_deposit) {
            assert!(
                vec_set::contains(&safe.collections_with_enabled_deposits, &type_name::get<T>()),
                err::safe_does_not_accept_deposits(),
            );
        }
    }

    public fun assert_id(safe: &Safe, id: ID) {
        assert!(object::id(safe) == id, err::safe_id_mismatch());
    }

    fun assert_not_exclusively_listed_internal(ref: &NftRef) {
        assert!(!ref.is_exclusively_listed, err::nft_exclusively_listed());
    }
}
