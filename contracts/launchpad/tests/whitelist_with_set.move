#[test_only]
#[lint_allow(share_owned)]
module ob_launchpad::test_whitelist_with_set {
    use sui::test_scenario::{Self, ctx};

    use sui::object::UID;
    use sui::transfer;

    use ob_launchpad::listing;
    use ob_launchpad::market_whitelist;
    use ob_launchpad::fixed_price;
    use ob_launchpad::test_listing;

    use sui::sui::SUI;

    struct Foo has key, store {
        id: UID,
    }
    struct Witness has drop {}

    const CREATOR: address = @0xA1C05;
    const RAND_WL: address = @0xA1C15;
    const SPOOFER: address = @0xB1C10;

    #[test]
    public fun create_whitelist() {
        let scenario = test_scenario::begin(CREATOR);

        let listing = test_listing::init_listing(CREATOR, &mut scenario);

        // 2. Create `Warehouse`
        let inventory_id = listing::create_warehouse<Foo>(
            &mut listing,
            ctx(&mut scenario),
        );

        let venue_id = fixed_price::create_venue<Foo, SUI>(
            &mut listing, inventory_id, true, 100, ctx(&mut scenario)
        );

        market_whitelist::add_whitelist(&mut listing, venue_id, ctx(&mut scenario));

        market_whitelist::add_addresses(&mut listing, venue_id, vector[RAND_WL, CREATOR], ctx(&mut scenario));
        market_whitelist::remove_addresses(&mut listing, venue_id, vector[RAND_WL, CREATOR], ctx(&mut scenario));

        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad::listing::EWrongAdminNoMembers)]
    public fun fail_add_whitelist_if_not_authorized() {
        let scenario = test_scenario::begin(CREATOR);

        let listing = test_listing::init_listing(CREATOR, &mut scenario);

        // 2. Create `Warehouse`
        let inventory_id = listing::create_warehouse<Foo>(
            &mut listing,
            ctx(&mut scenario),
        );

        let venue_id = fixed_price::create_venue<Foo, SUI>(
            &mut listing, inventory_id, false, 100, ctx(&mut scenario)
        );

        test_scenario::next_tx(&mut scenario, SPOOFER);

        market_whitelist::add_whitelist(&mut listing, venue_id, ctx(&mut scenario)); // this should err

        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad::listing::EWrongAdminNoMembers)]
    public fun fail_add_addrs_to_whitelist_if_not_authorized() {
        let scenario = test_scenario::begin(CREATOR);

        let listing = test_listing::init_listing(CREATOR, &mut scenario);

        // 2. Create `Warehouse`
        let inventory_id = listing::create_warehouse<Foo>(
            &mut listing,
            ctx(&mut scenario),
        );

        let venue_id = fixed_price::create_venue<Foo, SUI>(
            &mut listing, inventory_id, true, 100, ctx(&mut scenario)
        );

        market_whitelist::add_whitelist(&mut listing, venue_id, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, SPOOFER);

        market_whitelist::add_addresses(&mut listing, venue_id, vector[SPOOFER], ctx(&mut scenario)); // This should err

        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }

    #[test]
    public fun checks_in_whitelist_if_authorized() {
        let scenario = test_scenario::begin(CREATOR);

        let listing = test_listing::init_listing(CREATOR, &mut scenario);

        // 2. Create `Warehouse`
        let inventory_id = listing::create_warehouse<Foo>(
            &mut listing,
            ctx(&mut scenario),
        );

        let venue_id = fixed_price::create_venue<Foo, SUI>(
            &mut listing, inventory_id, true, 100, ctx(&mut scenario)
        );

        market_whitelist::add_whitelist(&mut listing, venue_id, ctx(&mut scenario));
        market_whitelist::add_addresses(&mut listing, venue_id, vector[RAND_WL], ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, RAND_WL);
        let cert = market_whitelist::check_in_address(&mut listing, venue_id, ctx(&mut scenario));

        transfer::public_transfer(cert, RAND_WL);
        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad::market_whitelist::ENOT_WHITELISTED)]
    public fun fail_check_in_whitelist_if_not_authorized() {
        let scenario = test_scenario::begin(CREATOR);

        let listing = test_listing::init_listing(CREATOR, &mut scenario);

        // 2. Create `Warehouse`
        let inventory_id = listing::create_warehouse<Foo>(
            &mut listing,
            ctx(&mut scenario),
        );

        let venue_id = fixed_price::create_venue<Foo, SUI>(
            &mut listing, inventory_id, true, 100, ctx(&mut scenario)
        );

        market_whitelist::add_whitelist(&mut listing, venue_id, ctx(&mut scenario));
        market_whitelist::add_addresses(&mut listing, venue_id, vector[RAND_WL], ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, SPOOFER);
        let cert = market_whitelist::check_in_address(&mut listing, venue_id, ctx(&mut scenario));

        transfer::public_transfer(cert, SPOOFER);
        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }
}
