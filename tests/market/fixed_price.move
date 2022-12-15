#[test_only]
module nft_protocol::test_fixed_price {
    use sui::sui::SUI;
    use sui::object::{Self, ID};
    use sui::test_scenario::{Self, Scenario, ctx};

    use nft_protocol::flat_fee;
    use nft_protocol::inventory;
    use nft_protocol::slot::{Self, Slot};
    use nft_protocol::launchpad::{Self, Launchpad};
    use nft_protocol::fixed_price::{Self, FixedPriceMarket};

    const CREATOR: address = @0xA1C05;
    const BUYER: address = @0xA1C06;

    fun init_slot(scenario: &mut Scenario): (Launchpad, Slot) {
        test_scenario::next_tx(scenario, CREATOR);

        launchpad::init_launchpad(
            CREATOR,
            CREATOR,
            true,
            flat_fee::new(0, ctx(scenario)),
            ctx(scenario),
        );

        test_scenario::next_tx(scenario, CREATOR);
        let launchpad = test_scenario::take_shared<Launchpad>(scenario);

        slot::init_slot(
            &launchpad,
            CREATOR,
            CREATOR,
            ctx(scenario),
        );

        test_scenario::next_tx(scenario, CREATOR);
        let slot = test_scenario::take_shared<Slot>(scenario);

        (launchpad, slot)
    }

    fun init_market<Market: key + store>(
        slot: &mut Slot,
        market: Market,
        scenario: &mut Scenario,
    ): ID {
        let market_id = object::id(&market);

        slot::add_market(
            slot,
            market,
            inventory::new(false, ctx(scenario)),
            ctx(scenario)
        );

        market_id
    }

    #[test]
    fun create_market() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(&mut scenario);

        let market = fixed_price::new<SUI>(0, ctx(&mut scenario));
        let market_id = init_market(&mut slot, market, &mut scenario);

        let _market: &FixedPriceMarket<SUI> = slot::market(&slot, market_id);

        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    fun buy_nft() {
        let scenario = test_scenario::begin(CREATOR);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure]
    fun try_buy() {
        let scenario = test_scenario::begin(CREATOR);

        test_scenario::end(scenario);
    }

    #[test]
    fun buy_whitelisted_nft() {
        let scenario = test_scenario::begin(CREATOR);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure]
    fun try_buy_whitelisted_nft() {
        let scenario = test_scenario::begin(CREATOR);

        test_scenario::end(scenario);
    }

    #[test]
    fun change_price() {
        let scenario = test_scenario::begin(CREATOR);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure]
    fun try_change_price() {
        let scenario = test_scenario::begin(CREATOR);

        test_scenario::end(scenario);
    }
}
