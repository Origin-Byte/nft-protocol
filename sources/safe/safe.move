module nft_protocol::safe {
    use sui::object::{ID, UID};
    use sui::vec_map::{Self, VecMap};
    use sui::tx_context::{Self, TxContext};
    use sui::object;
    use sui::transfer::{share_object, transfer};
    use nft_protocol::err;
    use nft_protocol::nft::Nft;
    use nft_protocol::transfer_whitelist::Whitelist;

    struct Safe has key {
        id: UID,
        nfts: VecMap<ID, NftRef>,
    }

    /// Keeps info about an NFT which enables us to issue transfer caps etc.
    struct NftRef has store, copy, drop {
        /// Is generated anew every time a counter is incremented from zero to
        /// one.
        ///
        /// We don't use monotonically increasing integer so that we can remove
        /// withdrawn NFTs from the map.
        version: ID,
        /// How many transfer caps are there for this version of Rc.
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

        let rc = vec_map::get_mut(&mut safe.nfts, &nft);
        assert_not_exlusively_listed(rc);
        rc.transfer_cap_counter = rc.transfer_cap_counter + 1;
        if (rc.transfer_cap_counter == 1) {
            rc.version = new_id(ctx);
        };

        TransferCap {
            id: object::new(ctx),
            is_exlusive: false,
            nft: nft,
            safe: object::id(safe),
            version: rc.version,
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

        let rc = vec_map::get_mut(&mut safe.nfts, &nft);
        assert_not_exlusively_listed(rc);

        rc.transfer_cap_counter = 1;
        rc.version = new_id(ctx);

        TransferCap {
            id: object::new(ctx),
            is_exlusive: true,
            nft: nft,
            safe: object::id(safe),
            version: rc.version,
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

        vec_map::insert(&mut safe.nfts, object::id(&nft), NftRef {
            version: new_id(ctx),
            transfer_cap_counter: 0,
            is_exlusively_listed: false,
        });

        // TODO: transfer nft as a child obj
        abort(0)
    }

    /// Remove an NFT from the `Safe` and give it back to the logical owner.
    public fun withdraw_nft<T>(
        nft: ID,
        owner_cap: &OwnerCap,
        safe: &mut Safe,
    ) {
        assert_owner_cap(owner_cap, safe);
        assert_contains_nft(&nft, safe);

        // TODO: get NFT
        // TODO: move from safe to logical owner
        abort(0)
    }

    /// Use a transfer cap to get an NFT out of the `Safe`.
    ///
    /// If the NFT is not exlusively listed, it can happen that the transfer
    /// cap is no longer valid. The NFT could've been traded or the trading cap
    /// revoked.
    public fun transfer_nft<T, W>(
        nft: ID,
        transfer_cap: TransferCap,
        recipient: address,
        whitelist: &Whitelist<W>,
        safe: &mut Safe,
    ) {
        assert_transfer_cap(&transfer_cap, safe);
        assert_contains_nft(&nft, safe);

        // TODO: get NFT
        // TODO: move from safe to new owner
        abort(0)
    }

    /// Destroys given transfer cap. This is mainly useful for exlusively listed
    /// NFTs.
    public fun burn_transfer_cap(
        transfer_cap: TransferCap,
        safe: &mut Safe,
    ) {
        assert_transfer_cap(&transfer_cap, safe);

        let TransferCap {
            id,
            is_exlusive: _,
            nft,
            safe: _,
            version,
        } = transfer_cap;
        object::delete(id);

        let rc = vec_map::get_mut(&mut safe.nfts, &nft);
        if (rc.version == version) {
            rc.transfer_cap_counter = rc.transfer_cap_counter - 1;
            if (rc.transfer_cap_counter == 0) {
                rc.is_exlusively_listed = false;
            };
        }
    }

    /// Can happen only if the NFT is not listed exlusively.
    public fun delist_nft(
        nft: &ID,
        owner_cap: &OwnerCap,
        safe: &mut Safe,
        ctx: &mut TxContext,
    ) {
        assert_owner_cap(owner_cap, safe);
        assert_contains_nft(nft, safe);

        let rc = vec_map::get_mut(&mut safe.nfts, nft);
        assert_not_exlusively_listed(rc);

        rc.version = new_id(ctx);
        rc.transfer_cap_counter = 0;
    }

    fun create_safe_(ctx: &mut TxContext): OwnerCap {
        let safe = Safe {
            id: object::new(ctx),
            nfts: vec_map::empty(),
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

    public fun assert_transfer_cap(cap: &TransferCap, safe: &Safe) {
        assert!(cap.safe == object::id(safe), err::safe_cap_mismatch());
    }

    public fun assert_contains_nft(nft: &ID, safe: &Safe) {
        assert!(
            vec_map::contains(&safe.nfts, nft), err::safe_does_not_contain_nft()
        );
    }

    public fun assert_not_exlusively_listed(rc: &NftRef) {
        assert!(!rc.is_exlusively_listed, err::nft_exlusively_listed());
    }
}
