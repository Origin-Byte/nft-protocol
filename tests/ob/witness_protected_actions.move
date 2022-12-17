#[test_only]
module nft_protocol::test_ob_witness_protected_actions {
    use nft_protocol::ob::{Self, Orderbook};
    use nft_protocol::safe;
    use nft_protocol::test_ob_utils::{Self as test_ob, Foo};
    use nft_protocol::transfer_whitelist::Whitelist;
    use sui::coin;
    use sui::object::ID;
    use sui::sui::SUI;
    use sui::transfer::transfer;
    use sui::test_scenario::{Self, Scenario, ctx};

    const BUYER: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;
    const SELLER: address = @0xA1C04;
    const THIRD_PARTY: address = @0xA1C03;

    const OFFER_SUI: u64 = 100;
    const COMMISSION_SUI: u64 = 10;

    struct WrongWitness has drop {}

    fun create_col_wl_ob_nft_safes(scenario: &mut Scenario): ID {
        test_scenario::next_tx(scenario, CREATOR);
        test_ob::create_collection_and_whitelist(scenario);
        test_ob::create_ob(scenario);

        test_scenario::next_tx(scenario, SELLER);
        test_ob::create_safe(scenario, SELLER);
        let nft_id = test_ob::create_and_deposit_nft(
            scenario,
            SELLER,
        );

        test_scenario::next_tx(scenario, BUYER);
        test_ob::create_safe(scenario, BUYER);

        nft_id
    }

    #[test]
    #[expected_failure(abort_code = 13370304, location = nft_protocol::ob)]
    fun it_protects_buy_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let nft_id = create_col_wl_ob_nft_safes(&mut scenario);
        protect_buy_nft(&mut scenario);
        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::create_ask(
            &mut scenario,
            nft_id,
            OFFER_SUI,
        );

        test_scenario::next_tx(&mut scenario, BUYER);
        test_ob::buy_nft(&mut scenario, nft_id, SELLER, OFFER_SUI);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370600, location = nft_protocol::utils)]
    fun it_cannot_toggle_protection_on_buy_nft_with_wrong_witness() {
        let scenario = test_scenario::begin(CREATOR);

        create_col_wl_ob_nft_safes(&mut scenario);

        test_scenario::next_tx(&mut scenario, CREATOR);
        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(&scenario);
        ob::toggle_protection_on_buy_nft(WrongWitness {}, &mut ob);

        test_scenario::return_shared(ob);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370600, location = nft_protocol::utils)]
    fun it_cannot_call_buy_nft_protected_with_wrong_witness() {
        let scenario = test_scenario::begin(CREATOR);
        let nft_id = create_col_wl_ob_nft_safes(&mut scenario);
        protect_buy_nft(&mut scenario);

        test_scenario::next_tx(&mut scenario, BUYER);
        let buyer_safe = test_ob::user_safe(&scenario, BUYER);
        let seller_safe = test_ob::user_safe(&scenario, SELLER);
        let wallet = coin::mint_for_testing<SUI>(OFFER_SUI, ctx(&mut scenario));
        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(&scenario);
        let wl: Whitelist = test_scenario::take_shared(&scenario);

        ob::buy_nft_protected(
            WrongWitness {},
            &mut ob,
            nft_id,
            OFFER_SUI,
            &mut wallet,
            &mut seller_safe,
            &mut buyer_safe,
            &wl,
            ctx(&mut scenario),
        );

        test_scenario::return_shared(ob);
        test_scenario::return_shared(wl);
        test_scenario::return_shared(buyer_safe);
        test_scenario::return_shared(seller_safe);
        coin::destroy_zero(wallet);

        test_scenario::end(scenario);
    }

    #[test]
    fun it_buys_nft_protected() {
        let scenario = test_scenario::begin(CREATOR);
        let nft_id = create_col_wl_ob_nft_safes(&mut scenario);
        protect_buy_nft(&mut scenario);
        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::create_ask(
            &mut scenario,
            nft_id,
            OFFER_SUI,
        );

        test_scenario::next_tx(&mut scenario, BUYER);
        let buyer_safe = test_ob::user_safe(&scenario, BUYER);
        let seller_safe = test_ob::user_safe(&scenario, SELLER);
        let wallet = coin::mint_for_testing<SUI>(OFFER_SUI, ctx(&mut scenario));
        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(&scenario);
        let wl: Whitelist = test_scenario::take_shared(&scenario);

        ob::buy_nft_protected(
            test_ob::witness(),
            &mut ob,
            nft_id,
            OFFER_SUI,
            &mut wallet,
            &mut seller_safe,
            &mut buyer_safe,
            &wl,
            ctx(&mut scenario),
        );

        test_scenario::return_shared(ob);
        test_scenario::return_shared(wl);
        test_scenario::return_shared(buyer_safe);
        test_scenario::return_shared(seller_safe);
        coin::destroy_zero(wallet);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370304, location = nft_protocol::ob)]
    fun it_protects_create_ask() {
        let scenario = test_scenario::begin(CREATOR);
        let nft_id = create_col_wl_ob_nft_safes(&mut scenario);
        protect_create_ask(&mut scenario);
        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::create_ask(
            &mut scenario,
            nft_id,
            OFFER_SUI,
        );

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370600, location = nft_protocol::utils)]
    fun it_cannot_toggle_protection_on_create_ask_with_wrong_witness() {
        let scenario = test_scenario::begin(CREATOR);

        create_col_wl_ob_nft_safes(&mut scenario);

        test_scenario::next_tx(&mut scenario, CREATOR);
        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(&scenario);
        ob::toggle_protection_on_create_ask(WrongWitness {}, &mut ob);

        test_scenario::return_shared(ob);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370600, location = nft_protocol::utils)]
    fun it_cannot_call_create_ask_protected_with_wrong_witness() {
        let scenario = test_scenario::begin(CREATOR);
        let nft_id = create_col_wl_ob_nft_safes(&mut scenario);
        protect_create_ask(&mut scenario);

        test_scenario::next_tx(&mut scenario, SELLER);
        let (owner_cap, seller_safe) = test_ob::owner_cap_and_safe(&scenario, SELLER);
        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(&scenario);
        let wl: Whitelist = test_scenario::take_shared(&scenario);
        let transfer_cap = safe::create_exclusive_transfer_cap(
            nft_id,
            &owner_cap,
            &mut seller_safe,
            ctx(&mut scenario)
        );

        ob::create_ask_protected(
            WrongWitness {},
            &mut ob,
            OFFER_SUI,
            transfer_cap,
            &mut seller_safe,
            ctx(&mut scenario),
        );

        test_scenario::return_shared(ob);
        test_scenario::return_shared(wl);
        test_scenario::return_shared(seller_safe);
        transfer(owner_cap, SELLER);

        test_scenario::end(scenario);
    }

    #[test]
    fun it_creates_ask_protected() {
        let scenario = test_scenario::begin(CREATOR);
        let nft_id = create_col_wl_ob_nft_safes(&mut scenario);
        protect_create_ask(&mut scenario);

        test_scenario::next_tx(&mut scenario, SELLER);
        let (owner_cap, seller_safe) = test_ob::owner_cap_and_safe(&scenario, SELLER);
        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(&scenario);
        let wl: Whitelist = test_scenario::take_shared(&scenario);
        let transfer_cap = safe::create_exclusive_transfer_cap(
            nft_id,
            &owner_cap,
            &mut seller_safe,
            ctx(&mut scenario)
        );

        ob::create_ask_protected(
            test_ob::witness(),
            &mut ob,
            OFFER_SUI,
            transfer_cap,
            &mut seller_safe,
            ctx(&mut scenario),
        );

        test_scenario::return_shared(ob);
        test_scenario::return_shared(wl);
        test_scenario::return_shared(seller_safe);
        transfer(owner_cap, SELLER);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370304, location = nft_protocol::ob)]
    fun it_protects_create_bid() {
        let scenario = test_scenario::begin(CREATOR);
        create_col_wl_ob_nft_safes(&mut scenario);
        protect_create_bid(&mut scenario);
        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::create_bid(&mut scenario, OFFER_SUI);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370600, location = nft_protocol::utils)]
    fun it_cannot_toggle_protection_on_create_bid_with_wrong_witness() {
        let scenario = test_scenario::begin(CREATOR);

        create_col_wl_ob_nft_safes(&mut scenario);

        test_scenario::next_tx(&mut scenario, CREATOR);
        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(&scenario);
        ob::toggle_protection_on_create_bid(WrongWitness {}, &mut ob);

        test_scenario::return_shared(ob);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370600, location = nft_protocol::utils)]
    fun it_cannot_call_create_bid_protected_with_wrong_witness() {
        let scenario = test_scenario::begin(CREATOR);
        create_col_wl_ob_nft_safes(&mut scenario);
        protect_create_bid(&mut scenario);

        test_scenario::next_tx(&mut scenario, BUYER);
        let buyer_safe = test_ob::user_safe(&scenario, BUYER);
        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(&scenario);
        let wallet = coin::mint_for_testing<SUI>(OFFER_SUI, ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, BUYER);

        ob::create_bid_protected(
            WrongWitness {},
            &mut ob,
            &mut buyer_safe,
            OFFER_SUI,
            &mut wallet,
            ctx(&mut scenario),
        );

        test_scenario::return_shared(ob);
        test_scenario::return_shared(buyer_safe);
        coin::destroy_zero(wallet);

        test_scenario::end(scenario);
    }

    #[test]
    fun it_creates_bid_protected() {
        let scenario = test_scenario::begin(CREATOR);
        create_col_wl_ob_nft_safes(&mut scenario);
        protect_create_bid(&mut scenario);

        test_scenario::next_tx(&mut scenario, BUYER);
        let buyer_safe = test_ob::user_safe(&scenario, BUYER);
        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(&scenario);
        let wallet = coin::mint_for_testing<SUI>(OFFER_SUI, ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, BUYER);

        ob::create_bid_protected(
            test_ob::witness(),
            &mut ob,
            &mut buyer_safe,
            OFFER_SUI,
            &mut wallet,
            ctx(&mut scenario),
        );

        test_scenario::return_shared(ob);
        test_scenario::return_shared(buyer_safe);
        coin::destroy_zero(wallet);

        test_scenario::end(scenario);
    }

    #[test]
    fun it_protects_cancel_ask() {
        //
    }

    #[test]
    fun it_protects_cancel_bid() {
        //
    }

    fun protect_buy_nft(scenario: &mut Scenario) {
        test_scenario::next_tx(scenario, CREATOR);
        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(scenario);
        ob::toggle_protection_on_buy_nft(test_ob::witness(), &mut ob);
        test_scenario::return_shared(ob);
    }

    fun protect_create_ask(scenario: &mut Scenario) {
        test_scenario::next_tx(scenario, CREATOR);
        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(scenario);
        ob::toggle_protection_on_create_ask(test_ob::witness(), &mut ob);
        test_scenario::return_shared(ob);
    }

    fun protect_create_bid(scenario: &mut Scenario) {
        test_scenario::next_tx(scenario, CREATOR);
        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(scenario);
        ob::toggle_protection_on_create_bid(test_ob::witness(), &mut ob);
        test_scenario::return_shared(ob);
    }
}
