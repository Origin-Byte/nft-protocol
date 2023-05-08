#[test_only]
module ob_tests::orderbook_migration {
    // use std::option;
    // use std::vector;
    use std::debug;

    // use sui::coin::{Self, Coin};
    use sui::object;
    // use sui::kiosk;
    use sui::transfer;
    use sui::sui::SUI;
    use sui::kiosk::Kiosk;
    use sui::test_scenario::{Self, ctx};
    use sui::transfer_policy::{TransferPolicy};

    use ob_permissions::witness;
    // use ob_utils::crit_bit::{Self};
    // use ob_request::transfer_request;
    use ob_kiosk::ob_kiosk::{Self};
    use liquidity_layer::orderbook::{Self};
    use ob_tests::test_utils::{Self, Foo,  seller, buyer, creator};
    use originmate::crit_bit_u64::{Self as crit_bit};
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

        // 3. Create Buyer Kiosk
        test_scenario::next_tx(&mut scenario, buyer());
        let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        transfer::public_share_object(buyer_kiosk);

        // 4. Create Seller Kiosk
        test_scenario::next_tx(&mut scenario, seller());
        let (seller_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
        transfer::public_share_object(seller_kiosk);

        // 5. Create asks order for NFT
        test_scenario::next_tx(&mut scenario, seller());
        let book_v1 = test_scenario::take_shared<OrderbookV1<Foo, SUI>>(&mut scenario);
        let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

        let price_levels = crit_bit::length(orderbook_v1::borrow_asks(&book_v1));

        let quantity = 300;
        let i = quantity;
        let price = 1;

        while (i > 0) {
            debug::print(&i);
            test_scenario::next_tx(&mut scenario, seller());

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

            // Assersions
            // 1. NFT is exclusively listed in the Seller Kiosk
            ob_kiosk::assert_exclusively_listed(&mut seller_kiosk, nft_id);

            // 2. New price level gets added with new Ask
            price_levels = price_levels + 1;
            assert!(crit_bit::length(orderbook_v1::borrow_asks(&book_v1)) == price_levels, 0);

            i = i - 1;
            price = price + 1;
        };

        test_scenario::next_tx(&mut scenario, creator());

        let i = quantity;

        let dw = witness::from_witness(test_utils::witness());

        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

        let book_v2 = orderbook::new(
            dw,
            &mut tx_policy,
            orderbook::custom_protection(true, true, true),
            ctx(&mut scenario),
        );

        orderbook_v1::start_migration_with_witness(
            dw, &mut book_v1
        );

        // 6. Create market bids
        while (i > 0) {
            debug::print(&i);
            orderbook::migrate_ask<Foo, SUI>(
                dw,
                &mut seller_kiosk,
                &mut book_v1,
                &mut book_v2,
                ctx(&mut scenario),
            );

            i = i - 1;
        };

        // Assert that orderbook is empty
        assert!(crit_bit::is_empty(orderbook_v1::borrow_bids(&book_v1)), 0);
        assert!(crit_bit::is_empty(orderbook_v1::borrow_asks(&book_v1)), 0);


        // assert!(crit_bit::is_empty(orderbook::borrow_bids(&book)), 0);
        // assert!(crit_bit::is_empty(orderbook::borrow_asks(&book)), 0);

        transfer::public_transfer(publisher, creator());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        test_scenario::return_shared(tx_policy);
        test_scenario::return_shared(seller_kiosk);
        // test_scenario::return_shared(buyer_kiosk);
        test_scenario::return_shared(book_v1);
        test_scenario::return_shared(book_v2);
        test_scenario::end(scenario);
    }

    // #[test]
    // fun test_limit_bid_insert_and_popping_with_market_sell() {
    //     let scenario = test_scenario::begin(creator());

    //     // 1. Create Collection, TransferPolicy and Orderbook
    //     let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
    //     let publisher = test_utils::get_publisher(ctx(&mut scenario));
    //     let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

    //     let dw = witness::test_dw<Foo>();
    //     test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

    //     transfer::public_share_object(collection);
    //     transfer::public_share_object(tx_policy);

    //     // 3. Create Buyer Kiosk
    //     test_scenario::next_tx(&mut scenario, buyer());
    //     let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

    //     transfer::public_share_object(buyer_kiosk);

    //     // 4. Create Seller Kiosk
    //     test_scenario::next_tx(&mut scenario, seller());
    //     let (seller_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
    //     transfer::public_share_object(seller_kiosk);

    //     // 5. Create bid order for NFTs
    //     test_scenario::next_tx(&mut scenario, seller());
    //     let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
    //     let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
    //     let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

    //     let initial_funds = 1_000_000;
    //     let price_levels = crit_bit::size(orderbook::borrow_bids(&book));
    //     let funds_locked = 0;

    //     let coin = coin::mint_for_testing<SUI>(initial_funds, ctx(&mut scenario));

    //     let quantity = 300;
    //     let i = quantity;
    //     let price = 1;

    //     while (i > 0) {
    //         test_scenario::next_tx(&mut scenario, buyer());

    //         orderbook::create_bid(
    //             &mut book,
    //             &mut buyer_kiosk,
    //             price,
    //             &mut coin,
    //             ctx(&mut scenario),
    //         );

    //         // Register funds locked in the Bid
    //         funds_locked = funds_locked + price;

    //         // Assersions
    //         // 1. Funds withdrawn from Wallet
    //         assert!(coin::value(&coin) == initial_funds - funds_locked, 0);

    //         // 2. New price level gets added with new Bid
    //         price_levels = price_levels + 1;
    //         assert!(crit_bit::size(orderbook::borrow_bids(&book)) == price_levels, 0);

    //         price = price + 1;
    //         i = i - 1;
    //     };

    //     test_scenario::next_tx(&mut scenario, buyer());

    //     let i = quantity;
    //     // Seller gets best price (highest)
    //     let price = 300;

    //     // 6. Create market bids

    //     while (i > 0) {
    //         test_scenario::next_tx(&mut scenario, seller());

    //         // Create and deposit NFT
    //         let nft = test_utils::get_foo_nft(ctx(&mut scenario));
    //         let nft_id = object::id(&nft);
    //         ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

    //         let trade_info = orderbook::market_sell(
    //             &mut book,
    //             &mut seller_kiosk,
    //             price,
    //             nft_id,
    //             ctx(&mut scenario),
    //         );

    //         assert!(orderbook::trade_price(&trade_info) == price, 0);

    //         i = i - 1;
    //         price = price - 1;
    //     };

    //     // Assert that orderbook is empty
    //     assert!(crit_bit::is_empty(orderbook::borrow_bids(&book)), 0);
    //     assert!(crit_bit::is_empty(orderbook::borrow_asks(&book)), 0);

    //     coin::burn_for_testing(coin);
    //     transfer::public_transfer(publisher, creator());
    //     transfer::public_transfer(mint_cap, creator());
    //     transfer::public_transfer(policy_cap, creator());
    //     test_scenario::return_shared(seller_kiosk);
    //     test_scenario::return_shared(buyer_kiosk);
    //     test_scenario::return_shared(book);
    //     test_scenario::end(scenario);
    // }

    // #[test]
    // fun test_limit_ask_insert_and_popping_with_limit_buy() {
    //     let scenario = test_scenario::begin(creator());

    //     // 1. Create Collection, TransferPolicy and Orderbook
    //     let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
    //     let publisher = test_utils::get_publisher(ctx(&mut scenario));
    //     let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

    //     let dw = witness::test_dw<Foo>();
    //     test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

    //     transfer::public_share_object(collection);
    //     transfer::public_share_object(tx_policy);

    //     // 3. Create Buyer Kiosk
    //     test_scenario::next_tx(&mut scenario, buyer());
    //     let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

    //     transfer::public_share_object(buyer_kiosk);

    //     // 4. Create Seller Kiosk
    //     test_scenario::next_tx(&mut scenario, seller());
    //     let (seller_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
    //     transfer::public_share_object(seller_kiosk);

    //     // 5. Create asks order for NFT
    //     test_scenario::next_tx(&mut scenario, seller());
    //     let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
    //     let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

    //     let price_levels = crit_bit::size(orderbook::borrow_asks(&book));

    //     let quantity = 300;
    //     let i = quantity;
    //     let price = 1;

    //     while (i > 0) {
    //         test_scenario::next_tx(&mut scenario, seller());

    //         // Create and deposit NFT
    //         let nft = test_utils::get_foo_nft(ctx(&mut scenario));
    //         let nft_id = object::id(&nft);
    //         ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

    //         orderbook::create_ask(
    //             &mut book,
    //             &mut seller_kiosk,
    //             price,
    //             nft_id,
    //             ctx(&mut scenario),
    //         );

    //         // Assersions
    //         // 1. NFT is exclusively listed in the Seller Kiosk
    //         ob_kiosk::assert_exclusively_listed(&mut seller_kiosk, nft_id);

    //         // 2. New price level gets added with new Ask
    //         price_levels = price_levels + 1;
    //         assert!(crit_bit::size(orderbook::borrow_asks(&book)) == price_levels, 0);

    //         i = i - 1;
    //         price = price + 1;
    //     };

    //     test_scenario::next_tx(&mut scenario, buyer());

    //     // Buyer gets best price (lowest)
    //     let price = 1;
    //     let i = quantity;

    //     // 6. Create market bids
    //     let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

    //     let initial_funds = 1_000_000;
    //     let funds_sent = 0;
    //     let coin = coin::mint_for_testing<SUI>(initial_funds, ctx(&mut scenario));

    //     while (i > 0) {
    //         test_scenario::next_tx(&mut scenario, buyer());

    //         let trade_info_opt = orderbook::create_bid(
    //             &mut book,
    //             &mut buyer_kiosk,
    //             price,
    //             &mut coin,
    //             ctx(&mut scenario),
    //         );

    //         // Register funds sent
    //         funds_sent = funds_sent + price;

    //         // Assersions
    //         // 1. Funds withdrawn from Wallet
    //         assert!(coin::value(&coin) == initial_funds - funds_sent, 0);

    //         // 2. Ask gets popped and price level removed
    //         price_levels = price_levels - 1;
    //         assert!(crit_bit::size(orderbook::borrow_asks(&book)) == price_levels, 0);

    //         // 3. Assert trade match
    //         let trade_info = option::extract(&mut trade_info_opt);
    //         option::destroy_none(trade_info_opt);
    //         assert!(orderbook::trade_price(&trade_info) == price, 0);

    //         price = price + 1;
    //         i = i - 1;
    //     };

    //     // Assert that orderbook is empty
    //     assert!(crit_bit::is_empty(orderbook::borrow_bids(&book)), 0);
    //     assert!(crit_bit::is_empty(orderbook::borrow_asks(&book)), 0);

    //     coin::burn_for_testing(coin);
    //     transfer::public_transfer(publisher, creator());
    //     transfer::public_transfer(mint_cap, creator());
    //     transfer::public_transfer(policy_cap, creator());
    //     test_scenario::return_shared(seller_kiosk);
    //     test_scenario::return_shared(buyer_kiosk);
    //     test_scenario::return_shared(book);
    //     test_scenario::end(scenario);
    // }

    // #[test]
    // fun test_limit_bid_and_limit_sell_inserts() {
    //     let scenario = test_scenario::begin(creator());

    //     // 1. Create Collection, TransferPolicy and Orderbook
    //     let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
    //     let publisher = test_utils::get_publisher(ctx(&mut scenario));
    //     let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

    //     let dw = witness::test_dw<Foo>();
    //     test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

    //     transfer::public_share_object(collection);
    //     transfer::public_share_object(tx_policy);

    //     // 3. Create Buyer Kiosk
    //     test_scenario::next_tx(&mut scenario, buyer());
    //     let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

    //     transfer::public_share_object(buyer_kiosk);

    //     // 4. Create Seller Kiosk
    //     test_scenario::next_tx(&mut scenario, seller());
    //     let (seller_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
    //     transfer::public_share_object(seller_kiosk);

    //     // 5. Create bid order for NFTs
    //     test_scenario::next_tx(&mut scenario, seller());
    //     let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
    //     let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
    //     let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

    //     let initial_funds = 1_000_000;
    //     let bid_price_levels = crit_bit::size(orderbook::borrow_bids(&book));
    //     let funds_locked = 0;

    //     let coin = coin::mint_for_testing<SUI>(1_000_000, ctx(&mut scenario));

    //     let quantity = 300;
    //     let i = quantity;
    //     let price = 1;

    //     while (i > 0) {
    //         test_scenario::next_tx(&mut scenario, buyer());

    //         orderbook::create_bid(
    //             &mut book,
    //             &mut buyer_kiosk,
    //             price,
    //             &mut coin,
    //             ctx(&mut scenario),
    //         );

    //         // Register funds locked in the Bid
    //         funds_locked = funds_locked + price;

    //         // Assersions
    //         // 1. Funds withdrawn from Wallet
    //         assert!(coin::value(&coin) == initial_funds - funds_locked, 0);

    //         // 2. New price level gets added with new Bid
    //         bid_price_levels = bid_price_levels + 1;
    //         assert!(crit_bit::size(orderbook::borrow_bids(&book)) == bid_price_levels, 0);

    //         price = price + 1;
    //         i = i - 1;
    //     };

    //     test_scenario::next_tx(&mut scenario, buyer());

    //     // Seller gets best price (highest)
    //     let ask_price_levels = crit_bit::size(orderbook::borrow_asks(&book));
    //     let price = 301;
    //     let i = quantity;

    //     // 6. Create limit ask

    //     while (i > 0) {
    //         test_scenario::next_tx(&mut scenario, seller());

    //         // Create and deposit NFT
    //         let nft = test_utils::get_foo_nft(ctx(&mut scenario));
    //         let nft_id = object::id(&nft);
    //         ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

    //         orderbook::create_ask(
    //             &mut book,
    //             &mut seller_kiosk,
    //             price,
    //             nft_id,
    //             ctx(&mut scenario),
    //         );

    //         // Assersions
    //         // 1. NFT is exclusively listed in the Seller Kiosk
    //         ob_kiosk::assert_exclusively_listed(&mut seller_kiosk, nft_id);

    //         // 2. New price level gets added with new Ask
    //         ask_price_levels = ask_price_levels + 1;
    //         assert!(crit_bit::size(orderbook::borrow_asks(&book)) == ask_price_levels, 0);

    //         i = i - 1;
    //         price = price + 1;
    //     };

    //     // Assert orderbook state

    //     let (max_key_bid, _) = crit_bit::max_leaf(orderbook::borrow_bids(&book));
    //     let (min_key_bid, _) = crit_bit::min_leaf(orderbook::borrow_bids(&book));
    //     let (max_key_ask, _) = crit_bit::max_leaf(orderbook::borrow_asks(&book));
    //     let (min_key_ask, _) = crit_bit::min_leaf(orderbook::borrow_asks(&book));

    //     assert!(max_key_bid == 300, 0);
    //     assert!(min_key_bid == 1, 0);
    //     assert!(max_key_ask == 600, 0);
    //     assert!(min_key_ask == 301, 0);

    //     coin::burn_for_testing(coin);
    //     transfer::public_transfer(publisher, creator());
    //     transfer::public_transfer(mint_cap, creator());
    //     transfer::public_transfer(policy_cap, creator());
    //     test_scenario::return_shared(seller_kiosk);
    //     test_scenario::return_shared(buyer_kiosk);
    //     test_scenario::return_shared(book);
    //     test_scenario::end(scenario);
    // }

    // #[test]
    // fun test_cancel_asks() {
    //     let scenario = test_scenario::begin(creator());

    //     // 1. Create Collection, TransferPolicy and Orderbook
    //     let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
    //     let publisher = test_utils::get_publisher(ctx(&mut scenario));
    //     let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

    //     let dw = witness::test_dw<Foo>();
    //     test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

    //     transfer::public_share_object(collection);
    //     transfer::public_share_object(tx_policy);

    //     // 3. Create Buyer Kiosk
    //     test_scenario::next_tx(&mut scenario, buyer());
    //     let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

    //     transfer::public_share_object(buyer_kiosk);

    //     // 4. Create Seller Kiosk
    //     test_scenario::next_tx(&mut scenario, seller());
    //     let (seller_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
    //     transfer::public_share_object(seller_kiosk);

    //     // 5. Create bid order for NFTs
    //     test_scenario::next_tx(&mut scenario, seller());
    //     let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
    //     let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
    //     let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

    //     let coin = coin::mint_for_testing<SUI>(1_000_000, ctx(&mut scenario));

    //     let quantity = 300;
    //     let i = quantity;
    //     let price = 300;

    //     let nfts = vector::empty();

    //     while (i > 0) {
    //         test_scenario::next_tx(&mut scenario, seller());

    //         // Create and deposit NFT
    //         let nft = test_utils::get_foo_nft(ctx(&mut scenario));
    //         let nft_id = object::id(&nft);
    //         vector::push_back(&mut nfts, nft_id);

    //         ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

    //         orderbook::create_ask(
    //             &mut book,
    //             &mut seller_kiosk,
    //             price,
    //             nft_id,
    //             ctx(&mut scenario),
    //         );

    //         i = i - 1;
    //         price = price - 1;
    //     };

    //     // Assert that orderbook state
    //     let (max_key_ask, _) = crit_bit::max_leaf(orderbook::borrow_asks(&book));
    //     let (min_key_ask, _) = crit_bit::min_leaf(orderbook::borrow_asks(&book));

    //     assert!(max_key_ask == 300, 0);
    //     assert!(min_key_ask == 1, 0);

    //     let i = quantity;
    //     let price = 1;

    //     // 6. Cancel orders
    //     while (i > 0) {
    //         test_scenario::next_tx(&mut scenario, seller());
    //         let nft_id = vector::pop_back(&mut nfts);

    //         orderbook::cancel_ask(
    //             &mut book,
    //             &mut seller_kiosk,
    //             price,
    //             nft_id,
    //             ctx(&mut scenario),
    //         );

    //         price = price + 1;
    //         i = i - 1;
    //     };

    //     // Assert that orderbook state
    //     assert!(crit_bit::is_empty(orderbook::borrow_asks(&book)), 0);

    //     coin::burn_for_testing(coin);
    //     transfer::public_transfer(publisher, creator());
    //     transfer::public_transfer(mint_cap, creator());
    //     transfer::public_transfer(policy_cap, creator());
    //     test_scenario::return_shared(seller_kiosk);
    //     test_scenario::return_shared(buyer_kiosk);
    //     test_scenario::return_shared(book);
    //     test_scenario::end(scenario);
    // }

    // #[test]
    // fun test_cancel_bids() {
    //     let scenario = test_scenario::begin(creator());

    //     // 1. Create Collection, TransferPolicy and Orderbook
    //     let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
    //     let publisher = test_utils::get_publisher(ctx(&mut scenario));
    //     let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

    //     let dw = witness::test_dw<Foo>();
    //     test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

    //     transfer::public_share_object(collection);
    //     transfer::public_share_object(tx_policy);

    //     // 3. Create Buyer Kiosk
    //     test_scenario::next_tx(&mut scenario, buyer());
    //     let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

    //     transfer::public_share_object(buyer_kiosk);

    //     // 4. Create Seller Kiosk
    //     test_scenario::next_tx(&mut scenario, seller());
    //     let (seller_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
    //     transfer::public_share_object(seller_kiosk);

    //     // 5. Create bid order for NFTs
    //     test_scenario::next_tx(&mut scenario, seller());
    //     let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
    //     let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
    //     let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

    //     let initial_funds = 1_000_000;
    //     let price_levels = crit_bit::size(orderbook::borrow_bids(&book));
    //     let funds_locked = 0;

    //     let coin = coin::mint_for_testing<SUI>(initial_funds, ctx(&mut scenario));

    //     let quantity = 300;
    //     let i = quantity;
    //     let price = 1;

    //     while (i > 0) {
    //         test_scenario::next_tx(&mut scenario, buyer());

    //         orderbook::create_bid(
    //             &mut book,
    //             &mut buyer_kiosk,
    //             price,
    //             &mut coin,
    //             ctx(&mut scenario),
    //         );

    //         // Register funds locked in the Bid
    //         funds_locked = funds_locked + price;

    //         // Assersions
    //         // 1. Funds withdrawn from Wallet
    //         assert!(coin::value(&coin) == initial_funds - funds_locked, 0);

    //         // 2. New price level gets added with new Bid
    //         price_levels = price_levels + 1;
    //         assert!(crit_bit::size(orderbook::borrow_bids(&book)) == price_levels, 0);

    //         price = price + 1;
    //         i = i - 1;
    //     };

    //     // Assert that orderbook state
    //     let (max_key_bid, _) = crit_bit::max_leaf(orderbook::borrow_bids(&book));
    //     let (min_key_bid, _) = crit_bit::min_leaf(orderbook::borrow_bids(&book));


    //     assert!(max_key_bid == 300, 0);
    //     assert!(min_key_bid == 1, 0);

    //     let i = quantity;
    //     let price = 1;

    //     // 6. Cancel orders
    //     while (i > 0) {
    //         test_scenario::next_tx(&mut scenario, buyer());

    //         orderbook::cancel_bid(
    //             &mut book,
    //             price,
    //             &mut coin,
    //             ctx(&mut scenario),
    //         );

    //         // Register funds unlocked with the Bid cancellation
    //         funds_locked = funds_locked - price;

    //         // Assersions
    //         // 1. Funds withdrawn from Wallet
    //         assert!(coin::value(&coin) == initial_funds - funds_locked, 0);

    //         // 2. New price level gets removed with Bid popped
    //         price_levels = price_levels - 1;
    //         assert!(crit_bit::size(orderbook::borrow_bids(&book)) == price_levels, 0);

    //         price = price + 1;
    //         i = i - 1;
    //     };

    //     // Assert that orderbook state
    //     assert!(crit_bit::is_empty(orderbook::borrow_bids(&book)), 0);

    //     coin::burn_for_testing(coin);
    //     transfer::public_transfer(publisher, creator());
    //     transfer::public_transfer(mint_cap, creator());
    //     transfer::public_transfer(policy_cap, creator());
    //     test_scenario::return_shared(seller_kiosk);
    //     test_scenario::return_shared(buyer_kiosk);
    //     test_scenario::return_shared(book);
    //     test_scenario::end(scenario);
    // }

    // #[test]
    // fun test_edit_asks() {
    //     let scenario = test_scenario::begin(creator());

    //     // 1. Create Collection, TransferPolicy and Orderbook
    //     let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
    //     let publisher = test_utils::get_publisher(ctx(&mut scenario));
    //     let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

    //     let dw = witness::test_dw<Foo>();
    //     test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

    //     transfer::public_share_object(collection);
    //     transfer::public_share_object(tx_policy);

    //     // 3. Create Buyer Kiosk
    //     test_scenario::next_tx(&mut scenario, buyer());
    //     let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

    //     transfer::public_share_object(buyer_kiosk);

    //     // 4. Create Seller Kiosk
    //     test_scenario::next_tx(&mut scenario, seller());
    //     let (seller_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
    //     transfer::public_share_object(seller_kiosk);

    //     // 5. Create bid order for NFTs
    //     test_scenario::next_tx(&mut scenario, seller());
    //     let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
    //     let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
    //     let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

    //     let coin = coin::mint_for_testing<SUI>(1_000_000, ctx(&mut scenario));

    //     let quantity = 300;
    //     let i = quantity;
    //     let price = 300;

    //     let nfts = vector::empty();

    //     while (i > 0) {
    //         test_scenario::next_tx(&mut scenario, seller());

    //         // Create and deposit NFT
    //         let nft = test_utils::get_foo_nft(ctx(&mut scenario));
    //         let nft_id = object::id(&nft);
    //         vector::push_back(&mut nfts, nft_id);

    //         ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

    //         orderbook::create_ask(
    //             &mut book,
    //             &mut seller_kiosk,
    //             price,
    //             nft_id,
    //             ctx(&mut scenario),
    //         );

    //         i = i - 1;
    //         price = price - 1;
    //     };

    //     // Assert that orderbook state
    //     let (max_key_ask, _) = crit_bit::max_leaf(orderbook::borrow_asks(&book));
    //     let (min_key_ask, _) = crit_bit::min_leaf(orderbook::borrow_asks(&book));

    //     assert!(max_key_ask == 300, 0);
    //     assert!(min_key_ask == 1, 0);
    //     assert!(crit_bit::size(orderbook::borrow_asks(&book)) == 300, 0);

    //     let i = quantity;
    //     let price = 1;

    //     // 6. Cancel orders
    //     while (i > 0) {
    //         test_scenario::next_tx(&mut scenario, seller());
    //         let nft_id = vector::pop_back(&mut nfts);

    //         orderbook::edit_ask(
    //             &mut book,
    //             &mut seller_kiosk,
    //             price,
    //             nft_id,
    //             500,
    //             ctx(&mut scenario),
    //         );

    //         price = price + 1;
    //         i = i - 1;
    //     };

    //     // Assert that orderbook state
    //     // All orders are concentrated into one price level
    //     assert!(crit_bit::size(orderbook::borrow_asks(&book)) == 1, 0);

    //     let (max_key_ask, _) = crit_bit::max_leaf(orderbook::borrow_asks(&book));
    //     let (min_key_ask, _) = crit_bit::min_leaf(orderbook::borrow_asks(&book));

    //     assert!(max_key_ask == 500, 0);
    //     assert!(min_key_ask == 500, 0);

    //     coin::burn_for_testing(coin);
    //     transfer::public_transfer(publisher, creator());
    //     transfer::public_transfer(mint_cap, creator());
    //     transfer::public_transfer(policy_cap, creator());
    //     test_scenario::return_shared(seller_kiosk);
    //     test_scenario::return_shared(buyer_kiosk);
    //     test_scenario::return_shared(book);
    //     test_scenario::end(scenario);
    // }

    // #[test]
    // fun test_edit_bids() {
    //     let scenario = test_scenario::begin(creator());

    //     // 1. Create Collection, TransferPolicy and Orderbook
    //     let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
    //     let publisher = test_utils::get_publisher(ctx(&mut scenario));
    //     let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

    //     let dw = witness::test_dw<Foo>();
    //     test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

    //     transfer::public_share_object(collection);
    //     transfer::public_share_object(tx_policy);

    //     // 3. Create Buyer Kiosk
    //     test_scenario::next_tx(&mut scenario, buyer());
    //     let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

    //     transfer::public_share_object(buyer_kiosk);

    //     // 4. Create Seller Kiosk
    //     test_scenario::next_tx(&mut scenario, seller());
    //     let (seller_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
    //     transfer::public_share_object(seller_kiosk);

    //     // 5. Create bid order for NFTs
    //     test_scenario::next_tx(&mut scenario, seller());
    //     let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
    //     let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
    //     let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

    //     let initial_funds = 1_000_000;
    //     let price_levels = crit_bit::size(orderbook::borrow_bids(&book));
    //     let funds_locked = 0;

    //     let coin = coin::mint_for_testing<SUI>(initial_funds, ctx(&mut scenario));

    //     let quantity = 300;
    //     let i = quantity;
    //     let price = 1;

    //     while (i > 0) {
    //         test_scenario::next_tx(&mut scenario, buyer());

    //         orderbook::create_bid(
    //             &mut book,
    //             &mut buyer_kiosk,
    //             price,
    //             &mut coin,
    //             ctx(&mut scenario),
    //         );

    //         // Register funds locked in the Bid
    //         funds_locked = funds_locked + price;

    //         // Assersions
    //         // 1. Funds withdrawn from Wallet
    //         assert!(coin::value(&coin) == initial_funds - funds_locked, 0);

    //         // 2. New price level gets added with new Bid
    //         price_levels = price_levels + 1;
    //         assert!(crit_bit::size(orderbook::borrow_bids(&book)) == price_levels, 0);

    //         price = price + 1;
    //         i = i - 1;
    //     };

    //     // Assert that orderbook state
    //     let (max_key_bid, _) = crit_bit::max_leaf(orderbook::borrow_bids(&book));
    //     let (min_key_bid, _) = crit_bit::min_leaf(orderbook::borrow_bids(&book));

    //     assert!(max_key_bid == 300, 0);
    //     assert!(min_key_bid == 1, 0);

    //     let i = quantity;
    //     let price = 1;

    //     // 6. Cancel orders
    //     while (i > 0) {
    //         test_scenario::next_tx(&mut scenario, buyer());

    //         orderbook::edit_bid(
    //             &mut book,
    //             &mut buyer_kiosk,
    //             price,
    //             500,
    //             &mut coin,
    //             ctx(&mut scenario),
    //         );

    //         // Register funds locked in the Bid
    //         funds_locked = funds_locked + (500 - price);

    //         // Assersions
    //         // 1. Funds withdrawn from Wallet
    //         assert!(coin::value(&coin) == initial_funds - funds_locked, 0);

    //         // 2. Number of Bids however they all get concentrated into the same
    //         // price level - In the first iteration the length does not really change because
    //         // we are just swapping one price level for another.
    //         price_levels = if (i == quantity) {price_levels} else {price_levels - 1};
    //         assert!(crit_bit::size(orderbook::borrow_bids(&book)) == price_levels, 0);

    //         price = price + 1;
    //         i = i - 1;
    //     };

    //     // Assert orderbook state
    //     // All orders are concentrated into one price level
    //     assert!(crit_bit::size(orderbook::borrow_bids(&book)) == 1, 0);

    //     let (max_key_bid, _) = crit_bit::max_leaf(orderbook::borrow_bids(&book));
    //     let (min_key_bid, _) = crit_bit::min_leaf(orderbook::borrow_bids(&book));

    //     assert!(max_key_bid == 500, 0);
    //     assert!(min_key_bid == 500, 0);

    //     coin::burn_for_testing(coin);
    //     transfer::public_transfer(publisher, creator());
    //     transfer::public_transfer(mint_cap, creator());
    //     transfer::public_transfer(policy_cap, creator());
    //     test_scenario::return_shared(seller_kiosk);
    //     test_scenario::return_shared(buyer_kiosk);
    //     test_scenario::return_shared(book);
    //     test_scenario::end(scenario);
    // }
}
