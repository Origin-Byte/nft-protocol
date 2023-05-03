#[test_only]
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

        listing::pay(&mut listing, balance::create_for_testing<SUI>(1123), 1);

        flat_fee::collect_proceeds_and_fees<SUI>(
            &marketplace, &mut listing, ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, MARKETPLACE);

        let marketplace_proceeds =
            test_scenario::take_from_address<Coin<SUI>>(&scenario, MARKETPLACE);
        assert!(coin::value(&marketplace_proceeds) == 224, 0);

        test_scenario::return_to_address(MARKETPLACE, marketplace_proceeds);

        let creator_proceeds =
            test_scenario::take_from_address<Coin<SUI>>(&scenario, CREATOR);
        assert!(coin::value(&creator_proceeds) == 899, 0);

        test_scenario::return_to_address(CREATOR, creator_proceeds);

        test_scenario::return_shared(marketplace);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    public fun listing_fee() {
        let scenario = test_scenario::begin(MARKETPLACE);

        // Creates `Marketplace` with default fee
        let (marketplace, listing) = test_listing::init_listing_and_marketplace(
            CREATOR, MARKETPLACE, 2000, &mut scenario,
        );

        // Overwrite `Marketplace` fee policy with custom `Listing` policy
        let fee = flat_fee::new(4000, ctx(&mut scenario));
        listing::add_fee(&marketplace, &mut listing, fee, ctx(&mut scenario));

        listing::pay(&mut listing, balance::create_for_testing<SUI>(1123), 1);

        flat_fee::collect_proceeds_and_fees<SUI>(
            &marketplace, &mut listing, ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, MARKETPLACE);

        let marketplace_proceeds =
            test_scenario::take_from_address<Coin<SUI>>(&scenario, MARKETPLACE);
        assert!(coin::value(&marketplace_proceeds) == 449, 0);

        test_scenario::return_to_address(MARKETPLACE, marketplace_proceeds);

        let creator_proceeds =
            test_scenario::take_from_address<Coin<SUI>>(&scenario, CREATOR);
        assert!(coin::value(&creator_proceeds) == 674, 0);

        test_scenario::return_to_address(CREATOR, creator_proceeds);

        test_scenario::return_shared(marketplace);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    public fun standalone_listing() {
        let scenario = test_scenario::begin(MARKETPLACE);

        // Creates `Marketplace` with default fee
        let listing = test_listing::init_listing(
            CREATOR, &mut scenario,
        );

        listing::pay(&mut listing, balance::create_for_testing<SUI>(1123), 1);

        listing::collect_proceeds<SUI>(&mut listing, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, MARKETPLACE);

        assert!(!test_scenario::has_most_recent_for_address<Coin<SUI>>(MARKETPLACE), 0);

        let creator_proceeds =
            test_scenario::take_from_address<Coin<SUI>>(&scenario, CREATOR);
        assert!(coin::value(&creator_proceeds) == 1123, 0);

        test_scenario::return_to_address(CREATOR, creator_proceeds);

        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }
}
