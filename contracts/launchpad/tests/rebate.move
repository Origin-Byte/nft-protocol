#[test_only]
module ob_launchpad::test_rebate {
    use sui::test_scenario::{Self, Scenario, ctx};
    use sui::object::{Self, ID, UID};
    use sui::sui::SUI;
    use sui::coin;
    use sui::balance;
    use sui::transfer;

    use ob_launchpad::fixed_price;
    use ob_launchpad::listing::{Self, Listing};
    use ob_launchpad::rebate;
    use ob_launchpad::test_listing::init_listing;

    const USER: address = @0xA1C05;
    const MARKETPLACE: address = @0xA1C20;

    struct Foo has key, store {
        id: UID,
    }

    struct Bar has key, store {
        id: UID,
    }

    struct FT {}

    struct Witness has drop {}

    fun init_market(listing: &mut Listing, scenario: &mut Scenario): ID {
        let (inventory_id, venue_id) = ob_launchpad::test_fixed_price::init_market<Foo, SUI>(
            listing, 20, false, scenario,
        );

        let nft = Foo { id: object::new(ctx(scenario)) };
        listing::add_nft(listing, inventory_id, nft, ctx(scenario));

        let nft = Foo { id: object::new(ctx(scenario)) };
        listing::add_nft(listing, inventory_id, nft, ctx(scenario));

        let nft = Foo { id: object::new(ctx(scenario)) };
        listing::add_nft(listing, inventory_id, nft, ctx(scenario));

        let nft = Foo { id: object::new(ctx(scenario)) };
        listing::add_nft(listing, inventory_id, nft, ctx(scenario));

        listing::sale_on(listing, venue_id, ctx(scenario));

        venue_id
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad::listing::EWrongAdmin)]
    fun test_try_set_rebate_not_admin() {
        let scenario = test_scenario::begin(MARKETPLACE);
        let listing = init_listing(MARKETPLACE, &mut scenario);

        test_scenario::next_tx(&mut scenario, USER);

        listing::set_rebate<Foo, SUI>(&mut listing, 10, ctx(&mut scenario));

        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    /// Check that rebates can be set individually of `T` and `FT`
    fun test_set_rebate() {
        let scenario = test_scenario::begin(MARKETPLACE);
        let listing = init_listing(MARKETPLACE, &mut scenario);

        listing::set_rebate<Foo, SUI>(&mut listing, 10, ctx(&mut scenario));
        assert!(
            rebate::borrow_rebate_amount(listing::borrow_rebate<Foo, SUI>(&mut listing)) == 10,
            0,
        );

        listing::set_rebate<Foo, FT>(&mut listing, 20, ctx(&mut scenario));
        assert!(
            rebate::borrow_rebate_amount(listing::borrow_rebate<Foo, FT>(&mut listing)) == 20,
            0,
        );

        listing::set_rebate<Bar, SUI>(&mut listing, 30, ctx(&mut scenario));
        assert!(
            rebate::borrow_rebate_amount(listing::borrow_rebate<Bar, SUI>(&mut listing)) == 30,
            0,
        );

        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_buy_rebate() {
        let scenario = test_scenario::begin(USER);
        let listing = init_listing(USER, &mut scenario);

        let wallet = coin::mint_for_testing<SUI>(70, ctx(&mut scenario));
        let venue_id = init_market(&mut listing, &mut scenario);

        test_scenario::next_tx(&mut scenario, USER);

        // Check if we can buy without rebate
        fixed_price::buy_nft<Foo, SUI>(
            &mut listing, venue_id, &mut wallet, ctx(&mut scenario),
        );
        assert!(balance::value(coin::balance(&wallet)) == 50, 0);

        test_scenario::next_tx(&mut scenario, USER);

        // Check if we can buy with rebate but no funds
        listing::set_rebate<Foo, SUI>(&mut listing, 10, ctx(&mut scenario));

        fixed_price::buy_nft<Foo, SUI>(
            &mut listing, venue_id, &mut wallet, ctx(&mut scenario),
        );
        assert!(balance::value(coin::balance(&wallet)) == 30, 0);

        test_scenario::next_tx(&mut scenario, USER);

        // Check if we can buy with funded rebate
        let fund = coin::mint_for_testing<SUI>(15, ctx(&mut scenario));
        listing::fund_rebate<Foo, SUI>(&mut listing, &mut fund, 15);

        fixed_price::buy_nft<Foo, SUI>(
            &mut listing, venue_id, &mut wallet, ctx(&mut scenario),
        );
        assert!(balance::value(coin::balance(&wallet)) == 20, 0);

        test_scenario::next_tx(&mut scenario, USER);

        // Check that rebate is not applied for partial fund
        fixed_price::buy_nft<Foo, SUI>(
            &mut listing, venue_id, &mut wallet, ctx(&mut scenario),
        );
        assert!(balance::value(coin::balance(&wallet)) == 0, 0);

        transfer::public_transfer(fund, MARKETPLACE);
        transfer::public_transfer(wallet, USER);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
     #[expected_failure(abort_code = ob_launchpad::listing::EWrongAdmin)]
    fun test_try_withdraw_funds_not_admin() {
        let scenario = test_scenario::begin(MARKETPLACE);
        let listing = init_listing(MARKETPLACE, &mut scenario);
        listing::set_rebate<Foo, SUI>(&mut listing, 10, ctx(&mut scenario));

        let fund = coin::mint_for_testing<SUI>(20, ctx(&mut scenario));
        listing::fund_rebate<Foo, SUI>(&mut listing, &mut fund, 20);

        test_scenario::next_tx(&mut scenario, USER);

        let wallet = coin::zero<SUI>(ctx(&mut scenario));
        listing::withdraw_rebate_funds<Foo, SUI>(
            &mut listing, &mut wallet, 10, ctx(&mut scenario),
        );

        transfer::public_transfer(fund, MARKETPLACE);
        transfer::public_transfer(wallet, USER);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_withdraw_funds() {
        let scenario = test_scenario::begin(MARKETPLACE);
        let listing = init_listing(MARKETPLACE, &mut scenario);
        listing::set_rebate<Foo, SUI>(&mut listing, 10, ctx(&mut scenario));

        let fund = coin::mint_for_testing<SUI>(20, ctx(&mut scenario));
        listing::fund_rebate<Foo, SUI>(&mut listing, &mut fund, 20);

        test_scenario::next_tx(&mut scenario, MARKETPLACE);

        let wallet = coin::zero<SUI>(ctx(&mut scenario));
        listing::withdraw_rebate_funds<Foo, SUI>(
            &mut listing, &mut wallet, 10, ctx(&mut scenario),
        );

        assert!(balance::value(coin::balance(&wallet)) == 10, 0);

        transfer::public_transfer(fund, MARKETPLACE);
        transfer::public_transfer(wallet, USER);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }
}
