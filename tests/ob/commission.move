#[test_only]
module nft_protocol::test_ob_commission {
    // TODO: test trading with commission - check all assertions and that the
    // funds are wrapped in the right way

    use nft_protocol::test_utils as test_ob;
    use sui::test_scenario;

    const SELLER: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;

    #[test]
    #[expected_failure(abort_code = 13370701, location = nft_protocol::ob)]
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
}
