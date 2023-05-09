#[test_only]
/// This test focuses on integration between OB, Safe, a allowlist and
/// royalty collection.
///
/// We simulate a trade between two Safes, end to end, including royalty
/// collection.
module ob_tests::orderbook_migration {
    use std::vector;
    use std::debug;
    use std::string::utf8;

    use sui::coin::{Self};
    use sui::object;
    use sui::transfer;
    use sui::sui::SUI;
    // use sui::kiosk::Kiosk;
    use sui::test_scenario::{Self, ctx};

    use ob_permissions::witness;
    // use ob_utils::crit_bit::{Self};
    use ob_kiosk::ob_kiosk::{Self};
    // use ob_allowlist::allowlist::{Self, Allowlist};
    // use nft_protocol::transfer_allowlist;
    use ob_tests::test_utils::{Self, Foo,  seller, buyer, creator};
    use originmate::crit_bit_u64::{Self as crit_bit_v1};

    // use liquidity_layer::orderbook::{Self as orderbook_v2, Orderbook as OrderbookV2};
    use liquidity_layer_v1::orderbook::{Self as orderbook_v1, Orderbook as OrderbookV1};

    #[test]
    fun migrate_orderbook() {
        let order_no = 300;

        let scenario = test_scenario::begin(creator());

        // 1. Create Collection, TransferPolicy and Orderbook
        let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        let dw = witness::test_dw<Foo>();
        test_utils::create_orderbook_v1<Foo>(dw, &tx_policy, &mut scenario);

        transfer::public_share_object(collection);
        transfer::public_share_object(tx_policy);

        // 3. Create Buyer Kiosks
        // test_scenario::next_tx(&mut scenario, buyer());

        // let buyer_kiosks = vector::empty();

        // let i = order_no;

        // while (i > 0) {
        //     let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
        //     vector::push_back(&mut buyer_kiosks, kiosk);
        // };

        // 4. Create Seller Kiosk
        test_scenario::next_tx(&mut scenario, seller());

        let seller_kiosks = vector::empty();

        let i = order_no;

        while (i > 0) {
            let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
            vector::push_back(&mut seller_kiosks, kiosk);
            i = i - 1;
        };

        // 5. Create asks order for NFTs
        test_scenario::next_tx(&mut scenario, buyer());

        let book_v1 = test_scenario::take_shared<OrderbookV1<Foo, SUI>>(&mut scenario);

        let coin = coin::mint_for_testing<SUI>(1_000_000, ctx(&mut scenario));

        let i = order_no;
        let price = 300;

        let nfts = vector::empty();

        while (i > 0) {
            test_scenario::next_tx(&mut scenario, seller());

            // Create and deposit NFT
            let nft = test_utils::get_foo_nft(ctx(&mut scenario));
            let nft_id = object::id(&nft);
            vector::push_back(&mut nfts, nft_id);

            let seller_kiosk = vector::borrow_mut(&mut seller_kiosks, i - 1);

            ob_kiosk::deposit(seller_kiosk, nft, ctx(&mut scenario));

            orderbook_v1::create_ask(
                &mut book_v1,
                seller_kiosk,
                price,
                nft_id,
                ctx(&mut scenario),
            );

            i = i - 1;
            price = price - 1;
        };

        // Assert that orderbook state
        assert!(crit_bit_v1::max_key(orderbook_v1::borrow_asks(&book_v1)) == 300, 0);
        assert!(crit_bit_v1::min_key(orderbook_v1::borrow_asks(&book_v1)) == 1, 0);
        assert!(crit_bit_v1::length(orderbook_v1::borrow_asks(&book_v1)) == 300, 0);

        // === Initiate Migration ===
        test_scenario::next_tx(&mut scenario, creator());

        orderbook_v1::disable_trading(
            &publisher, &mut book_v1,
        );

        orderbook_v1::freeze_orderbook_with_witness(
            dw, &mut book_v1
        );

        // === Cancel asks

        // [Ask 1, Ask 2, Ask 3, Ask 4, Ask 5, ...]
        // [Kiosk 1, Kiosk 2, Kiosk 3, Kiosk 4, Kiosk 5, ...]
        // [NFT 1, NFT 2, NFT 3, NFT 4, NFT 5, ...]
        // [300, 299, 298, 297, 296, ...]

        // Revert order so we can start with the highest bids
        // [..., Ask 1, Ask 2, Ask 3, Ask 4, Ask 5]
        // [..., Kiosk 5, Kiosk 4, Kiosk 3, Kiosk 2, Kiosk 1]
        // [..., NFT 5, NFT 4, NFT 3, NFT 2, NFT 1]
        // [..., 296, 297, 298, 299, 300]
        vector::reverse(&mut nfts);
        // vector::reverse(&mut seller_kiosks);

        let i = order_no;
        price = 300;

        while (i > 0) {
            test_scenario::next_tx(&mut scenario, creator());

            let seller_kiosk = vector::borrow_mut(&mut seller_kiosks, i - 1);
            let nft_id = vector::borrow(&mut nfts, i - 1);

            debug::print(seller_kiosk);
            debug::print(&price);
            debug::print(nft_id);
            orderbook_v1::cancel_ask_permissionless(
                &mut book_v1,
                seller_kiosk,
                price,
                *nft_id,
            );

            i = i -1;
            price = price -1;
        };

        let i = order_no;

        while (i > 0) {
            let kiosk = vector::pop_back(&mut seller_kiosks);
            // We do not share just for the convenience here - but obviously
            // these should be shared
            transfer::public_transfer(kiosk, seller());
            i = i - 1;
            debug::print(&vector::length(&seller_kiosks));
        };

        vector::destroy_empty(seller_kiosks);

        coin::burn_for_testing(coin);
        transfer::public_transfer(publisher, creator());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        test_scenario::return_shared(book_v1);
        test_scenario::end(scenario);
    }
}
