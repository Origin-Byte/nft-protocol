#[test_only]
/// This test focuses on integration between OB, Safe, a allowlist and
/// royalty collection.
///
/// We simulate a trade between two Safes, end to end, including royalty
/// collection.
module nft_protocol::test_ob_safe_to_safe_trade {
    use sui::test_scenario;

    use nft_protocol::test_utils as test_ob;

    const BUYER: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;
    const SELLER: address = @0xA1C04;

    const OFFER_SUI: u64 = 100;

    #[test]
    fun it_works() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(&mut scenario);

        test_ob::create_ob(&mut scenario);

        test_ob::create_safe(&mut scenario, SELLER);
        let nft_id = test_ob::create_and_deposit_nft(
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

        test_scenario::end(scenario);
    }
}
