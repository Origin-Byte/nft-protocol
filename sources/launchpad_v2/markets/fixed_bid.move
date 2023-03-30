/// Module of `FixedPriceMarket`
///
/// It implements a fixed price sale configuration, where all NFTs in the
/// inventory get sold at a fixed price.
///
/// NFT creators can decide to use multiple markets to create a tiered market
/// sale by segregating NFTs by different sale segments.
module nft_protocol::fixed_bid_2 {
    use std::option::{Self, Option};
    use nft_protocol::listing::{Self, Listing};
    use nft_protocol::market_whitelist::{Self, Certificate};
    use nft_protocol::ob_kiosk::{Self, OwnerCap};
    use nft_protocol::venue_2::Venue;

    use sui::coin::{Self, Coin};
    use sui::kiosk::Kiosk;
    use sui::object::{Self, ID, UID};
    use sui::transfer::{public_transfer, public_share_object};
    use sui::tx_context::{Self, TxContext};

    /// Fixed price market object
    struct FixedPriceMarket<phantom FT> has key, store {
        /// `FixedPriceMarket` ID
        id: UID,
        /// Fixed price denominated in fungible-token, `FT`
        price: u64,
        // If option is None then the stock is unlimited
        stock: Option<u64>,
    }

    struct PurchaseReceipt {
        venue_id: ID,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    // === Init functions ===

    /// Create a new `FixedPriceMarket<FT>`
    ///
    /// Price is denominated in fungible token, `FT`, such as SUI.
    ///
    /// Requires that `Inventory` with given ID exists on the `Listing` that
    /// this market will be inserted into.
    public fun new<FT>(
        price: u64,
        stock: Option<u64>,
        ctx: &mut TxContext,
    ): FixedPriceMarket<FT> {
        FixedPriceMarket {
            id: object::new(ctx),
            price,
            stock,
        }
    }

    /// Creates a `FixedPriceMarket<FT>` and transfers to transaction sender
    ///
    /// Price is denominated in fungible token, `FT`, such as SUI.
    ///
    /// Requires that `Inventory` with given ID exists on the `Listing` that
    /// this market will be inserted into.
    ///
    /// This market can later be consumed by `listing::init_venue` or
    /// `venue::init_venue` for later use in a launchpad listing.
    public entry fun init_market<FT>(
        price: u64,
        stock: Option<u64>,
        ctx: &mut TxContext,
    ) {
        let market = new<FT>(price, stock, ctx);
        public_transfer(market, tx_context::sender(ctx));
    }

    // === Entrypoints ===

    /// Buy NFT for non-whitelisted sale
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` does not exist, is not live, or is whitelisted or
    /// wallet does not have the necessary funds.
    public entry fun buy_nft<FT>(
        auth: Auth,
        venue: &mut Venue,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let venue = listing::borrow_venue(listing, venue_id);
        venue::assert_is_live(venue);
        venue::assert_is_not_whitelisted(venue);

        let nft = pay_for_nft<T, FT>(listing, venue_id, wallet, ctx);
        public_transfer(nft, tx_context::sender(ctx));
    }

    /// Buy NFT for non-whitelisted sale
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` does not exist, is not live, or is whitelisted or
    /// wallet does not have the necessary funds.
    public entry fun buy_nft_into_safe<T: key + store, FT>(
        auth: Auth,
        venue: &mut Venue,
        wallet: &mut Coin<FT>,
        owner_cap: &OwnerCap,
        buyer_safe: &mut Kiosk,
        ctx: &mut TxContext,
    ) {
        let venue = listing::borrow_venue(listing, venue_id);
        venue::assert_is_live(venue);
        venue::assert_is_not_whitelisted(venue);

        let nft = pay_for_nft<T, FT>(listing, venue_id, wallet, ctx);
        ob_kiosk::deposit_as_owner(buyer_safe, owner_cap, nft);
    }

    /// Buy NFT for non-whitelisted sale.
    /// Deposits the NFT to a safe and transfers the ownership to the buyer.
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` does not exist, is not live, or is whitelisted or
    /// wallet does not have the necessary funds.
    public entry fun create_safe_and_buy_nft<T: key + store, FT>(
        auth: Auth,
        venue: &mut Venue,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let (buyer_safe, owner_cap) = ob_kiosk::new(ctx);
        buy_nft_into_safe<T, FT>(listing, venue_id, wallet, &owner_cap, &mut buyer_safe, ctx);

        ob_kiosk::transfer_cap_to_owner(
            owner_cap,
            &buyer_safe,
            tx_context::sender(ctx)
        );
        public_share_object(buyer_safe);
    }


    /// Internal method to buy NFT
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` or associated `Inventory` does not exist or wallet
    /// does not have required funds.
    fun pay_for_nft<FT>(
        listing: &mut Listing,
        venue_id: ID,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): PurchaseReceipt {
        let market = listing::borrow_market<FixedPriceMarket<FT>>(
            listing, venue_id,
        );

        let price = market.price;
        let inventory_id = market.inventory_id;

        listing::buy_pseudorandom_nft<T, FT, FixedPriceMarket<FT>, Witness>(
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
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        new_price: u64,
        ctx: &mut TxContext,
    ) {
        listing::assert_listing_admin(listing, ctx);

        let market =
            listing::market_internal_mut<FixedPriceMarket<FT>, Witness>(
                Witness {}, listing, venue_id
            );

        market.price = new_price;
    }

    // === Getter Functions ===

    /// Return market price
    public fun price<FT>(market: &FixedPriceMarket<FT>): u64 {
        market.price
    }
}
