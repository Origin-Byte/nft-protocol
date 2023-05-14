#[test_only]
module ob_launchpad::test_whitelist {
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

    const OWNER: address = @0xA1C05;
    const CREATOR: address = @0xA1C05;
    const MARKETPLACE: address = @0xA1C20;

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
            &mut listing, inventory_id, false, 100, ctx(&mut scenario)
        );

        let cert = market_whitelist::new(&mut listing, venue_id, ctx(&mut scenario));

        transfer::public_transfer(cert, OWNER);
        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad::listing::EUndefinedVenue)]
    public fun fail_spoof_whitelist() {
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

        transfer::public_share_object(listing);

        test_scenario::next_tx(&mut scenario, OWNER);
        let fake_listing = test_listing::init_listing(OWNER, &mut scenario);

        let cert = market_whitelist::new(&mut fake_listing, venue_id, ctx(&mut scenario));

        transfer::public_transfer(cert, OWNER);

        transfer::public_share_object(fake_listing);
        test_scenario::end(scenario);
    }
}
