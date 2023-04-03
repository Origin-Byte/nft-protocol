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
    use nft_protocol::venue_v2::{Self, Venue, NftCert};

    // use nft_protocol::listing::{Self, Listing};
    use nft_protocol::market_whitelist::{Self, Certificate};
    use nft_protocol::ob_kiosk;
    use sui::coin::{Self, Coin};
    use sui::kiosk::Kiosk;
    use sui::clock::Clock;
    use sui::transfer::public_transfer;
    use sui::dynamic_field as df;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};

    const EMAX_BUY_QUANTITY_SURPASSED: u64 = 1;

    /// Fixed price market object
    struct FixedBidMarket<phantom FT> has store {
        /// `FixedBidMarket` ID
        id: UID,
        /// Fixed price denominated in fungible-token, `FT`
        price: u64,
        max_buy: u64,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    struct FixedBidDfKey has store, copy, drop {}

    // === Init functions ===

    // TODO: make this public but access to venue permissioned
    /// Create a new `FixedBidMarket<FT>`
    ///
    /// Price is denominated in fungible token, `FT`, such as SUI.
    ///
    /// Requires that `Inventory` with given ID exists on the `Listing` that
    /// this market will be inserted into.
    fun new<FT>(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        price: u64,
        max_buy: u64,
        ctx: &mut TxContext,
    ): FixedBidMarket<FT> {
        venue_v2::assert_launch_cap(venue, launch_cap);

        FixedBidMarket {
            id: object::new(ctx),
            price,
            max_buy
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
        max_buy: u64,
        ctx: &mut TxContext,
    ) {
        let market = new<FT>(launch_cap, venue, price, max_buy, ctx);

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
    public entry fun buy_nft_cert_and_transfer<T: key + store, FT>(
        venue: &mut Venue,
        wallet: &mut Coin<FT>,
        // TODO: Put Quantity and Receiver inside VenueRequest to reduce params
        quantity: u64,
        // Receiver is not sender necessarily to allow for burner wallets
        receiver: address,
        request: VenueRequest,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        venue_v2::assert_venue_request(venue, &request);
        venue_v2::check_if_live(clock, venue);

        let cert = buy_nft_cert_<T, FT>(venue, wallet, quantity, receiver, ctx);
        public_transfer(cert, receiver);
    }

    /// Internal method to buy NFT
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` or associated `Inventory` does not exist or wallet
    /// does not have required funds.
    public fun buy_nft_cert<T: key + store, FT>(
        venue: &mut Venue,
        wallet: &mut Coin<FT>,
        // TODO: Put Quantity and Receiver inside VenueRequest to reduce params
        quantity: u64,
        receiver: address,
        request: VenueRequest,
        clock: &Clock,
        ctx: &mut TxContext,
    ): NftCert {
        venue_v2::assert_venue_request(venue, &request);
        venue_v2::check_if_live(clock, venue);

        buy_nft_cert_<T, FT>(venue, wallet, quantity, receiver, ctx)
    }


    /// Internal method to buy NFT
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` or associated `Inventory` does not exist or wallet
    /// does not have required funds.
    fun buy_nft_cert_<T: key + store, FT>(
        venue: &mut Venue,
        wallet: &mut Coin<FT>,
        quantity: u64,
        receiver: address,
        ctx: &mut TxContext,
    ): NftCert {
        let market = venue_v2::get_df<FixedBidDfKey, FixedBidMarket<FT>>(
            venue,
            FixedBidDfKey {}
        );

        assert!(quantity <= market.max_buy, EMAX_BUY_QUANTITY_SURPASSED);

        venue_v2::decrement_supply_if_any(Witness {}, venue, quantity);

        venue_v2::pay<Witness, FT, T>(
            Witness {},
            venue,
            coin::balance_mut(wallet),
            market.price,
            quantity,
        );

        // TODO: Allow for burner wallets
        venue_v2::redeem_generic_cert(
            Witness {},
            venue,
            receiver,
            quantity,
            ctx
        )
    }

    // === Modifier Functions ===

    /// Change market price
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not `Listing` admin.
    public entry fun set_price<FT>(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        new_price: u64,
    ) {
        venue_v2::assert_launch_cap(venue, launch_cap);

        let market = venue_v2::get_df_mut<FixedBidDfKey, FixedBidMarket<FT>>(
            venue,
            launch_cap,
            FixedBidDfKey {}
        );

        market.price = new_price;
    }

    /// Change max_buy quantity
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not `Listing` admin.
    public entry fun set_max_buy<FT>(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        new_max_buy: u64,
    ) {
        venue_v2::assert_launch_cap(venue, launch_cap);

        let market = venue_v2::get_df_mut<FixedBidDfKey, FixedBidMarket<FT>>(
            venue,
            launch_cap,
            FixedBidDfKey {}
        );

        market.max_buy = new_max_buy;
    }

    // === Getter Functions ===

    /// Return market price
    public fun price<FT>(market: &FixedBidMarket<FT>): u64 {
        market.price
    }

    /// Return market price
    public fun max_buy<FT>(market: &FixedBidMarket<FT>): u64 {
        market.max_buy
    }
}
