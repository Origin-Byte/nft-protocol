#[test_only]
module nft_protocol::test_royalty {

    use sui::test_scenario::{Self, ctx};

    use nft_protocol::royalty;
    use nft_protocol::royalty_strategy_bps as royalty_bps;
    use nft_protocol::royalty_strategy_constant as royalty_const;
    use nft_protocol::collection::{Collection, MintCap};
    use nft_protocol::test_utils_2::create_collection_and_whitelist;

    struct Witness has drop {}
    struct Foo has drop {}

    const OWNER: address = @0xA1C05;
    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_royalty() {
        let scenario = test_scenario::begin(CREATOR);

        let (col_id, cap_id, _wl_id) = create_collection_and_whitelist(
            Foo {},
            Witness {},
            &mut scenario,
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        let collection = test_scenario::take_shared_by_id<Collection<Foo>>(
            &scenario, col_id
        );

        let mint_cap = test_scenario::take_from_address_by_id<MintCap<Foo>>(
            &scenario, CREATOR, cap_id
        );

        let royalty = royalty::new(ctx(&mut scenario));

        royalty::add_proportional_royalty(
            &mut royalty,
            royalty_bps::new(100),
        );

        royalty::add_constant_royalty(
            &mut royalty,
            royalty_const::new(100),
        );

        royalty::add_royalty_domain(
            &mut collection, &mut mint_cap, royalty
        );

        test_scenario::return_shared(collection);
        test_scenario::return_to_address(CREATOR, mint_cap);

        test_scenario::end(scenario);
    }
}
