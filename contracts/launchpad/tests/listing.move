#[test_only]
module ob_launchpad::test_listing {
    use sui::test_scenario::{Self, Scenario, ctx};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::sui::SUI;

    use ob_launchpad::flat_fee;
    use ob_launchpad::marketplace as mkt;
    use ob_launchpad::fixed_price;
    use ob_launchpad::listing::{Self, Listing};
    use ob_launchpad::marketplace::{Self, Marketplace};

    struct Foo has key, store {
        id: UID,
    }

    struct Witness has drop {}

    struct FakeDFObject has store {}
    struct FakeDFKey has store, copy, drop {}

    const OWNER: address = @0xA1C05;
    const CREATOR: address = @0xA1C05;
    const MARKETPLACE: address = @0xA1C20;
    const FAKE_ADDRESS: address = @0x1;

    #[test]
    #[expected_failure(abort_code = ob_launchpad::listing::EWrongAdminNoMembers)]
    fun test_fail_turn_sale_on_as_fake_admin() {
        // 1. Create `Listing`
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(MARKETPLACE, &mut scenario);

        // 2. Create `Warehouse`
        let inventory_id = listing::create_warehouse<Foo>(
            &mut listing,
            ctx(&mut scenario),
        );
        let venue_id = fixed_price::create_venue<Foo, SUI>(
            &mut listing, inventory_id, false, 100, ctx(&mut scenario)
        );

        test_scenario::next_tx(&mut scenario, FAKE_ADDRESS);

        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad::listing::EWrongAdminNoMembers)]
    fun test_fail_turn_sale_off_as_fake_admin() {
        // 1. Create `Listing`
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(MARKETPLACE, &mut scenario);

        // 2. Create `Warehouse`
        let inventory_id = listing::create_warehouse<Foo>(
            &mut listing,
            ctx(&mut scenario),
        );
        let venue_id = fixed_price::create_venue<Foo, SUI>(
            &mut listing, inventory_id, false, 100, ctx(&mut scenario)
        );
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        // === Adverserial attack ===

        test_scenario::next_tx(&mut scenario, FAKE_ADDRESS);
        listing::sale_off(&mut listing, venue_id, ctx(&mut scenario));

        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad::listing::EMarketplaceListingMismatch)]
    fun test_fail_add_custom_fee_as_fake_marketplace_when_none() {
        // 1. Create `Listing`
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(MARKETPLACE, &mut scenario);

        // === Adverserial attack ===

        test_scenario::next_tx(&mut scenario, FAKE_ADDRESS);

        let dummy_fee_obj = Foo { id: object::new(ctx(&mut scenario))};

        let fake_mktplace = mkt::new(
            FAKE_ADDRESS,
            FAKE_ADDRESS,
            dummy_fee_obj,
            ctx(&mut scenario)
        );

        let dummy_fee_obj = Foo { id: object::new(ctx(&mut scenario))};

        listing::add_fee(
            &fake_mktplace, &mut listing, dummy_fee_obj, ctx(&mut scenario)
        );

        transfer::public_share_object(fake_mktplace);
        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad::listing::EWrongAdminNoMembers)]
    fun fail_access_to_inventory_as_fake_admin() {
        // 1. Create `Listing`
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(MARKETPLACE, &mut scenario);

        // 2. Create `Warehouse`
        let inventory_id = listing::create_warehouse<Foo>(
            &mut listing,
            ctx(&mut scenario),
        );
        let _venue_id = fixed_price::create_venue<Foo, SUI>(
            &mut listing, inventory_id, false, 100, ctx(&mut scenario)
        );

        // === Adverserial attack ===

        test_scenario::next_tx(&mut scenario, FAKE_ADDRESS);

        let _inventory = listing::inventory_admin_mut<Foo>(
            &mut listing,
            inventory_id,
            ctx(&mut scenario),
        );

        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad::listing::EWrongAdminNoMembers)]
    fun fail_add_nft_inventory_as_fake_admin() {
        // 1. Create `Listing`
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(MARKETPLACE, &mut scenario);

        // 2. Create `Warehouse`
        let inventory_id = listing::create_warehouse<Foo>(
            &mut listing,
            ctx(&mut scenario),
        );
        let _venue_id = fixed_price::create_venue<Foo, SUI>(
            &mut listing, inventory_id, false, 100, ctx(&mut scenario)
        );

        // === Adverserial attack ===

        test_scenario::next_tx(&mut scenario, FAKE_ADDRESS);

        listing::add_nft<Foo>(
            &mut listing,
            inventory_id,
            Foo { id: object::new(ctx(&mut scenario)) },
            ctx(&mut scenario),
        );

        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad::listing::EWrongAdminNoMembers)]
    fun fail_add_venue_as_fake_admin() {
        // 1. Create `Listing`
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(MARKETPLACE, &mut scenario);

        // 2. Create `Warehouse`
        let inventory_id = listing::create_warehouse<Foo>(
            &mut listing,
            ctx(&mut scenario),
        );
        let _venue_id = fixed_price::create_venue<Foo, SUI>(
            &mut listing, inventory_id, false, 100, ctx(&mut scenario)
        );

        // === Adverserial attack ===

        test_scenario::next_tx(&mut scenario, FAKE_ADDRESS);

        listing::create_venue<FakeDFObject, FakeDFKey>(
            &mut listing,
            FakeDFKey {},
            FakeDFObject {},
            false,
            ctx(&mut scenario),
        );

        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad::listing::EWrongAdminNoMembers)]
    fun fail_request_to_join_marketplace_as_fake_listing_admin() {
        // 1. Create `Listing`
        let scenario = test_scenario::begin(CREATOR);

        let (marketplace, listing) = init_listing_and_marketplace(
            MARKETPLACE,
            MARKETPLACE,
            100,
            &mut scenario
        );

        transfer::public_share_object(marketplace);

        // === Adverserial attack ===

        test_scenario::next_tx(&mut scenario, FAKE_ADDRESS);

        let marketplace = test_scenario::take_shared<Marketplace>(&mut scenario);

        listing::request_to_join_marketplace(
            &mut marketplace, &mut listing, ctx(&mut scenario)
        );

        test_scenario::return_shared(marketplace);
        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad::marketplace::ENotAMemberNorAdmin)]
    fun fail_accept_listing_request_as_fake_marketplace_admin() {
        //listing::accept_listing_request

        // 1. Create `Listing`
        let scenario = test_scenario::begin(CREATOR);

        let (marketplace, listing) = init_listing_and_marketplace(
            MARKETPLACE,
            MARKETPLACE,
            100,
            &mut scenario
        );

        transfer::public_share_object(marketplace);
        transfer::public_share_object(listing);

        // === Adverserial attack ===

        test_scenario::next_tx(&mut scenario, FAKE_ADDRESS);
        let marketplace = test_scenario::take_shared<Marketplace>(&mut scenario);
        let listing = test_scenario::take_shared<Listing>(&mut scenario);

        let fake_listing = init_listing(OWNER, &mut scenario);

        listing::accept_listing_request(&marketplace, &mut fake_listing, ctx(&mut scenario));

        test_scenario::return_shared(marketplace);
        test_scenario::return_shared(listing);
        test_scenario::return_shared(fake_listing);
        test_scenario::end(scenario);
    }

    #[test]
    fun fail_create_warehouse_as_fake_listing_admin() {
        //listing::create_warehouse
        // TODO
    }

    #[test]
    fun fail_create_venue_as_fake_listing_admin() {
        //listing::create_venue
        // TODO
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad::listing::EMarketplaceListingMismatch)]
    fun test_fail_add_custom_fee_as_fake_marketplace_when_some() {
        // 1. Create `Listing`
        let scenario = test_scenario::begin(CREATOR);

        let (marketplace, listing) = init_listing_and_marketplace(
            MARKETPLACE,
            MARKETPLACE,
            100,
            &mut scenario
        );

        transfer::public_share_object(marketplace);

        // === Adverserial attack ===

        test_scenario::next_tx(&mut scenario, FAKE_ADDRESS);

        let dummy_fee_obj = Foo { id: object::new(ctx(&mut scenario))};

        let fake_mktplace = mkt::new(
            FAKE_ADDRESS,
            FAKE_ADDRESS,
            dummy_fee_obj,
            ctx(&mut scenario)
        );

        let dummy_fee_obj = Foo { id: object::new(ctx(&mut scenario))};

        listing::add_fee(
            &fake_mktplace, &mut listing, dummy_fee_obj, ctx(&mut scenario)
        );

        transfer::public_share_object(fake_mktplace);
        transfer::public_share_object(listing);
        test_scenario::end(scenario);
    }

    #[test_only]
    public fun init_listing(
        creator: address,
        scenario: &mut Scenario,
    ): Listing {
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

    #[test_only]
    public fun init_listing_and_marketplace(
        creator: address,
        marketplace_admin: address,
        default_fee: u64,
        scenario: &mut Scenario,
    ): (Marketplace, Listing) {
        test_scenario::next_tx(scenario, marketplace_admin);

        marketplace::init_marketplace(
            marketplace_admin,
            marketplace_admin,
            flat_fee::new(default_fee, ctx(scenario)),
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
