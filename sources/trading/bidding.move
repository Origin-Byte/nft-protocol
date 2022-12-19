//! Bidding module that allows users to bid for any given NFT in a safe,
//! giving NFT owners a platform to sell their NFTs to any available bid.
module nft_protocol::bidding {
    // TODO: Consider allowing for NFT owners to create their own Asks
    use std::option::{Self, Option};

    use sui::event::emit;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, ID, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer::{transfer, share_object};

    use nft_protocol::err;
    use nft_protocol::safe::{Self, Safe, TransferCap};
    use nft_protocol::transfer_whitelist::Whitelist;
    use nft_protocol::trading::{
        AskCommission,
        BidCommission,
        destroy_bid_commission,
        new_ask_commission,
        new_bid_commission,
        settle_funds,
        transfer_bid_commission,
    };

    struct Witness has drop {}

    struct Bid<phantom FT> has key {
        id: UID,
        nft: ID,
        buyer: address,
        safe: ID,
        offer: Balance<FT>,
        commission: Option<BidCommission<FT>>,
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

    /// Payable entry function to create a bid for an NFT.
    ///
    /// It performs the following:
    /// - Sends funds Balance<FT> from `wallet` to the `bid`
    /// - Creates object `bid` and shares it.
    public entry fun create_bid<FT>(
        nft: ID,
        buyers_safe: ID,
        price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        create_bid_(nft, buyers_safe, price, option::none(), wallet, ctx);
    }

    /// Payable entry function to create a bid for an NFT.
    ///
    /// It performs the following:
    /// - Sends funds Balance<FT> from `wallet` to the `bid`
    /// - Creates object `bid` with `commission` and shares it.
    ///
    /// To be called by a intermediate application, for the purpose
    /// of securing a commission for intermediating the process.
    public entry fun create_bid_with_commission<FT>(
        nft: ID,
        buyers_safe: ID,
        price: u64,
        beneficiary: address,
        commission_ft: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let commission = new_bid_commission(
            beneficiary,
            balance::split(coin::balance_mut(wallet), commission_ft),
        );
        create_bid_(nft, buyers_safe, price, option::some(commission), wallet, ctx);
    }

    /// Entry function to sell an NFT with an open `bid`.
    ///
    /// It performs the following:
    /// - Splits funds from `Bid<FT>` by:
    ///     - (1) Creating TradePayment<C, FT> for the trade amount
    /// - Transfers NFT from `sellers_safe` to `buyers_safe` and
    /// burns `TransferCap`
    /// - Transfers bid commission funds to the address
    /// `bid.commission.beneficiary`
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

    /// Entry function to sell an NFT with an open `bid`.
    ///
    /// It performs the following:
    /// - Splits funds from `Bid<FT>` by:
    ///     - (1) Creating TradePayment<C, FT> for the Ask commision
    ///     - (2) Creating TradePayment<C, FT> for the net trade amount
    /// - Transfers NFT from `sellers_safe` to `buyers_safe` and
    /// burns `TransferCap`
    /// - Transfers bid commission funds to the address
    /// `bid.commission.beneficiary`
    ///
    /// To be called by a intermediate application, for the purpose of
    /// securing a commission for intermediating the process.
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
        let commission = new_ask_commission(
            beneficiary,
            commission_ft,
        );
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

    /// Sends funds Balance<FT> from `wallet` to the `bid` and
    /// shares object `bid.`
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

    /// Entry function to sell an NFT with an open `bid`.
    ///
    /// It splits funds from `Bid<FT>` by creating TradePayment<C, FT>
    /// for the Ask commision if any, and creating TradePayment<C, FT> for the
    /// next trade amount. It transfers the NFT from `sellers_safe` to
    /// `buyers_safe` and burns `TransferCap`. It then transfers bid
    /// commission funds to address `bid.commission.beneficiary`.
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

        settle_funds<C, FT>(
            &mut bid.offer,
            tx_context::sender(ctx),
            // bid.buyer,
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
            let commission = option::extract(&mut bid.commission);
            let (cut, _beneficiary) = destroy_bid_commission(commission);

            balance::join(coin::balance_mut(&mut offer), cut);
        };

        transfer(offer, sender);
    }
}
