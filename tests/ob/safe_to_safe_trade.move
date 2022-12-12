#[test_only]
module nft_protocol::test_ob_safe_to_safe_trade {
    //! This test focuses on integration between OB, Safe, a whitelist and
    //! royalty collection.
    //!
    //! We simulate a trade between two Safes, end to end, including royalty
    //! collection.
    use sui::sui::SUI;
    use sui::coin;
    use std::vector;
    use sui::object::{Self, ID};
    use sui::test_scenario::{Self, Scenario, ctx};
    use sui::transfer::{transfer, share_object};

    use nft_protocol::nft;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::ob::{Self, Orderbook};
    use nft_protocol::safe::{Self, Safe};
    use nft_protocol::transfer_whitelist::{Self, Whitelist};

    use nft_protocol::test_ob_utils as test_ob;

    const CREATOR: address = @0xA1C05;
    const OFFER_SUI: u64 = 100;

    #[test]
    fun it_works() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_whitelist(&mut scenario);

        test_ob::create_ob(&mut scenario);

        let nft_id =
            test_ob::create_seller_safe_and_make_an_offer_for_nft_id(
                &mut scenario
            );

        test_ob::buy_nft(&mut scenario, nft_id);

        test_scenario::end(scenario);
    }
}
