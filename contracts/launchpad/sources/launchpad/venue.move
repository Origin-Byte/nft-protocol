/// Module representing the market `Venue` type
///
/// `Venue` allows creator to configure a primary market through which
/// their collection will be sold. `Venue` enforces that all purchases made
/// through it will draw from an inventory determined at construction.
///
/// `Venue` is an unprotected type that composes the market structure of
/// `Listing`.
module ob_launchpad::venue {
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::dynamic_field as df;

    friend ob_launchpad::listing;
    friend ob_launchpad::english_auction;
    friend ob_launchpad::dutch_auction;

    /// `Venue` is not live
    ///
    /// Call `Venue::set_live` or `Listing::sale_on` to make it live.
    const EVenueNotLive: u64 = 1;

    /// `Venue` whitelisted
    ///
    /// Ensure that `Venue` is not whitelisted when calling `Venue::new` or
    /// call `Venue::set_whitelisted`.
    const EVenueWhitelisted: u64 = 2;

    /// `Venue` not whitelisted
    ///
    /// Ensure that `Venue` is whitelisted when calling `Venue::new` or call
    /// `Venue::set_whitelisted`.
    const EVenueNotWhitelisted: u64 = 3;

    /// `Venue` market accessed with incorrect type
    ///
    /// Ensure that the type argument provided to `Venue::borrow_market`
    /// corresponds to the underlying market.
    const EVenueIncorrectMarketType: u64 = 4;

    /// `Venue` object
    ///
    /// `Venue` is a thin wrapper around a generic `Market` that handles
    /// tracking live status and whitelist assertions. `Venue` itself is not
    /// generic as to not require knowledge of the underlying market to
    /// perform administrative operations.
    ///
    /// `Venue` is unprotected and relies on safely obtaining a mutable
    /// reference.
    struct Venue has key, store {
        id: UID,
        /// Track whether market is live
        is_live: bool,
        /// Track which market is whitelisted
        is_whitelisted: bool,
    }

    /// Create a new `Venue`
    public fun new<Market: store, MarketKey: copy + drop + store>(
        key: MarketKey,
        market: Market,
        is_whitelisted: bool,
        ctx: &mut TxContext
    ): Venue {
        let venue_id = object::new(ctx);
        df::add(&mut venue_id, key, market);

        Venue {
            id: venue_id,
            is_live: false,
            is_whitelisted,
        }
    }

    /// Initializes a `Venue` and transfers to transaction sender
    public fun init_venue<Market: store, MarketKey: copy + drop + store>(
        key: MarketKey,
        market: Market,
        is_whitelisted: bool,
        ctx: &mut TxContext
    ) {
        let venue = new(key, market, is_whitelisted, ctx);
        transfer::public_transfer(venue, tx_context::sender(ctx));
    }

    /// Set market's live status
    public(friend) fun set_live(
        venue: &mut Venue,
        is_live: bool,
    ) {
        venue.is_live = is_live;
    }

    /// Set market's whitelist status
    public(friend) fun set_whitelisted(
        venue: &mut Venue,
        is_whitelisted: bool,
    ) {
        venue.is_whitelisted = is_whitelisted;
    }

    // === Getter Functions ===

    /// Get whether the venue is live
    public fun is_live(venue: &Venue): bool {
        venue.is_live
    }

    /// Get whether the venue is whitelisted
    public fun is_whitelisted(venue: &Venue): bool {
        venue.is_whitelisted
    }

    /// Borrow `Venue` market
    ///
    /// #### Panics
    ///
    /// Panics if incorrect type was provided for the underlying market.
    public fun borrow_market<Market: store, MarketKey: copy + drop + store>(
        key: MarketKey,
        venue: &Venue,
    ): &Market {
        assert_market<Market, MarketKey>(key, venue);
        df::borrow(&venue.id, key)
    }

    /// Mutably borrow `Venue` market
    ///
    /// #### Panics
    ///
    /// Panics if incorrect type was provided for the underlying market.
    public(friend) fun borrow_market_mut<Market: store, MarketKey: copy + drop + store>(
        key: MarketKey,
        venue: &mut Venue,
    ): &mut Market {
        assert_market<Market, MarketKey>(key, venue);
        df::borrow_mut(&mut venue.id, key)
    }

    /// Deconstruct `Venue` returning the underlying market
    ///
    /// #### Panics
    ///
    /// Panics if underlying market does not match the provided type.
    public(friend) fun delete<Market: store, MarketKey: copy + drop + store>(
        key: MarketKey,
        venue: Venue,
    ): Market {
        let market = df::remove(&mut venue.id, key);

        let Venue { id, is_live: _, is_whitelisted: _ } = venue;
        object::delete(id);

        market
    }

    // === Assertions ===

    /// Asserts the type of the underlying market of the `Venue`
    ///
    /// #### Panics
    ///
    /// Panics if incorrect type was provided
    public fun assert_market<Market: store, MarketKey: copy + drop + store>(
        key: MarketKey,
        venue: &Venue,
    ): bool {
        df::exists_with_type<MarketKey, Market>(&venue.id, key)
    }

    /// Asserts that `Venue` is live
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` is not live
    public fun assert_is_live(venue: &Venue) {
        assert!(is_live(venue), EVenueNotLive);
    }

    /// Asserts that `Venue` is whitelisted
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` is not whitelisted
    public fun assert_is_whitelisted(venue: &Venue) {
        assert!(is_whitelisted(venue), EVenueNotWhitelisted);
    }

    /// Asserts that `Venue` is not whitelisted
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` is whitelisted
    public fun assert_is_not_whitelisted(venue: &Venue) {
        assert!(!is_whitelisted(venue), EVenueWhitelisted);
    }
}
