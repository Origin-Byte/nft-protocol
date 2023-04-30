#[test_only]
module ob_tests::test_fixed_bid {
    use std::type_name;
    use std::option;
    use std::vector;
    // use std::debug;
    // use std::string::utf8;
    // debug::print(&utf8(b"a"));

    use sui::test_scenario::{Self, ctx};
    use sui::sui::SUI;
    use sui::transfer;
    use sui::object::{Self, ID};
    use sui::vec_map;
    use sui::coin;

    use ob_launchpad_v2::launchpad::{Self};
    use ob_launchpad_v2::venue::{Self, Venue};
    use ob_launchpad_v2::fixed_bid::{Self, Witness as FixedBidWit};
    use ob_launchpad_v2::warehouse::{Self, Warehouse, Witness as WarehouseWit};
    use ob_launchpad_v2::pseudorand_redeem::{Self as pseudorand, Witness as PseudoRandomWit};
    use ob_launchpad_v2::sequential::{Self, Witness as SequentialWit};
    use ob_tests::test_utils::{Self as utils, Foo};
    use ob_launchpad_v2::certificate;
    use ob_kiosk::ob_kiosk;

    use ob_utils::sized_vec::SizedVec;
    use ob_utils::utils_supply::{Self as supply};

    const MARKETPLACE: address = @0xA1C08;
    const BUYER: address = @0xA1C10;

    #[test]
    public fun buy_1_nft_pseudorand() {
        let scenario = test_scenario::begin(MARKETPLACE);

        // 1. Create a Launchpad Listing
        let (listing, launch_cap) = launchpad::new(ctx(&mut scenario));

        // 2. Create Sales Venue
        let venue = venue::new(
            &mut listing,
            &launch_cap,
            // Market type
            type_name::get<FixedBidWit>(),
            // Inventory Type
            type_name::get<WarehouseWit>(),
            // Inventory Retrieval Method
            type_name::get<PseudoRandomWit>(),
            // NFT Retrieval Method
            type_name::get<PseudoRandomWit>(),
            ctx(&mut scenario),
        );

        // Add redeem rules for Inventory and NFT choice
        pseudorand::add_inventory_method(&launch_cap, &mut venue);
        pseudorand::add_nft_method(&launch_cap, &mut venue);

        let supply = 1_000;
        let nfts_to_buy = 1;
        let max_buy = 1;
        let price = 10;

        // 3. Add market module
        fixed_bid::init_market<SUI>(&launch_cap, &mut venue, price, max_buy, ctx(&mut scenario));

        transfer::public_share_object(listing);
        transfer::public_share_object(venue);

        // 4. Create warehouse
        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let warehouse = warehouse::new<Foo>(&launch_cap, ctx(&mut scenario));
        let warehouse_id = object::id(&warehouse);

        // 5. Mint NFTs to the Warehouse
        utils::batch_mint_foo_nft_to_warehouse(&mut warehouse, supply, ctx(&mut scenario));
        warehouse::share(warehouse);

        // 6. Register Supply
        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let warehouse = test_scenario::take_shared<Warehouse<Foo>>(&scenario);
        let venue = test_scenario::take_shared<Venue>(&scenario);

        warehouse::register_supply(&launch_cap, &mut venue, &mut warehouse, supply);

        // 6. Buy NFT
        test_scenario::next_tx(&mut scenario, BUYER);

        let coin = coin::mint_for_testing<SUI>(price * nfts_to_buy, ctx(&mut scenario));
        let req = venue::request_access(&venue, ctx(&mut scenario));

        let cert = fixed_bid::buy_nft_cert<Foo, SUI>(
            &mut venue,
            &mut coin,
            nfts_to_buy,
            req,
            ctx(&mut scenario),
        );

        // Assert correct data in NftCertificate
        assert!(certificate::venue_id(&cert) == object::id(&venue), 0);
        assert!(certificate::quantity(&cert) == nfts_to_buy, 0);
        assert!(certificate::nft_map(&cert) == &vec_map::empty<ID, SizedVec<u64>>(), 0);
        assert!(certificate::buyer(&cert) == BUYER, 0);
        assert!(certificate::inventory_type(&cert) == type_name::get<WarehouseWit>(), 0);

        // Assert correct update of Venue Supply
        assert!(supply::get_max(option::borrow(venue::get_supply(&venue))) == supply, 0);
        assert!(supply::get_current(option::borrow(venue::get_supply(&venue))) == nfts_to_buy, 0);

        // The NFT has not been withdrawn from the inventory and therefore the supply
        // registered here is still 1_000
        assert!(venue::get_inventory_supply(&venue, warehouse_id) == supply, 0);

        pseudorand::assign_inventory(&mut venue, &mut cert, ctx(&mut scenario));
        pseudorand::assign_nft(&mut venue, &mut cert, ctx(&mut scenario));

        // Once the Inventory has been assigned, that's when we decrease the available supply
        // on the bookeeping
        assert!(venue::get_inventory_supply(&venue, warehouse_id) == supply - nfts_to_buy, 0);

        // Since the redeem method is pseudo-random we have to call another transaction
        // to make sure we choose the correct warehouse
        test_scenario::next_tx(&mut scenario, BUYER);

        // Redeem NFT from the warehosue
        let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
        warehouse::redeem_nft_to_kiosk(&mut warehouse, &mut cert, &mut buyer_kiosk ,ctx(&mut scenario));

        certificate::consume_for_test(cert);// TODO replace
        coin::burn_for_testing(coin);

        test_scenario::return_shared(warehouse);
        test_scenario::return_shared(venue);
        transfer::public_transfer(launch_cap, MARKETPLACE);
        transfer::public_share_object(buyer_kiosk);

        test_scenario::end(scenario);
    }

    #[test]
    public fun buy_all_nfts_pseudo_rand() {
        let scenario = test_scenario::begin(MARKETPLACE);

        // 1. Create a Launchpad Listing
        let (listing, launch_cap) = launchpad::new(ctx(&mut scenario));

        // 2. Create Sales Venue
        let venue = venue::new(
            &mut listing,
            &launch_cap,
            // Market type
            type_name::get<FixedBidWit>(),
            // Inventory Type
            type_name::get<WarehouseWit>(),
            // Inventory Retrieval Method
            type_name::get<PseudoRandomWit>(),
            // NFT Retrieval Method
            type_name::get<PseudoRandomWit>(),
            ctx(&mut scenario),
        );

        // Add redeem rules for Inventory and NFT choice
        pseudorand::add_inventory_method(&launch_cap, &mut venue);
        pseudorand::add_nft_method(&launch_cap, &mut venue);

        let supply = 1_000;
        let nfts_to_buy = 1_000;
        let max_buy = 1_000;
        let price = 10;

        // 3. Add market module
        fixed_bid::init_market<SUI>(&launch_cap, &mut venue, price, max_buy, ctx(&mut scenario));

        transfer::public_share_object(listing);
        transfer::public_share_object(venue);

        // 4. Create warehouse
        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let warehouse = warehouse::new<Foo>(&launch_cap, ctx(&mut scenario));
        let warehouse_id = object::id(&warehouse);

        // 5. Mint NFTs to the Warehouse
        utils::batch_mint_foo_nft_to_warehouse(&mut warehouse, supply, ctx(&mut scenario));
        warehouse::share(warehouse);

        // 6. Register Supply
        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let warehouse = test_scenario::take_shared<Warehouse<Foo>>(&scenario);
        let venue = test_scenario::take_shared<Venue>(&scenario);

        warehouse::register_supply(&launch_cap, &mut venue, &mut warehouse, supply);

        // 6. Buy NFT
        test_scenario::next_tx(&mut scenario, BUYER);
        let coin = coin::mint_for_testing<SUI>(price * nfts_to_buy, ctx(&mut scenario));
        let req = venue::request_access(&venue, ctx(&mut scenario));

        let cert = fixed_bid::buy_nft_cert<Foo, SUI>(
            &mut venue,
            &mut coin,
            nfts_to_buy,
            req,
            ctx(&mut scenario),
        );

        // Assert correct data in NftCertificate
        assert!(certificate::venue_id(&cert) == object::id(&venue), 0);
        assert!(certificate::quantity(&cert) == nfts_to_buy, 0);
        assert!(certificate::nft_map(&cert) == &vec_map::empty<ID, SizedVec<u64>>(), 0);
        assert!(certificate::buyer(&cert) == BUYER, 0);
        assert!(certificate::inventory_type(&cert) == type_name::get<WarehouseWit>(), 0);

        // Assert correct update of Venue Supply
        assert!(supply::get_max(option::borrow(venue::get_supply(&venue))) == supply, 0);
        assert!(supply::get_current(option::borrow(venue::get_supply(&venue))) == nfts_to_buy, 0);

        // The NFT has not been withdrawn from the inventory and therefore the supply
        // registered here is stil 1_000
        assert!(venue::get_inventory_supply(&venue, warehouse_id) == supply, 0);

        pseudorand::assign_inventory(&mut venue, &mut cert, ctx(&mut scenario));
        pseudorand::assign_nft(&mut venue, &mut cert, ctx(&mut scenario));

        // Once the Inventory has been assigned, that's when we decrease the available supply
        // on the bookeeping - When supply is 0 we pop the K, V out
        assert!(!vec_map::contains(venue::get_invetories(&venue), &warehouse_id), 0);

        // Since the redeem method is pseudo-random we have to call another transaction
        // to make sure we choose the correct warehouse
        test_scenario::next_tx(&mut scenario, BUYER);

        // Redeem NFT from the warehouse
        let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
        warehouse::redeem_nft_to_kiosk(&mut warehouse, &mut cert, &mut buyer_kiosk ,ctx(&mut scenario));


        certificate::consume_for_test(cert);// TODO replace
        coin::burn_for_testing(coin);

        test_scenario::return_shared(warehouse);
        test_scenario::return_shared(venue);
        transfer::public_transfer(launch_cap, MARKETPLACE);
        transfer::public_share_object(buyer_kiosk);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad_v2::fixed_bid::EMAX_BUY_QUANTITY_SURPASSED)]
    public fun try_buy_more_than_max_buy() {
        let scenario = test_scenario::begin(MARKETPLACE);

        // 1. Create a Launchpad Listing
        let (listing, launch_cap) = launchpad::new(ctx(&mut scenario));

        // 2. Create Sales Venue
        let venue = venue::new(
            &mut listing,
            &launch_cap,
            // Market type
            type_name::get<FixedBidWit>(),
            // Inventory Type
            type_name::get<WarehouseWit>(),
            // Inventory Retrieval Method
            type_name::get<PseudoRandomWit>(),
            // NFT Retrieval Method
            type_name::get<PseudoRandomWit>(),
            ctx(&mut scenario),
        );

        // Add redeem rules for Inventory and NFT choice
        pseudorand::add_inventory_method(&launch_cap, &mut venue);
        pseudorand::add_nft_method(&launch_cap, &mut venue);

        let supply = 20;
        let nfts_to_buy = 20;
        let max_buy = 10;
        let price = 10;

        // 3. Add market module
        fixed_bid::init_market<SUI>(&launch_cap, &mut venue, price, max_buy, ctx(&mut scenario));

        transfer::public_share_object(listing);
        transfer::public_share_object(venue);

        // 4. Create warehouse
        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let warehouse = warehouse::new<Foo>(&launch_cap, ctx(&mut scenario));

        // 5. Mint NFTs to the Warehouse
        utils::batch_mint_foo_nft_to_warehouse(&mut warehouse, supply, ctx(&mut scenario));
        warehouse::share(warehouse);

        // 6. Register Supply
        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let warehouse = test_scenario::take_shared<Warehouse<Foo>>(&scenario);
        let venue = test_scenario::take_shared<Venue>(&scenario);

        warehouse::register_supply(&launch_cap, &mut venue, &mut warehouse, supply);

        // 6. Buy NFT
        test_scenario::next_tx(&mut scenario, BUYER);
        let coin = coin::mint_for_testing<SUI>(price * nfts_to_buy, ctx(&mut scenario));
        let req = venue::request_access(&venue, ctx(&mut scenario));

        let cert = fixed_bid::buy_nft_cert<Foo, SUI>(
            &mut venue,
            &mut coin,
            // FAILS here becuase the max buy is set to 10
            nfts_to_buy,
            req,
            ctx(&mut scenario),
        );

        certificate::consume_for_test(cert);// TODO replace
        coin::burn_for_testing(coin);

        test_scenario::return_shared(venue);
        test_scenario::return_shared(warehouse);
        transfer::public_transfer(launch_cap, MARKETPLACE);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_utils::utils_supply::EExceededSupply)]
    public fun try_buy_more_than_max_supply() {
        let scenario = test_scenario::begin(MARKETPLACE);

        // 1. Create a Launchpad Listing
        let (listing, launch_cap) = launchpad::new(ctx(&mut scenario));

        // 2. Create Sales Venue
        let venue = venue::new(
            &mut listing,
            &launch_cap,
            // Market type
            type_name::get<FixedBidWit>(),
            // Inventory Type
            type_name::get<WarehouseWit>(),
            // Inventory Retrieval Method
            type_name::get<PseudoRandomWit>(),
            // NFT Retrieval Method
            type_name::get<PseudoRandomWit>(),
            ctx(&mut scenario),
        );

        // Add redeem rules for Inventory and NFT choice
        pseudorand::add_inventory_method(&launch_cap, &mut venue);
        pseudorand::add_nft_method(&launch_cap, &mut venue);

        let supply = 10;
        let nfts_to_buy = 11;
        let max_buy = 10;
        let price = 10;

        // 3. Add market module
        fixed_bid::init_market<SUI>(&launch_cap, &mut venue, price, max_buy, ctx(&mut scenario));

        transfer::public_share_object(listing);
        transfer::public_share_object(venue);

        // 4. Create warehouse
        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let warehouse = warehouse::new<Foo>(&launch_cap, ctx(&mut scenario));

        // 5. Mint NFTs to the Warehouse
        utils::batch_mint_foo_nft_to_warehouse(&mut warehouse, supply, ctx(&mut scenario));
        warehouse::share(warehouse);

        // 6. Register Supply
        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let warehouse = test_scenario::take_shared<Warehouse<Foo>>(&scenario);
        let venue = test_scenario::take_shared<Venue>(&scenario);

        warehouse::register_supply(&launch_cap, &mut venue, &mut warehouse, supply);

        // 6. Buy NFT
        test_scenario::next_tx(&mut scenario, BUYER);
        let coin = coin::mint_for_testing<SUI>(price * nfts_to_buy, ctx(&mut scenario));
        let req = venue::request_access(&venue, ctx(&mut scenario));

        let cert = fixed_bid::buy_nft_cert<Foo, SUI>(
            &mut venue,
            &mut coin,
            // FAILS here because we are trying to buy 11 NFTs whilst tehre are only 10 available
            nfts_to_buy,
            req,
            ctx(&mut scenario),
        );

        certificate::consume_for_test(cert); // TODO replace
        coin::burn_for_testing(coin);

        test_scenario::return_shared(venue);
        test_scenario::return_shared(warehouse);
        transfer::public_transfer(launch_cap, MARKETPLACE);
        test_scenario::end(scenario);
    }

    #[test]
    public fun buy_nfts_fifo() {
        let scenario = test_scenario::begin(MARKETPLACE);

        // 1. Create a Launchpad Listing
        let (listing, launch_cap) = launchpad::new(ctx(&mut scenario));

        // 2. Create Sales Venue
        let venue = venue::new(
            &mut listing,
            &launch_cap,
            // Market type
            type_name::get<FixedBidWit>(),
            // Inventory Type
            type_name::get<WarehouseWit>(),
            // Inventory Retrieval Method
            type_name::get<SequentialWit>(),
            // NFT Retrieval Method
            type_name::get<SequentialWit>(),
            ctx(&mut scenario),
        );

        // Add redeem rules for Inventory and NFT choice
        sequential::add_inventory_method(&launch_cap, &mut venue);
        sequential::add_nft_method(&launch_cap, &mut venue);

        let supply = 10;
        let nfts_to_buy = 5;
        let max_buy = 5;
        let price = 10;

        // 3. Add market module
        fixed_bid::init_market<SUI>(&launch_cap, &mut venue, price, max_buy, ctx(&mut scenario));

        transfer::public_share_object(listing);
        transfer::public_share_object(venue);

        // 4. Create warehouse
        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let warehouse = warehouse::new<Foo>(&launch_cap, ctx(&mut scenario));
        let warehouse_id = object::id(&warehouse);

        // 5. Mint NFTs to the Warehouse
        utils::batch_mint_foo_nft_to_warehouse(&mut warehouse, supply, ctx(&mut scenario));
        warehouse::share(warehouse);

        // 6. Register Supply
        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let warehouse = test_scenario::take_shared<Warehouse<Foo>>(&scenario);
        let venue = test_scenario::take_shared<Venue>(&scenario);

        warehouse::register_supply(&launch_cap, &mut venue, &mut warehouse, supply);

        // 6. Buy NFT
        test_scenario::next_tx(&mut scenario, BUYER);
        let coin = coin::mint_for_testing<SUI>(price * nfts_to_buy, ctx(&mut scenario));
        let req = venue::request_access(&venue, ctx(&mut scenario));

        let cert = fixed_bid::buy_nft_cert<Foo, SUI>(
            &mut venue,
            &mut coin,
            nfts_to_buy,
            req,
            ctx(&mut scenario),
        );

        // Assert correct data in NftCertificate
        assert!(certificate::venue_id(&cert) == object::id(&venue), 0);
        assert!(certificate::quantity(&cert) == nfts_to_buy, 0);
        assert!(certificate::nft_map(&cert) == &vec_map::empty<ID, SizedVec<u64>>(), 0);
        assert!(certificate::buyer(&cert) == BUYER, 0);
        assert!(certificate::inventory_type(&cert) == type_name::get<WarehouseWit>(), 0);

        // Assert correct update of Venue Supply
        assert!(supply::get_max(option::borrow(venue::get_supply(&venue))) == supply, 0);
        assert!(supply::get_current(option::borrow(venue::get_supply(&venue))) == nfts_to_buy, 0);

        // The NFT has not been withdrawn from the inventory and therefore the supply
        // registered here is stil 10
        assert!(venue::get_inventory_supply(&venue, warehouse_id) == supply, 0);

        sequential::assign_inventory(&mut venue, &mut cert);
        sequential::assign_nft(&mut venue, &mut cert);

        assert!(venue::get_inventory_supply(&venue, warehouse_id) == supply - nfts_to_buy, 0);

        // Since the redeem method is pseudo-random we have to call another transaction
        // to make sure we choose the correct warehouse
        test_scenario::next_tx(&mut scenario, BUYER);

        // Redeem NFT from the warehouse
        let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
        let nfts = warehouse::test_redeem_nft(&mut warehouse, &mut cert, &mut buyer_kiosk ,ctx(&mut scenario));

        let len = vector::length(&nfts);
        let i = 5;

        while (len > 0) {
            let nft = vector::borrow(&nfts, len - 1);

            // For the FIFO method, we expect to get the first 5 NFTs deposited in the Warehouse
            // which have index 1 to 5
            assert!(utils::index(nft) == i, 0);

            i = i - 1;
            len = len - 1;
        };

        ob_kiosk::deposit_batch(&mut buyer_kiosk, nfts, ctx(&mut scenario));

        certificate::consume_for_test(cert);// TODO replace
        coin::burn_for_testing(coin);

        test_scenario::return_shared(venue);
        test_scenario::return_shared(warehouse);
        transfer::public_transfer(launch_cap, MARKETPLACE);
        transfer::public_share_object(buyer_kiosk);
        test_scenario::end(scenario);
    }

    #[test]
    public fun buy_all_nfts_fifo() {
        let scenario = test_scenario::begin(MARKETPLACE);

        // 1. Create a Launchpad Listing
        let (listing, launch_cap) = launchpad::new(ctx(&mut scenario));

        // 2. Create Sales Venue
        let venue = venue::new(
            &mut listing,
            &launch_cap,
            // Market type
            type_name::get<FixedBidWit>(),
            // Inventory Type
            type_name::get<WarehouseWit>(),
            // Inventory Retrieval Method
            type_name::get<SequentialWit>(),
            // NFT Retrieval Method
            type_name::get<SequentialWit>(),
            ctx(&mut scenario),
        );

        // Add redeem rules for Inventory and NFT choice
        sequential::add_inventory_method(&launch_cap, &mut venue);
        sequential::add_nft_method(&launch_cap, &mut venue);

        let supply = 10;
        let nfts_to_buy = 10;
        let max_buy = 10;
        let price = 10;

        // 3. Add market module
        fixed_bid::init_market<SUI>(&launch_cap, &mut venue, price, max_buy, ctx(&mut scenario));

        transfer::public_share_object(listing);
        transfer::public_share_object(venue);

        // 4. Create warehouse
        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let warehouse = warehouse::new<Foo>(&launch_cap, ctx(&mut scenario));
        let warehouse_id = object::id(&warehouse);

        // 5. Mint NFTs to the Warehouse
        utils::batch_mint_foo_nft_to_warehouse(&mut warehouse, supply, ctx(&mut scenario));
        warehouse::share(warehouse);

        // 6. Register Supply
        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let warehouse = test_scenario::take_shared<Warehouse<Foo>>(&scenario);
        let venue = test_scenario::take_shared<Venue>(&scenario);

        warehouse::register_supply(&launch_cap, &mut venue, &mut warehouse, supply);

        // 6. Buy NFT
        test_scenario::next_tx(&mut scenario, BUYER);
        let coin = coin::mint_for_testing<SUI>(price * nfts_to_buy, ctx(&mut scenario));
        let req = venue::request_access(&venue, ctx(&mut scenario));

        let cert = fixed_bid::buy_nft_cert<Foo, SUI>(
            &mut venue,
            &mut coin,
            nfts_to_buy,
            req,
            ctx(&mut scenario),
        );

        // Assert correct data in NftCertificate
        assert!(certificate::venue_id(&cert) == object::id(&venue), 0);
        assert!(certificate::quantity(&cert) == nfts_to_buy, 0);
        assert!(certificate::nft_map(&cert) == &vec_map::empty<ID, SizedVec<u64>>(), 0);
        assert!(certificate::buyer(&cert) == BUYER, 0);
        assert!(certificate::inventory_type(&cert) == type_name::get<WarehouseWit>(), 0);

        // Assert correct update of Venue Supply
        assert!(supply::get_max(option::borrow(venue::get_supply(&venue))) == supply, 0);
        assert!(supply::get_current(option::borrow(venue::get_supply(&venue))) == nfts_to_buy, 0);

        // The NFT has not been withdrawn from the inventory and therefore the supply
        // registered here is stil 10
        assert!(venue::get_inventory_supply(&venue, warehouse_id) == supply, 0);

        sequential::assign_inventory(&mut venue, &mut cert);
        sequential::assign_nft(&mut venue, &mut cert);

        assert!(!vec_map::contains(venue::get_invetories(&venue), &warehouse_id), 0);

        // Since the redeem method is pseudo-random we have to call another transaction
        // to make sure we choose the correct warehouse
        test_scenario::next_tx(&mut scenario, BUYER);

        // Redeem NFT from the warehouse
        let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
        let nfts = warehouse::test_redeem_nft(&mut warehouse, &mut cert, &mut buyer_kiosk ,ctx(&mut scenario));

        let len = vector::length(&nfts);
        let i = 10;

        while (len > 0) {
            let nft = vector::borrow(&nfts, len - 1);

            // For the FIFO method, we expect to get the first 5 NFTs deposited in the Warehouse
            // which have index 1 to 5
            assert!(utils::index(nft) == i, 0);

            i = i - 1;
            len = len - 1;
        };

        ob_kiosk::deposit_batch(&mut buyer_kiosk, nfts, ctx(&mut scenario));

        certificate::consume_for_test(cert);// TODO replace
        coin::burn_for_testing(coin);

        test_scenario::return_shared(venue);
        test_scenario::return_shared(warehouse);
        transfer::public_transfer(launch_cap, MARKETPLACE);
        transfer::public_share_object(buyer_kiosk);
        test_scenario::end(scenario);
    }
}
