module nft_protocol::safe {
    use sui::object::{ID, UID};
    use sui::vec_map::{Self, VecMap};
    use sui::tx_context::{Self, TxContext};
    use sui::object;
    use sui::transfer::{share_object, transfer};
    use nft_protocol::err;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::transfer_whitelist::Whitelist;
    use sui::object_bag::{Self, ObjectBag};

    struct Safe has key {
        id: UID,
        refs: VecMap<ID, NftRef>,
        nfts: ObjectBag,
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
        /// An exlusively listed NFT cannot have its `TransferCap` revoked.
        is_exlusively_listed: bool,
    }

    /// Whoever owns this object can perform some admin actions against the
    /// `Safe` shared object with the corresponding id.
    struct OwnerCap has key, store {
        id: UID,
        safe: ID,
    }

    /// Enables the owner to deposit NFTs into the `Safe`.
    struct DepositCap has key, store {
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
        is_exlusive: bool,
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
        assert_not_exlusively_listed(ref);
        ref.transfer_cap_counter = ref.transfer_cap_counter + 1;
        if (ref.transfer_cap_counter == 1) {
            ref.version = new_id(ctx);
        };

        TransferCap {
            id: object::new(ctx),
            is_exlusive: false,
            nft: nft,
            safe: safe_id,
            version: ref.version,
        }
    }

    /// Creates an irrevocable and exclusive transfer cap.
    ///
    /// Useful for trading contracts which cannot claim an NFT atomically.
    public fun create_exlusive_transfer_cap(
        nft: ID,
        owner_cap: &OwnerCap,
        safe: &mut Safe,
        ctx: &mut TxContext,
    ): TransferCap {
        assert_owner_cap(owner_cap, safe);
        assert_contains_nft(&nft, safe);

        let safe_id = object::id(safe);
        let ref = vec_map::get_mut(&mut safe.refs, &nft);
        assert_not_exlusively_listed(ref);

        ref.transfer_cap_counter = 1;
        ref.version = new_id(ctx);

        TransferCap {
            id: object::new(ctx),
            is_exlusive: true,
            nft: nft,
            safe: safe_id,
            version: ref.version,
        }
    }

    /// Transfer an NFT from the logical owner to the `Safe`.
    public fun deposit_nft<C, D: store>(
        nft: Nft<C, D>,
        deposit_cap: &DepositCap,
        safe: &mut Safe,
        ctx: &mut TxContext,
    ) {
        assert_deposit_cap(deposit_cap, safe);

        let nft_id = object::id(&nft);

        vec_map::insert(&mut safe.refs, nft_id, NftRef {
            version: new_id(ctx),
            transfer_cap_counter: 0,
            is_exlusively_listed: false,
        });

        object_bag::add(&mut safe.nfts, nft_id, nft);
    }

    /// Remove an NFT from the `Safe` and give it back to the logical owner.
    public fun withdraw_nft<T, D: store>(
        nft_id: ID,
        owner_cap: &OwnerCap,
        safe: &mut Safe,
    ) {
        assert_owner_cap(owner_cap, safe);
        assert_contains_nft(&nft_id, safe);

        let (_, ref) = vec_map::remove(&mut safe.refs, &nft_id);
        // an exlusively listed NFT must first have its transfer cap burned
        // via fun burn_transfer_cap
        assert_not_exlusively_listed(&ref);

        let nft = object_bag::remove<ID, Nft<T, D>>(&mut safe.nfts, nft_id);
        nft::transfer_to_owner(nft);
    }

    /// Use a transfer cap to get an NFT out of the `Safe`.
    ///
    /// If the NFT is not exlusively listed, it can happen that the transfer
    /// cap is no longer valid. The NFT could've been traded or the trading cap
    /// revoked.
    public fun transfer_nft<T, D: store, WW, Auth: drop>(
        nft_id: ID,
        transfer_cap: TransferCap,
        recipient: address,
        authority: Auth,
        whitelist: &Whitelist<WW>,
        safe: &mut Safe,
    ) {
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
            is_exlusive: _,
        } = transfer_cap;
        object::delete(id);

        let nft = object_bag::remove<ID, Nft<T, D>>(&mut safe.nfts, nft_id);
        nft::transfer(nft, recipient, authority, whitelist);
    }

    /// Destroys given transfer cap. This is mainly useful for exlusively listed
    /// NFTs.
    public fun burn_transfer_cap(
        transfer_cap: TransferCap,
        safe: &mut Safe,
    ) {
        assert_transfer_cap_of_safe(&transfer_cap, safe);

        let TransferCap {
            id,
            is_exlusive: _,
            nft,
            safe: _,
            version,
        } = transfer_cap;
        object::delete(id);

        let ref = vec_map::get_mut(&mut safe.refs, &nft);
        if (ref.version == version) {
            ref.transfer_cap_counter = ref.transfer_cap_counter - 1;
            if (ref.transfer_cap_counter == 0) {
                ref.is_exlusively_listed = false;
            };
        }
    }

    /// Changes the transfer ref version, thereby invalidating all existing
    /// `TransferCap` objects.
    ///
    /// Can happen only if the NFT is not listed exlusively.
    public fun delist_nft(
        nft: &ID,
        owner_cap: &OwnerCap,
        safe: &mut Safe,
        ctx: &mut TxContext,
    ) {
        assert_owner_cap(owner_cap, safe);
        assert_contains_nft(nft, safe);

        let ref = vec_map::get_mut(&mut safe.refs, nft);
        assert_not_exlusively_listed(ref);

        ref.version = new_id(ctx);
        ref.transfer_cap_counter = 0;
    }

    fun create_safe_(ctx: &mut TxContext): OwnerCap {
        let safe = Safe {
            id: object::new(ctx),
            refs: vec_map::empty(),
            nfts: object_bag::new(ctx),
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

    // === Getters ===

    public fun owner_cap_safe(cap: &OwnerCap): ID {
        cap.safe
    }

    public fun deposit_cap_safe(cap: &DepositCap): ID {
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
    public fun transfer_cap_is_exlusive(cap: &TransferCap): bool {
        cap.is_exlusive
    }

    // === Assertions ===

    public fun assert_owner_cap(cap: &OwnerCap, safe: &Safe) {
        assert!(cap.safe == object::id(safe), err::safe_cap_mismatch());
    }

    public fun assert_deposit_cap(cap: &DepositCap, safe: &Safe) {
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

    public fun assert_not_exlusively_listed(ref: &NftRef) {
        assert!(!ref.is_exlusively_listed, err::nft_exlusively_listed());
    }

    public fun assert_version_match(ref: &NftRef, cap: &TransferCap) {
        assert!(ref.version == cap.version, err::transfer_cap_expired());
    }
}
