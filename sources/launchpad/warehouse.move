/// Module representing the NFT bookkeeping `Warehouse` type
///
/// `Warehouse` is an unprotected type that can be constructed independently
/// before it is merged to a `Venue`, allowing `Warehouse` to be constructed
/// while avoiding shared consensus transactions on `Listing`.
module nft_protocol::warehouse {
    use std::vector;

    use sui::transfer;
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, ID , UID};

    use nft_protocol::nft::Nft;

    /// `Warehouse` does not have NFTs left to withdraw
    ///
    /// Call `Venue::deposit_nft` or `Listing::add_nft` to add NFTs.
    const EEMPTY: u64 = 1;

    /// `Warehouse` still has NFTs left to withdraw
    ///
    /// Call `Venue::redeem_nft` or a `Listing` market to withdraw remaining
    /// NFTs.
    const ENOT_EMPTY: u64 = 2;

    /// `Warehouse` object
    struct Warehouse<phantom C> has key, store {
        /// `Warehouse` ID
        id: UID,
        /// NFTs that are currently on sale
        nfts: vector<ID>,
        // By subtracting `warehouse.total_deposited` to the length of `warehouse.nfts`
        // one can get total redeemed
        total_deposited: u64,
    }

    /// Create a new `Warehouse`
    public fun new<C>(ctx: &mut TxContext): Warehouse<C> {
        Warehouse {
            id: object::new(ctx),
            nfts: vector::empty(),
            total_deposited: 0,
        }
    }

    /// Creates a `Warehouse` and transfers to transaction sender
    public entry fun init_warehouse<C>(ctx: &mut TxContext) {
        transfer::transfer(new<C>(ctx), tx_context::sender(ctx));
    }

    /// Deposits NFT to `Warehouse`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    public entry fun deposit_nft<C>(
        warehouse: &mut Warehouse<C>,
        nft: Nft<C>,
    ) {
        let nft_id = object::id(&nft);
        vector::push_back(&mut warehouse.nfts, nft_id);
        warehouse.total_deposited = warehouse.total_deposited + 1;

        dof::add(&mut warehouse.id, nft_id, nft);
    }

    /// Redeems NFT from `Warehouse`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    ///
    /// `Warehouse` may not change the logical owner of an `Nft` when
    /// redeeming as this would allow royalties to be trivially bypassed.
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is empty
    public fun redeem_nft<C>(
        warehouse: &mut Warehouse<C>,
    ): Nft<C> {
        let nfts = &mut warehouse.nfts;
        assert!(!vector::is_empty(nfts), EEMPTY);

        dof::remove(&mut warehouse.id, vector::pop_back(nfts))
    }

    /// Redeems specific NFT from `Warehouse` and transfers to sender
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    ///
    /// `Warehouse` may not change the logical owner of an `Nft` when
    /// redeeming as this would allow royalties to be trivially bypassed.
    ///
    /// #### Usage
    ///
    /// Entry mint functions like `suimarines::mint_nft` take an `Warehouse`
    /// object to deposit into. Calling `redeem_nft_transfer` allows one to
    /// withdraw an NFT and own it directly.
    public entry fun redeem_nft_transfer<C>(
        warehouse: &mut Warehouse<C>,
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        let nft = redeem_nft<C>(warehouse);
        transfer::transfer(nft, sender);
    }

    /// Destroys `Warehouse`
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is not empty
    public entry fun destroy<C>(warehouse: Warehouse<C>) {
        assert_is_empty(&warehouse);
        let Warehouse { id, nfts: _, total_deposited: _ } = warehouse;
        object::delete(id);
    }

    // === Getter Functions ===

    /// Return how many `Nft` there are to sell
    public fun supply<C>(warehouse: &Warehouse<C>): u64 {
        vector::length(&warehouse.nfts)
    }

    /// Return whether there are any `Nft` in the `Warehouse`
    public fun is_empty<C>(warehouse: &Warehouse<C>): bool {
        vector::is_empty(&warehouse.nfts)
    }

    /// Return cumulated amount of `Nft`s deposited in the `Warehouse`
    public fun total_deposited<C>(warehouse: &Warehouse<C>): u64 {
        warehouse.total_deposited
    }

    /// Return cumulated amount of `Nft`s redeemed in the `Warehouse`
    public fun total_redeemed<C>(warehouse: &Warehouse<C>): u64 {
        warehouse.total_deposited - vector::length(&warehouse.nfts)
    }

    // === Assertions ===

    /// Asserts that `Warehouse` is empty
    public fun assert_is_empty<C>(warehouse: &Warehouse<C>) {
        assert!(is_empty(warehouse), ENOT_EMPTY);
    }
}
