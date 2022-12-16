#[test_only]
module nft_protocol::test_attribution {

    use sui::test_scenario;

    use nft_protocol::attribution::{Self, AttributionDomain};
    use nft_protocol::collection::{Self, Collection, MintCap};
    use nft_protocol::test_utils_2::create_collection_and_whitelist;

    struct Witness has drop {}
    struct Foo has drop {}

    const OWNER: address = @0xA1C05;
    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_attribution() {
        let scenario = test_scenario::begin(CREATOR);

        let (col_id, cap_id, _wl_id) = create_collection_and_whitelist(
            Foo {},
            Witness {},
            CREATOR,
            &mut scenario,
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        let collection = test_scenario::take_shared_by_id<Collection<Foo>>(
            &scenario, col_id
        );

        let mint_cap = test_scenario::take_from_address_by_id<MintCap<Foo>>(
            &scenario, CREATOR, cap_id
        );

        let attribution = attribution::from_address(CREATOR);

        attribution::add_attribution_domain(
            &mut collection, &mut mint_cap, attribution
        );

        // If domain does not exist this function call will fail
        collection::borrow_domain<Foo, AttributionDomain>(&collection);

        test_scenario::return_shared(collection);
        test_scenario::return_to_address(CREATOR, mint_cap);

        test_scenario::end(scenario);
    }
}
