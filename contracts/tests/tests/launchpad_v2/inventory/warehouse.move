#[test_only]
module ob_tests::test_warehouse {
    use sui::test_scenario::{Self, ctx};
    use sui::transfer;

    use ob_launchpad_v2::launchpad::{Self};
    use ob_launchpad_v2::warehouse::{Self};
    use ob_tests::test_utils::{Self as utils, Foo};

    const MARKETPLACE: address = @0xA1C08;

    #[test]
    public fun create_warehouse() {
        let scenario = test_scenario::begin(MARKETPLACE);

        // 1. Create a Launchpad Listing
        let (listing, launch_cap) = launchpad::new(ctx(&mut scenario));

        // 2. Create Sales Venue
        let venue = utils::create_dummy_venue(&mut listing, &launch_cap, ctx(&mut scenario));

        let supply = 7_000;

        // 4. Create warehouse
        let warehouse = warehouse::new<Foo>(ctx(&mut scenario));

        // 4. Mint NFTs to the Warehouse
        utils::batch_mint_foo_nft_to_warehouse(&mut warehouse, supply, ctx(&mut scenario));
        warehouse::register_supply(&launch_cap, &mut venue, &mut warehouse, supply);

        transfer::public_share_object(warehouse);
        transfer::public_share_object(listing);
        transfer::public_share_object(venue);
        transfer::public_transfer(launch_cap, MARKETPLACE);

        test_scenario::end(scenario);
    }
}
