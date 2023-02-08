#[test_only]
module nft_protocol::test_ob_commission {
    // TODO: test trading with commission - check all assertions and that the
    // funds are wrapped in the right way

    use nft_protocol::orderbook::{Self as ob, Orderbook};
    use nft_protocol::test_utils as test_ob;
    use sui::sui::SUI;
    use sui::test_scenario;
    use sui::transfer::transfer;

    const SELLER: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;

    #[test]
    #[expected_failure(abort_code = 13370701, location = nft_protocol::orderbook)]
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
            100,
            CREATOR,
            101,
        );

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
        transfer(owner_cap, SELLER);

        test_scenario::end(scenario);
    }
}
