// TODO(https://github.com/Origin-Byte/nft-protocol/issues/80): Market slot is toggled globally
module nft_protocol::dutch_auction {
    //! Auction where bids are fungible tokens.
    //! Winning bids are awarded NFTs.

    use std::vector;

    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    use movemate::crit_bit::{Self, CB as CBTree};

    use nft_protocol::err;
    use nft_protocol::object_box;
    use nft_protocol::inventory::{Self, Inventory};
    use nft_protocol::whitelist::{Self, Whitelist};
    use nft_protocol::launchpad::{Self, Launchpad, Slot};

    struct DutchAuctionMarket<phantom FT> has key, store {
        id: UID,
        /// The minimum price at which NFTs can be sold
        reserve_price: u64,
        /// A bid order stores amount of "T"okens the buyer is willing to
        /// purchase
        bids: CBTree<vector<Bid<FT>>>,
        /// Whether the auction is currently live
        live: bool,
        outlet: Inventory,
    }

    /// A bid for one NFT
    struct Bid<phantom FT> has store {
        /// Amount is equal to the price that the bidder is ready to pay for
        /// one NFT.
        amount: Balance<FT>,
        /// The address of the user who created this bid and who will receive
        /// an NFT in exchange for their tokens.
        owner: address,
    }

    // === Functions exposed to Witness Module ===

    public fun create_market<FT>(
        launchpad: &Launchpad,
        slot: &mut Slot,
        is_whitelisted: bool,
        reserve_price: u64,
        ctx: &mut TxContext
    ) {
        let outlet = inventory::create(
            is_whitelisted,
            ctx,
        );

        let market = object_box::empty(ctx);

        object_box::add(
            &mut market,
            DutchAuctionMarket<FT> {
                id: object::new(ctx),
                reserve_price,
                bids: crit_bit::empty(),
                live: false,
                outlet,
            }
        );

        launchpad::add_market(
            launchpad,
            slot,
            market,
            ctx,
        );

    }

    // === Entrypoints ===

    /// Creates a bid in a FIFO manner, previous bids are retained
    public entry fun create_bid<FT>(
        wallet: &mut Coin<FT>,
        slot: &mut Slot,
        market: &mut DutchAuctionMarket<FT>,
        price: u64,
        quantity: u64,
        ctx: &mut TxContext,
    ) {
        // One can only place bids on NFT certificates if the slingshot is live
        assert!(launchpad::live(slot), err::slot_not_live());

        // Infer that sales is NOT whitelisted
        assert!(!inventory::whitelisted(&market.outlet), err::sale_is_not_whitelisted());

        create_bid_(
            market,
            wallet,
            price,
            quantity,
            tx_context::sender(ctx)
        );
    }

    public entry fun create_bid_whitelisted<FT>(
        wallet: &mut Coin<FT>,
        slot: &mut Slot,
        market: &mut DutchAuctionMarket<FT>,
        whitelist_token: Whitelist,
        price: u64,
        quantity: u64,
        ctx: &mut TxContext,
    ) {
        // One can only place bids on NFT certificates if the slingshot is live
        assert!(launchpad::live(slot), err::slot_not_live());

        // Infer that sales is whitelisted
        assert!(inventory::whitelisted(&market.outlet), err::sale_is_whitelisted());

        // Infer that whitelist token corresponds to correct sale outlet
        assert!(
            whitelist::sale_id(&whitelist_token) == object::id(&market.outlet),
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
    public entry fun cancel_bid<FT>(
        wallet: &mut Coin<FT>,
        _slot: &mut Slot,
        market: &mut DutchAuctionMarket<FT>,
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
    public entry fun sale_on(
        slot: &mut Slot,
        ctx: &mut TxContext
    ) {
        assert!(
            launchpad::slot_admin(slot) == tx_context::sender(ctx),
            err::wrong_launchpad_admin()
        );
        launchpad::sale_on(slot, ctx);
    }

    /// Toggle the Slingshot's `live` to `false` therefore pausing the auction.
    /// This does not allocate any NFTs to bidders.
    ///
    /// Permissioned endpoint to be called by `admin`.
    public entry fun sale_off(
        slot: &mut Slot,
        ctx: &mut TxContext
    ) {
        assert!(
            launchpad::slot_admin(slot) == tx_context::sender(ctx),
            err::wrong_launchpad_admin()
        );
        launchpad::sale_off(slot, ctx);
    }

    /// Cancel the auction and toggle the Slingshot's `live` to `false`.
    /// All bids will be cancelled and refunded.
    ///
    /// Permissioned endpoint to be called by `admin`.
    public entry fun sale_cancel<FT>(
        slot: &mut Slot,
        market: &mut DutchAuctionMarket<FT>,
        ctx: &mut TxContext
    ) {
        assert!(
            launchpad::slot_admin(slot) == tx_context::sender(ctx),
            err::wrong_launchpad_admin()
        );

        cancel_auction(market, ctx);


        launchpad::sale_off(slot, ctx);
    }

    /// Conclude the auction and toggle the Slingshot's `live` to `false`.
    /// NFTs will be allocated to the winning biddeers.
    ///
    /// Permissioned endpoint to be called by `admin`.
    public entry fun sale_conclude<FT>(
        launchpad: &Launchpad,
        slot: &mut Slot,
        market: &mut DutchAuctionMarket<FT>,
        ctx: &mut TxContext
    ) {
        assert!(
            launchpad::slot_admin(slot) == tx_context::sender(ctx),
            err::wrong_launchpad_admin()
        );

        let nfts_to_sell = inventory::length(&market.outlet);

        conclude_auction<FT>(
            launchpad,
            slot,
            market,
            // TODO(https://github.com/Origin-Byte/nft-protocol/issues/63):
            // Investigate whether this logic should be paginated
            nfts_to_sell,
            ctx
        );

        launchpad::sale_off(slot, ctx);
    }

    // === Private Functions ===

    fun create_bid_<FT>(
        auction: &mut DutchAuctionMarket<FT>,
        wallet: &mut Coin<FT>,
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
    fun cancel_bid_<FT>(
        auction: &mut DutchAuctionMarket<FT>,
        wallet: &mut Coin<FT>,
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
    fun cancel_auction<FT>(
        book: &mut DutchAuctionMarket<FT>,
        ctx: &mut TxContext
    ) {
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

    fun refund_bid<FT>(
        bid: Bid<FT>,
        wallet: &mut Coin<FT>,
        sender: &address
    ) {
        let Bid { amount, owner } = bid;
        assert!(sender == &owner, err::order_owner_must_be_sender());

        balance::join(coin::balance_mut(wallet), amount);
    }

    fun conclude_auction<FT>(
        launchpad: &Launchpad,
        slot: &mut Slot,
        auction: &mut DutchAuctionMarket<FT>,
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
        let launchpad_id = launchpad::slot_id(slot);

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

        let total_funds = balance::zero<FT>();

        while (!vector::is_empty(&bids_to_fill)) {
            let Bid {amount, owner} = vector::pop_back(&mut bids_to_fill);

            let filled_funds = balance::split(&mut amount, (fill_price as u64));

            balance::join<FT>(
                &mut total_funds,
                filled_funds
            );

            let certificate = inventory::issue_nft_certificate(
                &mut auction.outlet,
                launchpad_id,
                launchpad::slot_id(slot),
                ctx
            );

            // Transfer certificate to winning bid
            transfer::transfer(
                certificate,
                owner,
            );

            if (balance::value(&amount) == 0) {
                balance::destroy_zero(amount);
            } else {
                // Transfer bidding coins back to bid owner
                transfer::transfer(coin::from_balance(amount, ctx), owner);
            };
        };

        launchpad::pay<FT>(
            launchpad,
            slot,
            coin::from_balance(total_funds, ctx),
            1,
        );

        vector::destroy_empty(bids_to_fill);
    }
}
