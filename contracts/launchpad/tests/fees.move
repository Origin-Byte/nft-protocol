module ob_launchpad::test_fees {
    use sui::balance;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::test_scenario::{Self, ctx};

    use ob_launchpad::flat_fee;
    use ob_launchpad::listing;
    use ob_launchpad::test_listing;

    const MARKETPLACE: address = @0xA123;
    const CREATOR: address = @0xA1C05;

    #[test]
    public fun marketplace_default_fee() {
        let scenario = test_scenario::begin(MARKETPLACE);

        // Creates `Marketplace` with default fee
        let (marketplace, listing) = test_listing::init_listing_and_marketplace(
            CREATOR, MARKETPLACE, 2000, &mut scenario,
        );

        listing::pay(&mut listing, balance::create_for_testing<SUI>(20000), 1);

        flat_fee::collect_proceeds_and_fees<SUI>(
            &marketplace, &mut listing, ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, MARKETPLACE);

        let marketplace_proceeds =
            test_scenario::take_from_address<Coin<SUI>>(&scenario, MARKETPLACE);
        assert!(coin::value(&marketplace_proceeds) == 4000, 0);

        test_scenario::return_to_address(MARKETPLACE, marketplace_proceeds);

        let creator_proceeds =
            test_scenario::take_from_address<Coin<SUI>>(&scenario, CREATOR);
        assert!(coin::value(&creator_proceeds) == 16000, 0);

        test_scenario::return_to_address(CREATOR, creator_proceeds);

        test_scenario::return_shared(marketplace);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }
}