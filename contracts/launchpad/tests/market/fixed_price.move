#[test_only]
module ob_launchpad::test_fixed_price {
    use sui::sui::SUI;
    use sui::coin;
    use sui::balance;
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::test_scenario::{Self, Scenario, ctx};

    use ob_launchpad::venue;
    use ob_launchpad::proceeds;
    use ob_launchpad::warehouse;
    use ob_launchpad::listing::{Self, Listing};
    use ob_launchpad::market_whitelist::{Self, Certificate};
    use ob_launchpad::fixed_price;

    use ob_launchpad::test_listing::init_listing;

    struct Foo has key, store {
        id: UID,
    }
    struct Witness has drop {}

    const CREATOR: address = @0xA1C05;
    const BUYER: address = @0xA1C06;

    /// Initializes warehouse and market
    fun init_market(
        listing: &mut Listing,
        price: u64,
        is_whitelisted: bool,
        scenario: &mut Scenario,
    ): (ID, ID) {
        let inventory_id = listing::create_warehouse<Foo>(listing, ctx(scenario));
        let venue_id = fixed_price::create_venue<Foo, SUI>(
            listing, inventory_id, is_whitelisted, price, ctx(scenario)
        );

        (inventory_id, venue_id)
    }

    #[test]
    fun create_market() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);

        let (_, venue_id) =
            init_market(&mut listing, 10, false, &mut scenario);
        let market = fixed_price::borrow_market(
            listing::borrow_venue(&listing, venue_id)
        );

        assert!(fixed_price::price<SUI>(market) == 10, 0);

        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = venue::EVenueNotLive)]
    fun try_buy_not_live() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);

        let (_, venue_id) =
            init_market(&mut listing, 10, false, &mut scenario);

        let wallet = coin::mint_for_testing<SUI>(10, ctx(&mut scenario));
        fixed_price::buy_nft<Foo, SUI>(
            &mut listing,
            venue_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        transfer::public_transfer(wallet, BUYER);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = warehouse::EEmpty)]
    fun try_buy_no_supply() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);

        let (_, venue_id) =
            init_market(&mut listing, 10, false, &mut scenario);
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        let wallet = coin::mint_for_testing<SUI>(10, ctx(&mut scenario));
        fixed_price::buy_nft<Foo, SUI>(
            &mut listing,
            venue_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        transfer::public_transfer(wallet, BUYER);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    fun buy_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);

        let (warehouse_id, venue_id) =
            init_market(&mut listing, 10, false, &mut scenario);

        let nft = Foo { id: object::new(ctx(&mut scenario)) };

        listing::add_nft(
            &mut listing, warehouse_id, nft, ctx(&mut scenario)
        );

        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        let wallet = coin::mint_for_testing<SUI>(15, ctx(&mut scenario));

        fixed_price::buy_nft<Foo, SUI>(
            &mut listing,
            venue_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        // Check wallet balances
        assert!(coin::value(&wallet) == 5, 0);

        // Nft should have sold at 10
        let proceeds = listing::borrow_proceeds(&listing);
        assert!(proceeds::total(proceeds) == 1, 0);
        assert!(balance::value(proceeds::balance<SUI>(proceeds)) == 10, 0);

        // Check NFT was transferred with correct logical owner
        let nft = test_scenario::take_from_address<Foo>(
            &scenario, BUYER
        );
        transfer::public_transfer(nft, BUYER);

        transfer::public_transfer(wallet, BUYER);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = venue::EVenueWhitelisted)]
    fun try_buy_whitelisted_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);

        let (_, venue_id) =
            init_market(&mut listing, 10, true, &mut scenario);
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        let wallet = coin::mint_for_testing<SUI>(10, ctx(&mut scenario));
        fixed_price::buy_nft<Foo, SUI>(
            &mut listing,
            venue_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        assert!(coin::value(&wallet) == 0, 0);

        transfer::public_transfer(wallet, BUYER);
        test_scenario::next_tx(&mut scenario, BUYER);

        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    fun buy_whitelisted_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);

        let (warehouse_id, venue_id) =
            init_market(&mut listing, 10, true, &mut scenario);

        listing::add_nft(
            &mut listing,
            warehouse_id,
            Foo { id: object::new(ctx(&mut scenario)) },
            ctx(&mut scenario)
        );

        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        market_whitelist::issue(&listing, venue_id, BUYER, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        let certificate = test_scenario::take_from_address<Certificate>(
            &scenario, BUYER
        );

        let wallet = coin::mint_for_testing<SUI>(10, ctx(&mut scenario));
        fixed_price::buy_whitelisted_nft<Foo, SUI>(
            &mut listing,
            venue_id,
            &mut wallet,
            certificate,
            ctx(&mut scenario),
        );

        transfer::public_transfer(wallet, BUYER);
        test_scenario::next_tx(&mut scenario, BUYER);

        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = listing::ENotAMemberNorAdmin)]
    fun try_change_price() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);

        let (_, venue_id) =
            init_market(&mut listing, 10, true, &mut scenario);

        test_scenario::next_tx(&mut scenario, BUYER);

        fixed_price::set_price<SUI>(
            &mut listing, venue_id, 20, ctx(&mut scenario)
        );

        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    fun change_price() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);

        let (_, venue_id) =
            init_market(&mut listing, 10, true, &mut scenario);

        test_scenario::next_tx(&mut scenario, CREATOR);

        fixed_price::set_price<SUI>(
            &mut listing, venue_id, 20, ctx(&mut scenario)
        );

        let market = fixed_price::borrow_market(
            listing::borrow_venue(&listing, venue_id)
        );
        assert!(fixed_price::price<SUI>(market) == 20, 0);

        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }
}
