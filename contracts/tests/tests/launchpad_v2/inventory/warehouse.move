#[test_only]
module ob_tests::test_warehouse {
    use sui::test_scenario::{Self, ctx};
    use sui::transfer;

    use ob_launchpad_v2::launchpad::{Self};
    use ob_launchpad_v2::venue::Venue;
    use ob_launchpad_v2::warehouse::{Self, Warehouse};
    use ob_tests::test_utils::{Self as utils, Foo};

    const MARKETPLACE: address = @0xA1C08;

    #[test]
    public fun test_create_warehouse() {
        let scenario = test_scenario::begin(MARKETPLACE);

        // 1. Create a Launchpad Listing
        let (listing, launch_cap) = launchpad::new(ctx(&mut scenario));

        // 2. Create Sales Venue
        let venue = utils::create_dummy_venue(&mut listing, &launch_cap, ctx(&mut scenario));
        transfer::public_share_object(venue);
        transfer::public_share_object(listing);

        test_scenario::next_tx(&mut scenario, MARKETPLACE);

        // 4. Create warehouse
        let warehouse = warehouse::new<Foo>(ctx(&mut scenario));

        // 5. Mint NFTs to the Warehouse
        let supply = 7_000;
        utils::batch_mint_foo_nft_to_warehouse(&mut warehouse, supply, ctx(&mut scenario));
        warehouse::share(warehouse);

        // 6. Register NFTs
        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let warehouse = test_scenario::take_shared<Warehouse<Foo>>(&scenario);
        let venue = test_scenario::take_shared<Venue>(&scenario);

        warehouse::register_supply(&launch_cap, &mut venue, &mut warehouse, supply);

        test_scenario::return_shared(venue);
        test_scenario::return_shared(warehouse);
        transfer::public_transfer(launch_cap, MARKETPLACE);

        test_scenario::end(scenario);
    }

    #[test]
    public fun create_private_warehouse_and_share() {
        let scenario = test_scenario::begin(MARKETPLACE);

        // 1. Create warehouse and make it a private object
        let warehouse = warehouse::new<Foo>(ctx(&mut scenario));

        transfer::public_transfer(warehouse, MARKETPLACE);
        test_scenario::next_tx(&mut scenario, MARKETPLACE);

        // 2. Share Warehouse with a new UID, keeping all its internal state
        let warehouse = test_scenario::take_from_address<Warehouse<Foo>>(
            &scenario, MARKETPLACE
        );
        warehouse::share_from_private(warehouse, ctx(&mut scenario));

        test_scenario::end(scenario);
    }
}
