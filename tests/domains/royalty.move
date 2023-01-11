#[test_only]
module nft_protocol::test_royalty {

    use sui::test_scenario::{Self, ctx};

    use nft_protocol::royalty::{Self, RoyaltyDomain};
    use nft_protocol::collection::{Self, Collection, MintCap};
    use nft_protocol::test_utils::create_collection_and_allowlist_with_type;

    struct Witness has drop {}
    struct Foo has drop {}

    const OWNER: address = @0xA1C05;
    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_royalty() {
        let scenario = test_scenario::begin(CREATOR);

        let (col_id, cap_id, _wl_id) = create_collection_and_allowlist_with_type(
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

        let royalty = royalty::from_address(CREATOR, ctx(&mut scenario));
        royalty::add_proportional_royalty(&mut royalty, 100);
        royalty::add_constant_royalty(&mut royalty, 100);
        royalty::add_royalty_domain(
            &mut collection, &mut mint_cap, royalty
        );

        // If domain does not exist this function call will fail
        collection::borrow_domain<Foo, RoyaltyDomain>(&collection);

        test_scenario::return_shared(collection);
        test_scenario::return_to_address(CREATOR, mint_cap);

        test_scenario::end(scenario);
    }
}
