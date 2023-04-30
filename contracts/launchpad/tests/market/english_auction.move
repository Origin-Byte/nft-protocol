#[test_only]
module ob_launchpad::test_english_auction {
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::balance;
    use sui::object::{Self, UID, ID};
    use sui::test_scenario::{Self, Scenario, ctx};

    use ob_launchpad::venue;
    use ob_launchpad::proceeds;
    use ob_launchpad::listing::{Self, Listing};
    use ob_launchpad::market_whitelist::{Self, Certificate};
    use ob_launchpad::english_auction;

    use ob_launchpad::test_listing::init_listing;

    struct Foo has key, store {
        id: UID,
    }
    struct Witness has drop {}

    const CREATOR: address = @0xA1C05;
    const BUYER: address = @0xA1C06;

    /// Initializes warehouse and market with pre-minted NFT
    fun init_market(
        listing: &mut Listing,
        wallet: &mut Coin<SUI>,
        is_whitelisted: bool,
        bid: u64,
        scenario: &mut Scenario,
    ): ID {
        let inventory_id =
            listing::create_warehouse<Foo>(listing, ctx(scenario));

        let nft = Foo { id: object::new(ctx(scenario)) };
        let nft_id = object::id(&nft);
        listing::add_nft(listing, inventory_id, nft, ctx(scenario));

        let venue_id = english_auction::create_auction<Foo, SUI>(
            listing,
            wallet,
            is_whitelisted,
            inventory_id,
            nft_id,
            bid,
            ctx(scenario),
        );

        venue_id
    }

    #[test]
    fun create_market() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);
        let wallet = coin::mint_for_testing<SUI>(10, ctx(&mut scenario));

        let venue_id =
            init_market(&mut listing, &mut wallet, false, 10, &mut scenario);

        let auction = english_auction::borrow_market<Foo, SUI>(
            listing::borrow_venue(&listing, venue_id),
        );

        assert!(english_auction::current_bid(auction) == 10, 0);
        assert!(english_auction::current_bidder(auction) == CREATOR, 0);

        english_auction::assert_not_concluded(auction);

        coin::burn_for_testing(wallet);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = venue::EVenueNotLive)]
    fun try_bid_not_live() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);
        let wallet = coin::mint_for_testing<SUI>(21, ctx(&mut scenario));

        let venue_id =
            init_market(&mut listing, &mut wallet, false, 10, &mut scenario);

        english_auction::create_bid<Foo, SUI>(
            &mut listing,
            &mut wallet,
            venue_id,
            11,
            ctx(&mut scenario),
        );

        coin::burn_for_testing(wallet);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = sui::balance::ENotEnough)]
    fun try_bid_insufficient_coin() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);
        let wallet = coin::mint_for_testing<SUI>(20, ctx(&mut scenario));

        let venue_id =
            init_market(&mut listing, &mut wallet, false, 10, &mut scenario);
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        english_auction::create_bid<Foo, SUI>(
            &mut listing,
            &mut wallet,
            venue_id,
            11,
            ctx(&mut scenario),
        );

        coin::burn_for_testing(wallet);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = english_auction::EBidTooLow)]
    fun try_bid_too_low() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);
        let wallet = coin::mint_for_testing<SUI>(21, ctx(&mut scenario));

        let venue_id =
            init_market(&mut listing, &mut wallet, false, 10, &mut scenario);
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        english_auction::create_bid<Foo, SUI>(
            &mut listing,
            &mut wallet,
            venue_id,
            10,
            ctx(&mut scenario),
        );

        coin::burn_for_testing(wallet);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    fun bid_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);
        let wallet = coin::mint_for_testing<SUI>(21, ctx(&mut scenario));

        let venue_id =
            init_market(&mut listing, &mut wallet, false, 10, &mut scenario);
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        english_auction::create_bid<Foo, SUI>(
            &mut listing,
            &mut wallet,
            venue_id,
            11,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        // Check wallet balances
        assert!(coin::value(&wallet) == 0, 0);

        // Check auction state
        let auction = english_auction::borrow_market<Foo, SUI>(
            listing::borrow_venue(&listing, venue_id),
        );

        assert!(english_auction::current_bid(auction) == 11, 0);
        assert!(english_auction::current_bidder(auction) == BUYER, 0);

        // Check that first bidder was refunded
        let refund = test_scenario::take_from_address<Coin<SUI>>(
            &scenario, CREATOR
        );

        assert!(coin::value(&refund) == 10, 0);

        test_scenario::return_to_address(CREATOR, refund);

        coin::burn_for_testing(wallet);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = venue::EVenueWhitelisted)]
    fun try_bid_whitelisted_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);
        let wallet = coin::mint_for_testing<SUI>(21, ctx(&mut scenario));

        let venue_id =
            init_market(&mut listing, &mut wallet, true, 10, &mut scenario);
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        english_auction::create_bid<Foo, SUI>(
            &mut listing,
            &mut wallet,
            venue_id,
            11,
            ctx(&mut scenario),
        );

        assert!(coin::value(&wallet) == 0, 0);

        coin::burn_for_testing(wallet);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    fun bid_whitelisted_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);
        let wallet = coin::mint_for_testing<SUI>(21, ctx(&mut scenario));

        let venue_id =
            init_market(&mut listing, &mut wallet, true, 10, &mut scenario);
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        market_whitelist::issue(&listing, venue_id, BUYER, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        let certificate = test_scenario::take_from_address<Certificate>(
            &scenario, BUYER
        );

        english_auction::create_bid_whitelisted<Foo, SUI>(
            &mut listing,
            &mut wallet,
            venue_id,
            certificate,
            11,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        // Check wallet balances
        assert!(coin::value(&wallet) == 0, 0);

        // Check auction state
        let auction = english_auction::borrow_market<Foo, SUI>(
            listing::borrow_venue(&listing, venue_id),
        );

        assert!(english_auction::current_bid(auction) == 11, 0);
        assert!(english_auction::current_bidder(auction) == BUYER, 0);

        // Check that first bidder was refunded
        let refund = test_scenario::take_from_address<Coin<SUI>>(
            &scenario, CREATOR
        );

        assert!(coin::value(&refund) == 10, 0);

        test_scenario::return_to_address(CREATOR, refund);

        coin::burn_for_testing(wallet);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = listing::EWrongAdmin)]
    fun try_conclude_auction() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);
        let wallet = coin::mint_for_testing<SUI>(21, ctx(&mut scenario));

        let venue_id =
            init_market(&mut listing, &mut wallet, false, 10, &mut scenario);
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        english_auction::conclude_auction<Foo, SUI>(
            &mut listing, venue_id, ctx(&mut scenario),
        );

        coin::burn_for_testing(wallet);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = english_auction::EAuctionConcluded)]
    fun try_conclude_auction_twice() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);
        let wallet = coin::mint_for_testing<SUI>(21, ctx(&mut scenario));

        let venue_id =
            init_market(&mut listing, &mut wallet, false, 10, &mut scenario);
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);

        english_auction::conclude_auction<Foo, SUI>(
            &mut listing, venue_id, ctx(&mut scenario),
        );

        english_auction::conclude_auction<Foo, SUI>(
            &mut listing, venue_id, ctx(&mut scenario),
        );

        coin::burn_for_testing(wallet);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    fun conclude_auction() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);
        let wallet = coin::mint_for_testing<SUI>(21, ctx(&mut scenario));

        let venue_id =
            init_market(&mut listing, &mut wallet, false, 10, &mut scenario);
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);

        english_auction::conclude_auction<Foo, SUI>(
            &mut listing, venue_id, ctx(&mut scenario),
        );

        // Check that auction was concluded
        let auction = english_auction::borrow_market<Foo, SUI>(
            listing::borrow_venue(&listing, venue_id),
        );

        english_auction::assert_concluded(auction);

        coin::burn_for_testing(wallet);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = english_auction::EAuctionNotConcluded)]
    fun try_claim_nft_unconcluded() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);
        let wallet = coin::mint_for_testing<SUI>(21, ctx(&mut scenario));

        let venue_id =
            init_market(&mut listing, &mut wallet, false, 10, &mut scenario);
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);

        english_auction::claim_nft<Foo, SUI>(
            &mut listing, venue_id, ctx(&mut scenario),
        );

        coin::burn_for_testing(wallet);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = english_auction::ECannotClaim)]
    fun try_claim_nft_wrong_sender() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);
        let wallet = coin::mint_for_testing<SUI>(21, ctx(&mut scenario));

        let venue_id =
            init_market(&mut listing, &mut wallet, false, 10, &mut scenario);
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);

        english_auction::conclude_auction<Foo, SUI>(
            &mut listing, venue_id, ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, BUYER);

        english_auction::claim_nft<Foo, SUI>(
            &mut listing, venue_id, ctx(&mut scenario),
        );

        coin::burn_for_testing(wallet);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    fun claim_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);
        let wallet = coin::mint_for_testing<SUI>(21, ctx(&mut scenario));

        let venue_id =
            init_market(&mut listing, &mut wallet, false, 10, &mut scenario);
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);

        english_auction::conclude_auction<Foo, SUI>(
            &mut listing, venue_id, ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        english_auction::claim_nft<Foo, SUI>(
            &mut listing, venue_id, ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        // Check that auction has been deconstructed
        assert!(!listing::contains_venue(&listing, venue_id), 0);

        // Check that NFT was correctly sold
        let proceeds = listing::borrow_proceeds(&listing);
        assert!(proceeds::total(proceeds) == 1, 0);
        assert!(balance::value(proceeds::balance<SUI>(proceeds)) == 10, 0);

        // TODO: Check Kiosk created and NFT was deposited
        // assert!(test_scenario::has_most_recent_for_address<Foo>(CREATOR), 0);

        coin::burn_for_testing(wallet);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }
}
