/// Module of `FixedBidMarket`
///
/// It implements a fixed price sale configuration, where all NFTs in the
/// inventory get sold at a fixed price.
///
/// NFT creators can decide to use multiple markets to create a tiered market
/// sale by segregating NFTs by different sale segments.
module ob_launchpad_v2::fixed_bid {
    use ob_launchpad_v2::launchpad::LaunchCap;
    use ob_launchpad_v2::auth_request::{Self, AuthRequest};
    use ob_launchpad_v2::venue::{Self, Venue};
    use ob_launchpad_v2::certificate::{Self, NftCertificate};

    use sui::coin::{Self, Coin};
    use sui::dynamic_field as df;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    const EMAX_BUY_QUANTITY_SURPASSED: u64 = 1;

    /// Fixed price market object
    struct FixedBidMarket<phantom FT> has store {
        /// `FixedBidMarket` ID
        id: UID,
        /// Fixed price denominated in fungible-token, `FT`
        price: u64,
        /// Maximum number of NFTs one can buy in a bulk
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
        price: u64,
        max_buy: u64,
        ctx: &mut TxContext,
    ): FixedBidMarket<FT> {
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
        // TODO: Need to assert the market policy
        venue::assert_launch_cap(venue, launch_cap);
        let market = new<FT>(price, max_buy, ctx);
        let venue_uid = venue::uid_mut(venue, launch_cap);

        df::add(venue_uid, FixedBidDfKey {}, market);
    }


    // === Entrypoints ===

    /// Method to buy NFT
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` or associated `Inventory` does not exist or wallet
    /// does not have required funds.
    public fun buy_nft_cert<T: key + store, FT>(
        venue: &mut Venue,
        wallet: &mut Coin<FT>,
        // TODO: Put Quantity and Receiver inside AuthRequest to reduce params
        quantity: u64,
        request: AuthRequest,
        ctx: &mut TxContext,
    ): NftCertificate {
        venue::assert_request(venue, &request);

        auth_request::confirm(request, venue::get_auth_policy(venue));
        buy_nft_cert_<T, FT>(venue, wallet, quantity, ctx)
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
        ctx: &mut TxContext,
    ): NftCertificate {
        venue::increment_supply_if_any(Witness {}, venue, quantity);

        let market = venue::get_df<FixedBidDfKey, FixedBidMarket<FT>>(
            venue,
            FixedBidDfKey {}
        );

        assert_quantity(market, quantity);

        venue::pay<Witness, FT, T>(
            Witness {},
            venue,
            coin::into_balance(coin::split(wallet, market.price, ctx)),
            quantity,
        );

        // TODO: Allow for burner wallets
        certificate::get_redeem_certificate(
            Witness {},
            venue,
            tx_context::sender(ctx),
            quantity,
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
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        new_price: u64,
    ) {
        venue::assert_launch_cap(venue, launch_cap);

        let market = venue::get_df_mut<FixedBidDfKey, FixedBidMarket<FT>>(
            venue,
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
        venue::assert_launch_cap(venue, launch_cap);

        let market = venue::get_df_mut<FixedBidDfKey, FixedBidMarket<FT>>(
            venue,
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

    public fun assert_quantity<FT>(market: &FixedBidMarket<FT>, quantity: u64) {
        assert!(quantity <= market.max_buy, EMAX_BUY_QUANTITY_SURPASSED);
    }
}
