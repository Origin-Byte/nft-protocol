// #[test_only]
// /// This test focuses on integration between OB, Safe, a allowlist and
// /// royalty collection.
// ///
// /// We simulate a trade between two Safes, end to end, including royalty
// /// collection.
// module ob_tests::test_ob_load {
//     use std::debug;
//     use sui::object;
//     use sui::transfer;
//     use sui::sui::SUI;
//     use sui::kiosk::Kiosk;
//     use sui::test_scenario::{Self, ctx};

//     use ob_permissions::witness;
//     use ob_kiosk::ob_kiosk::{Self};
//     use liquidity_layer::orderbook::{Self, Orderbook};
//     use ob_tests::test_utils::{Self, Foo,  seller, buyer, creator};

//     const OFFER_SUI: u64 = 100;

//     #[test]
//     fun test_trade_orderly_insertion_popping() {
//         let scenario = test_scenario::begin(creator());

//         // 1. Create Collection, TransferPolicy and Orderbook
//         let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
//         let publisher = test_utils::get_publisher(ctx(&mut scenario));
//         let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

//         let dw = witness::test_dw<Foo>();
//         test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

//         transfer::public_share_object(collection);
//         transfer::public_share_object(tx_policy);

//         // 3. Create Buyer Kiosk
//         test_scenario::next_tx(&mut scenario, buyer());
//         let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

//         transfer::public_share_object(buyer_kiosk);

//         // 4. Create Seller Kiosk
//         test_scenario::next_tx(&mut scenario, seller());
//         let (seller_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
//         transfer::public_share_object(seller_kiosk);

//         // 5. Create asks order for NFT
//         test_scenario::next_tx(&mut scenario, seller());
//         let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
//         let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

//         let quantity = 3_000;
//         let i = quantity;
//         let price = 1;

//         while (i > 0) {
//             test_scenario::next_tx(&mut scenario, seller());

//             // Create and deposit NFT
//             debug::print(&price);
//             // debug::print(&i);
//             let nft = test_utils::get_foo_nft(ctx(&mut scenario));
//             let nft_id = object::id(&nft);
//             ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

//             orderbook::create_ask(
//                 &mut book,
//                 &mut seller_kiosk,
//                 price,
//                 nft_id,
//                 ctx(&mut scenario),
//             );

//             i = i - 1;
//             price = price + 1;
//         };


//         test_scenario::next_tx(&mut scenario, buyer());

//         // let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
//         // let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

//         // // 6. Create bid for NFT
//         // let coin = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));

//         // let trade_opt = orderbook::create_bid(
//         //     &mut book,
//         //     &mut buyer_kiosk,
//         //     100,
//         //     &mut coin,
//         //     ctx(&mut scenario),
//         // );

//         // let trade = option::destroy_some(trade_opt);

//         // test_scenario::next_tx(&mut scenario, seller());
//         // let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

//         // let request = orderbook::finish_trade(
//         //     &mut book,
//         //     orderbook::trade_id(&trade),
//         //     &mut seller_kiosk,
//         //     &mut buyer_kiosk,
//         //     ctx(&mut scenario),
//         // );

//         // transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

//         // coin::burn_for_testing(coin);
//         transfer::public_transfer(publisher, creator());
//         transfer::public_transfer(mint_cap, creator());
//         transfer::public_transfer(policy_cap, creator());
//         // test_scenario::return_shared(tx_policy);
//         test_scenario::return_shared(seller_kiosk);
//         // test_scenario::return_shared(buyer_kiosk);
//         test_scenario::return_shared(book);
//         test_scenario::end(scenario);
//     }

//     #[test]
//     fun test_bench_orders_in_the_same_level() {
//         let scenario = test_scenario::begin(creator());

//         // 1. Create Collection, TransferPolicy and Orderbook
//         let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
//         let publisher = test_utils::get_publisher(ctx(&mut scenario));
//         let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

//         let dw = witness::test_dw<Foo>();
//         test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

//         transfer::public_share_object(collection);
//         transfer::public_share_object(tx_policy);

//         // 3. Create Buyer Kiosk
//         test_scenario::next_tx(&mut scenario, buyer());
//         let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

//         transfer::public_share_object(buyer_kiosk);

//         // 4. Create Seller Kiosk
//         test_scenario::next_tx(&mut scenario, seller());
//         let (seller_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
//         transfer::public_share_object(seller_kiosk);

//         // 5. Create asks order for NFT
//         test_scenario::next_tx(&mut scenario, seller());
//         let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
//         let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

//         let quantity = 3_000;
//         let i = quantity;
//         let price = 1;
//         let depth = 3_000;

//         let j = 1;
//         while (i > 0) {
//             test_scenario::next_tx(&mut scenario, seller());

//             // Create and deposit NFT
//             let nft = test_utils::get_foo_nft(ctx(&mut scenario));
//             let nft_id = object::id(&nft);
//             ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

//             orderbook::create_ask(
//                 &mut book,
//                 &mut seller_kiosk,
//                 price,
//                 nft_id,
//                 ctx(&mut scenario),
//             );

//             i = i - 1;
//             j = j + 1;
//             debug::print(&j);

//             if (j == depth) {
//                 price = price + 1;
//                 j = 1;
//             };
//         };


//         test_scenario::next_tx(&mut scenario, buyer());

//         // let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
//         // let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

//         // // 6. Create bid for NFT
//         // let coin = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));

//         // let trade_opt = orderbook::create_bid(
//         //     &mut book,
//         //     &mut buyer_kiosk,
//         //     100,
//         //     &mut coin,
//         //     ctx(&mut scenario),
//         // );

//         // let trade = option::destroy_some(trade_opt);

//         // test_scenario::next_tx(&mut scenario, seller());
//         // let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

//         // let request = orderbook::finish_trade(
//         //     &mut book,
//         //     orderbook::trade_id(&trade),
//         //     &mut seller_kiosk,
//         //     &mut buyer_kiosk,
//         //     ctx(&mut scenario),
//         // );

//         // transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

//         // coin::burn_for_testing(coin);
//         transfer::public_transfer(publisher, creator());
//         transfer::public_transfer(mint_cap, creator());
//         transfer::public_transfer(policy_cap, creator());
//         // test_scenario::return_shared(tx_policy);
//         test_scenario::return_shared(seller_kiosk);
//         // test_scenario::return_shared(buyer_kiosk);
//         test_scenario::return_shared(book);
//         test_scenario::end(scenario);
//     }

//     #[test]
//     fun test_bench_max_capacity() {
//         let scenario = test_scenario::begin(creator());

//         // 1. Create Collection, TransferPolicy and Orderbook
//         let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
//         let publisher = test_utils::get_publisher(ctx(&mut scenario));
//         let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

//         let dw = witness::test_dw<Foo>();
//         test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

//         transfer::public_share_object(collection);
//         transfer::public_share_object(tx_policy);

//         // 3. Create Buyer Kiosk
//         test_scenario::next_tx(&mut scenario, buyer());
//         let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

//         transfer::public_share_object(buyer_kiosk);

//         // 4. Create Seller Kiosk
//         test_scenario::next_tx(&mut scenario, seller());
//         let (seller_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
//         transfer::public_share_object(seller_kiosk);

//         // 5. Create asks order for NFT
//         test_scenario::next_tx(&mut scenario, seller());
//         let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
//         let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

//         let quantity = 30_000;
//         let i = quantity;
//         let price = 1;
//         let depth = 1_000;

//         let j = 1;
//         while (i > 0) {
//             test_scenario::next_tx(&mut scenario, seller());

//             // Create and deposit NFT
//             let nft = test_utils::get_foo_nft(ctx(&mut scenario));
//             let nft_id = object::id(&nft);
//             ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

//             orderbook::create_ask(
//                 &mut book,
//                 &mut seller_kiosk,
//                 price,
//                 nft_id,
//                 ctx(&mut scenario),
//             );

//             i = i - 1;
//             j = j + 1;

//             debug::print(&i);
//             if (j == depth) {
//                 price = price + 1;
//                 j = 1;
//             };
//         };


//         test_scenario::next_tx(&mut scenario, buyer());

//         // let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
//         // let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

//         // // 6. Create bid for NFT
//         // let coin = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));

//         // let trade_opt = orderbook::create_bid(
//         //     &mut book,
//         //     &mut buyer_kiosk,
//         //     100,
//         //     &mut coin,
//         //     ctx(&mut scenario),
//         // );

//         // let trade = option::destroy_some(trade_opt);

//         // test_scenario::next_tx(&mut scenario, seller());
//         // let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

//         // let request = orderbook::finish_trade(
//         //     &mut book,
//         //     orderbook::trade_id(&trade),
//         //     &mut seller_kiosk,
//         //     &mut buyer_kiosk,
//         //     ctx(&mut scenario),
//         // );

//         // transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

//         // coin::burn_for_testing(coin);
//         transfer::public_transfer(publisher, creator());
//         transfer::public_transfer(mint_cap, creator());
//         transfer::public_transfer(policy_cap, creator());
//         // test_scenario::return_shared(tx_policy);
//         test_scenario::return_shared(seller_kiosk);
//         // test_scenario::return_shared(buyer_kiosk);
//         test_scenario::return_shared(book);
//         test_scenario::end(scenario);
//     }
// }
