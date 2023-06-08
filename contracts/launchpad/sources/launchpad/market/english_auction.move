/// Module implements the `EnglishAuction` primitive intended to be embedded
/// within primary and secondary markets
module ob_launchpad::english_auction {
    use sui::transfer;
    use sui::object::ID;
    use sui::kiosk::Kiosk;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::tx_context::{Self, TxContext};

    use ob_kiosk::ob_kiosk;

    use ob_launchpad::venue::{Self, Venue};
    use ob_launchpad::listing::{Self, Listing};
    use ob_launchpad::warehouse::{Self, Warehouse};
    use ob_launchpad::inventory::{Self, Inventory};
    use ob_launchpad::market_whitelist::{Self, Certificate};

    /// Bid was lower than existing bid
    ///
    /// Call `english_auction::create_bid` with a higher bid.
    const EBidTooLow: u64 = 1;

    /// Auction was already concluded
    const EAuctionConcluded: u64 = 2;

    /// Auction was not concluded
    const EAuctionNotConcluded: u64 = 3;

    /// Tried to claim NFT by transaction sender that was not auction winner
    const ECannotClaim: u64 = 4;

    /// Auction bid
    struct Bid<phantom FT> has store {
        bidder: address,
        offer: Balance<FT>,
    }

    /// English auction object
    ///
    /// Handles the logic for running an english auction
    struct EnglishAuction<T, phantom FT> has store {
        /// Owned NFT subject of the auction
        nft: T,
        /// Best bid for `nft`
        ///
        /// Must always exist such that auction may be concluded at any time
        bid: Bid<FT>,
        /// Whether auction has concluded
        concluded: bool,
    }

    struct MarketKey has copy, drop, store {}

    /// Create `EnglishAuction` from NFT `T` with bids denominated in fungible
    /// token `FT`
    public fun new<T, FT>(
        nft: T,
        bid: Bid<FT>,
    ): EnglishAuction<T, FT> {
        EnglishAuction { nft, bid, concluded: false }
    }

    /// Create a new auction `Bid` for fungible token `FT`
    public fun bid_from_balance<FT>(
        offer: Balance<FT>,
        ctx: &mut TxContext,
    ): Bid<FT> {
        Bid {
            bidder: tx_context::sender(ctx),
            offer,
        }
    }

    /// Create a new auction `Bid` for fungible token `FT`
    ///
    /// #### Panics
    ///
    /// Panics if there are insufficient funds in `Coin<FT>`
    public fun bid_from_coin<FT>(
        wallet: &mut Coin<FT>,
        bid: u64,
        ctx: &mut TxContext,
    ): Bid<FT> {
        bid_from_balance(
            balance::split(coin::balance_mut(wallet), bid),
            ctx,
        )
    }

    /// Helper method to create `EnglishAuction` from `warehouse::Warehouse`
    ///
    /// Requires an immediate placement of a `Bid` as the NFT will be withdrawn
    /// from the `Warehouse`.
    ///
    /// #### Panics
    ///
    /// Panics if NFT with ID does not exist.
    public fun from_warehouse<T: key + store, FT>(
        warehouse: &mut Warehouse<T>,
        nft_id: ID,
        bid: Bid<FT>,
    ): EnglishAuction<T, FT> {
        new(warehouse::redeem_nft_with_id(warehouse, nft_id), bid)
    }

    /// Helper method to create `EnglishAuction` from `inventory::Inventory`
    ///
    /// Requires an immediate placement of a `Bid` as the NFT will be withdrawn
    /// from the `Inventory`.
    ///
    /// #### Panics
    ///
    /// Panics if underlying `Inventory` type is not a `Warehouse` or NFT with
    /// ID does not exist.
    public fun from_inventory<T: key + store, FT>(
        inventory: &mut Inventory<T>,
        nft_id: ID,
        bid: Bid<FT>,
    ): EnglishAuction<T, FT> {
        new(inventory::redeem_nft_with_id(inventory, nft_id), bid)
    }

    /// Initializes a `Venue` with `EnglishAuction<FT>`
    public entry fun init_auction<T: key + store, FT>(
        listing: &mut Listing,
        wallet: &mut Coin<FT>,
        inventory_id: ID,
        is_whitelisted: bool,
        nft_id: ID,
        bid: u64,
        ctx: &mut TxContext,
    ) {
        create_auction<T, FT>(
            listing, wallet, is_whitelisted, inventory_id, nft_id, bid, ctx
        );
    }

    /// Creates a `Venue` with `EnglishAuction<FT>`
    public fun create_auction<T: key + store, FT>(
        listing: &mut Listing,
        wallet: &mut Coin<FT>,
        is_whitelisted: bool,
        inventory_id: ID,
        nft_id: ID,
        bid: u64,
        ctx: &mut TxContext,
    ): ID {
        let bid = bid_from_coin(wallet, bid, ctx);
        let inventory =
            listing::inventory_admin_mut<T>(listing, inventory_id, ctx);

        let auction = from_inventory(inventory, nft_id, bid);

        listing::create_venue(listing, MarketKey {}, auction, is_whitelisted, ctx)
    }

    /// Borrows `DutchAuctionMarket<FT>` from `Venue`
    public fun borrow_market<T: key + store, FT>(
        venue: &Venue,
    ): &EnglishAuction<T, FT> {
        venue::borrow_market(MarketKey {}, venue)
    }

    // === Entrypoints ===

    /// Creates a bid on the NFT
    public entry fun create_bid<T: key + store, FT>(
        listing: &mut Listing,
        wallet: &mut Coin<FT>,
        venue_id: ID,
        bid: u64,
        ctx: &mut TxContext,
    ) {
        let venue = listing::venue_internal_mut<EnglishAuction<T, FT>, MarketKey>(
            listing, MarketKey {}, venue_id
        );

        venue::assert_is_live(venue);
        venue::assert_is_not_whitelisted(venue);

        create_bid_<T, FT>(
            venue::borrow_market_mut(MarketKey {}, venue),
            balance::split(coin::balance_mut(wallet), bid),
            ctx,
        );
    }

    /// Creates a bid on NFT for whitelisted auction
    public entry fun create_bid_whitelisted<T: key + store, FT>(
        listing: &mut Listing,
        wallet: &mut Coin<FT>,
        venue_id: ID,
        whitelist_token: Certificate,
        bid: u64,
        ctx: &mut TxContext,
    ) {
        let venue = listing::venue_internal_mut<EnglishAuction<T, FT>, MarketKey>(
            listing, MarketKey {}, venue_id
        );

        venue::assert_is_live(venue);
        venue::assert_is_whitelisted(venue);

        market_whitelist::assert_certificate(&whitelist_token, venue_id);

        create_bid_<T, FT>(
            venue::borrow_market_mut(MarketKey {}, venue),
            balance::split(coin::balance_mut(wallet), bid),
            ctx,
        );

        market_whitelist::burn(whitelist_token);
    }

    fun create_bid_<T: key + store, FT>(
        auction: &mut EnglishAuction<T, FT>,
        bid: Balance<FT>,
        ctx: &mut TxContext,
    ) {
        assert!(
            balance::value(&bid) > balance::value(&auction.bid.offer),
            EBidTooLow,
        );

        assert_not_concluded(auction);

        // Transfer balance of old bid back to original bidder
        let old_bid = balance::withdraw_all(&mut auction.bid.offer);
        transfer::public_transfer(
            coin::from_balance(old_bid, ctx), auction.bid.bidder,
        );

        // Update `Bid`
        auction.bid.bidder = tx_context::sender(ctx);
        balance::join(&mut auction.bid.offer, bid);
    }

    /// Conclude english auction
    ///
    /// This does not actually resolve
    public entry fun conclude_auction<T: key + store, FT>(
        listing: &mut Listing,
        venue_id: ID,
        ctx: &mut TxContext,
    ) {
        listing::assert_listing_admin_or_member(listing, ctx);

        let auction: &mut EnglishAuction<T, FT> = listing::market_internal_mut(
            listing, MarketKey {}, venue_id,
        );

        assert_not_concluded(auction);
        auction.concluded = true;
    }

    /// Claim NFT after auction has concluded and transfer to transaction
    /// sender
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` does not exist or has not yet concluded.
    public entry fun claim_nft<T: key + store, FT>(
        listing: &mut Listing,
        venue_id: ID,
        ctx: &mut TxContext,
    ) {
        let (kiosk, _) = ob_kiosk::new(ctx);
        claim_nft_into_kiosk<T, FT>(listing, venue_id, &mut kiosk, ctx);
        transfer::public_share_object(kiosk);
    }

    /// Claim NFT into kiosk after auction has concluded
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` does not exist or has not yet concluded.
    public entry fun claim_nft_into_kiosk<T: key + store, FT>(
        listing: &mut Listing,
        venue_id: ID,
        buyer_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ) {
        let nft = claim_nft_<T, FT>(listing, venue_id, ctx);
        ob_kiosk::deposit(buyer_kiosk, nft, ctx);
    }

    /// Claim NFT after auction has concluded
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` does not exist or has not yet concluded.
    fun claim_nft_<T: key + store, FT>(
        listing: &mut Listing,
        venue_id: ID,
        ctx: &mut TxContext,
    ): T {
        let venue = listing::remove_venue<EnglishAuction<T, FT>, MarketKey>(
            listing, MarketKey {}, venue_id
        );

        let auction: EnglishAuction<T, FT> = venue::delete(MarketKey {}, venue);
        assert_concluded(&auction);

        let (nft, bid) = delete(auction);

        let buyer = bid.bidder;
        assert!(buyer == tx_context::sender(ctx), ECannotClaim);

        let bid = delete_bid(bid);
        listing::pay_and_emit_sold_event(listing, &nft, bid, buyer);
        nft
    }

    /// Deconstruct the `EnglishAuction` struct
    public fun delete<T: key + store, FT>(
        auction: EnglishAuction<T, FT>,
    ): (T, Bid<FT>) {
        let EnglishAuction { nft, bid, concluded: _ } = auction;
        (nft, bid)
    }

    /// Deconstruct the `Bid` struct
    public fun delete_bid<FT>(bid: Bid<FT>): Balance<FT> {
        let Bid { bidder: _, offer } = bid;
        offer
    }

    // === Getter Functions ===

    /// Return current auction bid
    public fun current_bid<T, FT>(auction: &EnglishAuction<T, FT>): u64 {
        balance::value(&auction.bid.offer)
    }

    /// Return current auction bidder
    public fun current_bidder<T, FT>(
        auction: &EnglishAuction<T, FT>,
    ): address {
        auction.bid.bidder
    }

    /// Return whether auction is concluded
    public fun is_concluded<T, FT>(
        auction: &EnglishAuction<T, FT>,
    ): bool {
        auction.concluded
    }

    // === Assertions ===

    /// Assert that auction is not concluded
    ///
    /// #### Panics
    ///
    /// Panics if auction was not concluded
    public fun assert_concluded<T: key + store, FT>(
        auction: &EnglishAuction<T, FT>,
    ) {
        assert!(auction.concluded, EAuctionNotConcluded)
    }

    /// Assert that auction is not concluded
    ///
    /// #### Panics
    ///
    /// Panics if auction was concluded
    public fun assert_not_concluded<T: key + store, FT>(
        auction: &EnglishAuction<T, FT>,
    ) {
        assert!(!auction.concluded, EAuctionConcluded)
    }
}
