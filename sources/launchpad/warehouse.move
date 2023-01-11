/// Module representing the Nft bookeeping Inventories of `Slot`s.
///
/// Listings can have multiple concurrent markets, repsented
/// through `markets: ObjectBag`, allowing NFT creators to perform tiered sales.
/// An example of this would be an Gaming NFT creator separating the sale
/// based on NFT rarity and emit whitelist tokens to different users for
/// different rarities depending on the user's game score.
///
/// The Slot object is agnostic to the Market mechanism and instead decides to
/// outsource this logic to generic `Market` objects. This way developers can
/// come up with their plug-and-play market primitives, of which some examples
/// are Dutch Auctions, Sealed-Bid Auctions, etc.
///
/// Each market has a dedicated warehouse, which tracks which NFTs are on
/// the shelves still to be sold, and which NFTs have been sold via Certificates
/// but are still waiting to be redeemed.
module nft_protocol::warehouse {
    use std::vector;

    use sui::transfer;
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};
    use sui::object::{Self, ID , UID};
    use sui::object_bag::{Self, ObjectBag};

    use nft_protocol::nft::Nft;
    use nft_protocol::err;

    friend nft_protocol::listing;

    // The `Warehouse` of a sale performs the bookeeping of all the NFTs that
    // are currently on sale as well as the NFTs whose certificates have been
    // sold and currently waiting to be redeemed
    struct Warehouse has key, store {
        id: UID,
        /// Track which markets are live
        live: VecMap<ID, bool>,
        /// Track which markets are whitelisted
        whitelisted: VecMap<ID, bool>,
        /// Vector of all markets outlets that, each outles holding IDs
        /// owned by the warehouse
        markets: ObjectBag,
        // NFTs that are currently on sale. When a `NftCertificate` is sold,
        // its corresponding NFT ID will be flushed from `nfts` and will be
        // added to `queue`.
        nfts_on_sale: vector<ID>,
    }

    public fun new(
        ctx: &mut TxContext,
    ): Warehouse {
        Warehouse {
            id: object::new(ctx),
            live: vec_map::empty(),
            whitelisted: vec_map::empty(),
            markets: object_bag::new(ctx),
            nfts_on_sale: vector::empty(),
        }
    }

    /// Creates a `Warehouse` and transfers to transaction sender
    public entry fun init_warehouse(ctx: &mut TxContext) {
        let warehouse = new(ctx);
        transfer::transfer(warehouse, tx_context::sender(ctx));
    }

    /// Adds a new market to `Warehouse` allowing NFTs deposited to the
    /// warehouse to be sold.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    public entry fun add_market<Market: key + store>(
        warehouse: &mut Warehouse,
        is_whitelisted: bool,
        market: Market,
    ) {
        let market_id = object::id(&market);

        vec_map::insert(&mut warehouse.live, market_id, false);
        vec_map::insert(&mut warehouse.whitelisted, market_id, is_whitelisted);

        object_bag::add<ID, Market>(
            &mut warehouse.markets,
            market_id,
            market,
        );
    }

    /// Adds NFT as a dynamic child object with its ID as key and
    /// adds an NFT's ID to the `nfts` field in `Warehouse` object.
    ///
    /// This should only be callable when Warehouse is private and not
    /// owned by the Slot. The function call will fail otherwise, because
    /// one would have to refer to the Slot, the parent shared object, in order
    /// for the bytecode verifier not to fail.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    public entry fun deposit_nft<C>(
        warehouse: &mut Warehouse,
        nft: Nft<C>,
    ) {
        let nft_id = object::id(&nft);
        vector::push_back(&mut warehouse.nfts_on_sale, nft_id);

        dof::add(&mut warehouse.id, nft_id, nft);
    }

    /// Redeems NFT from `Warehouse`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    public fun redeem_nft<C>(
        warehouse: &mut Warehouse,
    ): Nft<C> {
        let nfts = &mut warehouse.nfts_on_sale;
        assert!(!vector::is_empty(nfts), err::no_nfts_left());

        dof::remove(&mut warehouse.id, vector::pop_back(nfts))
    }

    /// Redeems NFT from `Warehouse` and transfers to sender
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    ///
    /// ##### Usage
    ///
    /// Entry mint functions like `suimarines::mint_nft` take an `Warehouse`
    /// object to deposit into. Calling `redeem_nft_transfer` allows one to
    /// withdraw an NFT and own it directly.
    public entry fun redeem_nft_transfer<C>(
        warehouse: &mut Warehouse,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_nft<C>(warehouse);
        transfer::transfer(nft, tx_context::sender(ctx));
    }

    /// Set market's live status
    public entry fun set_live(
        warehouse: &mut Warehouse,
        market_id: ID,
        is_live: bool,
    ) {
        *vec_map::get_mut(&mut warehouse.live, &market_id) = is_live;
    }

    /// Set market's whitelist status
    public entry fun set_whitelisted(
        warehouse: &mut Warehouse,
        market_id: ID,
        is_whitelisted: bool,
    ) {
        *vec_map::get_mut(&mut warehouse.whitelisted, &market_id) =
            is_whitelisted;
    }

    // === Getter Functions ===

    /// Check how many `nfts` there are to sell
    public fun length(warehouse: &Warehouse): u64 {
        vector::length(&warehouse.nfts_on_sale)
    }

    /// Get the market's `live` status
    public fun is_live(warehouse: &Warehouse, market_id: &ID): bool {
        *vec_map::get(&warehouse.live, market_id)
    }

    public fun is_empty(warehouse: &Warehouse): bool {
        vector::is_empty(&warehouse.nfts_on_sale)
    }

    public fun is_whitelisted(warehouse: &Warehouse, market_id: &ID): bool {
        *vec_map::get(&warehouse.whitelisted, market_id)
    }

    /// Get the `Warehouse` markets
    public fun markets(warehouse: &Warehouse): &ObjectBag {
        &warehouse.markets
    }

    /// Get specific `Warehouse` market
    public fun market<Market: key + store>(
        warehouse: &Warehouse,
        market_id: ID,
    ): &Market {
        assert_market<Market>(warehouse, market_id);
        object_bag::borrow<ID, Market>(&warehouse.markets, market_id)
    }

    /// Get specific `Warehouse` market mutably
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    public fun market_mut<Market: key + store>(
        warehouse: &mut Warehouse,
        market_id: ID,
    ): &mut Market {
        assert_market<Market>(warehouse, market_id);
        object_bag::borrow_mut<ID, Market>(&mut warehouse.markets, market_id)
    }

    // === Assertions ===

    public fun assert_is_live(warehouse: &Warehouse, market_id: &ID) {
        assert!(is_live(warehouse, market_id), err::listing_not_live());
    }

    public fun assert_is_whitelisted(warehouse: &Warehouse, market_id: &ID) {
        assert!(
            is_whitelisted(warehouse, market_id),
            err::sale_is_not_whitelisted()
        );
    }

    public fun assert_is_not_whitelisted(warehouse: &Warehouse, market_id: &ID) {
        assert!(
            !is_whitelisted(warehouse, market_id),
            err::sale_is_whitelisted()
        );
    }

    public fun assert_market<Market: key + store>(
        warehouse: &Warehouse,
        market_id: ID,
    ) {
        assert!(
            object_bag::contains_with_type<ID, Market>(
                &warehouse.markets, market_id
            ),
            err::undefined_market(),
        );
    }
}
