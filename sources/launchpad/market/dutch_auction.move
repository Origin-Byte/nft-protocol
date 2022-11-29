// TODO(https://github.com/Origin-Byte/nft-protocol/issues/80): Market slingshot is toggled globally
module nft_protocol::dutch_auction {
    //! Auction where bids are fungible tokens.
    //! Winning bids are awarded NFTs.

    use std::vector;

    use sui::pay;
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::object::{Self, UID, ID};

    use movemate::crit_bit::{Self, CB as CBTree};

    use nft_protocol::err;
    use nft_protocol::generic;
    use nft_protocol::launchpad::{Self, Launchpad, Trebuchet};
    use nft_protocol::outlet::{Self, Outlet};
    use nft_protocol::whitelist::{Self, Whitelist};

    struct DutchAuctionMarket has key, store {
        id: UID,
        /// The minimum price at which NFTs can be sold
        reserve_price: u64,
        /// A bid order stores amount of "T"okens the buyer is willing to
        /// purchase
        bids: CBTree<vector<Bid>>,
        /// Whether the auction is currently live
        live: bool,
        outlet: Outlet,
    }

    /// A bid for one NFT
    struct Bid has store {
        /// Amount is equal to the price that the bidder is ready to pay for
        /// one NFT.
        amount: Balance<SUI>,
        /// The address of the user who created this bid and who will receive
        /// an NFT in exchange for their tokens.
        owner: address,
    }

    // === Functions exposed to Witness Module ===

    public fun create_market<W: drop>(
        witness: W,
        launchpad: &mut Launchpad<W>,
        trebuchet: &mut Trebuchet,
        tier: u64,
        is_whitelisted: bool,
        reserve_price: u64,
        ctx: &mut TxContext
    ) {
        let outlet = outlet::create(
            tier,
            is_whitelisted,
            ctx,
        );

        let market = generic::new(ctx);

        generic::add_object(
            &mut market,
            DutchAuctionMarket {
                id: object::new(ctx),
                reserve_price,
                bids: crit_bit::empty(),
                live: false,
                outlet,
            }
        );

        launchpad::add_market(
            launchpad,
            trebuchet,
            market,
        );

    }

    // === Entrypoints ===

    /// Creates a bid in a FIFO manner, previous bids are retained
    public entry fun create_bid<T>(
        wallet: &mut Coin<SUI>,
        launchpad: &mut Launchpad<T>,
        trebuchet: &mut Trebuchet,
        market: &mut DutchAuctionMarket,
        price: u64,
        quantity: u64,
        ctx: &mut TxContext,
    ) {
        // One can only place bids on NFT certificates if the slingshot is live
        assert!(launchpad::live(launchpad, trebuchet), err::launchpad_not_live());

        // Infer that sales is NOT whitelisted
        assert!(!outlet::whitelisted(&market.outlet), err::sale_is_not_whitelisted());

        create_bid_(
            market,
            wallet,
            price,
            quantity,
            tx_context::sender(ctx)
        );
    }

    public entry fun create_bid_whitelisted<T>(
        wallet: &mut Coin<SUI>,
        launchpad: &mut Launchpad<T>,
        trebuchet: &mut Trebuchet,
        market: &mut DutchAuctionMarket,
        whitelist_token: Whitelist,
        price: u64,
        quantity: u64,
        ctx: &mut TxContext,
    ) {
        // One can only place bids on NFT certificates if the slingshot is live
        assert!(launchpad::live(launchpad, trebuchet), err::launchpad_not_live());

        // Infer that sales is whitelisted
        assert!(outlet::whitelisted(&market.outlet), err::sale_is_whitelisted());

        // Infer that whitelist token corresponds to correct sale outlet
        assert!(
            whitelist::sale_id(&whitelist_token) == outlet::id(&market.outlet),
            err::incorrect_whitelist_token()
        );

        create_bid_(
            market,
            wallet,
            price,
            quantity,
            tx_context::sender(ctx)
        );

        whitelist::burn_whitelist_token(whitelist_token);
    }

    /// Cancels a single bid at the given price level in a FIFO manner
    ///
    /// Bids can always be canceled no matter whether the auction is live.
    //
    // TODO(https://github.com/Origin-Byte/nft-protocol/issues/76):
    // Cancel all bids endpoint
    public entry fun cancel_bid<T>(
        wallet: &mut Coin<SUI>,
        launchpad: &mut Launchpad<T>,
        trebuchet: &mut Trebuchet,
        market: &mut DutchAuctionMarket,
        price: u64,
        ctx: &mut TxContext,
    ) {
        cancel_bid_(
            market,
            wallet,
            price,
            tx_context::sender(ctx)
        )
    }

    // === Modifier Functions ===

    /// Toggle the Slingshot's `live` to `true` therefore allowing participants
    /// to place bids on the NFT collection.
    ///
    /// Permissioned endpoint to be called by `admin`.
    public entry fun sale_on<T>(
        launchpad: &mut Launchpad<T>,
        slingshot: &mut Trebuchet,
        ctx: &mut TxContext
    ) {
        assert!(
            launchpad::admin(launchpad, slingshot) == tx_context::sender(ctx),
            err::wrong_launchpad_admin()
        );
        launchpad::sale_on(launchpad, slingshot);
    }

    /// Toggle the Slingshot's `live` to `false` therefore pausing the auction.
    /// This does not allocate any NFTs to bidders.
    ///
    /// Permissioned endpoint to be called by `admin`.
    public entry fun sale_off<T>(
        launchpad: &mut Launchpad<T>,
        slingshot: &mut Trebuchet,
        ctx: &mut TxContext
    ) {
        assert!(
            launchpad::admin(launchpad, slingshot) == tx_context::sender(ctx),
            err::wrong_launchpad_admin()
        );
        launchpad::sale_off(launchpad, slingshot);
    }

    /// Cancel the auction and toggle the Slingshot's `live` to `false`.
    /// All bids will be cancelled and refunded.
    ///
    /// Permissioned endpoint to be called by `admin`.
    public entry fun sale_cancel<T>(
        launchpad: &mut Launchpad<T>,
        slingshot: &mut Trebuchet,
        market: &mut DutchAuctionMarket,
        ctx: &mut TxContext
    ) {
        assert!(
            launchpad::admin(launchpad, slingshot) == tx_context::sender(ctx),
            err::wrong_launchpad_admin()
        );

        cancel_auction(market, ctx);


        launchpad::sale_off(launchpad, slingshot);
    }

    /// Conclude the auction and toggle the Slingshot's `live` to `false`.
    /// NFTs will be allocated to the winning biddeers.
    ///
    /// Permissioned endpoint to be called by `admin`.
    public entry fun sale_conclude<T>(
        launchpad: &mut Launchpad<T>,
        trebuchet: &mut Trebuchet,
        slingshot: &mut Trebuchet,
        market: &mut DutchAuctionMarket,
        ctx: &mut TxContext
    ) {
        assert!(
            launchpad::admin(launchpad, slingshot) == tx_context::sender(ctx),
            err::wrong_launchpad_admin()
        );

        let launchpad_id = launchpad::id(launchpad, slingshot);

        let receiver = launchpad::receiver(launchpad, slingshot);

        let nfts_to_sell = outlet::length(&market.outlet);

        conclude_auction(
            launchpad,
            trebuchet,
            market,
            launchpad_id,
            receiver,
            // TODO(https://github.com/Origin-Byte/nft-protocol/issues/63):
            // Investigate whether this logic should be paginated
            nfts_to_sell,
            ctx
        );

        launchpad::sale_off(launchpad, slingshot);
    }

    // === Private Functions ===

    fun create_bid_(
        auction: &mut DutchAuctionMarket,
        wallet: &mut Coin<SUI>,
        price: u64,
        quantity: u64,
        bidder: address,
    ) {
        assert!(
            price >= auction.reserve_price,
            err::order_price_below_reserve()
        );

        // Create price level if it does not exist
        if (!crit_bit::has_key(&auction.bids, (price as u128))) {
            crit_bit::insert(
                &mut auction.bids,
                (price as u128),
                vector::empty()
            );
        };

        let price_level =
            crit_bit::borrow_mut(&mut auction.bids, (price as u128));

        // Make `quantity` number of bids
        let index = 0;
        while (quantity > index) {
            let amount = balance::split(coin::balance_mut(wallet), price);
            vector::push_back(price_level, Bid { amount, owner: bidder });
            index = index + 1;
        }
    }

    /// Cancels a single order in a FIFO manner
    fun cancel_bid_(
        auction: &mut DutchAuctionMarket,
        wallet: &mut Coin<SUI>,
        price: u64,
        sender: address,
    ) {
        let bids = &mut auction.bids;

        assert!(
            crit_bit::has_key(bids, (price as u128)),
            err::order_does_not_exist()
        );

        let price_level = crit_bit::borrow_mut(bids, (price as u128));

        let bid_index = 0;
        let bid_count = vector::length(price_level);
        while (bid_count > bid_index) {
            let bid = vector::borrow(price_level, bid_index);
            if (bid.owner == sender) {
                break
            };

            bid_index = bid_index + 1;
        };

        assert!(bid_index < bid_count, err::order_owner_must_be_sender());

        let bid = vector::remove(price_level, bid_index);
        refund_bid(bid, wallet, &sender);
    }

    // Cancels all bids present on the auction book
    fun cancel_auction(book: &mut DutchAuctionMarket, ctx: &mut TxContext) {
        let bids = &mut book.bids;

        while (!crit_bit::is_empty(bids)) {
            let min_key = crit_bit::min_key(bids);
            let price_level = crit_bit::pop(bids, min_key);
            while (!vector::is_empty(&price_level)) {
                let bid = vector::pop_back(&mut price_level);

                // Since we do not have access to the original wallet
                // we must create a wallet wherein the bidder can be refunded.
                let wallet = coin::zero(ctx);
                let owner = bid.owner;
                refund_bid(bid, &mut wallet, &owner);

                transfer::transfer(wallet, owner);
            };

            vector::destroy_empty(price_level);
        }
    }

    fun refund_bid(bid: Bid, wallet: &mut Coin<SUI>, sender: &address) {
        let Bid { amount, owner } = bid;
        assert!(sender == &owner, err::order_owner_must_be_sender());

        balance::join(coin::balance_mut(wallet), amount);
    }

    fun conclude_auction<T>(
        launchpad: &mut Launchpad<T>,
        trebuchet: &mut Trebuchet,
        auction: &mut DutchAuctionMarket,
        launchpad_id: ID,
        receiver: address,
        // Use to specify how many NFTs will be transfered to the winning bids
        // during the `conclude_auction`. This functionality is used to avoid
        // hitting computational costs during large auction sales.
        //
        // To conclude the entire auction, the total number of NFTs in the sale
        // should be passed.
        nfts_to_sell: u64,
        ctx: &mut TxContext
    ) {
        let bids = &mut auction.bids;

        let fill_price = 0;
        let bids_to_fill = vector::empty();
        while (nfts_to_sell > 0 && !crit_bit::is_empty(bids)) {
            // Get key of maximum price level representing the price level from
            // which the next winning bid is extracted.
            let max_key = crit_bit::max_key(bids);
            let price_level = crit_bit::borrow_mut(bids, max_key);

            if (vector::is_empty(price_level)) {
                let price_level = crit_bit::pop(bids, max_key);
                vector::destroy_empty(price_level);
                continue
            };

            // There exists a bid we can match to an NFT
            // Match in FIFO order
            let bid = vector::remove(price_level, 0);

            fill_price = max_key;
            nfts_to_sell = nfts_to_sell - 1;
            vector::push_back(&mut bids_to_fill, bid);
        };

        while (!vector::is_empty(&bids_to_fill)) {
            let Bid {amount, owner} = vector::pop_back(&mut bids_to_fill);
            let funds = coin::from_balance(amount, ctx);

            pay::split_and_transfer<SUI>(
                &mut funds,
                // SAFE: Price levels will respect u64 bounds
                (fill_price as u64),
                receiver,
                ctx
            );

            let certificate = outlet::issue_nft_certificate(
                &mut auction.outlet,
                launchpad_id,
                ctx
            );

            // Transfer certificate to winning bid
            transfer::transfer(
                certificate,
                owner,
            );

            if (coin::value(&funds) == 0) {
                coin::destroy_zero(funds);
            } else {
                // Transfer bidding coins back to bid owner
                transfer::transfer(funds, owner);
            }
        };

        vector::destroy_empty(bids_to_fill);
    }
}
