#[test_only]
#[lint_allow(share_owned)]
/// This test focuses on integration between OB, Safe, a allowlist and
/// royalty collection.
///
/// We simulate a trade between two Safes, end to end, including royalty
/// collection.
module ob_tests::orderbook_depth_v1 {
    use std::vector;

    use sui::coin;
    use sui::object;
    use sui::transfer;
    use sui::sui::SUI;
    use sui::kiosk::Kiosk;
    use sui::test_scenario::{Self, ctx};

    use ob_permissions::witness;
    use originmate::crit_bit_u64::{Self as crit_bit};
    use ob_tests::test_utils::{Self, Foo,  seller, buyer, creator};
    use ob_kiosk::ob_kiosk;
    use liquidity_layer_v1::orderbook::{Self, Orderbook};

    #[test]
    fun test_limit_ask_insert_and_popping_with_market_buy_with_depth() {
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
        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&scenario);
        let seller_kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        // We had one here to account for the first iteration
        let price_levels = crit_bit::length(orderbook::borrow_asks(&book)) + 1;

        let quantity = 100;
        let depth = 10;
        let j = 0;

        let i = quantity;
        let price = 1;

        while (i > 0) {
            test_scenario::next_tx(&mut scenario, seller());

            // Create and deposit NFT
            let nft = test_utils::get_foo_nft(ctx(&mut scenario));
            let nft_id = object::id(&nft);
            ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

            orderbook::create_ask(
                &mut book,
                &mut seller_kiosk,
                price,
                nft_id,
                ctx(&mut scenario),
            );

            j = j + 1;

            // Assersions
            // 1. NFT is exclusively listed in the Seller Kiosk
            ob_kiosk::assert_exclusively_listed(&mut seller_kiosk, nft_id);

            // 2. New price level gets added with new Ask
            assert!(crit_bit::length(orderbook::borrow_asks(&book)) == price_levels, 0);

            if (j == depth) {
                price_levels = price_levels + 1;
                price = price + 1;
                j = 0;
            };

            i = i - 1;
        };

        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 1)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 2)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 3)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 4)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 5)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 6)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 7)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 8)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 9)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 10)) == 10, 0);
        assert!(crit_bit::has_key(orderbook::borrow_asks(&book), 11) == false, 0);

        test_scenario::next_tx(&mut scenario, buyer());

        let i = quantity;
        // Buyer gets best price (lowest)
        let price = 1;
        let j = 0;

        // 6. Create market bids
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        let coin = coin::mint_for_testing<SUI>(1_000_000, ctx(&mut scenario));

        while (i > 0) {
            test_scenario::next_tx(&mut scenario, buyer());

            let trade_info = orderbook::market_buy(
                &mut book,
                &mut buyer_kiosk,
                &mut coin,
                price,
                ctx(&mut scenario),
            );

            j = j + 1;

            assert!(orderbook::trade_price(&trade_info) == price, 0);

            if (j == depth) {
                price_levels = price_levels - 1;
                price = price + 1;
                j = 0;
            };

            i = i - 1;
        };

        // Assert that orderbook is empty
        assert!(crit_bit::is_empty(orderbook::borrow_bids(&book)), 0);
        assert!(crit_bit::is_empty(orderbook::borrow_asks(&book)), 0);

        coin::burn_for_testing(coin);
        transfer::public_transfer(publisher, creator());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        // test_scenario::return_shared(tx_policy);
        test_scenario::return_shared(seller_kiosk);
        test_scenario::return_shared(buyer_kiosk);
        test_scenario::return_shared(book);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_limit_bid_insert_and_popping_with_market_sell_with_depth() {
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

        // 5. Create bid order for NFTs
        test_scenario::next_tx(&mut scenario, seller());
        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&scenario);
        let seller_kiosk = test_scenario::take_shared<Kiosk>(&scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        // We had one here to account for the firs iteration
        let initial_funds = 1_000_000;
        let funds_locked = 0;

        let price_levels = crit_bit::length(orderbook::borrow_bids(&book)) + 1;
        let coin = coin::mint_for_testing<SUI>(initial_funds, ctx(&mut scenario));

        let quantity = 100;
        let depth = 10;
        let j = 0;

        let i = quantity;
        let price = 1;

        while (i > 0) {
            test_scenario::next_tx(&mut scenario, buyer());

            // // Create and deposit NFT
            // let nft = test_utils::get_foo_nft(ctx(&mut scenario));
            // let nft_id = object::id(&nft);
            // ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

            orderbook::create_bid(
                &mut book,
                &mut buyer_kiosk,
                price,
                &mut coin,
                ctx(&mut scenario),
            );

            j = j + 1;

            // Register funds locked in the Bid
            funds_locked = funds_locked + price;

            // Assersions
            // 1. Funds withdrawn from Wallet
            assert!(coin::value(&coin) == initial_funds - funds_locked, 0);

            // 2. New price level gets added with new Bid
            assert!(crit_bit::length(orderbook::borrow_bids(&book)) == price_levels, 0);

            if (j == depth) {
                price_levels = price_levels + 1;
                price = price + 1;
                j = 0;
            };

            i = i - 1;
        };

        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 1)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 2)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 3)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 4)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 5)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 6)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 7)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 8)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 9)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 10)) == 10, 0);
        assert!(crit_bit::has_key(orderbook::borrow_bids(&book), 11) == false, 0);


        test_scenario::next_tx(&mut scenario, seller());

        let i = quantity;
        // Buyer gets best price (lowest)
        let price = 10;
        let j = 0;

        // 6. Create market sells

        while (i > 0) {
            test_scenario::next_tx(&mut scenario, seller());

            // Create and deposit NFT
            let nft = test_utils::get_foo_nft(ctx(&mut scenario));
            let nft_id = object::id(&nft);
            ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

            let trade_info = orderbook::market_sell(
                &mut book,
                &mut seller_kiosk,
                price,
                nft_id,
                ctx(&mut scenario),
            );

            j = j + 1;

            assert!(orderbook::trade_price(&trade_info) == price, 0);

            if (j == depth) {
                price_levels = price_levels - 1;
                price = price - 1;
                j = 0;
            };

            i = i - 1;
        };

        // Assert that orderbook is empty
        assert!(crit_bit::is_empty(orderbook::borrow_bids(&book)), 0);
        assert!(crit_bit::is_empty(orderbook::borrow_asks(&book)), 0);

        coin::burn_for_testing(coin);
        transfer::public_transfer(publisher, creator());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        test_scenario::return_shared(seller_kiosk);
        test_scenario::return_shared(buyer_kiosk);
        test_scenario::return_shared(book);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_cancel_asks_with_depth() {
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

        // 5. Create bid order for NFTs
        test_scenario::next_tx(&mut scenario, seller());
        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&scenario);
        let seller_kiosk = test_scenario::take_shared<Kiosk>(&scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        // We had one here to account for the first iteration
        let price_levels = crit_bit::length(orderbook::borrow_asks(&book)) + 1;

        let quantity = 100;
        let depth = 10;
        let j = 0;

        let i = quantity;
        let price = 1;

        let nfts = vector::empty();

        while (i > 0) {
            test_scenario::next_tx(&mut scenario, seller());

            // Create and deposit NFT
            let nft = test_utils::get_foo_nft(ctx(&mut scenario));
            let nft_id = object::id(&nft);
            vector::push_back(&mut nfts, nft_id);

            ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

            orderbook::create_ask(
                &mut book,
                &mut seller_kiosk,
                price,
                nft_id,
                ctx(&mut scenario),
            );

            j = j + 1;

            // Assersions
            // 1. NFT is exclusively listed in the Seller Kiosk
            ob_kiosk::assert_exclusively_listed(&mut seller_kiosk, nft_id);

            // 2. New price level gets added with new Ask
            assert!(crit_bit::length(orderbook::borrow_asks(&book)) == price_levels, 0);

            if (j == depth) {
                price_levels = price_levels + 1;
                price = price + 1;
                j = 0;
            };

            i = i - 1;
        };

        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 1)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 2)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 3)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 4)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 5)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 6)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 7)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 8)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 9)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_asks(&book), 10)) == 10, 0);
        assert!(crit_bit::has_key(orderbook::borrow_asks(&book), 11) == false, 0);

        let i = quantity;
        let price = 10;
        let j = 0;

        // // 6. Cancel orders
        while (i > 0) {
            test_scenario::next_tx(&mut scenario, seller());
            let nft_id = vector::pop_back(&mut nfts);

            orderbook::cancel_ask(
                &mut book,
                &mut seller_kiosk,
                price,
                nft_id,
                ctx(&mut scenario),
            );

            j = j + 1;

            if (j == depth) {
                price_levels = price_levels - 1;
                price = price - 1;
                j = 0;
            };

            i = i - 1;
        };

        // Assert that orderbook state
        assert!(crit_bit::is_empty(orderbook::borrow_asks(&book)), 0);

        // coin::burn_for_testing(coin);
        transfer::public_transfer(publisher, creator());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        test_scenario::return_shared(seller_kiosk);
        test_scenario::return_shared(buyer_kiosk);
        test_scenario::return_shared(book);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_cancel_bids_with_depth() {
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

        // 5. Create bid order for NFTs
        test_scenario::next_tx(&mut scenario, seller());
        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&scenario);
        let seller_kiosk = test_scenario::take_shared<Kiosk>(&scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        // We had one here to account for the firs iteration
        let initial_funds = 1_000_000;
        let funds_locked = 0;

        let price_levels = crit_bit::length(orderbook::borrow_bids(&book)) + 1;
        let coin = coin::mint_for_testing<SUI>(initial_funds, ctx(&mut scenario));

        let quantity = 100;
        let depth = 10;
        let j = 0;

        let i = quantity;
        let price = 1;

        while (i > 0) {
            test_scenario::next_tx(&mut scenario, buyer());

            orderbook::create_bid(
                &mut book,
                &mut buyer_kiosk,
                price,
                &mut coin,
                ctx(&mut scenario),
            );

            j = j + 1;

            // Register funds locked in the Bid
            funds_locked = funds_locked + price;

            // Assersions
            // 1. Funds withdrawn from Wallet
            assert!(coin::value(&coin) == initial_funds - funds_locked, 0);

            // 2. New price level gets added with new Bid
            assert!(crit_bit::length(orderbook::borrow_bids(&book)) == price_levels, 0);

            if (j == depth) {
                price_levels = price_levels + 1;
                price = price + 1;
                j = 0;
            };

            i = i - 1;
        };

        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 1)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 2)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 3)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 4)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 5)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 6)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 7)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 8)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 9)) == 10, 0);
        assert!(vector::length(crit_bit::borrow(orderbook::borrow_bids(&book), 10)) == 10, 0);
        assert!(crit_bit::has_key(orderbook::borrow_bids(&book), 11) == false, 0);

        let i = quantity;
        let price = 10;

        // 6. Cancel orders
        while (i > 0) {
            test_scenario::next_tx(&mut scenario, buyer());

            orderbook::cancel_bid(
                &mut book,
                price,
                &mut coin,
                ctx(&mut scenario),
            );

            j = j + 1;

            if (j == depth) {
                price_levels = price_levels - 1;
                price = price - 1;
                j = 0;
            };


            i = i - 1;
        };

        // Assert that orderbook state
        assert!(crit_bit::is_empty(orderbook::borrow_bids(&book)), 0);

        coin::burn_for_testing(coin);
        transfer::public_transfer(publisher, creator());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        test_scenario::return_shared(seller_kiosk);
        test_scenario::return_shared(buyer_kiosk);
        test_scenario::return_shared(book);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_edit_asks() {
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

        // 5. Create bid order for NFTs
        test_scenario::next_tx(&mut scenario, seller());
        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&scenario);
        let seller_kiosk = test_scenario::take_shared<Kiosk>(&scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        let coin = coin::mint_for_testing<SUI>(1_000_000, ctx(&mut scenario));

        let quantity = 300;
        let i = quantity;
        let price = 300;

        let nfts = vector::empty();

        while (i > 0) {
            test_scenario::next_tx(&mut scenario, seller());

            // Create and deposit NFT
            let nft = test_utils::get_foo_nft(ctx(&mut scenario));
            let nft_id = object::id(&nft);
            vector::push_back(&mut nfts, nft_id);

            ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

            orderbook::create_ask(
                &mut book,
                &mut seller_kiosk,
                price,
                nft_id,
                ctx(&mut scenario),
            );

            i = i - 1;
            price = price - 1;
        };

        // Assert that orderbook state
        assert!(crit_bit::max_key(orderbook::borrow_asks(&book)) == 300, 0);
        assert!(crit_bit::min_key(orderbook::borrow_asks(&book)) == 1, 0);
        assert!(crit_bit::length(orderbook::borrow_asks(&book)) == 300, 0);

        let i = quantity;
        let price = 1;

        // 6. Cancel orders
        while (i > 0) {
            test_scenario::next_tx(&mut scenario, seller());
            let nft_id = vector::pop_back(&mut nfts);

            orderbook::edit_ask(
                &mut book,
                &mut seller_kiosk,
                price,
                nft_id,
                500,
                ctx(&mut scenario),
            );

            price = price + 1;
            i = i - 1;
        };

        // Assert that orderbook state
        // All orders are concentrated into one price level
        assert!(crit_bit::length(orderbook::borrow_asks(&book)) == 1, 0);

        assert!(crit_bit::max_key(orderbook::borrow_asks(&book)) == 500, 0);
        assert!(crit_bit::min_key(orderbook::borrow_asks(&book)) == 500, 0);

        coin::burn_for_testing(coin);
        transfer::public_transfer(publisher, creator());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        test_scenario::return_shared(seller_kiosk);
        test_scenario::return_shared(buyer_kiosk);
        test_scenario::return_shared(book);
        test_scenario::end(scenario);
    }
}
