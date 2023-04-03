#[test_only]
module nft_protocol::mint_and_sell {
    use sui::coin;
    use sui::object::{Self, UID};
    use sui::sui::SUI;
    use sui::transfer;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::fixed_price;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::listing;
    use nft_protocol::warehouse;

    use nft_protocol::test_listing;

    struct Foo has key, store {
        id: UID,
    }
    struct Witness has drop {}

    const OWNER: address = @0xA1C05;
    const CREATOR: address = @0xA1C05;
    const MARKETPLACE: address = @0xA1C20;

    #[test]
    public fun listing_proxy_mint() {
        // 1. Create collection
        let scenario = test_scenario::begin(CREATOR);

        let collection: Collection<Foo> =
            collection::create(Witness {}, ctx(&mut scenario));
        transfer::public_share_object(collection);
        let listing = test_listing::init_listing(MARKETPLACE, &mut scenario);

        // 2. Create `Warehouse`
        let inventory_id = listing::create_warehouse<Foo>(
            &mut listing,
            ctx(&mut scenario),
        );
        let venue_id = fixed_price::create_venue<Foo, SUI>(
            &mut listing, inventory_id, false, 100, ctx(&mut scenario)
        );
        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        // 3. Mint NFT to listing `Warehouse`
        let nft = Foo { id: object::new(ctx(&mut scenario)) };

        let nft_id = object::id(&nft);
        listing::add_nft(&mut listing, inventory_id, nft, ctx(&mut scenario));

        // 5. Buy the NFT
        test_scenario::next_tx(&mut scenario, CREATOR);

        let wallet = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));
        fixed_price::buy_nft<Foo, SUI>(
            &mut listing,
            venue_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        // 6. Verify NFT was bought
        test_scenario::next_tx(&mut scenario, CREATOR);

        let bought_nft = test_scenario::take_from_address<Foo>(
            &scenario, CREATOR
        );
        assert!(nft_id == object::id(&bought_nft), 0);
        test_scenario::return_to_address(CREATOR, bought_nft);

        // Return objects and end test
        transfer::public_transfer(wallet, CREATOR);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }

    #[test]
    public fun inventory_proxy_mint() {
        // 1. Create collection and add domains
        let scenario = test_scenario::begin(CREATOR);

        let collection: Collection<Foo> =
            collection::create(Witness {}, ctx(&mut scenario));
        transfer::public_share_object(collection);
        let listing = test_listing::init_listing(MARKETPLACE, &mut scenario);

        // 2. Create `Warehouse`
        let warehouse = warehouse::new(ctx(&mut scenario));

        // 3. Mint NFT to `Warehouse`
        let nft = Foo { id: object::new(ctx(&mut scenario)) };

        let nft_id = object::id(&nft);
        warehouse::deposit_nft(&mut warehouse, nft);

        // 4. Insert `Warehouse` into `Listing` and create market
        //
        // For an entry function equivalent use `listing::add_warehouse`
        let inventory_id = listing::insert_warehouse(
            &mut listing,
            warehouse,
            ctx(&mut scenario)
        );

        let venue_id = fixed_price::create_venue<Foo, SUI>(
            &mut listing, inventory_id, false, 100, ctx(&mut scenario)
        );

        listing::sale_on(&mut listing, venue_id, ctx(&mut scenario));

        // 5. Buy the NFT
        test_scenario::next_tx(&mut scenario, CREATOR);

        let wallet = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));
        fixed_price::buy_nft<Foo, SUI>(
            &mut listing,
            venue_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        // 6. Verify NFT was bought
        test_scenario::next_tx(&mut scenario, CREATOR);

        let bought_nft = test_scenario::take_from_address<Foo>(
            &scenario, CREATOR
        );
        assert!(nft_id == object::id(&bought_nft), 0);
        test_scenario::return_to_address(CREATOR, bought_nft);

        // Return objects and end test
        transfer::public_transfer(wallet, CREATOR);
        test_scenario::return_shared(listing);
        test_scenario::end(scenario);
    }
}
