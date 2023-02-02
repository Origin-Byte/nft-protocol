#[test_only]
module nft_protocol::mint_and_sell {
    use sui::coin;
    use sui::object;
    use sui::sui::SUI;
    use sui::transfer;
    use sui::test_scenario::{Self, Scenario, ctx};

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::fixed_price;
    use nft_protocol::collection;
    use nft_protocol::listing;
    use nft_protocol::warehouse;

    use nft_protocol::test_listing;

    struct Witness has drop {}

    struct COLLECTION has drop {}

    const OWNER: address = @0xA1C05;
    const CREATOR: address = @0xA1C05;
    const MARKETPLACE: address = @0xA1C20;

    fun init_collection(scenario: &mut Scenario) {
        let (mint_cap, collection) = collection::create(
            &COLLECTION {}, ctx(scenario),
        );

        transfer::share_object(collection);
        transfer::transfer(mint_cap, CREATOR);
    }

    #[test]
    public fun listing_proxy_mint() {
        // 1. Create collection
        let scenario = test_scenario::begin(CREATOR);
        init_collection(&mut scenario);

        let listing = test_listing::init_listing(MARKETPLACE, &mut scenario);

        // 2. Create `Warehouse`
        let inventory_id = listing::create_warehouse(
            &mut listing, ctx(&mut scenario)
        );
        let venue_id = fixed_price::create_venue<SUI>(
            &mut listing, inventory_id, false, 100, ctx(&mut scenario)
        );
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        // 3. Mint NFT to listing `Warehouse`
        let nft = nft::new<COLLECTION, Witness>(
            &Witness {}, MARKETPLACE, ctx(&mut scenario),
        );

        let nft_id = object::id(&nft);
        listing::add_nft(&mut listing, inventory_id, nft, ctx(&mut scenario));

        // 5. Buy the NFT
        test_scenario::next_tx(&mut scenario, CREATOR);

        let wallet = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));
        fixed_price::buy_nft<COLLECTION, SUI>(
            &mut listing,
            venue_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        // 6. Verify NFT was bought
        test_scenario::next_tx(&mut scenario, CREATOR);

        let bought_nft = test_scenario::take_from_address<Nft<COLLECTION>>(
            &scenario, CREATOR
        );
        assert!(nft_id == object::id(&bought_nft), 0);
        test_scenario::return_to_address(CREATOR, bought_nft);

        // Return objects and end test
        transfer::transfer(wallet, CREATOR);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    public fun inventory_proxy_mint() {
        // 1. Create collection and add domains
        let scenario = test_scenario::begin(CREATOR);
        init_collection(&mut scenario);

        let listing = test_listing::init_listing(MARKETPLACE, &mut scenario);

        // 2. Create `Warehouse`
        let warehouse = warehouse::new(ctx(&mut scenario));

        // 3. Mint NFT to `Warehouse`
        let nft = nft::new<COLLECTION, Witness>(
            &Witness {}, MARKETPLACE, ctx(&mut scenario),
        );

        let nft_id = object::id(&nft);
        warehouse::deposit_nft(&mut warehouse, nft);

        // 4. Insert `Warehouse` into `Listing` and create market
        let inventory_id = object::id(&warehouse);
        listing::add_warehouse(&mut listing, warehouse, ctx(&mut scenario));

        let venue_id = fixed_price::create_venue<SUI>(
            &mut listing, inventory_id, false, 100, ctx(&mut scenario)
        );

        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        // 5. Buy the NFT
        test_scenario::next_tx(&mut scenario, CREATOR);

        let wallet = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));
        fixed_price::buy_nft<COLLECTION, SUI>(
            &mut listing,
            venue_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        // 6. Verify NFT was bought
        test_scenario::next_tx(&mut scenario, CREATOR);

        let bought_nft = test_scenario::take_from_address<Nft<COLLECTION>>(
            &scenario, CREATOR
        );
        assert!(nft_id == object::id(&bought_nft), 0);
        test_scenario::return_to_address(CREATOR, bought_nft);

        // Return objects and end test
        transfer::transfer(wallet, CREATOR);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }
}
