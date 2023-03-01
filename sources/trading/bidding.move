/// Bidding module that allows users to bid for any given NFT in a safe,
/// giving NFT owners a platform to sell their NFTs to any available bid.
module nft_protocol::bidding {
    use std::option::{Self, Option};

    use sui::event::emit;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, ID, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer::{transfer, share_object};

    use nft_protocol::err;
    use nft_protocol::safe::{Self, Safe, TransferCap};
    use nft_protocol::transfer_allowlist::Allowlist;
    use nft_protocol::trading::{
        AskCommission,
        BidCommission,
        destroy_bid_commission,
        new_ask_commission,
        new_bid_commission,
        settle_funds_no_royalties,
        settle_funds_with_royalties,
        transfer_bid_commission,
    };

    /// Witness used to authenticate witness protected endpoints
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
        let bid =
            new_bid(nft, buyers_safe, price, option::none(), wallet, ctx);
        share_object(bid);
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
        let bid =
            new_bid(nft, buyers_safe, price, option::some(commission), wallet, ctx);
        share_object(bid);
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
        allowlist: &Allowlist,
        ctx: &mut TxContext,
    ) {
        sell_nft_<C, FT>(
            bid,
            transfer_cap,
            option::none(),
            sellers_safe,
            buyers_safe,
            allowlist,
            ctx,
        );
    }

    /// Similar to [`sell_nft`] except that this is meant for
    /// generic collections, ie. those which aren't native to our protocol.
    public entry fun sell_generic_nft<C: key + store, FT>(
        bid: &mut Bid<FT>,
        transfer_cap: TransferCap,
        sellers_safe: &mut Safe,
        buyers_safe: &mut Safe,
        ctx: &mut TxContext,
    ) {
        sell_generic_nft_<C, FT>(
            bid,
            transfer_cap,
            option::none(),
            sellers_safe,
            buyers_safe,
            ctx,
        );
    }

    /// Entry function to sell an NFT with an open `bid`.
    ///
    /// It performs the following:
    /// - Splits funds from `Bid<FT>` by:
    ///     - (1) Creating TradePayment<C, FT> for the Ask commission
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
        allowlist: &Allowlist,
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
            allowlist,
            ctx,
        );
    }

    /// Similar to [`sell_nft_with_commission`] except that this is meant for
    /// generic collections, ie. those which aren't native to our protocol.
    public entry fun sell_generic_nft_with_commission<C: key + store, FT>(
        bid: &mut Bid<FT>,
        transfer_cap: TransferCap,
        beneficiary: address,
        commission_ft: u64,
        sellers_safe: &mut Safe,
        buyers_safe: &mut Safe,
        ctx: &mut TxContext,
    ) {
        let commission = new_ask_commission(
            beneficiary,
            commission_ft,
        );
        sell_generic_nft_<C, FT>(
            bid,
            transfer_cap,
            option::some(commission),
            sellers_safe,
            buyers_safe,
            ctx,
        );
    }

    /// If a user wants to cancel their position, they get their coins back.
    public entry fun close_bid<FT>(bid: &mut Bid<FT>, ctx: &mut TxContext) {
        close_bid_(bid, ctx);
    }

    /// Sends funds Balance<FT> from `wallet` to the `bid` and
    /// shares object `bid.`
    public fun new_bid<FT>(
        nft: ID,
        buyers_safe: ID,
        price: u64,
        commission: Option<BidCommission<FT>>,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): Bid<FT> {
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

        emit(BidCreated<FT> {
            id: bid_id,
            for_nft: nft,
            price
        });

        bid
    }

    /// Function to sell an NFT with an open `bid`.
    ///
    /// It splits funds from `Bid<FT>` by creating TradePayment<C, FT>
    /// for the Ask commission if any, and creating TradePayment<C, FT> for the
    /// next trade amount. It transfers the NFT from `sellers_safe` to
    /// `buyers_safe` and burns `TransferCap`. It then transfers bid
    /// commission funds to address `bid.commission.beneficiary`.
    fun sell_nft_<C, FT>(
        bid: &mut Bid<FT>,
        transfer_cap: TransferCap,
        ask_commission: Option<AskCommission>,
        sellers_safe: &mut Safe,
        buyers_safe: &mut Safe,
        allowlist: &Allowlist,
        ctx: &mut TxContext,
    ) {
        safe::assert_transfer_cap_of_safe(&transfer_cap, sellers_safe);
        safe::assert_nft_of_transfer_cap(&bid.nft, &transfer_cap);
        safe::assert_id(buyers_safe, bid.safe);

        let nft_id = safe::transfer_cap_nft(&transfer_cap);

        settle_funds_with_royalties<C, FT>(
            &mut bid.offer,
            tx_context::sender(ctx),
            &mut ask_commission,
            ctx,
        );
        option::destroy_none(ask_commission);

        safe::transfer_nft_to_safe<C, Witness>(
            transfer_cap,
            bid.buyer,
            Witness {},
            allowlist,
            sellers_safe,
            buyers_safe,
            ctx,
        );

        transfer_bid_commission(&mut bid.commission, ctx);

        emit(BidClosed<FT> { id: nft_id, sold: true });
    }

    /// Similar to [`sell_nft_`] except that this is meant for generic
    /// collections, ie. those which aren't native to our protocol.
    fun sell_generic_nft_<C: key + store, FT>(
        bid: &mut Bid<FT>,
        transfer_cap: TransferCap,
        ask_commission: Option<AskCommission>,
        sellers_safe: &mut Safe,
        buyers_safe: &mut Safe,
        ctx: &mut TxContext,
    ) {
        safe::assert_transfer_cap_of_safe(&transfer_cap, sellers_safe);
        safe::assert_nft_of_transfer_cap(&bid.nft, &transfer_cap);
        safe::assert_id(buyers_safe, bid.safe);

        let nft_id = safe::transfer_cap_nft(&transfer_cap);

        settle_funds_no_royalties<C, FT>(
            &mut bid.offer,
            tx_context::sender(ctx),
            &mut ask_commission,
            ctx,
        );
        option::destroy_none(ask_commission);

        safe::transfer_generic_nft_to_safe<C>(
            transfer_cap,
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
