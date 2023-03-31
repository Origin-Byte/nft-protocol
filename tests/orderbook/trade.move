#[test_only]
module nft_protocol::test_ob_trade {
    use std::option;

    use nft_protocol::orderbook::{Self as ob, Orderbook};
    use nft_protocol::safe;
    use nft_protocol::test_utils::{Self as test_ob};

    use originmate::crit_bit_u64 as crit_bit;

    use sui::object::ID;
    use sui::sui::SUI;
    use sui::test_scenario::{Self, Scenario};
    use sui::transfer::public_transfer;

    const BUYER1: address = @0xA1C07;
    const BUYER2: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;
    const SELLER1: address = @0xA1C04;
    const SELLER2: address = @0xA1C03;

    fun create_col_wl_safes(scenario: &mut Scenario) {
        test_scenario::next_tx(scenario, CREATOR);
        test_ob::create_collection_and_allowlist(CREATOR, scenario);
        test_ob::create_ob(scenario);

        test_scenario::next_tx(scenario, SELLER1);
        test_ob::create_safe(scenario, SELLER1);
        test_scenario::next_tx(scenario, BUYER1);
        test_ob::create_safe(scenario, BUYER1);
        test_scenario::next_tx(scenario, SELLER2);
        test_ob::create_safe(scenario, SELLER2);
        test_scenario::next_tx(scenario, BUYER2);
        test_ob::create_safe(scenario, BUYER2);
    }

    #[test]
    fun it_inserts_bids_and_fills_best_one() {
        let scenario = test_scenario::begin(CREATOR);

        create_col_wl_safes(&mut scenario);

        test_scenario::next_tx(&mut scenario, BUYER1);
        test_ob::create_bid(&mut scenario, 100);
        test_ob::create_bid(&mut scenario, 100);
        test_ob::create_bid(&mut scenario, 110);

        test_scenario::next_tx(&mut scenario, BUYER2);
        test_ob::create_bid(&mut scenario, 100);
        test_ob::create_bid(&mut scenario, 110);
        test_ob::create_bid(&mut scenario, 120);

        let ob: Orderbook<test_ob::Foo, SUI> = test_scenario::take_shared(&scenario);
        assert!(crit_bit::length(ob::borrow_bids(&ob)) == 3, 0); // 3x100, 2x110, 1x120
        test_scenario::return_shared(ob);

        test_scenario::next_tx(&mut scenario, SELLER1);
        let nft1_id = test_ob::mint_and_deposit_nft_sender(&mut scenario);
        let nft2_id = test_ob::mint_and_deposit_nft_sender(&mut scenario);

        test_scenario::next_tx(&mut scenario, SELLER2);
        let nft3_id = test_ob::mint_and_deposit_nft_sender(&mut scenario);
        let nft4_id = test_ob::mint_and_deposit_nft_sender(&mut scenario);

        test_scenario::next_tx(&mut scenario, SELLER1);
        test_ob::create_ask(&mut scenario, nft1_id, 90);
        let ob: Orderbook<test_ob::Foo, SUI> = test_scenario::take_shared(&scenario);
        assert!(crit_bit::length(ob::borrow_bids(&ob)) == 2, 0); // 3x100, 2x110
        test_scenario::return_shared(ob);
        let ti1_id = most_recent_trade_intermediate_id();

        test_scenario::next_tx(&mut scenario, SELLER1);
        test_ob::create_ask(&mut scenario, nft2_id, 90);
        let ob: Orderbook<test_ob::Foo, SUI> = test_scenario::take_shared(&scenario);
        assert!(crit_bit::length(ob::borrow_bids(&ob)) == 2, 0); // 3x100, 1x110
        test_scenario::return_shared(ob);
        let ti2_id = most_recent_trade_intermediate_id();

        test_scenario::next_tx(&mut scenario, SELLER2);
        test_ob::create_ask(&mut scenario, nft3_id, 120);
        let ob: Orderbook<test_ob::Foo, SUI> = test_scenario::take_shared(&scenario);
        assert!(crit_bit::length(ob::borrow_bids(&ob)) == 2, 0); // 3x100, 1x110
        test_scenario::return_shared(ob);

        test_scenario::next_tx(&mut scenario, SELLER2);
        test_ob::create_ask(&mut scenario, nft4_id, 100);
        let ob: Orderbook<test_ob::Foo, SUI> = test_scenario::take_shared(&scenario);
        assert!(crit_bit::length(ob::borrow_bids(&ob)) == 1, 0); // 3x100
        test_scenario::return_shared(ob);
        let ti3_id = most_recent_trade_intermediate_id();

        test_scenario::next_tx(&mut scenario, BUYER2);
        test_ob::finish_trade_id(
            &mut scenario,
            ti1_id,
            nft1_id,
            BUYER2,
            SELLER1,
        );
        test_ob::finish_trade_id(
            &mut scenario,
            ti2_id,
            nft2_id,
            BUYER1,
            SELLER1,
        );
        test_ob::finish_trade_id(
            &mut scenario,
            ti3_id,
            nft4_id,
            BUYER2,
            SELLER2,
        );

        let buyer1_safe = test_ob::user_safe(&scenario, BUYER1);
        assert!(safe::has_nft<test_ob::Foo>(nft2_id, &buyer1_safe), 0);
        let buyer2_safe = test_ob::user_safe(&scenario, BUYER2);
        assert!(safe::has_nft<test_ob::Foo>(nft1_id, &buyer2_safe), 0);
        assert!(safe::has_nft<test_ob::Foo>(nft4_id, &buyer2_safe), 0);
        let seller2_safe = test_ob::user_safe(&scenario, SELLER2);
        assert!(safe::has_nft<test_ob::Foo>(nft3_id, &seller2_safe), 0);
        test_scenario::return_shared(buyer1_safe);
        test_scenario::return_shared(buyer2_safe);
        test_scenario::return_shared(seller2_safe);

        test_scenario::end(scenario);
    }

    #[test]
    fun it_inserts_asks_and_fills_best_one() {
        let scenario = test_scenario::begin(CREATOR);

        create_col_wl_safes(&mut scenario);

        test_scenario::next_tx(&mut scenario, SELLER1);
        let nft1_id = test_ob::mint_and_deposit_nft_sender(&mut scenario);
        let nft2_id = test_ob::mint_and_deposit_nft_sender(&mut scenario);

        test_scenario::next_tx(&mut scenario, SELLER2);
        let nft3_id = test_ob::mint_and_deposit_nft_sender(&mut scenario);
        let nft4_id = test_ob::mint_and_deposit_nft_sender(&mut scenario);

        test_scenario::next_tx(&mut scenario, SELLER1);
        test_ob::create_ask(&mut scenario, nft1_id, 90);

        test_scenario::next_tx(&mut scenario, SELLER1);
        test_ob::create_ask(&mut scenario, nft2_id, 90);

        test_scenario::next_tx(&mut scenario, SELLER2);
        test_ob::create_ask(&mut scenario, nft3_id, 120);

        test_scenario::next_tx(&mut scenario, SELLER2);
        test_ob::create_ask(&mut scenario, nft4_id, 100);

        let ob: Orderbook<test_ob::Foo, SUI> = test_scenario::take_shared(&scenario);
        assert!(crit_bit::length(ob::borrow_asks(&ob)) == 3, 0); // 2x90, 1x100 1x120
        test_scenario::return_shared(ob);

        test_scenario::next_tx(&mut scenario, BUYER1);
        test_ob::create_bid(&mut scenario, 100);
        let ti1_id = most_recent_trade_intermediate_id();

        test_scenario::next_tx(&mut scenario, BUYER1);
        test_ob::create_bid(&mut scenario, 80);

        test_scenario::next_tx(&mut scenario, BUYER1);
        test_ob::create_bid(&mut scenario, 90);
        let ti2_id = most_recent_trade_intermediate_id();

        test_scenario::next_tx(&mut scenario, BUYER1);
        test_ob::create_bid(&mut scenario, 91);
        test_scenario::next_tx(&mut scenario, BUYER1);
        test_ob::create_bid(&mut scenario, 101);
        let ti3_id = most_recent_trade_intermediate_id();

        test_scenario::next_tx(&mut scenario, BUYER2);
        test_ob::create_bid(&mut scenario, 80);

        test_scenario::next_tx(&mut scenario, BUYER2);
        test_ob::create_bid(&mut scenario, 150);
        let ti4_id = most_recent_trade_intermediate_id();

        test_scenario::next_tx(&mut scenario, BUYER2);
        let ob: Orderbook<test_ob::Foo, SUI> = test_scenario::take_shared(&scenario);
        assert!(crit_bit::length(ob::borrow_bids(&ob)) == 2, 0); // 2x80 1x91
        assert!(crit_bit::length(ob::borrow_asks(&ob)) == 0, 0);
        test_scenario::return_shared(ob);

        test_scenario::next_tx(&mut scenario, CREATOR);
        test_ob::finish_trade_id(
            &mut scenario,
            ti1_id,
            nft1_id,
            BUYER1,
            SELLER1,
        );
        test_ob::finish_trade_id(
            &mut scenario,
            ti2_id,
            nft2_id,
            BUYER1,
            SELLER1,
        );
        test_ob::finish_trade_id(
            &mut scenario,
            ti3_id,
            nft4_id,
            BUYER1,
            SELLER2,
        );
        test_ob::finish_trade_id(
            &mut scenario,
            ti4_id,
            nft3_id,
            BUYER2,
            SELLER2,
        );

        let buyer1_safe = test_ob::user_safe(&scenario, BUYER1);
        assert!(safe::has_nft<test_ob::Foo>(nft1_id, &buyer1_safe), 0);
        assert!(safe::has_nft<test_ob::Foo>(nft2_id, &buyer1_safe), 0);
        assert!(safe::has_nft<test_ob::Foo>(nft4_id, &buyer1_safe), 0);
        let buyer2_safe = test_ob::user_safe(&scenario, BUYER2);
        assert!(safe::has_nft<test_ob::Foo>(nft3_id, &buyer2_safe), 0);

        test_scenario::return_shared(buyer1_safe);
        test_scenario::return_shared(buyer2_safe);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_buys_nfts() {
        let scenario = test_scenario::begin(CREATOR);

        create_col_wl_safes(&mut scenario);

        test_scenario::next_tx(&mut scenario, SELLER1);
        let nft1_id = test_ob::mint_and_deposit_nft_sender(&mut scenario);
        let nft2_id = test_ob::mint_and_deposit_nft_sender(&mut scenario);

        test_scenario::next_tx(&mut scenario, SELLER2);
        let nft3_id = test_ob::mint_and_deposit_nft_sender(&mut scenario);
        let nft4_id = test_ob::mint_and_deposit_nft_sender(&mut scenario);

        test_scenario::next_tx(&mut scenario, SELLER1);
        test_ob::create_ask(&mut scenario, nft1_id, 90);

        test_scenario::next_tx(&mut scenario, SELLER1);
        test_ob::create_ask(&mut scenario, nft2_id, 90);

        test_scenario::next_tx(&mut scenario, SELLER2);
        test_ob::create_ask(&mut scenario, nft3_id, 90);

        test_scenario::next_tx(&mut scenario, SELLER2);
        test_ob::create_ask(&mut scenario, nft4_id, 100);

        test_scenario::next_tx(&mut scenario, BUYER1);
        test_ob::buy_nft(
            &mut scenario,
            nft2_id,
            SELLER1,
            90,
        );

        test_scenario::next_tx(&mut scenario, BUYER1);
        test_ob::buy_nft(
            &mut scenario,
            nft4_id,
            SELLER2,
            100,
        );

        test_scenario::next_tx(&mut scenario, BUYER1);
        test_ob::buy_nft(
            &mut scenario,
            nft3_id,
            SELLER2,
            90,
        );

        test_scenario::next_tx(&mut scenario, BUYER1);
        let buyer1_safe = test_ob::user_safe(&scenario, BUYER1);
        assert!(safe::has_nft<test_ob::Foo>(nft3_id, &buyer1_safe), 0);
        assert!(safe::has_nft<test_ob::Foo>(nft2_id, &buyer1_safe), 0);
        assert!(safe::has_nft<test_ob::Foo>(nft4_id, &buyer1_safe), 0);

        test_scenario::return_shared(buyer1_safe);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 7, location = nft_protocol::orderbook)]
    fun it_fails_if_nft_does_not_exist() {
        let scenario = test_scenario::begin(CREATOR);

        create_col_wl_safes(&mut scenario);

        test_scenario::next_tx(&mut scenario, SELLER1);
        let nft1_id = test_ob::mint_and_deposit_nft_sender(&mut scenario);

        test_scenario::next_tx(&mut scenario, BUYER1);
        test_ob::buy_nft(
            &mut scenario,
            nft1_id,
            SELLER1,
            90,
        );

        test_scenario::end(scenario);
    }

    #[test]
    fun it_lists_nft() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(CREATOR, &mut scenario);
        let _ob_id = test_ob::create_ob(&mut scenario);
        test_scenario::next_tx(&mut scenario, SELLER1);
        test_ob::create_safe(&mut scenario, SELLER1);
        let nft_id = test_ob::mint_and_deposit_nft(&mut scenario, SELLER1);
        test_scenario::next_tx(&mut scenario, SELLER1);

        let (owner_cap, seller_safe) =
            test_ob::owner_cap_and_safe(&scenario, SELLER1);
        let ob: Orderbook<test_ob::Foo, SUI> =
            test_scenario::take_shared(&scenario);
        ob::list_nft(
            &mut ob,
            100,
            nft_id,
            &owner_cap,
            &mut seller_safe,
            test_scenario::ctx(&mut scenario),
        );

        test_scenario::return_shared(ob);
        test_scenario::return_shared(seller_safe);
        public_transfer(owner_cap, SELLER1);

        test_scenario::end(scenario);
    }

    fun most_recent_trade_intermediate_id(): ID {
        let id = test_scenario::most_recent_id_shared<
            ob::TradeIntermediate<test_ob::Foo, SUI>
        >();

        option::destroy_some(id)
    }
}
