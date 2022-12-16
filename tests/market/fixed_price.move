#[test_only]
module nft_protocol::test_fixed_price {
    use sui::sui::SUI;
    use sui::coin;
    use sui::object::{Self, ID};
    use sui::test_scenario::{Self, Scenario, ctx};

    use nft_protocol::nft;
    use nft_protocol::flat_fee;
    use nft_protocol::inventory;
    use nft_protocol::slot::{Self, Slot, NftCertificate};
    use nft_protocol::launchpad::{Self, Launchpad};
    use nft_protocol::fixed_price::{Self, FixedPriceMarket};

    struct COLLECTION {}

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
        let (launchpad, slot) = init_slot(&mut scenario);

        let market_id = init_market(&mut slot, 0, false, &mut scenario);
        let _market: &FixedPriceMarket<SUI> = slot::market(&slot, market_id);

        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    fun buy_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(&mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);
        slot::add_nft(
            &mut slot,
            market_id,
            nft::new<COLLECTION>(CREATOR, ctx(&mut scenario)),
            ctx(&mut scenario)
        );
        slot::sale_on(&mut slot, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        fixed_price::buy_nft_certificate(
            &launchpad,
            &mut slot,
            market_id,
            coin::mint_for_testing<SUI>(10, ctx(&mut scenario)),
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, BUYER);

        let certificate = test_scenario::take_from_address<NftCertificate>(
            &mut scenario, BUYER
        );
        slot::assert_nft_certificate_slot(object::id(&slot), &certificate);
        test_scenario::return_to_address(BUYER, certificate);

        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure]
    fun try_buy_no_supply() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(&mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);
        
        fixed_price::buy_nft_certificate(
            &launchpad,
            &mut slot,
            market_id,
            coin::mint_for_testing<SUI>(10, ctx(&mut scenario)),
            ctx(&mut scenario),
        );

        let certificate = test_scenario::take_from_address<NftCertificate>(
            &mut scenario, BUYER
        );
        test_scenario::return_to_address(BUYER, certificate);

        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure]
    fun try_buy_no_balance() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(&mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);
        
        fixed_price::buy_nft_certificate<SUI>(
            &launchpad,
            &mut slot,
            market_id,
            coin::mint_for_testing(9, ctx(&mut scenario)),
            ctx(&mut scenario),
        );

        let certificate = test_scenario::take_from_address<NftCertificate>(
            &mut scenario, BUYER
        );
        test_scenario::return_to_address(BUYER, certificate);

        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failute]
    fun try_buy_not_live() {

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
