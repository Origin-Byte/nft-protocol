#[test_only]
module nft_protocol::test_fixed_price {
    use sui::sui::SUI;
    use sui::coin;
    use sui::transfer;
    use sui::object::{Self, ID};
    use sui::test_scenario::{Self, Scenario, ctx};

    use nft_protocol::nft;
    use nft_protocol::warehouse;
    use nft_protocol::listing::{Self, Listing, WhitelistCertificate};
    use nft_protocol::fixed_price;

    use nft_protocol::test_listing::init_listing;

    struct COLLECTION {}

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
        let market = fixed_price::new<SUI>(price, ctx(scenario));
        let market_id = object::id(&market);

        let warehouse_id = listing::create_warehouse(listing, ctx(scenario));

        listing::add_market(
            listing,
            warehouse_id,
            is_whitelisted,
            market,
            ctx(scenario)
        );

        (warehouse_id, market_id)
    }

    #[test]
    fun create_market() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);

        let (warehouse_id, market_id) =
            init_market(&mut listing, 10, false, &mut scenario);
        let market = warehouse::market(
            listing::warehouse(&listing, warehouse_id),
            market_id,
        );

        assert!(fixed_price::price<SUI>(market) == 10, 0);

        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370202, location = nft_protocol::warehouse)]
    fun try_buy_not_live() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);

        let (warehouse_id, market_id) =
            init_market(&mut listing, 10, false, &mut scenario);

        let wallet = coin::mint_for_testing<SUI>(10, ctx(&mut scenario));
        fixed_price::buy_nft<COLLECTION, SUI>(
            &mut listing,
            warehouse_id,
            market_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        transfer::transfer(wallet, BUYER);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370209, location = nft_protocol::warehouse)]
    fun try_buy_no_supply() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);

        let (warehouse_id, market_id) =
            init_market(&mut listing, 10, false, &mut scenario);
        listing::sale_on(&mut listing, warehouse_id, market_id, ctx(&mut scenario));

        let wallet = coin::mint_for_testing<SUI>(10, ctx(&mut scenario));
        fixed_price::buy_nft<COLLECTION, SUI>(
            &mut listing,
            warehouse_id,
            market_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        transfer::transfer(wallet, BUYER);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    fun buy_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);

        let (warehouse_id, market_id) =
            init_market(&mut listing, 10, false, &mut scenario);

        listing::add_nft(
            &mut listing,
            warehouse_id,
            nft::new<COLLECTION, Witness>(
                &Witness {}, CREATOR, ctx(&mut scenario)
            ),
            ctx(&mut scenario)
        );

        listing::sale_on(&mut listing, warehouse_id, market_id, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        let wallet = coin::mint_for_testing<SUI>(15, ctx(&mut scenario));
        fixed_price::buy_nft<COLLECTION, SUI>(
            &mut listing,
            warehouse_id,
            market_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        assert!(coin::value(&wallet) == 5, 0);

        transfer::transfer(wallet, BUYER);
        test_scenario::next_tx(&mut scenario, BUYER);

        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370206, location = nft_protocol::warehouse)]
    fun try_buy_whitelisted_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);

        let (warehouse_id, market_id) =
            init_market(&mut listing, 10, true, &mut scenario);
        listing::sale_on(&mut listing, warehouse_id, market_id, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, BUYER);

        let wallet = coin::mint_for_testing<SUI>(10, ctx(&mut scenario));
        fixed_price::buy_nft<COLLECTION, SUI>(
            &mut listing,
            warehouse_id,
            market_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        assert!(coin::value(&wallet) == 0, 0);

        transfer::transfer(wallet, BUYER);
        test_scenario::next_tx(&mut scenario, BUYER);

        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    fun buy_whitelisted_nft() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);

        let (warehouse_id, market_id) =
            init_market(&mut listing, 10, true, &mut scenario);

        listing::add_nft(
            &mut listing,
            warehouse_id,
            nft::new<COLLECTION, Witness>(
                &Witness {}, CREATOR, ctx(&mut scenario)
            ),
            ctx(&mut scenario)
        );

        listing::sale_on(&mut listing, warehouse_id, market_id, ctx(&mut scenario));

        listing::transfer_whitelist_certificate(
            &listing, market_id, BUYER, ctx(&mut scenario)
        );

        test_scenario::next_tx(&mut scenario, BUYER);

        let certificate = test_scenario::take_from_address<
            WhitelistCertificate
        >(&scenario, BUYER);

        let wallet = coin::mint_for_testing<SUI>(10, ctx(&mut scenario));
        fixed_price::buy_whitelisted_nft<COLLECTION, SUI>(
            &mut listing,
            warehouse_id,
            market_id,
            &mut wallet,
            certificate,
            ctx(&mut scenario),
        );

        transfer::transfer(wallet, BUYER);
        test_scenario::next_tx(&mut scenario, BUYER);

        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370212, location = nft_protocol::listing)]
    fun try_change_price() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);

        let (warehouse_id, market_id) =
            init_market(&mut listing, 10, true, &mut scenario);

        test_scenario::next_tx(&mut scenario, BUYER);

        fixed_price::set_price<SUI>(
            &mut listing, warehouse_id, market_id, 20, ctx(&mut scenario)
        );

        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    fun change_price() {
        let scenario = test_scenario::begin(CREATOR);
        let listing = init_listing(CREATOR, &mut scenario);

        let (warehouse_id, market_id) =
            init_market(&mut listing, 10, true, &mut scenario);

        test_scenario::next_tx(&mut scenario, CREATOR);

        fixed_price::set_price<SUI>(
            &mut listing, warehouse_id, market_id, 20, ctx(&mut scenario)
        );

        let market = warehouse::market(
            listing::warehouse(&listing, warehouse_id),
            market_id,
        );
        assert!(fixed_price::price<SUI>(market) == 20, 0);

        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }
}
