/// Module of a Dutch Auction Sale `Market` type.
///
/// It implements a dutch auction sale configuration, where all NFTs in the sale
/// warehouse get sold to the winners of the auction. The number of winners
///
/// NFT creators can decide if they want to create a simple primary market sale
/// or if they want to create a tiered market sale by segregating NFTs by
/// different sale segments (e.g. based on rarity).
///
/// To create a market sale the administrator can simply call `create_market`.
/// Each sale segment can have a whitelisting process, each with their own
/// whitelist tokens.
module launchpad_v2::dutch_auction {
    // TODO: Test that random addresses can remove other addresses' bids
    use std::option;
    use std::vector;

    use sui::transfer;
    use sui::dynamic_field as df;
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use nft_protocol::utils_supply as supply;

    use launchpad_v2::launchpad::LaunchCap;
    use launchpad_v2::auth_request::{Self, AuthRequest};
    use launchpad_v2::venue::{Self, Venue};
    use launchpad_v2::certificate;

    use originmate::crit_bit_u64::{Self as crit_bit, CB as CBTree};

    const U64_MAX: u64 = 18446744073709551615;

    /// Order price was below auction reserve price
    const EOrderPriceBelowReserve: u64 = 1;

    /// Order was not found
    const EInvalidOrder: u64 = 2;

    /// Transaction sender must be order owner
    const EInvalidSender: u64 = 3;

    struct DutchAuctionMarket<phantom FT> has store {
        /// The minimum price at which NFTs can be sold
        reserve_price: u64,
        /// A bid order stores the amount of fungible token, FT, that the
        /// buyer is willing to purchase.
        bids: CBTree<vector<Bid<FT>>>,
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

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    struct DutchAuctionDfKey has store, copy, drop {}

    // === Init functions ===

    fun new<FT>(
        reserve_price: u64,
    ): DutchAuctionMarket<FT> {
        DutchAuctionMarket {
            reserve_price,
            bids: crit_bit::empty(),
        }
    }

    /// Creates a `DutchAuctionMarket<FT>` and transfers to transaction sender
    public fun init_market<FT>(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        reserve_price: u64,
    ) {
        venue::assert_launch_cap(venue, launch_cap);

        let market = new<FT>(reserve_price);
        let venue_uid = venue::uid_mut(venue, launch_cap);
        df::add(venue_uid, DutchAuctionDfKey {}, market);
    }

    // === Entrypoints ===

    /// Creates a bid in a FIFO manner, previous bids are retained
    public fun create_bid<FT>(
        venue: &mut Venue,
        wallet: &mut Coin<FT>,
        // TODO: Put Quantity and Receiver inside Request to reduce params
        price: u64,
        quantity: u64,
        request: AuthRequest,
        ctx: &mut TxContext,
    ) {
        venue::assert_request(venue, &request);
        auth_request::confirm(request, venue::get_auth_policy(venue));

        create_bid_(
            venue,
            wallet,
            price,
            quantity,
            tx_context::sender(ctx)
        );
    }

    /// Cancels a single bid at the given price level in a FIFO manner
    ///
    /// Bids can always be canceled no matter whether the auction is live.
    //
    // TODO(https://github.com/Origin-Byte/nft-protocol/issues/76):
    // Cancel all bids endpoint
    public entry fun cancel_bid<FT>(
        venue: &mut Venue,
        wallet: &mut Coin<FT>,
        price: u64,
        ctx: &mut TxContext,
    ) {
        cancel_bid_(venue, wallet, price, tx_context::sender(ctx))
    }

    public fun change_bid() {
        abort(0)
    }

    // === Modifier Functions ===

    /// Cancel the auction and toggle the Slingshot's `live` to `false`.
    /// All bids will be cancelled and refunded.
    ///
    /// Permissioned endpoint to be called by `admin`.
    public entry fun sale_cancel<FT>(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        ctx: &mut TxContext,
    ) {
        venue::assert_launch_cap(venue, launch_cap);
        // TODO: Check if it's live -->>>>>
        // venue::check_if_live(clock, venue);

        let market = venue::get_df_mut<DutchAuctionDfKey, DutchAuctionMarket<FT>>(
            venue,
            DutchAuctionDfKey {}
        );

        // TODO: Sale should no be cancellable if there are bids, in other words,
        // it needs to be empty
        assert!(is_empty(market), 0);

        cancel_auction<FT>(
            market,
            ctx,
        );
    }

    /// Conclude the auction and toggle the Slingshot's `live` to `false`.
    /// NFTs will be allocated to the winning biddeers.
    ///
    /// Permissioned endpoint to be called by `admin`.
    public entry fun sale_conclude<T: key + store, FT>(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        ctx: &mut TxContext,
    ) {
        venue::assert_launch_cap(venue, launch_cap);

        // Determine how much inventory there is to sell
        let supply = venue::get_supply(venue);

        // Auction could be drawing from an inventory with unregulated supply
        let nfts_to_sell = if (option::is_some(supply)) {
            supply::get_remaining(option::borrow(supply))
        } else {
            // TODO: remove this part potentially making only with fixed supply
            // to avoid footgun
            // NFTs sold will be ultimately limited by the amount of bids
            // therefore it is safe to return maximum number.
            U64_MAX
        };

        venue::increment_supply_if_any(Witness {}, venue, nfts_to_sell);

        // TODO(https://github.com/Origin-Byte/nft-protocol/issues/63):
        // Investigate whether this logic should be paginated
        let (fill_price, bids_to_fill) =
            conclude_auction<FT>(venue, nfts_to_sell);

        let total_funds = balance::zero<FT>();
        while (!vector::is_empty(&bids_to_fill)) {
            let Bid { amount, owner } = vector::pop_back(&mut bids_to_fill);

            let filled_funds = balance::split(&mut amount, fill_price);

            balance::join<FT>(&mut total_funds, filled_funds);

            let nft_receipt = certificate::get_redeem_certificate(
                Witness {},
                venue,
                owner,
                1, // each bid represents quantity = 1
                ctx,
            );
            transfer::public_transfer(nft_receipt, owner);

            if (balance::value(&amount) == 0) {
                balance::destroy_zero(amount);
            } else {
                // Transfer bidding coins back to bid owner
                transfer::public_transfer(coin::from_balance(amount, ctx), owner);
            };
        };

        venue::pay<Witness, FT, T>(
            Witness {},
            venue,
            total_funds,
            nfts_to_sell,
        );

        vector::destroy_empty(bids_to_fill);

        let market = venue::get_df_mut<DutchAuctionDfKey, DutchAuctionMarket<FT>>(
            venue,
            DutchAuctionDfKey {}
        );

        // We know by now that the supply is exhausted because
        // nfts_to_sell is set to remaining_supply
        cancel_auction<FT>(market, ctx);
    }

    // === Getter Functions ===

    /// Get the auction's reserve price
    public fun reserve_price<FT>(market: &DutchAuctionMarket<FT>): u64 {
        market.reserve_price
    }

    /// Get the auction's bids
    public fun bids<FT>(market: &DutchAuctionMarket<FT>): &CBTree<vector<Bid<FT>>> {
        &market.bids
    }

    public fun bid_owner<FT>(bid: &Bid<FT>): address {
        bid.owner
    }

    public fun bid_amount<FT>(bid: &Bid<FT>): &Balance<FT> {
        &bid.amount
    }

    public fun is_empty<FT>(market: &DutchAuctionMarket<FT>): bool {
        crit_bit::is_empty(&market.bids)
    }

    // === Private Functions ===

    fun create_bid_<FT>(
        venue: &mut Venue,
        wallet: &mut Coin<FT>,
        price: u64,
        quantity: u64,
        owner: address,
    ) {
        let market = venue::get_df_mut<DutchAuctionDfKey, DutchAuctionMarket<FT>>(
            venue,
            DutchAuctionDfKey {}
        );

        assert!(
            price >= market.reserve_price,
            EOrderPriceBelowReserve,
        );

        // Create price level if it does not exist
        if (!crit_bit::has_key(&market.bids, price)) {
            crit_bit::insert(
                &mut market.bids,
                price,
                vector::empty()
            );
        };

        let price_level =
            crit_bit::borrow_mut(&mut market.bids, price);

        // Make `quantity` number of bids
        let index = 0;
        while (quantity > index) {
            let amount = balance::split(coin::balance_mut(wallet), price);
            vector::push_back(price_level, Bid { amount, owner });
            index = index + 1;
        }
    }

    /// Cancels a single order in a FIFO manner
    fun cancel_bid_<FT>(
        venue: &mut Venue,
        wallet: &mut Coin<FT>,
        price: u64,
        sender: address,
    ) {
        let market = venue::get_df_mut<DutchAuctionDfKey, DutchAuctionMarket<FT>>(
            venue,
            DutchAuctionDfKey {}
        );

        let bids = &mut market.bids;


        assert!(
            crit_bit::has_key(bids, price),
            EInvalidOrder,
        );

        let price_level = crit_bit::borrow_mut(bids, price);

        let bid_index = 0;
        let bid_count = vector::length(price_level);
        while (bid_count > bid_index) {
            let bid = vector::borrow(price_level, bid_index);
            if (bid.owner == sender) {
                break
            };

            bid_index = bid_index + 1;
        };

        assert!(bid_index < bid_count, EInvalidSender);

        let bid = vector::remove(price_level, bid_index);
        refund_bid(bid, wallet, &sender);

        if (vector::is_empty(price_level)) {
            let price_level = crit_bit::pop(bids, price);
            vector::destroy_empty(price_level);
        }
    }

    // Cancels all bids present on the auction book
    fun cancel_auction<FT>(
        market: &mut DutchAuctionMarket<FT>,
        ctx: &mut TxContext,
    ) {
        let bids = &mut market.bids;

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

                transfer::public_transfer(wallet, owner);
            };

            vector::destroy_empty(price_level);
        }
    }

    fun refund_bid<FT>(
        bid: Bid<FT>,
        wallet: &mut Coin<FT>,
        sender: &address,
    ) {
        let Bid { amount, owner } = bid;
        assert!(sender == &owner, EInvalidSender);

        balance::join(coin::balance_mut(wallet), amount);
    }

    /// Returns the fill_price and bids that must be filled
    fun conclude_auction<FT>(
        venue: &mut Venue,
        // Use to specify how many NFTs will be transfered to the winning bids
        // during the `conclude_auction`. This functionality is used to avoid
        // hitting computational costs during large auction sales.
        //
        // To conclude the entire auction, the total number of NFTs in the sale
        // should be passed.
        nfts_to_sell: u64,
    ): (u64, vector<Bid<FT>>) {

        // Determine matching orders
        let market = venue::get_df_mut<DutchAuctionDfKey, DutchAuctionMarket<FT>>(
            venue,
            DutchAuctionDfKey {}
        );

        // TODO: venue::decrement_supply_if_any(Witness {}, venue, quantity);
        let bids = &mut market.bids;

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

        (fill_price, bids_to_fill)
    }
}
