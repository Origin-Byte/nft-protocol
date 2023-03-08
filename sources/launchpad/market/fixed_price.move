/// Module of `FixedPriceMarket`
///
/// It implements a fixed price sale configuration, where all NFTs in the
/// inventory get sold at a fixed price.
///
/// NFT creators can decide to use multiple markets to create a tiered market
/// sale by segregating NFTs by different sale segments.
module nft_protocol::fixed_price {
    use std::ascii::String;
    use std::type_name;

    use sui::balance;
    use sui::coin::{Self, Coin};
    use sui::event;
    use sui::object::{Self, ID, UID};
    use sui::transfer::{transfer, share_object};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::inventory;
    use nft_protocol::listing::{Self, Listing};
    use nft_protocol::market_whitelist::{Self, Certificate};
    use nft_protocol::nft::Nft;
    use nft_protocol::safe;
    use nft_protocol::venue;

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

    // === Events ===

    struct NftSoldEvent has copy, drop {
        nft: ID,
        price: u64,
        ft_type: String,
        nft_type: String,
        buyer: address,
    }

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
        transfer(market, tx_context::sender(ctx));
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
    public entry fun buy_nft<C, FT>(
        listing: &mut Listing,
        venue_id: ID,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let venue = listing::borrow_venue(listing, venue_id);
        venue::assert_is_live(venue);
        venue::assert_is_not_whitelisted(venue);

        let nft = buy_nft_<C, FT>(listing, venue_id, wallet, ctx);
        transfer(nft, tx_context::sender(ctx));
    }

    /// Buy NFT for non-whitelisted sale
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` does not exist, is not live, or is whitelisted or
    /// wallet does not have the necessary funds.
    public entry fun buy_nft_into_safe<C, FT>(
        listing: &mut Listing,
        venue_id: ID,
        wallet: &mut Coin<FT>,
        buyer_safe: &mut safe::Safe,
        ctx: &mut TxContext,
    ) {
        let venue = listing::borrow_venue(listing, venue_id);
        venue::assert_is_live(venue);
        venue::assert_is_not_whitelisted(venue);

        let nft = buy_nft_<C, FT>(listing, venue_id, wallet, ctx);
        safe::deposit_nft(nft, buyer_safe, ctx);
    }

    /// Buy NFT for non-whitelisted sale.
    /// Deposits the NFT to a safe and transfers the ownership to the buyer.
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` does not exist, is not live, or is whitelisted or
    /// wallet does not have the necessary funds.
    public entry fun create_safe_and_buy_nft<C, FT>(
        listing: &mut Listing,
        venue_id: ID,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let (buyer_safe, owner_cap) = safe::new(ctx);
        buy_nft_into_safe<C, FT>(listing, venue_id, wallet, &mut buyer_safe, ctx);
        transfer(owner_cap, tx_context::sender(ctx));
        share_object(buyer_safe);
    }

    /// Buy NFT for whitelisted sale
    ///
    /// #### Panics
    ///
    /// - If `Venue` does not exist, is not live, or is not whitelisted
    /// - If whitelist `Certificate` was not issued for given market
    public entry fun buy_whitelisted_nft<C, FT>(
        listing: &mut Listing,
        venue_id: ID,
        wallet: &mut Coin<FT>,
        whitelist_token: Certificate,
        ctx: &mut TxContext,
    ) {
        let venue = listing::borrow_venue(listing, venue_id);
        venue::assert_is_live(venue);
        venue::assert_is_whitelisted(venue);
        market_whitelist::assert_certificate(&whitelist_token, venue_id);

        market_whitelist::burn(whitelist_token);

        let nft = buy_nft_<C, FT>(listing, venue_id, wallet, ctx);
        transfer(nft, tx_context::sender(ctx));
    }

    /// Buy NFT for whitelisted sale
    /// Deposits the NFT to a safe and transfers the ownership to the buyer.
    ///
    /// #### Panics
    ///
    /// - If `Venue` does not exist, is not live, or is not whitelisted
    /// - If whitelist `Certificate` was not issued for given market
    public entry fun buy_whitelisted_nft_into_safe<C, FT>(
        listing: &mut Listing,
        venue_id: ID,
        wallet: &mut Coin<FT>,
        safe: &mut safe::Safe,
        whitelist_token: Certificate,
        ctx: &mut TxContext,
    ) {
        let venue = listing::borrow_venue(listing, venue_id);
        venue::assert_is_live(venue);
        venue::assert_is_whitelisted(venue);
        market_whitelist::assert_certificate(&whitelist_token, venue_id);

        market_whitelist::burn(whitelist_token);

        let nft = buy_nft_<C, FT>(listing, venue_id, wallet, ctx);
        safe::deposit_nft(nft, safe, ctx);
    }

    /// Buy NFT for whitelisted sale
    /// Deposits the NFT to a safe and transfers the ownership to the buyer.
    ///
    /// #### Panics
    ///
    /// - If `Venue` does not exist, is not live, or is not whitelisted
    /// - If whitelist `Certificate` was not issued for given market
    public entry fun create_safe_and_buy_whitelisted_nft<C, FT>(
        listing: &mut Listing,
        venue_id: ID,
        wallet: &mut Coin<FT>,
        whitelist_token: Certificate,
        ctx: &mut TxContext,
    ) {
        let (buyer_safe, owner_cap) = safe::new(ctx);
        buy_whitelisted_nft_into_safe<C, FT>(
            listing,
            venue_id,
            wallet,
            &mut buyer_safe,
            whitelist_token,
            ctx,
        );
        transfer(owner_cap, tx_context::sender(ctx));
        share_object(buyer_safe);
    }

    /// Internal method to buy NFT
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` or associated `Inventory` does not exist or wallet
    /// does not have required funds.
    fun buy_nft_<C, FT>(
        listing: &mut Listing,
        venue_id: ID,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): Nft<C> {
        let venue = listing::borrow_venue(listing, venue_id);
        let market =
            venue::borrow_market<FixedPriceMarket<FT>>(venue);
        let market_price = market.price;

        let funds = balance::split(coin::balance_mut(wallet), market_price);

        let inventory_id = market.inventory_id;
        let inventory =
            listing::inventory_internal_mut<C, FixedPriceMarket<FT>, Witness>(
                Witness {}, listing, venue_id, inventory_id
            );

        let owner = tx_context::sender(ctx);
        let nft = inventory::redeem_nft(inventory, owner, ctx);

        event::emit(NftSoldEvent {
            nft: object::id(&nft),
            price: market_price,
            ft_type: *type_name::borrow_string(&type_name::get<FT>()),
            nft_type: *type_name::borrow_string(&type_name::get<C>()),
            buyer: owner,
        });

        listing::pay(listing, funds, 1);

        nft
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

        let venue =
            listing::venue_internal_mut<FixedPriceMarket<FT>, Witness>(
                Witness {}, listing, venue_id
            );

        let market =
            venue::borrow_market_mut<FixedPriceMarket<FT>>(venue);

        market.price = new_price;
    }

    // === Getter Functions ===

    /// Return market price
    public fun price<FT>(market: &FixedPriceMarket<FT>): u64 {
        market.price
    }
}
