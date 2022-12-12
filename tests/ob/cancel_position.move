#[test_only]
module nft_protocol::test_ob_cancel_position {
    // TODO: open a new bid and cancel it
    // open a new ask and cancel it
    // open a new bid with commission and cancel it
    // open a new ask with commission and cancel it

    use nft_protocol::nft;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::ob::{Self, Orderbook};
    use nft_protocol::safe::{Self, Safe};
    use nft_protocol::transfer_whitelist::{Self, Whitelist};
    use sui::sui::SUI;
    use sui::coin;
    use std::vector;
    use sui::object::{Self, ID};
    use sui::test_scenario::{Self, Scenario, ctx};
    use sui::transfer::{transfer, share_object};

    use nft_protocol::test_ob_utils as test_ob;

    const BUYER: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;
    const SELLER: address = @0xA1C04;

    const OFFER_SUI: u64 = 100;

    struct Foo has drop {} // collection
    struct Witness has drop {} // collection witness, must be named witness
    struct WhitelistWitness has drop {}

    #[test]
    fun it_cancels_bid() {
        // TODO: Assert balance in coins
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_whitelist(&mut scenario);

        test_ob::create_ob(&mut scenario);

        test_ob::create_seller_safe_and_make_an_offer_for_nft_id(
            &mut scenario
        );

        test_ob::cancel_bid(&mut scenario);

        test_scenario::end(scenario);
    }
}
