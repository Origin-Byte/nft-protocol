#[test_only]
/// This test focuses on integration between OB, Safe, a allowlist and
/// royalty collection.
///
/// We simulate a trade between two Safes, end to end, including royalty
/// collection.
module nft_protocol::test_ob_safe_to_safe_trade {
    use sui::sui::SUI;
    use sui::test_scenario;

    use nft_protocol::royalties;
    use nft_protocol::test_utils as test_ob;

    const BUYER: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;
    const SELLER: address = @0xA1C04;

    const OFFER_SUI: u64 = 100;

    struct FakeCollection has drop {}
    // Witness for fake collection
    struct Witness has drop {}

    #[test]
    fun it_works() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(CREATOR, &mut scenario);

        test_ob::create_ob(&mut scenario);

        test_ob::create_safe(&mut scenario, SELLER);
        let nft_id = test_ob::mint_and_deposit_nft(
            &mut scenario,
            SELLER,
        );
        test_ob::create_ask(
            &mut scenario,
            nft_id,
            OFFER_SUI,
        );

        test_ob::create_safe(&mut scenario, BUYER);
        test_ob::create_bid(&mut scenario, OFFER_SUI);
        test_ob::finish_trade(
            &mut scenario,
            nft_id,
            BUYER,
            SELLER,
        );

        test_scenario::next_tx(&mut scenario, SELLER);
        let payment_for_seller: royalties::TradePayment<test_ob::Foo, SUI> =
            test_scenario::take_shared(&mut scenario);
        assert!(royalties::beneficiary(&payment_for_seller) == SELLER, 0);
        test_scenario::return_shared(payment_for_seller);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 4, location = nft_protocol::orderbook)]
    fun it_fails_if_buyer_safe_eq_seller_safe() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(CREATOR, &mut scenario);

        test_ob::create_ob(&mut scenario);

        test_ob::create_safe(&mut scenario, SELLER);
        let nft_id = test_ob::mint_and_deposit_nft(
            &mut scenario,
            SELLER,
        );
        test_ob::create_ask(
            &mut scenario,
            nft_id,
            OFFER_SUI,
        );
        test_ob::create_bid(&mut scenario, OFFER_SUI);

        test_scenario::end(scenario);
    }

    // #[test]
    // #[expected_failure(abort_code = 0, location = nft_protocol::unprotected_safe)]
    // fun if_fails_if_seller_spoofs_collection_type() {
    //     let scenario = test_scenario::begin(CREATOR);

    //     test_ob::create_collection_and_allowlist_with_type(
    //         &FakeCollection {},
    //         &Witness {},
    //         CREATOR,
    //         &mut scenario,
    //     );

    //     test_ob::create_ob(&mut scenario);

    //     test_ob::create_safe(&mut scenario, SELLER);
    //     let nft_id = test_ob::create_and_deposit_nft_with_type<FakeCollection>(
    //         &mut scenario,
    //         SELLER,
    //     );

    //     test_ob::create_ask(
    //         &mut scenario,
    //         nft_id,
    //         OFFER_SUI,
    //     );
    //     test_scenario::end(scenario);
    // }
}
