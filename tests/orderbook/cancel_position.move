#[test_only]
module nft_protocol::test_ob_cancel_position {
    use nft_protocol::safe::{TransferCap};
    use nft_protocol::test_utils as test_ob;
    use sui::sui::SUI;
    use nft_protocol::orderbook::{Self as ob, Orderbook};
    use sui::coin;
    use sui::test_scenario;
    use sui::transfer::transfer;
    use originmate::crit_bit_u64 as crit_bit;

    const BUYER: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;
    const SELLER: address = @0xA1C04;
    const THIRD_PARTY: address = @0xA1C03;

    const OFFER_SUI: u64 = 100;
    const COMMISSION_SUI: u64 = 10;

    #[test]
    #[expected_failure(abort_code = 7, location = nft_protocol::orderbook)]
    fun it_cannot_cancel_non_existing_ask() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(&mut scenario);
        let _ob_id = test_ob::create_ob<test_ob::Foo>(&mut scenario);
        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::create_safe(&mut scenario, SELLER);

        // Creates transfer cap and sends it to orderbook
        let nft_id = test_ob::create_and_deposit_nft(&mut scenario, SELLER);

        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::cancel_ask(&mut scenario, nft_id, OFFER_SUI);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 7, location = nft_protocol::orderbook)]
    fun it_cannot_cancel_someone_elses_ask() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(&mut scenario);
        let _ob_id = test_ob::create_ob<test_ob::Foo>(&mut scenario);
        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::create_safe(&mut scenario, SELLER);

        // Creates transfer cap and sends it to orderbook
        let nft_id = test_ob::create_and_deposit_nft(&mut scenario, SELLER);

        test_scenario::next_tx(&mut scenario, THIRD_PARTY);
        test_ob::cancel_ask(&mut scenario, nft_id, OFFER_SUI);

        test_scenario::end(scenario);
    }

    #[test]
    fun it_cancels_ask() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(&mut scenario);
        let _ob_id = test_ob::create_ob<test_ob::Foo>(&mut scenario);
        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::create_safe(&mut scenario, SELLER);

        // Creates transfer cap and sends it to orderbook
        let nft_id = test_ob::create_and_deposit_nft(&mut scenario, SELLER);

        test_scenario::next_tx(&mut scenario, SELLER);

        let transfer_cap_id = test_ob::create_ask<test_ob::Foo>(
            &mut scenario,
            nft_id,
            OFFER_SUI,
        );

        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::cancel_ask(&mut scenario, nft_id, OFFER_SUI);
        test_scenario::next_tx(&mut scenario, SELLER);

        let transfer_cap = test_scenario::take_from_address_by_id<TransferCap>(
            &mut scenario,
            SELLER,
            transfer_cap_id,
        );

        test_scenario::return_to_sender(&scenario, transfer_cap);

        test_scenario::end(scenario);
    }

    #[test]
    fun it_cancels_only_one_ask() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(&mut scenario);
        let _ob_id = test_ob::create_ob<test_ob::Foo>(&mut scenario);
        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::create_safe(&mut scenario, SELLER);

        let nft1_id = test_ob::create_and_deposit_nft(&mut scenario, SELLER);
        test_scenario::next_tx(&mut scenario, SELLER);
        let transfer_cap1_id = test_ob::create_ask<test_ob::Foo>(
            &mut scenario,
            nft1_id,
            OFFER_SUI,
        );

        let nft2_id = test_ob::create_and_deposit_nft(&mut scenario, SELLER);
        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::create_ask<test_ob::Foo>(
            &mut scenario,
            nft2_id,
            OFFER_SUI,
        );

        let nft3_id = test_ob::create_and_deposit_nft(&mut scenario, SELLER);
        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::create_ask<test_ob::Foo>(
            &mut scenario,
            nft3_id,
            OFFER_SUI,
        );

        test_scenario::next_tx(&mut scenario, CREATOR);
        let ob: Orderbook<test_ob::Foo, SUI> = test_scenario::take_shared(&scenario);
        assert!(crit_bit::length(ob::borrow_asks(&ob)) == 1, 0);
        test_scenario::return_shared(ob);

        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::cancel_ask(&mut scenario, nft1_id, OFFER_SUI);
        test_scenario::next_tx(&mut scenario, SELLER);
        let transfer_cap1 = test_scenario::take_from_address_by_id<TransferCap>(
            &mut scenario,
            SELLER,
            transfer_cap1_id,
        );
        test_scenario::return_to_sender(&scenario, transfer_cap1);

        test_scenario::next_tx(&mut scenario, CREATOR);
        let ob: Orderbook<test_ob::Foo, SUI> = test_scenario::take_shared(&scenario);
        assert!(crit_bit::length(ob::borrow_asks(&ob)) == 1, 0);
        test_scenario::return_shared(ob);

        test_scenario::end(scenario);
    }

    #[test]
    fun it_cancels_ask_with_commission() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(&mut scenario);
        let _ob_id = test_ob::create_ob<test_ob::Foo>(&mut scenario);
        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::create_safe(&mut scenario, SELLER);

        // Creates transfer cap and sends it to orderbook
        let nft_id = test_ob::create_and_deposit_nft(&mut scenario, SELLER);

        test_scenario::next_tx(&mut scenario, SELLER);

        let transfer_cap_id = test_ob::create_ask_with_commission(
            &mut scenario,
            nft_id,
            OFFER_SUI,
            CREATOR,
            COMMISSION_SUI,
        );

        test_scenario::next_tx(&mut scenario, SELLER);
        test_ob::cancel_ask(&mut scenario, nft_id, OFFER_SUI);
        test_scenario::next_tx(&mut scenario, SELLER);

        let transfer_cap = test_scenario::take_from_address_by_id<TransferCap>(
            &mut scenario,
            SELLER,
            transfer_cap_id,
        );

        test_scenario::return_to_sender(&scenario, transfer_cap);

        test_scenario::end(scenario);
    }

    #[test]
    fun it_cancels_bid() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(&mut scenario);
        let _ob_id = test_ob::create_ob<test_ob::Foo>(&mut scenario);
        test_ob::create_safe(&mut scenario, BUYER);

        test_ob::create_bid<test_ob::Foo>(&mut scenario, OFFER_SUI);
        let wallet = test_ob::cancel_bid(&mut scenario, BUYER, OFFER_SUI);

        assert!(coin::value(&wallet) == OFFER_SUI, 0);

        transfer(wallet, BUYER);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_cancels_only_one_bid() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(&mut scenario);
        let _ob_id = test_ob::create_ob<test_ob::Foo>(&mut scenario);
        test_ob::create_safe(&mut scenario, BUYER);

        test_ob::create_bid<test_ob::Foo>(&mut scenario, OFFER_SUI);
        test_ob::create_bid<test_ob::Foo>(&mut scenario, OFFER_SUI);
        let wallet = test_ob::cancel_bid(&mut scenario, BUYER, OFFER_SUI);
        assert!(coin::value(&wallet) == OFFER_SUI, 0);

        test_scenario::next_tx(&mut scenario, CREATOR);
        let ob: Orderbook<test_ob::Foo, SUI> = test_scenario::take_shared(&scenario);
        assert!(crit_bit::length(ob::borrow_bids(&ob)) == 1, 0);

        transfer(wallet, BUYER);
        test_scenario::return_shared(ob);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 7, location = nft_protocol::orderbook)]
    fun it_cannot_cancel_non_existing_bid() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(&mut scenario);
        let _ob_id = test_ob::create_ob<test_ob::Foo>(&mut scenario);
        test_scenario::next_tx(&mut scenario, BUYER);
        test_ob::create_safe(&mut scenario, BUYER);

        test_scenario::next_tx(&mut scenario, BUYER);
        let wallet = test_ob::cancel_bid(&mut scenario, BUYER, OFFER_SUI);

        transfer(wallet, BUYER);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 5, location = nft_protocol::orderbook)]
    fun it_cannot_cancel_someone_elses_bid() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(&mut scenario);
        let _ob_id = test_ob::create_ob<test_ob::Foo>(&mut scenario);
        test_scenario::next_tx(&mut scenario, BUYER);
        test_ob::create_safe(&mut scenario, BUYER);

        test_ob::create_bid<test_ob::Foo>(&mut scenario, OFFER_SUI);
        test_scenario::next_tx(&mut scenario, THIRD_PARTY);
        let wallet = test_ob::cancel_bid(&mut scenario, THIRD_PARTY, OFFER_SUI);

        transfer(wallet, BUYER);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_cancels_bid_with_commission() {
        let scenario = test_scenario::begin(CREATOR);

        test_ob::create_collection_and_allowlist(&mut scenario);
        let _ob_id = test_ob::create_ob<test_ob::Foo>(&mut scenario);
        test_ob::create_safe(&mut scenario, BUYER);

        test_ob::create_bid_with_commission(
            &mut scenario, OFFER_SUI, CREATOR, COMMISSION_SUI,
        );
        let wallet = test_ob::cancel_bid(&mut scenario, BUYER, OFFER_SUI);

        assert!(coin::value(&wallet) == OFFER_SUI + COMMISSION_SUI, 0);

        transfer(wallet, BUYER);
        test_scenario::end(scenario);
    }
}
