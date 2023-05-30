#[test_only]
module ob_tests::orderbook_migration {
    use std::vector;

    use sui::coin;
    use sui::object;
    use sui::transfer;
    use sui::sui::SUI;
    use sui::kiosk::Kiosk;
    use sui::test_scenario::{Self, ctx};
    use sui::transfer_policy::{TransferPolicy};

    use ob_permissions::witness;
    use critbit::critbit_u64::{Self as critbit};
    use ob_kiosk::ob_kiosk::{Self};
    use ob_tests::test_utils::{Self, Foo,  seller, buyer, creator};
    use originmate::crit_bit_u64::{Self as crit_bit};
    use liquidity_layer::orderbook::{Self as orderbook_v2, Orderbook as OrderbookV2};
    use liquidity_layer_v1::orderbook::{Self as orderbook_v1, Orderbook as OrderbookV1};

    const OFFER_SUI: u64 = 100;

    #[test]
    fun test_migrate_asks() {
        let scenario = test_scenario::begin(creator());

        // 1. Create Collection, TransferPolicy and Orderbook
        let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        let dw = witness::test_dw<Foo>();
        test_utils::create_orderbook_v1<Foo>(dw, &tx_policy, &mut scenario);

        transfer::public_share_object(collection);
        transfer::public_share_object(tx_policy);

        let quantity = 100;
        let i = quantity;
        let price = 1;
        let depth = 10;
        let j = 0;

        // 4. Create seller kiosks, NFTs and asks order
        test_scenario::next_tx(&mut scenario, seller());
        let book_v1 = test_scenario::take_shared<OrderbookV1<Foo, SUI>>(&mut scenario);

        let kiosks = vector::empty();

        let price_levels = 1;
        while (i > 0) {
            test_scenario::next_tx(&mut scenario, seller());

            // create kiosk
            let (seller_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

            // Create and deposit NFT
            let nft = test_utils::get_foo_nft(ctx(&mut scenario));
            let nft_id = object::id(&nft);
            ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

            orderbook_v1::create_ask(
                &mut book_v1,
                &mut seller_kiosk,
                price,
                nft_id,
                ctx(&mut scenario),
            );

            j = j + 1;

            // Assersions
            // 1. NFT is exclusively listed in the Seller Kiosk
            ob_kiosk::assert_exclusively_listed(&mut seller_kiosk, nft_id);

            vector::push_back(&mut kiosks, seller_kiosk);

            // Assert price level
            assert!(crit_bit::length(orderbook_v1::borrow_asks(&book_v1)) == price_levels, 0);

            // 2. New price level gets added
            if (j == depth) {
                price_levels = price_levels + 1;
                price = price + 1;
                j = 0;
            };

            i = i - 1;
        };

        test_scenario::next_tx(&mut scenario, creator());

        let i = quantity;
        let j = 0;
        let price_levels = depth;
        let price_levels_new = 1;

        let dw = witness::from_witness(test_utils::witness());
        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

        let book_v2 = orderbook_v2::new<Foo, SUI>(
            dw,
            &mut tx_policy,
            false,
            false,
            false,
            ctx(&mut scenario),
        );

        orderbook_v1::start_migration_to_v2(dw, &mut book_v1, &book_v2);
        orderbook_v2::start_migration_from_v1(dw, &mut book_v2, object::id(&book_v1));

        transfer::public_share_object(book_v2);
        test_scenario::next_tx(&mut scenario, creator());
        let book_v2 = test_scenario::take_shared<OrderbookV2<Foo, SUI>>(&mut scenario);

        // 6. Migrate asks
        while (i > 0) {
            test_scenario::next_tx(&mut scenario, seller());

            let seller_kiosk = vector::pop_back(&mut kiosks);

            orderbook_v1::migrate_ask<Foo, SUI>(
                dw,
                &mut seller_kiosk,
                &mut book_v1,
                &mut book_v2,
            );

            // Note: for simplicity in the test we transfer the object, but
            // in practice this object should be shared
            transfer::public_transfer(seller_kiosk, seller());

            j = j + 1;

            assert!(critbit::size(orderbook_v2::borrow_asks(&book_v2)) == price_levels_new, 0);

            // 2. New price level gets added
            if (j == depth) {
                price_levels_new = price_levels_new + 1;
                price_levels = price_levels - 1;
                j = 0;
            };

            assert!(crit_bit::length(orderbook_v1::borrow_asks(&book_v1)) == price_levels, 0);

            i = i - 1;
        };

        vector::destroy_empty(kiosks);

        // Assert that orderbook is empty
        assert!(crit_bit::is_empty(orderbook_v1::borrow_bids(&book_v1)), 0);
        assert!(crit_bit::is_empty(orderbook_v1::borrow_asks(&book_v1)), 0);

        assert!(critbit::size(orderbook_v2::borrow_bids(&book_v2)) == 0, 0);
        assert!(critbit::size(orderbook_v2::borrow_asks(&book_v2)) == 10, 0);

        orderbook_v2::finish_migration_from_v1(dw, &mut book_v2);
        orderbook_v1::finish_migration_to_v2(dw, &mut book_v1);

        transfer::public_transfer(publisher, creator());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        test_scenario::return_shared(tx_policy);
        test_scenario::return_shared(book_v1);
        test_scenario::return_shared(book_v2);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_migrate_bids() {
        let scenario = test_scenario::begin(creator());

        // 1. Create Collection, TransferPolicy and Orderbook
        let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        let dw = witness::test_dw<Foo>();
        test_utils::create_orderbook_v1<Foo>(dw, &tx_policy, &mut scenario);

        transfer::public_share_object(collection);
        transfer::public_share_object(tx_policy);

        // 3. Create Buyer Kiosk
        test_scenario::next_tx(&mut scenario, buyer());
        let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        transfer::public_share_object(buyer_kiosk);

        let quantity = 100;
        let i = quantity;
        let price = 1;
        let depth = 10;
        let j = 0;

        // 4. Create bid orders
        test_scenario::next_tx(&mut scenario, seller());
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
        let book_v1 = test_scenario::take_shared<OrderbookV1<Foo, SUI>>(&mut scenario);
        let wallet = coin::mint_for_testing<SUI>(1_000_000, ctx(&mut scenario));

        let price_levels = 1;
        while (i > 0) {
            test_scenario::next_tx(&mut scenario, buyer());

            orderbook_v1::create_bid(
                &mut book_v1,
                &mut buyer_kiosk,
                price,
                &mut wallet,
                ctx(&mut scenario),
            );

            j = j + 1;

            // Assert price level
            assert!(crit_bit::length(orderbook_v1::borrow_bids(&book_v1)) == price_levels, 0);

            // 2. New price level gets added
            if (j == depth) {
                price_levels = price_levels + 1;
                price = price + 1;
                j = 0;
            };

            i = i - 1;
        };

        test_scenario::next_tx(&mut scenario, creator());

        let i = quantity;
        let j = 0;
        let price_levels = depth;
        let price_levels_new = 1;

        let dw = witness::from_witness(test_utils::witness());
        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

        let book_v2 = orderbook_v2::new<Foo, SUI>(
            dw,
            &mut tx_policy,
            false,
            false,
            false,
            ctx(&mut scenario),
        );

        orderbook_v1::start_migration_to_v2(dw, &mut book_v1, &book_v2);
        orderbook_v2::start_migration_from_v1(dw, &mut book_v2, object::id(&book_v1));

        transfer::public_share_object(book_v2);
        test_scenario::next_tx(&mut scenario, creator());
        let book_v2 = test_scenario::take_shared<OrderbookV2<Foo, SUI>>(&mut scenario);

        // 6. Migrate asks
        while (i > 0) {
            test_scenario::next_tx(&mut scenario, seller());

            orderbook_v1::migrate_bid<Foo, SUI>(
                dw,
                &mut book_v1,
                &mut book_v2,
                ctx(&mut scenario),
            );

            j = j + 1;

            assert!(critbit::size(orderbook_v2::borrow_bids(&book_v2)) == price_levels_new, 0);

            // 2. New price level gets added
            if (j == depth) {
                price_levels_new = price_levels_new + 1;
                price_levels = price_levels - 1;
                j = 0;
            };

            assert!(crit_bit::length(orderbook_v1::borrow_bids(&book_v1)) == price_levels, 0);

            i = i - 1;
        };

        // Assert that orderbook is empty
        assert!(crit_bit::is_empty(orderbook_v1::borrow_asks(&book_v1)), 0);
        assert!(crit_bit::is_empty(orderbook_v1::borrow_bids(&book_v1)), 0);

        assert!(critbit::size(orderbook_v2::borrow_asks(&book_v2)) == 0, 0);
        assert!(critbit::size(orderbook_v2::borrow_bids(&book_v2)) == 10, 0);

        orderbook_v2::finish_migration_from_v1(dw, &mut book_v2);
        orderbook_v1::finish_migration_to_v2(dw, &mut book_v1);

        transfer::public_transfer(publisher, creator());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        transfer::public_transfer(wallet, buyer());
        test_scenario::return_shared(tx_policy);
        test_scenario::return_shared(book_v1);
        test_scenario::return_shared(book_v2);
        test_scenario::return_shared(buyer_kiosk);
        test_scenario::end(scenario);
    }
}
