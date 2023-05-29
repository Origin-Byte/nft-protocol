module liquidity_layer_v1::migration {
    use std::option;

    use sui::balance;
    use sui::coin;
    use sui::kiosk::Kiosk;
    use sui::object::{Self, ID};
    use sui::tx_context::TxContext;
    use sui::transfer_policy::TransferPolicy;

    use ob_permissions::witness::Witness as DelegatedWitness;

    use liquidity_layer_v1::trading;
    use liquidity_layer_v1::orderbook::{Self as orderbook_v1, Orderbook as OrderbookV1};
    use liquidity_layer::orderbook::{Self as orderbook_v2, Orderbook as OrderbookV2};
    use liquidity_layer::trading as trading_v2;

    const EIncorrectSellerKiosk: u64 = 1;

    public fun migrate_orderbook<T: key + store, FT>(
        witness: DelegatedWitness<T>,
        transfer_policy: &TransferPolicy<T>,
        book_v1: &mut OrderbookV1<T, FT>,
        ctx: &mut TxContext,
    ): ID {
        let actions = orderbook_v1::protected_actions(book_v1);

        let buy_nft = orderbook_v1::is_buy_nft_protected(actions);
        let create_ask = orderbook_v1::is_create_ask_protected(actions);
        let create_bid = orderbook_v1::is_create_bid_protected(actions);

        let orderbook_v2 = orderbook_v2::new<T, FT>(
            witness,
            transfer_policy,
            buy_nft,
            create_ask,
            create_bid,
            ctx,
        );

        // Only operations that buy NFTs can be completed
        orderbook_v1::set_protection(witness, book_v1, orderbook_v1::custom_protection(buy_nft, true, true));

        let orderbook_id = object::id(&orderbook_v2);
        orderbook_v2::share(orderbook_v2);
        orderbook_id
    }

    public fun migrate_bid<T: key + store, FT>(
        witness: DelegatedWitness<T>,
        book_v1: &mut OrderbookV1<T, FT>,
        book_v2: &mut OrderbookV2<T, FT>,
        ctx: &mut TxContext
    ) {
        let (buyer, bid_offer, buyer_kiosk_id, bid_commission_v1) = orderbook_v1::migrate_bid_(
            witness, book_v1
        );

        let bid_commission_v2 = option::none();

        if (option::is_some(&bid_commission_v1)) {
            let (commission, bid_beneficiary) = trading::destroy_bid_commission(
                option::extract(&mut bid_commission_v1)
            );

            option::fill(&mut bid_commission_v2, trading_v2::new_bid_commission(bid_beneficiary, commission));
        };

        option::destroy_none(bid_commission_v1);
        let price = balance::value(&bid_offer);

        let wallet = coin::from_balance(bid_offer, ctx);

        orderbook_v2::insert_bid_as_witness(
            witness,
            book_v2,
            buyer_kiosk_id,
            price,
            bid_commission_v2,
            &mut wallet,
            buyer
        );

        coin::destroy_zero(wallet);
    }

    public fun migrate_ask<T: key + store, FT>(
        witness: DelegatedWitness<T>,
        seller_kiosk: &mut Kiosk,
        book_v1: &mut OrderbookV1<T, FT>,
        book_v2: &mut OrderbookV2<T, FT>,
    ) {
        let (price, seller, nft_id, kiosk_id, ask_commission_v1) = orderbook_v1::migrate_ask_(
            witness, seller_kiosk, book_v1,
        );

        assert!(object::id(seller_kiosk) == kiosk_id, EIncorrectSellerKiosk);

        let ask_commission_v2 = option::none();

        if (option::is_some(&ask_commission_v1)) {
            let (commission, bid_beneficiary) = trading::destroy_ask_commission(
                option::extract(&mut ask_commission_v1)
            );

            option::fill(&mut ask_commission_v2, trading_v2::new_ask_commission(bid_beneficiary, commission));
        };

        option::destroy_none(ask_commission_v1);

        orderbook_v2::insert_ask_as_witness(
            witness,
            book_v2,
            seller_kiosk,
            price,
            ask_commission_v2,
            nft_id,
            seller,
            orderbook_v1::transfer_signer(witness, book_v1)
        );
    }
}
