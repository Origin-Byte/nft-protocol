/// Module of `LimitedFixedPriceMarket`
///
/// `LimitedFixedPriceMarket` functions as a `FixedPriceMarket` but allows
/// limiting the amount of NFTs that an address is allowed to buy from it.
///
/// It implements a fixed price sale configuration, where all NFTs in the
/// inventory get sold at a fixed price.
///
/// NFT creators can decide to use multiple markets to create a tiered market
/// sale by segregating NFTs by different sale segments.
module nft_protocol::limited_fixed_price {
    use std::option;

    use sui::balance;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer::{transfer, share_object};
    use sui::vec_map::{Self, VecMap};

    use nft_protocol::inventory;
    use nft_protocol::listing::{Self, Listing};
    use nft_protocol::market_whitelist::{Self, Certificate};
    use nft_protocol::nft::Nft;
    use nft_protocol::safe;
    use nft_protocol::venue;

    /// Limit of NFTs withdrawn from the market was exceeded
    ///
    /// Call `limited_fixed_price::set_limit` to increase limit.
    const EEXCEEDED_LIMIT: u64 = 1;

    /// Tried to decrease limit
    ///
    /// `limited_fixed_price::set_limit` may only be used to increase limit.
    const EDECREASED_LIMIT: u64 = 2;

    /// Fixed price market object
    struct LimitedFixedPriceMarket<phantom FT> has key, store {
        /// `LimitedFixedPriceMarket` ID
        id: UID,
        /// Limit of how many NFTs each account is allowed to buy from this
        /// market
        limit: u64,
        /// Fixed price denominated in fungible-token, `FT`
        price: u64,
        /// `Warehouse` or `Factory` that the market will redeem from
        inventory_id: ID,
        /// Stores the withdraw count for each address
        addresses: VecMap<address, u64>,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    // === Init functions ===

    /// Create a new `LimitedFixedPriceMarket<FT>`
    ///
    /// Price is denominated in fungible token, `FT`, such as SUI.
    ///
    /// Requires that `Inventory` with given ID exists on the `Listing` that
    /// this market will be inserted into.
    public fun new<FT>(
        inventory_id: ID,
        limit: u64,
        price: u64,
        ctx: &mut TxContext,
    ): LimitedFixedPriceMarket<FT> {
        LimitedFixedPriceMarket {
            id: object::new(ctx),
            limit,
            price,
            inventory_id,
            addresses: vec_map::empty(),
        }
    }

    /// Creates a `LimitedFixedPriceMarket<FT>` and transfers to transaction sender
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
        limit: u64,
        price: u64,
        ctx: &mut TxContext,
    ) {
        let market = new<FT>(inventory_id, limit, price, ctx);
        transfer(market, tx_context::sender(ctx));
    }

    /// Initializes a `Venue` with `LimitedFixedPriceMarket<FT>`
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
        limit: u64,
        price: u64,
        ctx: &mut TxContext,
    ) {
        create_venue<C, FT>(
            listing, inventory_id, is_whitelisted, limit, price, ctx,
        );
    }

    /// Creates a `Venue` with `LimitedFixedPriceMarket<FT>`
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
        limit: u64,
        price: u64,
        ctx: &mut TxContext,
    ): ID {
        listing::assert_inventory<C>(listing, inventory_id);

        let market = new<FT>(inventory_id, limit, price, ctx);
        listing::create_venue(listing, market, is_whitelisted, ctx)
    }

    /// Returns how many NFTs the given address bought from the market
    public fun borrow_count<FT>(
        market: &LimitedFixedPriceMarket<FT>,
        who: address,
    ): u64 {
        let idx_opt = vec_map::get_idx_opt(&market.addresses, &who);
        if (option::is_some(&idx_opt)) {
            let idx = option::destroy_some(idx_opt);
            let (_, count) =
                vec_map::get_entry_by_idx(&market.addresses, idx);
            *count
        } else {
            0
        }
    }

    /// Increments count while enforcing market limit
    ///
    /// #### Panics
    ///
    /// Panics if limit is violated
    public fun increment_count<FT>(
        market: &mut LimitedFixedPriceMarket<FT>,
        who: address
    ) {
        let idx_opt = vec_map::get_idx_opt(&market.addresses, &who);
        if (option::is_some(&idx_opt)) {
            let idx = option::destroy_some(idx_opt);
            let (_, count) =
                vec_map::get_entry_by_idx_mut(&mut market.addresses, idx);
            *count = *count + 1;
            assert_limit(market, *count);
        } else {
            vec_map::insert(&mut market.addresses, who, 1);
            assert_limit(market, 1);
        };
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
        let venue = listing::venue_internal_mut<
            LimitedFixedPriceMarket<FT>, Witness
        >(
            Witness {}, listing, venue_id
        );
        let market =
            venue::borrow_market_mut<LimitedFixedPriceMarket<FT>>(venue);

        let owner = tx_context::sender(ctx);
        increment_count(market, owner);

        let funds = balance::split(coin::balance_mut(wallet), market.price);

        let inventory_id = market.inventory_id;
        let inventory = listing::inventory_internal_mut<
            C, LimitedFixedPriceMarket<FT>, Witness
        >(
            Witness {}, listing, venue_id, inventory_id
        );

        let nft = inventory::redeem_nft(inventory, owner, ctx);

        listing::pay(listing, funds, 1);

        nft
    }

    // === Modifier Functions ===

    /// Change market limit
    ///
    /// Limit can only be increased.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not `Listing` admin or if limit was
    /// decreased.
    public entry fun set_limit<FT>(
        listing: &mut Listing,
        venue_id: ID,
        new_limit: u64,
        ctx: &mut TxContext,
    ) {
        listing::assert_listing_admin(listing, ctx);

        let venue = listing::venue_internal_mut<
            LimitedFixedPriceMarket<FT>, Witness
        >(
            Witness {}, listing, venue_id
        );

        let market =
            venue::borrow_market_mut<LimitedFixedPriceMarket<FT>>(venue);

        assert!(new_limit >= market.limit, EDECREASED_LIMIT);

        market.limit = new_limit;
    }

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

        let venue = listing::venue_internal_mut<
            LimitedFixedPriceMarket<FT>, Witness
        >(
            Witness {}, listing, venue_id
        );

        let market =
            venue::borrow_market_mut<LimitedFixedPriceMarket<FT>>(venue);

        market.price = new_price;
    }

    // === Getter Functions ===

    /// Return market limit
    public fun limit<FT>(market: &LimitedFixedPriceMarket<FT>): u64 {
        market.limit
    }

    /// Return market price
    public fun price<FT>(market: &LimitedFixedPriceMarket<FT>): u64 {
        market.price
    }

    // === Assertions ===

    /// Asserts that limit does not violate market limit
    ///
    /// #### Panics
    ///
    /// Panics if limit is greater than market limit.
    public fun assert_limit<FT>(
        market: &LimitedFixedPriceMarket<FT>,
        limit: u64,
    ) {
        assert!(limit <= market.limit, EEXCEEDED_LIMIT)
    }
}
