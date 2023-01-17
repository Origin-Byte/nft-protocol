/// Module representing the market `Venue` type
///
/// `Venue` allows creator to configure a primary market through which
/// their collection will be sold. This includes defining multiple markets,
/// but also their whitelist status.
///
/// `Venue` is an unprotected type that composes the inventory structure of
/// `Listing`. In consequence, `Inventory` can be constructed independently
/// before it is published in a `Listing`, allowing `Inventory` to be
/// constructed while avoiding shared consensus transactions on `Listing`.
module nft_protocol::venue {
    use std::vector;

    use sui::transfer;
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};
    use sui::object::{Self, ID , UID};
    use sui::object_bag::{Self, ObjectBag};

    use nft_protocol::err;
    use nft_protocol::nft::Nft;

    friend nft_protocol::listing;

    /// `Venue` object
    ///
    /// `Venue` is a private object that handles the parametrization of NFT
    /// primary sales. It is intended to be inserted into a `Listing` which
    /// publicises it as a market venue.
    ///
    /// NFTs are deposited into `Venue` by composing multiple `Inventory`.
    struct Venue has key, store {
        id: UID,
        /// Track which markets are live
        live: VecMap<ID, bool>,
        /// Track which markets are whitelisted
        whitelisted: VecMap<ID, bool>,
        /// Vector of all markets outlets that, each outles holding IDs
        /// owned by the inventory
        markets: ObjectBag,
        // NFTs that are currently on sale. When a `NftCertificate` is sold,
        // its corresponding NFT ID will be flushed from `nfts` and will be
        // added to `queue`.
        nfts_on_sale: vector<ID>,
    }

    /// Create a new `Venue`
    public fun new(ctx: &mut TxContext): Venue {
        Venue {
            id: object::new(ctx),
            live: vec_map::empty(),
            whitelisted: vec_map::empty(),
            markets: object_bag::new(ctx),
            nfts_on_sale: vector::empty(),
        }
    }

    /// Creates a `Venue` and transfers to transaction sender
    public entry fun init_inventory(ctx: &mut TxContext) {
        let inventory = new(ctx);
        transfer::transfer(inventory, tx_context::sender(ctx));
    }

    /// Adds a new market to `Venue` allowing NFTs deposited to the
    /// inventory to be sold.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Venue`.
    public entry fun add_market<Market: key + store>(
        venue: &mut Venue,
        is_whitelisted: bool,
        market: Market,
    ) {
        let market_id = object::id(&market);

        vec_map::insert(&mut venue.live, market_id, false);
        vec_map::insert(&mut venue.whitelisted, market_id, is_whitelisted);

        object_bag::add<ID, Market>(
            &mut venue.markets,
            market_id,
            market,
        );
    }

    /// Deposits NFT to `Venue`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Venue`.
    public entry fun deposit_nft<C>(venue: &mut Venue, nft: Nft<C>) {
        let nft_id = object::id(&nft);
        vector::push_back(&mut venue.nfts_on_sale, nft_id);

        dof::add(&mut venue.id, nft_id, nft);
    }

    /// Redeems NFT from `Venue`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Venue`.
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` is empty
    public fun redeem_nft<C>(
        venue: &mut Venue,
    ): Nft<C> {
        let nfts = &mut venue.nfts_on_sale;
        assert!(!vector::is_empty(nfts), err::no_nfts_left());

        dof::remove(&mut venue.id, vector::pop_back(nfts))
    }

    /// Redeems specific NFT from `Venue` and transfers to sender
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Venue`.
    ///
    /// #### Usage
    ///
    /// Entry mint functions like `suimarines::mint_nft` take an `Venue`
    /// object to deposit into. Calling `redeem_nft_transfer` allows one to
    /// withdraw an NFT and own it directly.
    public entry fun redeem_nft_transfer<C>(
        venue: &mut Venue,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_nft<C>(venue);
        transfer::transfer(nft, tx_context::sender(ctx));
    }

    /// Set market's live status
    public entry fun set_live(
        venue: &mut Venue,
        market_id: ID,
        is_live: bool,
    ) {
        *vec_map::get_mut(&mut venue.live, &market_id) = is_live;
    }

    /// Set market's whitelist status
    public entry fun set_whitelisted(
        venue: &mut Venue,
        market_id: ID,
        is_whitelisted: bool,
    ) {
        *vec_map::get_mut(&mut venue.whitelisted, &market_id) =
            is_whitelisted;
    }

    // === Getter Functions ===

    /// Check how many `nfts` there are to sell
    public fun length(venue: &Venue): u64 {
        vector::length(&venue.nfts_on_sale)
    }

    /// Get the market's `live` status
    public fun is_live(venue: &Venue, market_id: &ID): bool {
        *vec_map::get(&venue.live, market_id)
    }

    public fun is_empty(venue: &Venue): bool {
        vector::is_empty(&venue.nfts_on_sale)
    }

    public fun is_whitelisted(venue: &Venue, market_id: &ID): bool {
        *vec_map::get(&venue.whitelisted, market_id)
    }

    /// Get the `Venue` markets
    public fun markets<C>(venue: &Venue): &ObjectBag {
        &venue.markets
    }

    /// Get specific `Venue` market
    public fun market<Market: key + store>(
        venue: &Venue,
        market_id: ID,
    ): &Market {
        assert_market<Market>(venue, market_id);
        object_bag::borrow<ID, Market>(&venue.markets, market_id)
    }

    /// Get specific `Venue` market mutably
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Venue`.
    public fun market_mut<Market: key + store>(
        venue: &mut Venue,
        market_id: ID,
    ): &mut Market {
        assert_market<Market>(venue, market_id);
        object_bag::borrow_mut<ID, Market>(&mut venue.markets, market_id)
    }

    // === Assertions ===

    public fun assert_is_live(venue: &Venue, market_id: &ID) {
        assert!(is_live(venue, market_id), err::listing_not_live());
    }

    public fun assert_is_whitelisted(venue: &Venue, market_id: &ID) {
        assert!(
            is_whitelisted(venue, market_id),
            err::sale_is_not_whitelisted()
        );
    }

    public fun assert_is_not_whitelisted(venue: &Venue, market_id: &ID) {
        assert!(
            !is_whitelisted(venue, market_id),
            err::sale_is_whitelisted()
        );
    }

    public fun assert_market<Market: key + store>(venue: &Venue, market_id: ID) {
        assert!(
            object_bag::contains_with_type<ID, Market>(
                &venue.markets, market_id
            ),
            err::undefined_market(),
        );
    }
}
