#[test_only]
module nft_protocol::test_ob_safe_to_safe_trade {
    //! This test focuses on integration between OB, Safe, a whitelist and
    //! royalty collection.
    //!
    //! We simulate a trade between two Safes, end to end, including royalty
    //! collection.
    use sui::test_scenario;

    use nft_protocol::test_ob_utils as test_ob;

    const BUYER: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;
    const SELLER: address = @0xA1C04;

    const OFFER_SUI: u64 = 100;

    #[test]
    fun it_works() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_whitelist(&mut scenario);

        let ob_id = test_ob::create_ob(&mut scenario);

        let (seller_safe_id , seller_owner_cap_id) = test_ob::create_safe(
            &mut scenario,
            SELLER,
        );

        let nft_id = test_ob::create_and_deposit_nft(
            &mut scenario,
            seller_safe_id,
            seller_owner_cap_id,
            SELLER,
        );

        test_ob::create_ask(
            &mut scenario,
            seller_safe_id,
            seller_owner_cap_id,
            nft_id,
            SELLER,
            OFFER_SUI,
        );

        let (buyer_safe_id , _buyer_owner_cap_id) = test_ob::create_safe(
            &mut scenario,
            BUYER,
        );

        test_ob::create_bid(
            &mut scenario,
            buyer_safe_id,
            seller_safe_id,
            nft_id,
            ob_id,
            BUYER,
            OFFER_SUI,
        );

        test_scenario::end(scenario);
    }
}
