#[test_only]
module ob_launchpad::test_delegation {
    use sui::test_scenario::{Self, ctx};

    use sui::object::UID;
    use sui::transfer;

    use ob_launchpad::listing;
    use ob_launchpad::fixed_price;
    use ob_launchpad::test_listing;

    use sui::sui::SUI;

    struct Foo has key, store {
        id: UID,
    }

    const CREATOR: address = @0xA1C05;
    const DELEGATE: address = @0xA1C09;
    const ATACKER: address = @0xB1C00;

    #[test]
    public fun add_delegates() {
        let scenario = test_scenario::begin(CREATOR);

        let listing = test_listing::init_listing(CREATOR, &mut scenario);

        listing::add_member(&mut listing, DELEGATE, ctx(&mut scenario));

        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad::listing::EWrongAdmin)]
    public fun fail_add_delegates() {
        let scenario = test_scenario::begin(CREATOR);

        let listing = test_listing::init_listing(CREATOR, &mut scenario);

        test_scenario::next_tx(&mut scenario, ATACKER);

        listing::add_member(&mut listing, DELEGATE, ctx(&mut scenario));

        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }

    #[test]
    public fun delegate() {
        let scenario = test_scenario::begin(CREATOR);

        let listing = test_listing::init_listing(CREATOR, &mut scenario);

        listing::add_member(&mut listing, DELEGATE, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, DELEGATE);

        // Create Warehouses and Venues
        let inventory_id = listing::create_warehouse<Foo>(
            &mut listing,
            ctx(&mut scenario),
        );

        let venue_id = fixed_price::create_venue<Foo, SUI>(
            &mut listing, inventory_id, false, 100, ctx(&mut scenario)
        );

        test_scenario::next_tx(&mut scenario, DELEGATE);

        // Toggle sale on/off
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));
        listing::sale_off(&mut listing, venue_id, ctx(&mut scenario));

        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad::listing::ENotAMemberNorAdmin)]
    public fun add_and_remove_delegate() {
        let scenario = test_scenario::begin(CREATOR);

        let listing = test_listing::init_listing(CREATOR, &mut scenario);
        listing::add_member(&mut listing, DELEGATE, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);
        listing::remove_member(&mut listing, DELEGATE, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, DELEGATE);

        // Create Warehouses and Venues
        let inventory_id = listing::create_warehouse<Foo>(
            &mut listing,
            ctx(&mut scenario),
        );

        let venue_id = fixed_price::create_venue<Foo, SUI>(
            &mut listing, inventory_id, false, 100, ctx(&mut scenario)
        );

        test_scenario::next_tx(&mut scenario, DELEGATE);

        // Toggle sale on/off
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));
        listing::sale_off(&mut listing, venue_id, ctx(&mut scenario));

        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }
}
