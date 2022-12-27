#[test_only]
module nft_protocol::test_fixed_price {
    use sui::sui::SUI;
    use sui::coin;
    use sui::transfer;
    use sui::object::{Self, ID};
    use sui::test_scenario::{Self, Scenario, ctx};

    use nft_protocol::nft;
    use nft_protocol::inventory;
    use nft_protocol::slot::{Self, Slot, WhitelistCertificate};
    use nft_protocol::fixed_price::{Self, FixedPriceMarket};

    use nft_protocol::test_slot::init_slot;

    struct COLLECTION {}

    const CREATOR: address = @0xA1C05;
    const BUYER: address = @0xA1C06;

    fun init_market(
        slot: &mut Slot,
        price: u64,
        is_whitelisted: bool,
        scenario: &mut Scenario,
    ): ID {
        let market = fixed_price::new<SUI>(price, ctx(scenario));
        let market_id = object::id(&market);

        slot::add_market(
            slot,
            market,
            inventory::new(is_whitelisted, ctx(scenario)),
            ctx(scenario)
        );

        market_id
    }

    #[test]
    fun create_market() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);
        let _market: &FixedPriceMarket<SUI> = slot::market(&slot, market_id);

        assert!(fixed_price::price<SUI>(&slot, market_id) == 10, 0);

        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370202, location = nft_protocol::slot)]
    fun try_buy_not_live() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);

        let wallet = coin::mint_for_testing<SUI>(10, ctx(&mut scenario));
        fixed_price::buy_nft<COLLECTION, SUI>(
            &mut slot,
            market_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        transfer::transfer(wallet, BUYER);
        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370209, location = nft_protocol::inventory)]
    fun try_buy_no_supply() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);
        slot::sale_on(&mut slot, ctx(&mut scenario));

        let wallet = coin::mint_for_testing<SUI>(10, ctx(&mut scenario));
        fixed_price::buy_nft<COLLECTION, SUI>(
            &mut slot,
            market_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        transfer::transfer(wallet, BUYER);
        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    fun buy_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);

        slot::add_nft(
            &mut slot,
            market_id,
            nft::new<COLLECTION>(CREATOR, ctx(&mut scenario)),
            ctx(&mut scenario)
        );

        slot::sale_on(&mut slot, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        let wallet = coin::mint_for_testing<SUI>(15, ctx(&mut scenario));
        fixed_price::buy_nft<COLLECTION, SUI>(
            &mut slot,
            market_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        assert!(coin::value(&wallet) == 5, 0);

        transfer::transfer(wallet, BUYER);
        test_scenario::next_tx(&mut scenario, BUYER);

        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370206, location = nft_protocol::slot)]
    fun try_buy_whitelisted_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, true, &mut scenario);
        slot::sale_on(&mut slot, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        let wallet = coin::mint_for_testing<SUI>(10, ctx(&mut scenario));
        fixed_price::buy_nft<COLLECTION, SUI>(
            &mut slot,
            market_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        assert!(coin::value(&wallet) == 0, 0);

        transfer::transfer(wallet, BUYER);
        test_scenario::next_tx(&mut scenario, BUYER);

        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    fun buy_whitelisted_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, true, &mut scenario);

        slot::add_nft(
            &mut slot,
            market_id,
            nft::new<COLLECTION>(CREATOR, ctx(&mut scenario)),
            ctx(&mut scenario)
        );

        slot::sale_on(&mut slot, ctx(&mut scenario));

        slot::transfer_whitelist_certificate(
            &launchpad, &slot, market_id, BUYER, ctx(&mut scenario)
        );

        test_scenario::next_tx(&mut scenario, BUYER);

        let certificate = test_scenario::take_from_address<
            WhitelistCertificate
        >(&scenario, BUYER);

        let wallet = coin::mint_for_testing<SUI>(10, ctx(&mut scenario));
        fixed_price::buy_whitelisted_nft<COLLECTION, SUI>(
            &mut slot,
            market_id,
            &mut wallet,
            certificate,
            ctx(&mut scenario),
        );

        transfer::transfer(wallet, BUYER);
        test_scenario::next_tx(&mut scenario, BUYER);

        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370212, location = nft_protocol::slot)]
    fun try_change_price() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, true, &mut scenario);

        test_scenario::next_tx(&mut scenario, BUYER);

        fixed_price::set_price<SUI>(
            &mut slot, market_id, 20, ctx(&mut scenario)
        );

        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    fun change_price() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, true, &mut scenario);

        test_scenario::next_tx(&mut scenario, CREATOR);

        fixed_price::set_price<SUI>(
            &mut slot, market_id, 20, ctx(&mut scenario)
        );

        assert!(fixed_price::price<SUI>(&slot, market_id) == 20, 0);

        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }
}
