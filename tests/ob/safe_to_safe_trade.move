#[test_only]
/// This test focuses on integration between OB, Safe, a allowlist and
/// royalty collection.
///
/// We simulate a trade between two Safes, end to end, including royalty
/// collection.
module nft_protocol::test_ob_safe_to_safe_trade {
    use nft_protocol::test_utils as test_ob;
    use originmate::box::Box;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use nft_protocol::royalties;
    use sui::test_scenario;

    const BUYER: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;
    const SELLER: address = @0xA1C04;

    const OFFER_SUI: u64 = 100;

    #[test]
    fun it_works() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(&mut scenario);

        test_ob::create_ob<test_ob::Foo>(&mut scenario);

        test_ob::create_safe(&mut scenario, SELLER);
        let nft_id = test_ob::create_and_deposit_nft(
            &mut scenario,
            SELLER,
        );
        test_ob::create_ask<test_ob::Foo>(
            &mut scenario,
            nft_id,
            OFFER_SUI,
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
        let payment_for_seller: royalties::TradePayment<test_ob::Foo, SUI> =
            test_scenario::take_shared(&mut scenario);
        assert!(royalties::beneficiary(&payment_for_seller) == SELLER, 0);
        test_scenario::return_shared(payment_for_seller);

        test_scenario::end(scenario);
    }

    #[test]
    fun it_works_with_generic() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_ob<Box<bool>>(&mut scenario);
        test_ob::create_safe(&mut scenario, SELLER);
        let nft_id = test_ob::create_and_deposit_generic_nft(
            &mut scenario,
            SELLER,
        );
        test_ob::create_ask<Box<bool>>(
            &mut scenario,
            nft_id,
            OFFER_SUI,
        );

        test_ob::create_safe(&mut scenario, BUYER);
        test_ob::create_bid<Box<bool>>(&mut scenario, OFFER_SUI);
        test_ob::finish_generic_trade<Box<bool>>(
            &mut scenario,
            nft_id,
            BUYER,
            SELLER,
        );

        test_scenario::next_tx(&mut scenario, SELLER);
        let offer: Coin<SUI> = test_scenario::take_from_sender(&mut scenario);
        assert!(coin::value(&offer) == OFFER_SUI, 0);
        test_scenario::return_to_sender(&mut scenario, offer);

        test_scenario::end(scenario);
    }
}
