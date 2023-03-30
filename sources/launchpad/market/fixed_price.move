/// Module of `FixedPriceMarket`
///
/// It implements a fixed price sale configuration, where all NFTs in the
/// inventory get sold at a fixed price.
///
/// NFT creators can decide to use multiple markets to create a tiered market
/// sale by segregating NFTs by different sale segments.
module nft_protocol::fixed_price {
    use nft_protocol::listing::{Self, Listing};
    use nft_protocol::market_whitelist::{Self, Certificate};
    use nft_protocol::ob_kiosk::{Self, OwnerCap};
    use nft_protocol::venue;
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
        /// `Warehouse` or `Factory` that the market will redeem from
        inventory_id: ID,
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
        inventory_id: ID,
        price: u64,
        ctx: &mut TxContext,
    ): FixedPriceMarket<FT> {
        FixedPriceMarket {
            id: object::new(ctx),
            price,
            inventory_id,
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
        inventory_id: ID,
        price: u64,
        ctx: &mut TxContext,
    ) {
        let market = new<FT>(inventory_id, price, ctx);
        public_transfer(market, tx_context::sender(ctx));
    }

    /// Initializes a `Venue` with `FixedPriceMarket<FT>`
    ///
    /// Price is denominated in fungible token, `FT`, such as SUI.
    ///
    /// Requires that `Inventory` with given ID exists on the `Listing` that
    /// this market will be inserted into.
    ///
    /// Resultant `Venue` can later be consumed by `listing::add_venue` for
    /// later use in a launchpad listing.
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` with given ID does not exist on `Listing` or
    /// if transaction sender is not the `Listing` admin.
    public entry fun init_venue<C, FT>(
        listing: &mut Listing,
        inventory_id: ID,
        is_whitelisted: bool,
        price: u64,
        ctx: &mut TxContext,
    ) {
        create_venue<C, FT>(listing, inventory_id, is_whitelisted, price, ctx);
    }

    /// Creates a `Venue` with `FixedPriceMarket<FT>`
    ///
    /// Price is denominated in fungible token, `FT`, such as SUI.
    ///
    /// Requires that `Inventory` with given ID exists on the `Listing` that
    /// this market will be inserted into.
    ///
    /// Resultant `Venue` can later be consumed by `listing::add_venue` for
    /// later use in a launchpad listing.
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` with given ID does not exist on `Listing` or
    /// if transaction sender is not the `Listing` admin.
    public fun create_venue<C, FT>(
        listing: &mut Listing,
        inventory_id: ID,
        is_whitelisted: bool,
        price: u64,
        ctx: &mut TxContext,
    ): ID {
        listing::assert_inventory<C>(listing, inventory_id);

        let market = new<FT>(inventory_id, price, ctx);
        listing::create_venue(listing, market, is_whitelisted, ctx)
    }

    // === Entrypoints ===

    /// Buy NFT for non-whitelisted sale
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` does not exist, is not live, or is whitelisted or
    /// wallet does not have the necessary funds.
    public entry fun buy_nft<T: key + store, FT>(
        listing: &mut Listing,
        venue_id: ID,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let venue = listing::borrow_venue(listing, venue_id);
        venue::assert_is_live(venue);
        venue::assert_is_not_whitelisted(venue);

        let nft = buy_nft_<T, FT>(listing, venue_id, wallet, ctx);
        public_transfer(nft, tx_context::sender(ctx));
    }

    /// Buy NFT for non-whitelisted sale
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` does not exist, is not live, or is whitelisted or
    /// wallet does not have the necessary funds.
    public entry fun buy_nft_into_safe<T: key + store, FT>(
        listing: &mut Listing,
        venue_id: ID,
        wallet: &mut Coin<FT>,
        owner_cap: &OwnerCap,
        buyer_safe: &mut Kiosk,
        ctx: &mut TxContext,
    ) {
        let venue = listing::borrow_venue(listing, venue_id);
        venue::assert_is_live(venue);
        venue::assert_is_not_whitelisted(venue);

        let nft = buy_nft_<T, FT>(listing, venue_id, wallet, ctx);
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
        listing: &mut Listing,
        venue_id: ID,
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

    /// Buy NFT for whitelisted sale
    ///
    /// #### Panics
    ///
    /// - If `Venue` does not exist, is not live, or is not whitelisted
    /// - If whitelist `Certificate` was not issued for given market
    public entry fun buy_whitelisted_nft<T: key + store, FT>(
        listing: &mut Listing,
        venue_id: ID,
        wallet: &mut Coin<FT>,
        whitelist_token: Certificate,
        ctx: &mut TxContext,
    ) {
        let venue = listing::borrow_venue(listing, venue_id);
        venue::assert_is_live(venue);
        market_whitelist::assert_whitelist(&whitelist_token, venue);
        market_whitelist::burn(whitelist_token);

        let nft = buy_nft_<T, FT>(listing, venue_id, wallet, ctx);
        public_transfer(nft, tx_context::sender(ctx));
    }

    /// Buy NFT for whitelisted sale
    /// Deposits the NFT to a safe and transfers the ownership to the buyer.
    ///
    /// #### Panics
    ///
    /// - If `Venue` does not exist, is not live, or is not whitelisted
    /// - If whitelist `Certificate` was not issued for given market
    public entry fun buy_whitelisted_nft_into_safe<T: key + store, FT>(
        listing: &mut Listing,
        venue_id: ID,
        wallet: &mut Coin<FT>,
        owner_cap: &OwnerCap,
        safe: &mut Kiosk,
        whitelist_token: Certificate,
        ctx: &mut TxContext,
    ) {
        let venue = listing::borrow_venue(listing, venue_id);
        venue::assert_is_live(venue);
        market_whitelist::assert_whitelist(&whitelist_token, venue);
        market_whitelist::burn(whitelist_token);

        let nft = buy_nft_<T, FT>(listing, venue_id, wallet, ctx);
        ob_kiosk::deposit_as_owner(safe, owner_cap, nft);
    }

    /// Buy NFT for whitelisted sale
    /// Deposits the NFT to a safe and transfers the ownership to the buyer.
    ///
    /// #### Panics
    ///
    /// - If `Venue` does not exist, is not live, or is not whitelisted
    /// - If whitelist `Certificate` was not issued for given market
    public entry fun create_safe_and_buy_whitelisted_nft<T: key + store, FT>(
        listing: &mut Listing,
        venue_id: ID,
        wallet: &mut Coin<FT>,
        whitelist_token: Certificate,
        ctx: &mut TxContext,
    ) {
        let (buyer_safe, owner_cap) = ob_kiosk::new(ctx);
        buy_whitelisted_nft_into_safe<T, FT>(
            listing,
            venue_id,
            wallet,
            &owner_cap,
            &mut buyer_safe,
            whitelist_token,
            ctx,
        );

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
    fun buy_nft_<T: key + store, FT>(
        listing: &mut Listing,
        venue_id: ID,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): T {
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
        listing: &mut Listing,
        venue_id: ID,
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
