#[test_only]
module nft_protocol::test_dutch_auction {
    use std::vector;

    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::balance;
    use sui::transfer;
    use sui::object::{Self, ID};
    use sui::test_scenario::{Self, Scenario, ctx};

    use originmate::crit_bit_u64 as crit_bit;

    use nft_protocol::nft;
    use nft_protocol::proceeds;
    use nft_protocol::inventory;
    use nft_protocol::slot::{Self, NftCertificate, WhitelistCertificate, Slot};
    use nft_protocol::dutch_auction::{Self, DutchAuctionMarket};

    use nft_protocol::test_slot::init_slot;

    struct COLLECTION {}

    const CREATOR: address = @0xA1C05;
    const BUYER: address = @0xA1C06;

    fun init_market(
        slot: &mut Slot,
        reserve_price: u64,
        is_whitelisted: bool,
        scenario: &mut Scenario,
    ): ID {
        let market = dutch_auction::new<SUI>(reserve_price, ctx(scenario));
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
        let _market: &DutchAuctionMarket<SUI> = slot::market(&slot, market_id);

        assert!(dutch_auction::reserve_price<SUI>(&slot, market_id) == 10, 0);

        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370202, location = nft_protocol::slot)]
    fun try_bid_not_live() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);
        
        test_scenario::next_tx(&mut scenario, BUYER);

        let wallet = coin::mint_for_testing<SUI>(10, ctx(&mut scenario));
        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            1,
            ctx(&mut scenario),
        );

        transfer::transfer(wallet, BUYER);
        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370303, location = nft_protocol::dutch_auction)]
    fun try_bid_lower_than_reserve() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);
        slot::sale_on(&mut slot, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        let wallet = coin::mint_for_testing<SUI>(10, ctx(&mut scenario));
        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            9,
            1,
            ctx(&mut scenario),
        );

        transfer::transfer(wallet, BUYER);
        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    fun bid_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);
        slot::sale_on(&mut slot, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        let wallet = coin::mint_for_testing<SUI>(49, ctx(&mut scenario));

        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            1,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            1,
            ctx(&mut scenario),
        );

        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            12,
            2,
            ctx(&mut scenario),
        );

        assert!(coin::value(&wallet) == 5, 0);

        let bids = dutch_auction::bids<SUI>(&slot, market_id);

        // Test bids at price level 10
        let level = crit_bit::borrow(bids, 10);
        let bid = vector::borrow(level, 0);
        assert!(dutch_auction::bid_owner(bid) == BUYER, 0);
        assert!(balance::value(dutch_auction::bid_amount(bid)) == 10, 0);
        let bid = vector::borrow(level, 1);
        assert!(dutch_auction::bid_owner(bid) == CREATOR, 0);
        assert!(balance::value(dutch_auction::bid_amount(bid)) == 10, 0);

        // Test bids at price level 12
        let level = crit_bit::borrow(bids, 12);
        let bid = vector::borrow(level, 0);
        assert!(dutch_auction::bid_owner(bid) == CREATOR, 0);
        assert!(balance::value(dutch_auction::bid_amount(bid)) == 12, 0);
        let bid = vector::borrow(level, 1);
        assert!(dutch_auction::bid_owner(bid) == CREATOR, 0);
        assert!(balance::value(dutch_auction::bid_amount(bid)) == 12, 0);

        transfer::transfer(wallet, BUYER);
        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370206, location = nft_protocol::slot)]
    fun try_bid_whitelisted_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, true, &mut scenario);
        slot::sale_on(&mut slot, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        let wallet = coin::mint_for_testing<SUI>(10, ctx(&mut scenario));
        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            1,
            ctx(&mut scenario),
        );

        transfer::transfer(wallet, BUYER);
        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    fun bid_whitelisted_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, true, &mut scenario);
        slot::sale_on(&mut slot, ctx(&mut scenario));

        slot::transfer_whitelist_certificate(
            &launchpad, &slot, market_id, BUYER, ctx(&mut scenario)
        );

        test_scenario::next_tx(&mut scenario, BUYER);

        let certificate = test_scenario::take_from_address<
            WhitelistCertificate
        >(&scenario, BUYER);

        let wallet = coin::mint_for_testing<SUI>(15, ctx(&mut scenario));
        dutch_auction::create_bid_whitelisted<SUI>(
            &mut wallet,
            &mut slot,
            market_id,
            certificate,
            10,
            1,
            ctx(&mut scenario),
        );

        assert!(coin::value(&wallet) == 5, 0);

        transfer::transfer(wallet, BUYER);
        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370302, location = nft_protocol::dutch_auction)]
    fun cancel_bid_does_not_exist() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);
        slot::sale_on(&mut slot, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        let wallet = coin::mint_for_testing<SUI>(44, ctx(&mut scenario));
        
        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            1,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        slot::sale_off(&launchpad, &mut slot, ctx(&mut scenario));

        dutch_auction::cancel_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            ctx(&mut scenario),
        );

        transfer::transfer(wallet, BUYER);
        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    fun cancel_bid() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);
        slot::sale_on(&mut slot, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        let wallet = coin::mint_for_testing<SUI>(44, ctx(&mut scenario));

        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            1,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            1,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, BUYER);

        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            1,
            ctx(&mut scenario),
        );

        let bids = dutch_auction::bids<SUI>(&slot, market_id);
        let level = crit_bit::borrow(bids, 10);
        assert!(vector::length(level) == 3, 0);
        let bid = vector::borrow(level, 0);
        assert!(dutch_auction::bid_owner(bid) == BUYER, 0);
        let bid = vector::borrow(level, 1);
        assert!(dutch_auction::bid_owner(bid) == CREATOR, 0);
        let bid = vector::borrow(level, 2);
        assert!(dutch_auction::bid_owner(bid) == BUYER, 0);

        test_scenario::next_tx(&mut scenario, BUYER);

        dutch_auction::cancel_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            ctx(&mut scenario),
        );

        let bids = dutch_auction::bids<SUI>(&slot, market_id);
        let level = crit_bit::borrow(bids, 10);
        assert!(vector::length(level) == 2, 0);
        let bid = vector::borrow(level, 0);
        assert!(dutch_auction::bid_owner(bid) == CREATOR, 0);
        let bid = vector::borrow(level, 1);
        assert!(dutch_auction::bid_owner(bid) == BUYER, 0);

        dutch_auction::cancel_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            ctx(&mut scenario),
        );

        let bids = dutch_auction::bids<SUI>(&slot, market_id);
        let level = crit_bit::borrow(bids, 10);
        assert!(vector::length(level) == 1, 0);
        let bid = vector::borrow(level, 0);
        assert!(dutch_auction::bid_owner(bid) == CREATOR, 0);

        test_scenario::next_tx(&mut scenario, CREATOR);

        dutch_auction::cancel_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            ctx(&mut scenario),
        );

        assert!(coin::value(&wallet) == 44, 0);

        // Check that price levels are automatically removed once empty
        let bids = dutch_auction::bids<SUI>(&slot, market_id);
        assert!(crit_bit::is_empty(bids), 0);

        transfer::transfer(wallet, BUYER);
        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    fun cancel_while_not_live() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);
        slot::sale_on(&mut slot, ctx(&mut scenario));

        let wallet = coin::mint_for_testing<SUI>(44, ctx(&mut scenario));
        
        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            1,
            ctx(&mut scenario),
        );

        // Bids should be cancellable even if slot is turned off
        slot::sale_off(&launchpad, &mut slot, ctx(&mut scenario));

        dutch_auction::cancel_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            ctx(&mut scenario),
        );

        let bids = dutch_auction::bids<SUI>(&slot, market_id);
        assert!(crit_bit::is_empty(bids), 0);

        transfer::transfer(wallet, BUYER);
        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370212, location = nft_protocol::slot)]
    fun try_cancel_auction() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);

        test_scenario::next_tx(&mut scenario, BUYER);

        dutch_auction::sale_cancel<SUI>(
            &launchpad,
            &mut slot,
            market_id,
            ctx(&mut scenario),
        );

        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    fun cancel_auction() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);
        slot::sale_on(&mut slot, ctx(&mut scenario));

        let wallet = coin::mint_for_testing<SUI>(44, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            1,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            12,
            1,
            ctx(&mut scenario),
        );

        dutch_auction::sale_cancel<SUI>(
            &launchpad,
            &mut slot,
            market_id,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        // Slot should be automatically turned off after cancelling the auction
        assert!(!slot::is_live(&slot), 0);

        // Check wallet balances
        assert!(coin::value(&wallet) == 22, 0);

        let refunded = test_scenario::take_from_address<Coin<SUI>>(
            &scenario,
            BUYER,
        );
        assert!(coin::value(&refunded) == 10, 0);
        test_scenario::return_to_address(BUYER, refunded);

        let refunded = test_scenario::take_from_address<Coin<SUI>>(
            &scenario,
            CREATOR,
        );
        assert!(coin::value(&refunded) == 12, 0);
        test_scenario::return_to_address(CREATOR, refunded);

        // Check bid state
        let bids = dutch_auction::bids<SUI>(&slot, market_id);
        assert!(crit_bit::is_empty(bids), 0);

        transfer::transfer(wallet, BUYER);
        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370212, location = nft_protocol::slot)]
    fun try_conclude_auction() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);

        test_scenario::next_tx(&mut scenario, BUYER);

        dutch_auction::sale_conclude<SUI>(
            &launchpad,
            &mut slot,
            market_id,
            ctx(&mut scenario),
        );

        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    fun conclude_auction() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);
        
        slot::add_nft(
            &mut slot,
            market_id,
            nft::new<COLLECTION>(CREATOR, ctx(&mut scenario)),
            ctx(&mut scenario)
        );

        slot::add_nft(
            &mut slot,
            market_id,
            nft::new<COLLECTION>(CREATOR, ctx(&mut scenario)),
            ctx(&mut scenario)
        );
        
        slot::sale_on(&mut slot, ctx(&mut scenario));

        let wallet = coin::mint_for_testing<SUI>(35, ctx(&mut scenario));

        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            1,
            ctx(&mut scenario),
        );

        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            11,
            1,
            ctx(&mut scenario),
        );

        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            12,
            1,
            ctx(&mut scenario),
        );

        dutch_auction::sale_conclude<SUI>(
            &launchpad,
            &mut slot,
            market_id,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        // Slot should be automatically turned off after concluding the auction
        assert!(!slot::is_live(&slot), 0);

        // Check certificates

        let certificate0 = test_scenario::take_from_address<NftCertificate>(
            &mut scenario, CREATOR
        );
        slot::assert_nft_certificate_slot(object::id(&slot), &certificate0);
        
        let certificate1 = test_scenario::take_from_address<NftCertificate>(
            &mut scenario, CREATOR
        );
        slot::assert_nft_certificate_slot(object::id(&slot), &certificate1);
        
        test_scenario::return_to_address(CREATOR, certificate0);
        test_scenario::return_to_address(CREATOR, certificate1);

        // Check wallet balances
        assert!(coin::value(&wallet) == 2, 0);

        // Auction should have filled at 11
        let proceeds = slot::proceeds(&slot);
        assert!(proceeds::total(proceeds) == 2, 0);
        assert!(balance::value(proceeds::balance<SUI>(proceeds)) == 22, 0);

        // One bid should have been refunded and also some change
        let refunded0 = test_scenario::take_from_address<Coin<SUI>>(
            &scenario,
            CREATOR,
        );
        assert!(coin::value(&refunded0) == 10, 0);

        let refunded1 = test_scenario::take_from_address<Coin<SUI>>(
            &scenario,
            CREATOR,
        );
        assert!(coin::value(&refunded1) == 1, 0);

        test_scenario::return_to_address(CREATOR, refunded0);
        test_scenario::return_to_address(CREATOR, refunded1);

        // Check bid state
        let bids = dutch_auction::bids<SUI>(&slot, market_id);
        assert!(crit_bit::is_empty(bids), 0);

        transfer::transfer(wallet, BUYER);
        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }

    #[test]
    fun conclude_auction_not_all_sold() {
        let scenario = test_scenario::begin(CREATOR);
        let (launchpad, slot) = init_slot(CREATOR, &mut scenario);

        let market_id = init_market(&mut slot, 10, false, &mut scenario);
        
        slot::add_nft(
            &mut slot,
            market_id,
            nft::new<COLLECTION>(CREATOR, ctx(&mut scenario)),
            ctx(&mut scenario)
        );

        slot::add_nft(
            &mut slot,
            market_id,
            nft::new<COLLECTION>(CREATOR, ctx(&mut scenario)),
            ctx(&mut scenario)
        );
        
        slot::sale_on(&mut slot, ctx(&mut scenario));

        let wallet = coin::mint_for_testing<SUI>(35, ctx(&mut scenario));

        dutch_auction::create_bid(
            &mut wallet,
            &mut slot,
            market_id,
            10,
            1,
            ctx(&mut scenario),
        );

        dutch_auction::sale_conclude<SUI>(
            &launchpad,
            &mut slot,
            market_id,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        // Slot should not be turned off as all inventory has not been sold
        assert!(slot::is_live(&slot), 0);

        // Check bid state
        let bids = dutch_auction::bids<SUI>(&slot, market_id);
        assert!(crit_bit::is_empty(bids), 0);

        transfer::transfer(wallet, BUYER);
        test_scenario::return_shared(slot);
        test_scenario::return_shared(launchpad);
        test_scenario::end(scenario);
    }
}
