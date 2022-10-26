module nft_protocol::safe {
    use sui::object::{ID, UID};
    use sui::vec_set::{Self, VecSet};
    use sui::tx_context::{Self, TxContext};
    use sui::object;
    use sui::transfer::{share_object, transfer};
    use nft_protocol::err;

    struct Safe has key {
        id: UID,
        nfts: VecSet<ID>,
        listed_nfts: VecSet<ID>,
        exclusively_listed_nfts: VecSet<ID>,
    }

    struct OwnerCap has key, store {
        id: UID,
        safe: ID,
    }

    struct DepositCap has key, store {
        id: UID,
        safe: ID,
    }

    struct WithdrawCap has key, store {
        id: UID,
        safe_id: ID,
        nft_id: ID,
        /// If set to true, only one `WithdrawCap` can be issued for this NFT.
        /// It also cannot be revoked without burning this object.
        ///
        /// This is useful for trading flows that cannot guarantee that the NFT
        /// is claimed atomically.
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

    public fun create_withdraw_cap(
        nft: ID,
        owner_cap: &OwnerCap,
        safe: &mut Safe,
        ctx: &mut TxContext,
    ): WithdrawCap {
        assert_owner(owner_cap, safe);
        assert_in_set(&safe.nfts, &nft);
        assert_not_in_set(&safe.exclusively_listed_nfts, &nft);

        WithdrawCap {
            id: object::new(ctx),
            safe_id: object::id(safe),
            nft_id: nft,
            is_exlusive: false,
        }
    }
    public fun create_exlusive_withdraw_cap(
        nft: ID,
        owner_cap: &OwnerCap,
        safe: &mut Safe,
        ctx: &mut TxContext,
    ): WithdrawCap {
        let cap = create_withdraw_cap(nft, owner_cap, safe, ctx);

        assert_not_in_set(&safe.listed_nfts, &nft);
        cap.is_exlusive = true;
        cap
    }

    fun create_safe_(ctx: &mut TxContext): OwnerCap {
        let safe = Safe {
            id: object::new(ctx),
            nfts: vec_set::empty(),
            listed_nfts: vec_set::empty(),
            exclusively_listed_nfts: vec_set::empty(),
        };
        let cap = OwnerCap {
            id: object::new(ctx),
            safe: object::id(&safe),
        };

        share_object(safe);
        cap
    }

    //------- getters -------

    //------- assertions -------

    public fun assert_owner(cap: &OwnerCap, safe: &Safe) {
        assert!(cap.safe == object::id(safe), err::safe_owner_mismatch());
    }

    public fun assert_not_in_set(set: &VecSet<ID>, nft: &ID) {
        assert!(
            !vec_set::contains(set, nft),
            1
        );
    }

    public fun assert_in_set(set: &VecSet<ID>, nft: &ID) {
        assert!(
            vec_set::contains(set, nft),
            1
        );
    }
}
