#[test_only]
module nft_protocol::test_ob_commission {
    // TODO: test trading with commission - check all assertions and that the
    // funds are wrapped in the right way

    use nft_protocol::orderbook::{Self as ob, Orderbook};
    use nft_protocol::royalties;
    use nft_protocol::test_utils as test_ob;
    use sui::sui::SUI;
    use sui::test_scenario;
    use sui::transfer::public_transfer;

    const BUYER: address = @0xA1C07;
    const SELLER: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;

    const OFFER_SUI: u64 = 100;

    #[test]
    #[expected_failure(abort_code = 2, location = nft_protocol::orderbook)]
    fun it_cannot_create_ask_with_commission_greater_than_requested_tokens() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(&mut scenario);
        let _ob_id = test_ob::create_ob<test_ob::Foo>(&mut scenario);
        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::create_safe(&mut scenario, SELLER);
        let nft_id = test_ob::create_and_deposit_nft(&mut scenario, SELLER);
        test_scenario::next_tx(&mut scenario, SELLER);

        test_ob::create_ask_with_commission(
            &mut scenario,
            nft_id,
            OFFER_SUI,
            CREATOR,
            OFFER_SUI + 1,
        );

        test_scenario::end(scenario);
    }

    #[test]
    fun it_works() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(&mut scenario);
        let _ob_id = test_ob::create_ob<test_ob::Foo>(&mut scenario);
        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::create_safe(&mut scenario, SELLER);
        let nft_id = test_ob::create_and_deposit_nft(&mut scenario, SELLER);
        test_scenario::next_tx(&mut scenario, SELLER);

        test_ob::create_ask_with_commission(
            &mut scenario,
            nft_id,
            OFFER_SUI,
            CREATOR,
            10,
        );


        test_ob::create_safe(&mut scenario, BUYER);
        test_ob::create_bid<test_ob::Foo>(&mut scenario, OFFER_SUI);
        test_ob::finish_trade(
            &mut scenario,
            nft_id,
            BUYER,
            SELLER,
        );

        test_scenario::next_tx(&mut scenario, SELLER);
        let payment_for_commission: royalties::TradePayment<test_ob::Foo, SUI> =
            test_scenario::take_shared(&mut scenario);
        assert!(royalties::beneficiary(&payment_for_commission) == CREATOR, 0);

        let payment_for_seller: royalties::TradePayment<test_ob::Foo, SUI> =
            test_scenario::take_shared(&mut scenario);
        assert!(royalties::beneficiary(&payment_for_seller) == SELLER, 0);

        test_scenario::return_shared(payment_for_commission);
        test_scenario::return_shared(payment_for_seller);

        test_scenario::end(scenario);
    }

    #[test]
    fun it_lists_nft() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(&mut scenario);
        let _ob_id = test_ob::create_ob<test_ob::Foo>(&mut scenario);
        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::create_safe(&mut scenario, SELLER);
        let nft_id = test_ob::create_and_deposit_nft(&mut scenario, SELLER);
        test_scenario::next_tx(&mut scenario, SELLER);

        let (owner_cap, seller_safe) =
            test_ob::owner_cap_and_safe(&scenario, SELLER);
        let ob: Orderbook<test_ob::Foo, SUI> =
            test_scenario::take_shared(&scenario);
        ob::list_nft_with_commission(
            &mut ob,
            100,
            nft_id,
            &owner_cap,
            CREATOR,
            10,
            &mut seller_safe,
            test_scenario::ctx(&mut scenario),
        );

        test_scenario::return_shared(ob);
        test_scenario::return_shared(seller_safe);
        public_transfer(owner_cap, SELLER);

        test_scenario::end(scenario);
    }
}
