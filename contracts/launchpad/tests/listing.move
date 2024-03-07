#[test_only]
#[lint_allow(share_owned)]
module ob_launchpad::test_listing {
    use sui::test_scenario::{Self, Scenario, ctx};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::sui::SUI;
    use sui::clock;
    use sui::coin::{Self, Coin};

    use ob_launchpad::flat_fee;
    use ob_launchpad::warehouse;
    use ob_launchpad::market_whitelist;
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

    const OWNER: address = @0x1;
    const CREATOR: address = @0x2;
    const MARKETPLACE: address = @0x3;
    const FAKE_ADDRESS: address = @0x4;
    const BUYER: address = @0x5;


    #[test]
    fun it_works_with_permissionless_marketplace_and_start_time() {
        // 1. Create Marketplace
        let scenario = test_scenario::begin(MARKETPLACE);

        let marketplace = marketplace::new(
            MARKETPLACE, // Marketplace admin address
            MARKETPLACE, // Marketplace receiver address
            flat_fee::new(500, ctx(&mut scenario)), // 500 basis points => 5%
            ctx(&mut scenario),
        );

        marketplace::make_permissionless(&mut marketplace, ctx(&mut scenario));

        // 2. Create `Listing`
        test_scenario::next_tx(&mut scenario, CREATOR);

        listing::init_with_marketplace(
            &marketplace,
            CREATOR, // Listing administrator, i.e. NFT Creator
            CREATOR, // Address that receives the net revenue from the sales, i.e. NFT Creator
            ctx(&mut scenario),
        );

        // 3. Mint NFTS to Warehouse
        test_scenario::next_tx(&mut scenario, CREATOR);
        let listing = test_scenario::take_shared<Listing>(&scenario);

        let nft = Foo { id: object::new(ctx(&mut scenario)) };
        let warehouse = warehouse::new<Foo>(ctx(&mut scenario));

        // This scope typically runs inside a mint function from an NFT Contract
        {
            warehouse::deposit_nft(&mut warehouse, nft);
        };

        // 4. Attach Warehouse to Listing
        let inventory_id = listing::insert_warehouse(&mut listing, warehouse, ctx(&mut scenario));

        // 5. Set up the market settings
        let venue_id = fixed_price::create_venue<Foo, SUI>(
            &mut listing,
            inventory_id,
            true, // If its whitelisted or not
            100_000, // NFT price
            ctx(&mut scenario)
        );

        // 6. Setup whitelisting
        market_whitelist::add_whitelist(
            &mut listing,
            venue_id,
            ctx(&mut scenario)
        );

        market_whitelist::add_addresses(
            &mut listing,
            venue_id,
            vector[BUYER],
            ctx(&mut scenario)
        );

        // 7. Configure start time
        listing::set_start_sale_time(
            &mut listing,
            1704157261, // start timestamp
            venue_id,
            ctx(&mut scenario),
        );

        // 8. Initiate sale
        test_scenario::next_tx(&mut scenario, BUYER);

        let clock = clock::create_for_testing(ctx(&mut scenario));
        clock::set_for_testing(&mut clock, 1704157261);

        listing::start_sale_with_time(
            &mut listing,
            venue_id,
            &clock,
        );

        let wl_certificate = market_whitelist::check_in_address(
            &mut listing,
            venue_id,
            ctx(&mut scenario)
        );

        let funds = coin::mint_for_testing<SUI>(100_000, ctx(&mut scenario)); // 100_000 => NFT price

        // This function will buy an NFT from the launchpad and transfer
        // it to a newly create Kiosk. If the user already has a kiosk
        // consider using `buy_whitelisted_nft_into_kiosk` instead
        fixed_price::buy_whitelisted_nft<Foo, SUI>(
            &mut listing,
            venue_id,
            &mut funds,
            wl_certificate,
            ctx(&mut scenario)
        );

        // 9. Redeem proceeds from sale
        test_scenario::next_tx(&mut scenario, CREATOR); // This endpoint can also be called by the marketplace

        // It will transfer the proceeds to the respective `Listing.receiver`
        // and fees to the `Marketplace.receiver`
        flat_fee::collect_proceeds_and_fees<SUI>(
            &marketplace, &mut listing, ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, MARKETPLACE);

        let marketplace_proceeds =
            test_scenario::take_from_address<Coin<SUI>>(&scenario, MARKETPLACE);
        assert!(coin::value(&marketplace_proceeds) == 5_000, 0);


        let creator_proceeds =
            test_scenario::take_from_address<Coin<SUI>>(&scenario, CREATOR);
        assert!(coin::value(&creator_proceeds) == 95_000, 0);

        test_scenario::return_to_address(MARKETPLACE, marketplace_proceeds);
        test_scenario::return_to_address(CREATOR, creator_proceeds);
        listing::destroy_for_testing(listing);
        marketplace::destroy_for_testing(marketplace);
        coin::burn_for_testing(funds);
        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }

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

        let marketplace = test_scenario::take_shared<Marketplace>(&scenario);

        listing::request_to_join_marketplace(
            &marketplace, &mut listing, ctx(&mut scenario)
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
        let marketplace = test_scenario::take_shared<Marketplace>(&scenario);
        let listing = test_scenario::take_shared<Listing>(&scenario);

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
