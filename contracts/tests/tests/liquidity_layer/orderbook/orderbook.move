#[test_only]
/// This test focuses on integration between OB, Safe, a allowlist and
/// royalty collection.
///
/// We simulate a trade between two Safes, end to end, including royalty
/// collection.
module ob_tests::orderbook {
    use std::option;
    // use std::debug;
    use std::vector;

    use sui::coin;
    use sui::object;
    use sui::kiosk;
    use sui::transfer;
    use sui::sui::SUI;
    use sui::kiosk::Kiosk;
    use sui::test_scenario::{Self, ctx};
    use sui::transfer_policy::{Self, TransferPolicy};

    // TODO:
    // fun it_fails_if_buyer_safe_eq_seller_safe()
    // fun it_fails_if_buyer_safe_eq_seller_safe_with_generic_collection()
    // fun it_fails_if_buyer_safe_eq_seller_safe_with_generic_collection() {
    use ob_permissions::witness;
    use originmate::typed_id;
    use ob_utils::crit_bit::{Self};
    use ob_request::transfer_request;
    use ob_kiosk::ob_kiosk::{Self, OwnerToken};
    use ob_allowlist::allowlist::{Self, Allowlist};
    use liquidity_layer::orderbook::{Self, Orderbook};
    use nft_protocol::transfer_allowlist;
    use nft_protocol::royalty;
    use nft_protocol::royalty_strategy_bps::{Self, BpsRoyaltyStrategy};
    use ob_tests::test_utils::{Self, Foo,  seller, buyer, creator, marketplace};

    const OFFER_SUI: u64 = 100;

    #[test]
    fun create_exclusive_orderbook_as_originbyte_collection() {
        let scenario = test_scenario::begin(creator());

        // 1. Create OriginByte TransferPolicy and Orderbook
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (transfer_policy, policy_cap) = transfer_request::init_policy<Foo>(&publisher, ctx(&mut scenario));

        // This function can only be called if the TransferPolicy is created
        // from OriginByte's transfer_request module, or if at any time the
        // creator adds an OriginByte rule to their TransferPolicy object.
        let orderbook = orderbook::new_unprotected<Foo, SUI>(
            witness::from_witness(test_utils::witness()),
            &transfer_policy,
            ctx(&mut scenario),
        );

        orderbook::share(orderbook);
        transfer::public_share_object(transfer_policy);
        transfer::public_transfer(policy_cap, creator());
        transfer::public_transfer(publisher, creator());
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = orderbook::ENotOriginBytePolicy)]
    fun fail_create_exclusive_orderbook_as_non_originbyte_collection() {
        let scenario = test_scenario::begin(creator());

        // 1. Create OriginByte TransferPolicy and Orderbook
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (transfer_policy, policy_cap) = transfer_policy::new<Foo>(&publisher, ctx(&mut scenario));

        // This function can only be called if the TransferPolicy is created
        // from OriginByte's transfer_request module, or if at any time the
        // creator adds an OriginByte rule to their TransferPolicy object.
        let orderbook = orderbook::new_unprotected<Foo, SUI>(
            witness::from_witness(test_utils::witness()),
            &transfer_policy,
            ctx(&mut scenario),
        );

        orderbook::share(orderbook);
        transfer::public_share_object(transfer_policy);
        transfer::public_transfer(policy_cap, creator());
        transfer::public_transfer(publisher, creator());
        test_scenario::end(scenario);
    }

    #[test]
    fun create_non_exclusive_orderbook_as_non_originbyte_collection() {
        let scenario = test_scenario::begin(creator());

        // 1. Create OriginByte TransferPolicy and Orderbook
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (transfer_policy, policy_cap) = transfer_policy::new<Foo>(&publisher, ctx(&mut scenario));

        // This function can only be called if the TransferPolicy is external
        // to OriginByte, in other words, if the creator did not use OriginByte
        // transfer_request module to initiate the policy or never added OriginByte
        // rules to the policy.
        orderbook::create_for_external<Foo, SUI>(
            &transfer_policy,
            ctx(&mut scenario),
        );

        transfer::public_share_object(transfer_policy);

        test_scenario::next_tx(&mut scenario, marketplace());
        let transfer_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

        // When this is the case, anyone can come in a create an orderbook
        orderbook::create_for_external<Foo, SUI>(
            &transfer_policy,
            ctx(&mut scenario),
        );

        test_scenario::return_shared(transfer_policy);
        transfer::public_transfer(policy_cap, creator());
        transfer::public_transfer(publisher, creator());
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = orderbook::ENotExternalPolicy)]
    fun fail_create_non_exclusive_orderbook_as_originbyte_collection() {
        let scenario = test_scenario::begin(creator());

        // 1. Create OriginByte TransferPolicy and Orderbook
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (transfer_policy, policy_cap) = transfer_request::init_policy<Foo>(&publisher, ctx(&mut scenario));

        transfer::public_share_object(transfer_policy);

        test_scenario::next_tx(&mut scenario, marketplace());
        let transfer_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

        // When this is the case, anyone can come in a create an orderbook
        orderbook::create_for_external<Foo, SUI>(
            &transfer_policy,
            ctx(&mut scenario),
        );

        test_scenario::return_shared(transfer_policy);
        transfer::public_transfer(policy_cap, creator());
        transfer::public_transfer(publisher, creator());
        test_scenario::end(scenario);
    }

    #[test]
    fun test_trade_in_ob_kiosk() {
        let scenario = test_scenario::begin(creator());

        // 1. Create Collection, TransferPolicy and Orderbook
        let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        let dw = witness::test_dw<Foo>();
        test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

        transfer::public_share_object(collection);
        transfer::public_share_object(tx_policy);

        // 3. Create Buyer Kiosk
        test_scenario::next_tx(&mut scenario, buyer());
        let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        transfer::public_share_object(buyer_kiosk);

        // 4. Create Seller Kiosk
        test_scenario::next_tx(&mut scenario, seller());
        let (seller_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 4. Add NFT to Seller Kiosk
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

        // 5. Create ask order for NFT
        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
        orderbook::create_ask(
            &mut book,
            &mut seller_kiosk,
            100,
            nft_id,
            ctx(&mut scenario),
        );

        transfer::public_share_object(seller_kiosk);
        test_scenario::next_tx(&mut scenario, buyer());

        let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

        // 6. Create bid for NFT
        let coin = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));

        let trade_opt = orderbook::create_bid(
            &mut book,
            &mut buyer_kiosk,
            100,
            &mut coin,
            ctx(&mut scenario),
        );

        let trade = option::destroy_some(trade_opt);

        test_scenario::next_tx(&mut scenario, seller());
        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

        let request = orderbook::finish_trade(
            &mut book,
            orderbook::trade_id(&trade),
            &mut seller_kiosk,
            &mut buyer_kiosk,
            ctx(&mut scenario),
        );

        transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

        coin::burn_for_testing(coin);
        transfer::public_transfer(publisher, creator());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        test_scenario::return_shared(tx_policy);
        test_scenario::return_shared(seller_kiosk);
        test_scenario::return_shared(buyer_kiosk);
        test_scenario::return_shared(book);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_trade_in_ob_kiosk_full_royalty_enforcement() {
        let scenario = test_scenario::begin(creator());

        // 1. Create Collection and Orderbook
        let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
        let publisher = test_utils::get_publisher(ctx(&mut scenario));

        // 2. Add Royalty Policy and Allowlist
        let royalty_domain = royalty::from_address(creator(), ctx(&mut scenario));

        royalty_strategy_bps::create_domain_and_add_strategy<Foo>(
            witness::from_witness(test_utils::witness()), &mut collection, royalty_domain, 100, ctx(&mut scenario),
        );

        // Get allowlist. This can be any allowlist created by anyone but we create
        // one here for the purpose of the test
        let (al, al_cap) = test_utils::create_allowlist(&mut scenario);

        allowlist::insert_collection<Foo>(&mut al, &publisher);

        // 3. Create TransferPolocy, add Royalty and Allowlist step in it
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        transfer_allowlist::enforce(&mut tx_policy, &policy_cap);
        royalty_strategy_bps::enforce(&mut tx_policy, &policy_cap);

        let dw = witness::test_dw<Foo>();
        test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

        transfer::public_transfer(al_cap, marketplace());
        transfer::public_share_object(al);
        transfer::public_share_object(collection);
        transfer::public_share_object(tx_policy);

        // 3. Create Buyer Kiosk
        test_scenario::next_tx(&mut scenario, buyer());
        let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        transfer::public_share_object(buyer_kiosk);

        // 4. Create Seller Kiosk
        test_scenario::next_tx(&mut scenario, seller());
        let (seller_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 4. Add NFT to Seller Kiosk
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

        // 5. Create ask order for NFT
        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
        orderbook::create_ask(
            &mut book,
            &mut seller_kiosk,
            100_000_000,
            nft_id,
            ctx(&mut scenario),
        );

        transfer::public_share_object(seller_kiosk);
        test_scenario::next_tx(&mut scenario, buyer());

        let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

        // 6. Create bid for NFT
        let coin = coin::mint_for_testing<SUI>(100_000_000, ctx(&mut scenario));

        let trade_opt = orderbook::create_bid(
            &mut book,
            &mut buyer_kiosk,
            100_000_000,
            &mut coin,
            ctx(&mut scenario),
        );

        let trade = option::destroy_some(trade_opt);

        test_scenario::next_tx(&mut scenario, seller());
        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

        let request = orderbook::finish_trade(
            &mut book,
            orderbook::trade_id(&trade),
            &mut seller_kiosk,
            &mut buyer_kiosk,
            ctx(&mut scenario),
        );

        // 7. Verify action on allowlist
        let al = test_scenario::take_shared<Allowlist>(&mut scenario);
        transfer_allowlist::confirm_transfer(&al, &mut request);

        // 8. Pay royalties
        let royalty_engine = test_scenario::take_shared<BpsRoyaltyStrategy<Foo>>(&mut scenario);
        royalty_strategy_bps::confirm_transfer<Foo, SUI>(&mut royalty_engine, &mut request);

        transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

        coin::burn_for_testing(coin);
        transfer::public_transfer(publisher, creator());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        test_scenario::return_shared(tx_policy);
        test_scenario::return_shared(seller_kiosk);
        test_scenario::return_shared(buyer_kiosk);
        test_scenario::return_shared(book);
        test_scenario::return_shared(al);
        test_scenario::return_shared(royalty_engine);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_trade_with_sui_policy() {
        let scenario = test_scenario::begin(creator());

        // 1. Create Collection, TransferPolicy and Orderbook
        let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
        let publisher = test_utils::get_publisher(ctx(&mut scenario));

        let (tx_policy, policy_cap) = transfer_policy::new<Foo>(&publisher, ctx(&mut scenario));
        test_utils::create_external_orderbook<Foo>(&tx_policy, &mut scenario);

        transfer::public_share_object(collection);
        transfer::public_share_object(tx_policy);

        // 3. Create Buyer Kiosk
        test_scenario::next_tx(&mut scenario, buyer());
        let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        transfer::public_share_object(buyer_kiosk);

        // 4. Create Seller Kiosk
        test_scenario::next_tx(&mut scenario, seller());
        let (seller_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 4. Add NFT to Seller Kiosk
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

        // 5. Create ask order for NFT
        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
        orderbook::create_ask(
            &mut book,
            &mut seller_kiosk,
            100_000_000,
            nft_id,
            ctx(&mut scenario),
        );

        transfer::public_share_object(seller_kiosk);
        test_scenario::next_tx(&mut scenario, buyer());

        let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

        // 6. Create bid for NFT
        let coin = coin::mint_for_testing<SUI>(100_000_000, ctx(&mut scenario));

        let trade_opt = orderbook::create_bid(
            &mut book,
            &mut buyer_kiosk,
            100_000_000,
            &mut coin,
            ctx(&mut scenario),
        );

        let trade = option::destroy_some(trade_opt);

        test_scenario::next_tx(&mut scenario, seller());
        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

        let request = orderbook::finish_trade(
            &mut book,
            orderbook::trade_id(&trade),
            &mut seller_kiosk,
            &mut buyer_kiosk,
            ctx(&mut scenario),
        );

        let sui_request = transfer_request::into_sui<Foo>(request, &tx_policy, ctx(&mut scenario));
        transfer_policy::confirm_request<Foo>(&tx_policy, sui_request);

        coin::burn_for_testing(coin);
        transfer::public_transfer(publisher, creator());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        test_scenario::return_shared(tx_policy);
        test_scenario::return_shared(seller_kiosk);
        test_scenario::return_shared(buyer_kiosk);
        test_scenario::return_shared(book);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_trade_from_sui_kiosk() {
        let scenario = test_scenario::begin(creator());

        // 1. Create Collection, TransferPolicy and Orderbook
        let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
        let publisher = test_utils::get_publisher(ctx(&mut scenario));

        let (tx_policy, policy_cap) = transfer_policy::new<Foo>(&publisher, ctx(&mut scenario));
        test_utils::create_external_orderbook<Foo>(&tx_policy, &mut scenario);

        transfer::public_share_object(collection);
        transfer::public_share_object(tx_policy);

        // 3. Create Buyer Kiosk
        test_scenario::next_tx(&mut scenario, buyer());
        let (buyer_kiosk, buyer_cap) = kiosk::new(ctx(&mut scenario));

        transfer::public_share_object(buyer_kiosk);

        // 4. Create Seller Kiosk
        test_scenario::next_tx(&mut scenario, seller());
        let (seller_kiosk, seller_cap) = kiosk::new(ctx(&mut scenario));

        // 4. Add NFT to Seller Kiosk
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = typed_id::new(&nft);
        kiosk::place(&mut seller_kiosk, &seller_cap, nft);

        // 5. Create ask order for NFT
        ob_kiosk::install_extension(&mut seller_kiosk, seller_cap, ctx(&mut scenario));
        ob_kiosk::register_nft(&mut seller_kiosk, nft_id, ctx(&mut scenario));

        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
        orderbook::create_ask(
            &mut book,
            &mut seller_kiosk,
            100_000_000,
            typed_id::to_id(nft_id),
            ctx(&mut scenario),
        );

        transfer::public_share_object(seller_kiosk);
        test_scenario::next_tx(&mut scenario, buyer());

        let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

        // 6. Create bid for NFT
        let coin = coin::mint_for_testing<SUI>(100_000_000, ctx(&mut scenario));
        ob_kiosk::install_extension(&mut buyer_kiosk, buyer_cap, ctx(&mut scenario));

        let trade_opt = orderbook::create_bid(
            &mut book,
            &mut buyer_kiosk,
            100_000_000,
            &mut coin,
            ctx(&mut scenario),
        );

        let trade = option::destroy_some(trade_opt);

        test_scenario::next_tx(&mut scenario, seller());
        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

        let request = orderbook::finish_trade(
            &mut book,
            orderbook::trade_id(&trade),
            &mut seller_kiosk,
            &mut buyer_kiosk,
            ctx(&mut scenario),
        );

        let sui_request = transfer_request::into_sui<Foo>(request, &tx_policy, ctx(&mut scenario));
        transfer_policy::confirm_request<Foo>(&tx_policy, sui_request);

        // 7. Leave OriginByte
        let seller_token = test_scenario::take_from_address<OwnerToken>(
            &scenario, seller()
        );

        test_scenario::next_tx(&mut scenario, seller());
        ob_kiosk::uninstall_extension(&mut seller_kiosk, seller_token, ctx(&mut scenario));

        coin::burn_for_testing(coin);
        transfer::public_transfer(publisher, buyer());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        test_scenario::return_shared(tx_policy);
        test_scenario::return_shared(seller_kiosk);
        test_scenario::return_shared(buyer_kiosk);
        test_scenario::return_shared(book);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_limit_ask_insert_and_popping_with_market_buy() {
        let scenario = test_scenario::begin(creator());

        // 1. Create Collection, TransferPolicy and Orderbook
        let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        let dw = witness::test_dw<Foo>();
        test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

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
        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
        let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

        let price_levels = crit_bit::size(orderbook::borrow_asks(&book));

        let quantity = 300;
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

            // Assersions
            // 1. NFT is exclusively listed in the Seller Kiosk
            ob_kiosk::assert_exclusively_listed(&mut seller_kiosk, nft_id);

            // 2. New price level gets added with new Ask
            price_levels = price_levels + 1;
            assert!(crit_bit::size(orderbook::borrow_asks(&book)) == price_levels, 0);

            i = i - 1;
            price = price + 1;
        };

        test_scenario::next_tx(&mut scenario, buyer());

        let i = quantity;
        // Buyer gets best price (lowest)
        let price = 1;

        // 6. Create market bids
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

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

            assert!(orderbook::trade_price(&trade_info) == price, 0);
            price = price + 1;
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
    fun test_limit_bid_insert_and_popping_with_market_sell() {
        let scenario = test_scenario::begin(creator());

        // 1. Create Collection, TransferPolicy and Orderbook
        let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        let dw = witness::test_dw<Foo>();
        test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

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
        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
        let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

        let initial_funds = 1_000_000;
        let price_levels = crit_bit::size(orderbook::borrow_bids(&book));
        let funds_locked = 0;

        let coin = coin::mint_for_testing<SUI>(initial_funds, ctx(&mut scenario));

        let quantity = 300;
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

            // Register funds locked in the Bid
            funds_locked = funds_locked + price;

            // Assersions
            // 1. Funds withdrawn from Wallet
            assert!(coin::value(&coin) == initial_funds - funds_locked, 0);

            // 2. New price level gets added with new Bid
            price_levels = price_levels + 1;
            assert!(crit_bit::size(orderbook::borrow_bids(&book)) == price_levels, 0);

            price = price + 1;
            i = i - 1;
        };

        test_scenario::next_tx(&mut scenario, buyer());

        let i = quantity;
        // Seller gets best price (highest)
        let price = 300;

        // 6. Create market bids

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

            assert!(orderbook::trade_price(&trade_info) == price, 0);

            i = i - 1;
            price = price - 1;
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
    fun test_limit_ask_insert_and_popping_with_limit_buy() {
        let scenario = test_scenario::begin(creator());

        // 1. Create Collection, TransferPolicy and Orderbook
        let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        let dw = witness::test_dw<Foo>();
        test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

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
        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
        let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

        let price_levels = crit_bit::size(orderbook::borrow_asks(&book));

        let quantity = 300;
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

            // Assersions
            // 1. NFT is exclusively listed in the Seller Kiosk
            ob_kiosk::assert_exclusively_listed(&mut seller_kiosk, nft_id);

            // 2. New price level gets added with new Ask
            price_levels = price_levels + 1;
            assert!(crit_bit::size(orderbook::borrow_asks(&book)) == price_levels, 0);

            i = i - 1;
            price = price + 1;
        };

        test_scenario::next_tx(&mut scenario, buyer());

        // Buyer gets best price (lowest)
        let price = 1;
        let i = quantity;

        // 6. Create market bids
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

        let initial_funds = 1_000_000;
        let funds_sent = 0;
        let coin = coin::mint_for_testing<SUI>(initial_funds, ctx(&mut scenario));

        while (i > 0) {
            test_scenario::next_tx(&mut scenario, buyer());

            let trade_info_opt = orderbook::create_bid(
                &mut book,
                &mut buyer_kiosk,
                price,
                &mut coin,
                ctx(&mut scenario),
            );

            // Register funds sent
            funds_sent = funds_sent + price;

            // Assersions
            // 1. Funds withdrawn from Wallet
            assert!(coin::value(&coin) == initial_funds - funds_sent, 0);

            // 2. Ask gets popped and price level removed
            price_levels = price_levels - 1;
            assert!(crit_bit::size(orderbook::borrow_asks(&book)) == price_levels, 0);

            // 3. Assert trade match
            let trade_info = option::extract(&mut trade_info_opt);
            option::destroy_none(trade_info_opt);
            assert!(orderbook::trade_price(&trade_info) == price, 0);

            price = price + 1;
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
    fun test_limit_bid_and_limit_sell_inserts() {
        let scenario = test_scenario::begin(creator());

        // 1. Create Collection, TransferPolicy and Orderbook
        let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        let dw = witness::test_dw<Foo>();
        test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

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
        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
        let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

        let initial_funds = 1_000_000;
        let bid_price_levels = crit_bit::size(orderbook::borrow_bids(&book));
        let funds_locked = 0;

        let coin = coin::mint_for_testing<SUI>(1_000_000, ctx(&mut scenario));

        let quantity = 300;
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

            // Register funds locked in the Bid
            funds_locked = funds_locked + price;

            // Assersions
            // 1. Funds withdrawn from Wallet
            assert!(coin::value(&coin) == initial_funds - funds_locked, 0);

            // 2. New price level gets added with new Bid
            bid_price_levels = bid_price_levels + 1;
            assert!(crit_bit::size(orderbook::borrow_bids(&book)) == bid_price_levels, 0);

            price = price + 1;
            i = i - 1;
        };

        test_scenario::next_tx(&mut scenario, buyer());

        // Seller gets best price (highest)
        let ask_price_levels = crit_bit::size(orderbook::borrow_asks(&book));
        let price = 301;
        let i = quantity;

        // 6. Create limit ask

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

            // Assersions
            // 1. NFT is exclusively listed in the Seller Kiosk
            ob_kiosk::assert_exclusively_listed(&mut seller_kiosk, nft_id);

            // 2. New price level gets added with new Ask
            ask_price_levels = ask_price_levels + 1;
            assert!(crit_bit::size(orderbook::borrow_asks(&book)) == ask_price_levels, 0);

            i = i - 1;
            price = price + 1;
        };

        // Assert orderbook state

        let (max_key_bid, _) = crit_bit::max_leaf(orderbook::borrow_bids(&book));
        let (min_key_bid, _) = crit_bit::min_leaf(orderbook::borrow_bids(&book));
        let (max_key_ask, _) = crit_bit::max_leaf(orderbook::borrow_asks(&book));
        let (min_key_ask, _) = crit_bit::min_leaf(orderbook::borrow_asks(&book));

        assert!(max_key_bid == 300, 0);
        assert!(min_key_bid == 1, 0);
        assert!(max_key_ask == 600, 0);
        assert!(min_key_ask == 301, 0);

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
    fun test_cancel_asks() {
        let scenario = test_scenario::begin(creator());

        // 1. Create Collection, TransferPolicy and Orderbook
        let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        let dw = witness::test_dw<Foo>();
        test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

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
        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
        let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

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
        let (max_key_ask, _) = crit_bit::max_leaf(orderbook::borrow_asks(&book));
        let (min_key_ask, _) = crit_bit::min_leaf(orderbook::borrow_asks(&book));

        assert!(max_key_ask == 300, 0);
        assert!(min_key_ask == 1, 0);

        let i = quantity;
        let price = 1;

        // 6. Cancel orders
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

            price = price + 1;
            i = i - 1;
        };

        // Assert that orderbook state
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
    fun test_cancel_bids() {
        let scenario = test_scenario::begin(creator());

        // 1. Create Collection, TransferPolicy and Orderbook
        let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        let dw = witness::test_dw<Foo>();
        test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

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
        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
        let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

        let initial_funds = 1_000_000;
        let price_levels = crit_bit::size(orderbook::borrow_bids(&book));
        let funds_locked = 0;

        let coin = coin::mint_for_testing<SUI>(initial_funds, ctx(&mut scenario));

        let quantity = 300;
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

            // Register funds locked in the Bid
            funds_locked = funds_locked + price;

            // Assersions
            // 1. Funds withdrawn from Wallet
            assert!(coin::value(&coin) == initial_funds - funds_locked, 0);

            // 2. New price level gets added with new Bid
            price_levels = price_levels + 1;
            assert!(crit_bit::size(orderbook::borrow_bids(&book)) == price_levels, 0);

            price = price + 1;
            i = i - 1;
        };

        // Assert that orderbook state
        let (max_key_bid, _) = crit_bit::max_leaf(orderbook::borrow_bids(&book));
        let (min_key_bid, _) = crit_bit::min_leaf(orderbook::borrow_bids(&book));


        assert!(max_key_bid == 300, 0);
        assert!(min_key_bid == 1, 0);

        let i = quantity;
        let price = 1;

        // 6. Cancel orders
        while (i > 0) {
            test_scenario::next_tx(&mut scenario, buyer());

            orderbook::cancel_bid(
                &mut book,
                price,
                &mut coin,
                ctx(&mut scenario),
            );

            // Register funds unlocked with the Bid cancellation
            funds_locked = funds_locked - price;

            // Assersions
            // 1. Funds withdrawn from Wallet
            assert!(coin::value(&coin) == initial_funds - funds_locked, 0);

            // 2. New price level gets removed with Bid popped
            price_levels = price_levels - 1;
            assert!(crit_bit::size(orderbook::borrow_bids(&book)) == price_levels, 0);

            price = price + 1;
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
        test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

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
        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
        let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

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
        let (max_key_ask, _) = crit_bit::max_leaf(orderbook::borrow_asks(&book));
        let (min_key_ask, _) = crit_bit::min_leaf(orderbook::borrow_asks(&book));

        assert!(max_key_ask == 300, 0);
        assert!(min_key_ask == 1, 0);
        assert!(crit_bit::size(orderbook::borrow_asks(&book)) == 300, 0);

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
        assert!(crit_bit::size(orderbook::borrow_asks(&book)) == 1, 0);

        let (max_key_ask, _) = crit_bit::max_leaf(orderbook::borrow_asks(&book));
        let (min_key_ask, _) = crit_bit::min_leaf(orderbook::borrow_asks(&book));

        assert!(max_key_ask == 500, 0);
        assert!(min_key_ask == 500, 0);

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
    fun test_edit_bids() {
        let scenario = test_scenario::begin(creator());

        // 1. Create Collection, TransferPolicy and Orderbook
        let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        let dw = witness::test_dw<Foo>();
        test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

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
        let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
        let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

        let initial_funds = 1_000_000;
        let price_levels = crit_bit::size(orderbook::borrow_bids(&book));
        let funds_locked = 0;

        let coin = coin::mint_for_testing<SUI>(initial_funds, ctx(&mut scenario));

        let quantity = 300;
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

            // Register funds locked in the Bid
            funds_locked = funds_locked + price;

            // Assersions
            // 1. Funds withdrawn from Wallet
            assert!(coin::value(&coin) == initial_funds - funds_locked, 0);

            // 2. New price level gets added with new Bid
            price_levels = price_levels + 1;
            assert!(crit_bit::size(orderbook::borrow_bids(&book)) == price_levels, 0);

            price = price + 1;
            i = i - 1;
        };

        // Assert that orderbook state
        let (max_key_bid, _) = crit_bit::max_leaf(orderbook::borrow_bids(&book));
        let (min_key_bid, _) = crit_bit::min_leaf(orderbook::borrow_bids(&book));

        assert!(max_key_bid == 300, 0);
        assert!(min_key_bid == 1, 0);

        let i = quantity;
        let price = 1;

        // 6. Cancel orders
        while (i > 0) {
            test_scenario::next_tx(&mut scenario, buyer());

            orderbook::edit_bid(
                &mut book,
                &mut buyer_kiosk,
                price,
                500,
                &mut coin,
                ctx(&mut scenario),
            );

            // Register funds locked in the Bid
            funds_locked = funds_locked + (500 - price);

            // Assersions
            // 1. Funds withdrawn from Wallet
            assert!(coin::value(&coin) == initial_funds - funds_locked, 0);

            // 2. Number of Bids however they all get concentrated into the same
            // price level - In the first iteration the length does not really change because
            // we are just swapping one price level for another.
            price_levels = if (i == quantity) {price_levels} else {price_levels - 1};
            assert!(crit_bit::size(orderbook::borrow_bids(&book)) == price_levels, 0);

            price = price + 1;
            i = i - 1;
        };

        // Assert orderbook state
        // All orders are concentrated into one price level
        assert!(crit_bit::size(orderbook::borrow_bids(&book)) == 1, 0);

        let (max_key_bid, _) = crit_bit::max_leaf(orderbook::borrow_bids(&book));
        let (min_key_bid, _) = crit_bit::min_leaf(orderbook::borrow_bids(&book));

        assert!(max_key_bid == 500, 0);
        assert!(min_key_bid == 500, 0);

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
