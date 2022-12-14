module nft_protocol::bidding {
    use nft_protocol::err;
    use nft_protocol::royalties;
    use nft_protocol::safe::{Self, Safe, TransferCap};
    use nft_protocol::transfer_whitelist::Whitelist;

    use std::option::{Self, Option};

    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::event::emit;
    use sui::object::{Self, ID, UID};
    use sui::transfer::{transfer, share_object};
    use sui::tx_context::{Self, TxContext};

    struct Witness has drop {}

    struct Bid<phantom FT> has key {
        id: UID,
        nft: ID,
        buyer: address,
        safe: ID,
        offer: Balance<FT>,
        commission: Option<BidCommission<FT>>,
    }

    /// Enables collection of wallet/marketplace collection for buying NFTs.
    /// 1. user bids via wallet to buy NFT for `p`, wallet wants fee `f`
    /// 2. when executed, `p` goes to seller and `f` goes to wallet.
    ///
    ///
    /// TODO: deduplicate with OB
    struct BidCommission<phantom FT> has store {
        /// This is given to the facilitator of the trade.
        cut: Balance<FT>,
        /// A new `Coin` object is created and sent to this address.
        beneficiary: address,
    }

    /// TODO: deduplicate with OB
    struct AskCommission has store, drop {
        /// How many tokens of the transferred amount should go to the party
        /// which holds the private key of `beneficiary` address.
        ///
        /// Always less than ask price.
        cut: u64,
        /// A new `Coin` object is created and sent to this address.
        beneficiary: address,
    }

    struct BidCreated<phantom FT> has copy, drop {
        id: ID,
        for_nft: ID,
        price: u64,
    }

    struct BidClosed<phantom FT> has copy, drop {
        id: ID,
        /// Either sold or canceled
        sold: bool,
    }

    public entry fun create_bid<FT>(
        nft: ID,
        buyers_safe: ID,
        price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        create_bid_(nft, buyers_safe, price, option::none(), wallet, ctx);
    }
    public entry fun create_bid_with_commission<FT>(
        nft: ID,
        buyers_safe: ID,
        price: u64,
        beneficiary: address,
        commission_ft: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let commission = BidCommission {
            beneficiary,
            cut: balance::split(coin::balance_mut(wallet), commission_ft),
        };
        create_bid_(nft, buyers_safe, price, option::some(commission), wallet, ctx);
    }

    public entry fun sell_nft<C, FT>(
        bid: &mut Bid<FT>,
        transfer_cap: TransferCap,
        sellers_safe: &mut Safe,
        buyers_safe: &mut Safe,
        whitelist: &Whitelist,
        ctx: &mut TxContext,
    ) {
        sell_nft_<C, FT>(
            bid,
            transfer_cap,
            option::none(),
            sellers_safe,
            buyers_safe,
            whitelist,
            ctx,
        );
    }
    public entry fun sell_nft_with_commission<C, FT>(
        bid: &mut Bid<FT>,
        transfer_cap: TransferCap,
        beneficiary: address,
        commission_ft: u64,
        sellers_safe: &mut Safe,
        buyers_safe: &mut Safe,
        whitelist: &Whitelist,
        ctx: &mut TxContext,
    ) {
        let commission = AskCommission {
            cut: commission_ft,
            beneficiary,
        };
        sell_nft_<C, FT>(
            bid,
            transfer_cap,
            option::some(commission),
            sellers_safe,
            buyers_safe,
            whitelist,
            ctx,
        );
    }

    /// If a user wants to cancel their position, they get their coins back.
    public entry fun close_bid<FT>(bid: &mut Bid<FT>, ctx: &mut TxContext) {
        close_bid_(bid, ctx);
    }

    fun create_bid_<FT>(
        nft: ID,
        buyers_safe: ID,
        price: u64,
        commission: Option<BidCommission<FT>>,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let offer = balance::split(coin::balance_mut(wallet), price);
        let buyer = tx_context::sender(ctx);

        let bid = Bid<FT> {
            id: object::new(ctx),
            nft,
            offer,
            buyer,
            safe: buyers_safe,
            commission,
        };
        let bid_id = object::id(&bid);
        share_object(bid);

        emit(BidCreated<FT> {
            id: bid_id,
            for_nft: nft,
            price
        });
    }

    fun sell_nft_<C, FT>(
        bid: &mut Bid<FT>,
        transfer_cap: TransferCap,
        ask_commission: Option<AskCommission>,
        sellers_safe: &mut Safe,
        buyers_safe: &mut Safe,
        whitelist: &Whitelist,
        ctx: &mut TxContext,
    ) {
        safe::assert_transfer_cap_of_safe(&transfer_cap, sellers_safe);
        safe::assert_nft_of_transfer_cap(&bid.nft, &transfer_cap);
        safe::assert_id(buyers_safe, bid.safe);

        let nft_id = safe::transfer_cap_nft(&transfer_cap);

        pay_for_nft<C, FT>(
            &mut bid.offer,
            bid.buyer,
            &mut ask_commission,
            ctx,
        );
        option::destroy_none(ask_commission);

        safe::transfer_nft_to_safe<C, Witness>(
            transfer_cap,
            bid.buyer,
            Witness {},
            whitelist,
            sellers_safe,
            buyers_safe,
            ctx,
        );

        transfer_bid_commission(&mut bid.commission, ctx);

        emit(BidClosed<FT> { id: nft_id, sold: true });
    }

    fun close_bid_<FT>(bid: &mut Bid<FT>, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        assert!(bid.buyer == sender, err::sender_not_owner());

        let total = balance::value(&bid.offer);
        let offer = coin::take(&mut bid.offer, total, ctx);

        if (option::is_some(&bid.commission)) {
            let BidCommission { beneficiary: _, cut } =
                option::extract(&mut bid.commission);

            balance::join(coin::balance_mut(&mut offer), cut);
        };

        transfer(offer, sender);
    }

    /// TODO: deduplicate with OB
    fun pay_for_nft<C, FT>(
        paid: &mut Balance<FT>,
        buyer: address,
        maybe_commission: &mut Option<AskCommission>,
        ctx: &mut TxContext,
    ) {
        let amount = balance::value(paid);

        if (option::is_some(maybe_commission)) {
            // the `p`aid amount for the NFT and the commission `c`ut

            let AskCommission {
                cut, beneficiary,
            } = option::extract(maybe_commission);

            // associates both payments with each other
            let trade = object::new(ctx);

            // `p` - `c` goes to seller
            royalties::create_with_trade<C, FT>(
                balance::split(paid, amount - cut),
                buyer,
                object::uid_to_inner(&trade),
                ctx,
            );
            // `c` goes to the marketplace
            royalties::create_with_trade<C, FT>(
                balance::split(paid, cut),
                beneficiary,
                object::uid_to_inner(&trade),
                ctx,
            );

            object::delete(trade);
        } else {
            // no commission, all `p` goes to seller

            royalties::create<C, FT>(
                balance::split(paid, amount),
                buyer,
                ctx,
            );
        };
    }

    /// TODO: deduplicate with OB
    fun transfer_bid_commission<FT>(
        commission: &mut Option<BidCommission<FT>>,
        ctx: &mut TxContext,
    ) {
        if (option::is_some(commission)) {
            let BidCommission { beneficiary, cut } =
                option::extract(commission);

            transfer(coin::from_balance(cut, ctx), beneficiary);
        };
    }
}
