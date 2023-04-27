#[test_only]
module ob_launchpad::test_listing {
    use sui::test_scenario::{Self, Scenario, ctx};

    use ob_launchpad::flat_fee;
    use ob_launchpad::listing::{Self, Listing};
    use ob_launchpad::marketplace::{Self, Marketplace};

    public fun init_listing(
        creator: address,
        scenario: &mut Scenario,
    ): Listing {
        test_scenario::next_tx(scenario, creator);

        test_scenario::next_tx(scenario, creator);

        listing::init_listing(
            creator,
            creator,
            ctx(scenario),
        );

        test_scenario::next_tx(scenario, creator);
        let listing = test_scenario::take_shared<Listing>(scenario);

        listing
    }

    public fun init_listing_and_marketplace(
        creator: address,
        marketplace_admin: address,
        scenario: &mut Scenario,
    ): (Marketplace, Listing) {
        test_scenario::next_tx(scenario, marketplace_admin);

        marketplace::init_marketplace(
            creator,
            creator,
            flat_fee::new(0, ctx(scenario)),
            ctx(scenario),
        );

        test_scenario::next_tx(scenario, creator);

        listing::init_listing(
            creator,
            creator,
            ctx(scenario),
        );

        test_scenario::next_tx(scenario, creator);
        let listing = test_scenario::take_shared<Listing>(scenario);
        let marketplace = test_scenario::take_shared<Marketplace>(scenario);

        listing::request_to_join_marketplace(
            &marketplace, &mut listing, ctx(scenario)
        );

        test_scenario::next_tx(scenario, marketplace_admin);

        listing::accept_listing_request(
            &marketplace, &mut listing, ctx(scenario)
        );

        (marketplace, listing)
    }
}
