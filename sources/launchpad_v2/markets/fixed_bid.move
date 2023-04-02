/// Module of `FixedBidMarket`
///
/// It implements a fixed price sale configuration, where all NFTs in the
/// inventory get sold at a fixed price.
///
/// NFT creators can decide to use multiple markets to create a tiered market
/// sale by segregating NFTs by different sale segments.
module nft_protocol::fixed_bid_v2 {
    use nft_protocol::launchpad_v2::{Self, LaunchCap};
    use nft_protocol::venue_request::{Self, VenueRequest, VenuePolicyCap, VenuePolicy};
    use nft_protocol::venue_v2::{Self, Venue};

    // use nft_protocol::listing::{Self, Listing};
    use nft_protocol::market_whitelist::{Self, Certificate};
    use nft_protocol::ob_kiosk;
    use sui::coin::{Self, Coin};
    use sui::kiosk::Kiosk;
    use sui::clock::Clock;
    use sui::dynamic_field as df;
    use sui::object::{Self, ID, UID};
    use sui::transfer::public_transfer;
    use sui::tx_context::{Self, TxContext};

    /// Fixed price market object
    struct FixedBidMarket<phantom FT> has store {
        /// `FixedBidMarket` ID
        id: UID,
        /// Fixed price denominated in fungible-token, `FT`
        price: u64,
        /// `Warehouse` or `Factory` that the market will redeem from
        venue_id: ID,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    struct FixedBidDfKey has store, copy, drop {}

    // === Init functions ===

    /// Create a new `FixedBidMarket<FT>`
    ///
    /// Price is denominated in fungible token, `FT`, such as SUI.
    ///
    /// Requires that `Inventory` with given ID exists on the `Listing` that
    /// this market will be inserted into.
    public fun new<FT>(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        price: u64,
        ctx: &mut TxContext,
    ): FixedBidMarket<FT> {
        venue_v2::assert_launch_cap(venue, launch_cap);

        FixedBidMarket {
            id: object::new(ctx),
            price,
            venue_id: object::id(venue),
        }
    }

    /// Creates a `FixedBidMarket<FT>` and transfers to transaction sender
    ///
    /// Price is denominated in fungible token, `FT`, such as SUI.
    ///
    /// Requires that `Inventory` with given ID exists on the `Listing` that
    /// this market will be inserted into.
    ///
    /// This market can later be consumed by `listing::init_venue` or
    /// `venue::init_venue` for later use in a launchpad listing.
    public entry fun init_market<FT>(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        price: u64,
        ctx: &mut TxContext,
    ) {
        let market = new<FT>(launch_cap, venue, price, ctx);

        let venue_uid = venue_v2::uid_mut(venue, launch_cap);

        df::add(venue_uid, FixedBidDfKey {}, market);
    }


    // === Entrypoints ===

    /// Buy NFT for non-whitelisted sale
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` does not exist, is not live, or is whitelisted or
    /// wallet does not have the necessary funds.
    public entry fun buy_nft<T: key + store, FT>(
        venue: &mut Venue,
        wallet: &mut Coin<FT>,
        buyer_safe: &mut Kiosk,
        request: VenueRequest,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        venue_v2::assert_venue_request(venue, &request);
        venue_v2::check_if_live(clock, venue);

        let nft = buy_nft_<T, FT>(listing, venue_id, wallet, ctx);
        ob_kiosk::deposit_as_owner(buyer_safe, nft, ctx);
    }


    /// Internal method to buy NFT
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` or associated `Inventory` does not exist or wallet
    /// does not have required funds.
    fun buy_nft_<T: key + store, FT>(
        listing: &mut Listing,
        venue_id: ID,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): T {
        let market = listing::borrow_market<FixedBidMarket<FT>>(
            listing, venue_id,
        );

        let price = market.price;
        let inventory_id = market.inventory_id;

        listing::buy_pseudorandom_nft<T, FT, FixedBidMarket<FT>, Witness>(
            Witness {},
            listing,
            inventory_id,
            venue_id,
            tx_context::sender(ctx),
            price,
            coin::balance_mut(wallet),
            ctx,
        )
    }

    // === Modifier Functions ===

    /// Change market price
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not `Listing` admin.
    public entry fun set_price<FT>(
        listing: &mut Listing,
        venue_id: ID,
        new_price: u64,
        ctx: &mut TxContext,
    ) {
        listing::assert_listing_admin(listing, ctx);

        let market =
            listing::market_internal_mut<FixedBidMarket<FT>, Witness>(
                Witness {}, listing, venue_id
            );

        market.price = new_price;
    }

    // === Getter Functions ===

    /// Return market price
    public fun price<FT>(market: &FixedBidMarket<FT>): u64 {
        market.price
    }
}
