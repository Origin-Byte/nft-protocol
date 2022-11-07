module nft_protocol::bidding {
    use nft_protocol::transfer_whitelist::Whitelist;
    use nft_protocol::royalties;
    use nft_protocol::safe::{Self, Safe, TransferCap};
    use std::option::{Self, Option};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, ID, UID};
    use sui::transfer::{transfer, share_object};
    use sui::tx_context::{Self, TxContext};
    use sui::event::emit;

    struct Witness has drop {}

    // TODO: close bid

    struct Bid<phantom FT> has key {
        id: UID,
        nft: ID,
        buyer: address,
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
        price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        create_bid_(nft, price, option::none(), wallet, ctx);
    }
    public entry fun create_bid_with_commission<FT>(
        nft: ID,
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
        create_bid_(nft, price, option::some(commission), wallet, ctx);
    }

    public entry fun sell_nft<C, D: store, FT, WW>(
        bid: &mut Bid<FT>,
        transfer_cap: TransferCap,
        safe: &mut Safe,
        whitelist: &Whitelist<WW>,
        ctx: &mut TxContext,
    ) {
        sell_nft_<C, D, FT, WW>(
            bid,
            transfer_cap,
            option::none(),
            safe,
            whitelist,
            ctx,
        );
    }
    public entry fun sell_nft_with_commission<C, D: store, FT, WW>(
        bid: &mut Bid<FT>,
        transfer_cap: TransferCap,
        beneficiary: address,
        commission_ft: u64,
        safe: &mut Safe,
        whitelist: &Whitelist<WW>,
        ctx: &mut TxContext,
    ) {
        let commission = AskCommission {
            cut: commission_ft,
            beneficiary,
        };
        sell_nft_<C, D, FT, WW>(
            bid,
            transfer_cap,
            option::some(commission),
            safe,
            whitelist,
            ctx,
        );
    }

    fun create_bid_<FT>(
        nft: ID,
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

    fun sell_nft_<C, D: store, FT, WW>(
        bid: &mut Bid<FT>,
        transfer_cap: TransferCap,
        ask_commission: Option<AskCommission>,
        safe: &mut Safe,
        whitelist: &Whitelist<WW>,
        ctx: &mut TxContext,
    ) {
        safe::assert_transfer_cap_of_safe(&transfer_cap, safe);
        safe::assert_nft_of_transfer_cap(&bid.nft, &transfer_cap);

        let nft_id = safe::transfer_cap_nft(&transfer_cap);

        pay_for_nft(
            &mut bid.offer,
            bid.buyer,
            &mut ask_commission,
            ctx,
        );
        option::destroy_none(ask_commission);

        safe::transfer_nft_to_recipient<C, D, WW, Witness>(
            transfer_cap,
            bid.buyer,
            Witness {},
            whitelist,
            safe,
        );

        transfer_bid_commission(&mut bid.commission, ctx);

        emit(BidClosed<FT> { id: nft_id, sold: true });
    }

    /// TODO: deduplicate with OB
    fun pay_for_nft<W, FT>(
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
            royalties::create_with_trade<W, FT>(
                balance::split(paid, amount - cut),
                buyer,
                object::uid_to_inner(&trade),
                ctx,
            );
            // `c` goes to the marketplace
            royalties::create_with_trade<W, FT>(
                balance::split(paid, cut),
                beneficiary,
                object::uid_to_inner(&trade),
                ctx,
            );

            object::delete(trade);
        } else {
            // no commission, all `p` goes to seller

            royalties::create<W, FT>(
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
