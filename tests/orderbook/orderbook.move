// #[test_only]
// /// This test focuses on integration between OB, Safe, a allowlist and
// /// royalty collection.
// ///
// /// We simulate a trade between two Safes, end to end, including royalty
// /// collection.
// module nft_protocol::test_ob_kiok_to_kiosk_trade {
//     use std::option;

//     // TODO:
//     // fun it_fails_if_buyer_safe_eq_seller_safe()
//     // fun it_fails_if_buyer_safe_eq_seller_safe_with_generic_collection()
//     // fun it_fails_if_buyer_safe_eq_seller_safe_with_generic_collection() {
//     use nft_protocol::transfer_allowlist;
//     use nft_protocol::orderbook::{Self, Orderbook};
//     use nft_protocol::test_utils::{Self, Foo,  seller, buyer, creator, marketplace};
//     use nft_protocol::royalty_strategy_bps::{Self, BpsRoyaltyStrategy};

//     use sui::coin;
//     use sui::transfer_policy::{Self, TransferPolicy};
//     use sui::sui::SUI;
//     use sui::object;
//     use sui::kiosk;
//     use sui::kiosk::Kiosk;
//     use sui::transfer;
//     use sui::test_scenario::{Self, ctx};

//     use witness::witness;
//     use originmate::typed_id;
//     use allowlist::allowlist::{Self, Allowlist};
//     use request::ob_kiosk::{Self, OwnerToken};
//     use request::ob_transfer_request;

//     const OFFER_SUI: u64 = 100;

//     #[test]
//     fun test_trade_in_ob_kiosk() {
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
//         let buyer_kiosk = ob_kiosk::new(ctx(&mut scenario));

//         transfer::public_share_object(buyer_kiosk);

//         // 4. Create Seller Kiosk
//         test_scenario::next_tx(&mut scenario, seller());
//         let seller_kiosk = ob_kiosk::new(ctx(&mut scenario));

//         // 4. Add NFT to Seller Kiosk
//         let nft = test_utils::get_foo_nft(ctx(&mut scenario));
//         let nft_id = object::id(&nft);
//         ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

//         // 5. Create ask order for NFT
//         let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
//         orderbook::create_ask(
//             &mut book,
//             &mut seller_kiosk,
//             100,
//             nft_id,
//             ctx(&mut scenario),
//         );

//         transfer::public_share_object(seller_kiosk);
//         test_scenario::next_tx(&mut scenario, buyer());

//         let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
//         let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

//         // 6. Create bid for NFT
//         let coin = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));

//         let trade_opt = orderbook::create_bid(
//             &mut book,
//             &mut buyer_kiosk,
//             100,
//             &mut coin,
//             ctx(&mut scenario),
//         );

//         let trade = option::destroy_some(trade_opt);

//         test_scenario::next_tx(&mut scenario, seller());
//         let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

//         let request = orderbook::finish_trade(
//             &mut book,
//             orderbook::trade_id(&trade),
//             &mut seller_kiosk,
//             &mut buyer_kiosk,
//             ctx(&mut scenario),
//         );

//         ob_transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

//         coin::burn_for_testing(coin);
//         transfer::public_transfer(publisher, creator());
//         transfer::public_transfer(mint_cap, creator());
//         transfer::public_transfer(policy_cap, creator());
//         test_scenario::return_shared(tx_policy);
//         test_scenario::return_shared(seller_kiosk);
//         test_scenario::return_shared(buyer_kiosk);
//         test_scenario::return_shared(book);
//         test_scenario::end(scenario);
//     }

//     #[test]
//     fun test_trade_in_ob_kiosk_full_royalty_enforcement() {
//         let scenario = test_scenario::begin(creator());

//         // 1. Create Collection and Orderbook
//         let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
//         let publisher = test_utils::get_publisher(ctx(&mut scenario));

//         // 2. Add Royalty Policy and Allowlist
//         royalty_strategy_bps::create_domain_and_add_strategy<Foo>(
//             witness::from_witness(test_utils::witness()), &mut collection, 100, ctx(&mut scenario),
//         );

//         // Get allowlist. This can be any allowlist created by anyone but we create
//         // one here for the purpose of the test
//         let (al, al_cap) = test_utils::create_allowlist(&mut scenario);

//         allowlist::insert_collection<Foo>(&mut al, &publisher);

//         // 3. Create TransferPolocy, add Royalty and Allowlist step in it
//         let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

//         transfer_allowlist::enforce(&mut tx_policy, &policy_cap);
//         royalty_strategy_bps::enforce(&mut tx_policy, &policy_cap);

//         let dw = witness::test_dw<Foo>();
//         test_utils::create_orderbook<Foo>(dw, &tx_policy, &mut scenario);

//         transfer::public_transfer(al_cap, marketplace());
//         transfer::public_share_object(al);
//         transfer::public_share_object(collection);
//         transfer::public_share_object(tx_policy);

//         // 3. Create Buyer Kiosk
//         test_scenario::next_tx(&mut scenario, buyer());
//         let buyer_kiosk = ob_kiosk::new(ctx(&mut scenario));

//         transfer::public_share_object(buyer_kiosk);

//         // 4. Create Seller Kiosk
//         test_scenario::next_tx(&mut scenario, seller());
//         let seller_kiosk = ob_kiosk::new(ctx(&mut scenario));

//         // 4. Add NFT to Seller Kiosk
//         let nft = test_utils::get_foo_nft(ctx(&mut scenario));
//         let nft_id = object::id(&nft);
//         ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

//         // 5. Create ask order for NFT
//         let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
//         orderbook::create_ask(
//             &mut book,
//             &mut seller_kiosk,
//             100,
//             nft_id,
//             ctx(&mut scenario),
//         );

//         transfer::public_share_object(seller_kiosk);
//         test_scenario::next_tx(&mut scenario, buyer());

//         let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
//         let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

//         // 6. Create bid for NFT
//         let coin = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));

//         let trade_opt = orderbook::create_bid(
//             &mut book,
//             &mut buyer_kiosk,
//             100,
//             &mut coin,
//             ctx(&mut scenario),
//         );

//         let trade = option::destroy_some(trade_opt);

//         test_scenario::next_tx(&mut scenario, seller());
//         let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

//         let request = orderbook::finish_trade(
//             &mut book,
//             orderbook::trade_id(&trade),
//             &mut seller_kiosk,
//             &mut buyer_kiosk,
//             ctx(&mut scenario),
//         );

//         // 7. Verify action on allowlist
//         let al = test_scenario::take_shared<Allowlist>(&mut scenario);
//         transfer_allowlist::confirm_transfer(&al, &mut request);

//         // 8. Pay royalties
//         let royalty_engine = test_scenario::take_shared<BpsRoyaltyStrategy<Foo>>(&mut scenario);
//         royalty_strategy_bps::confirm_transfer<Foo, SUI>(&mut royalty_engine, &mut request);

//         ob_transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

//         coin::burn_for_testing(coin);
//         transfer::public_transfer(publisher, creator());
//         transfer::public_transfer(mint_cap, creator());
//         transfer::public_transfer(policy_cap, creator());
//         test_scenario::return_shared(tx_policy);
//         test_scenario::return_shared(seller_kiosk);
//         test_scenario::return_shared(buyer_kiosk);
//         test_scenario::return_shared(book);
//         test_scenario::return_shared(al);
//         test_scenario::return_shared(royalty_engine);
//         test_scenario::end(scenario);
//     }

//     #[test]
//     fun test_trade_with_sui_policy() {
//         let scenario = test_scenario::begin(creator());

//         // 1. Create Collection, TransferPolicy and Orderbook
//         let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
//         let publisher = test_utils::get_publisher(ctx(&mut scenario));

//         let (tx_policy, policy_cap) = transfer_policy::new<Foo>(&publisher, ctx(&mut scenario));
//         test_utils::create_external_orderbook<Foo>(&tx_policy, &mut scenario);

//         transfer::public_share_object(collection);
//         transfer::public_share_object(tx_policy);

//         // 3. Create Buyer Kiosk
//         test_scenario::next_tx(&mut scenario, buyer());
//         let buyer_kiosk = ob_kiosk::new(ctx(&mut scenario));

//         transfer::public_share_object(buyer_kiosk);

//         // 4. Create Seller Kiosk
//         test_scenario::next_tx(&mut scenario, seller());
//         let seller_kiosk = ob_kiosk::new(ctx(&mut scenario));

//         // 4. Add NFT to Seller Kiosk
//         let nft = test_utils::get_foo_nft(ctx(&mut scenario));
//         let nft_id = object::id(&nft);
//         ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

//         // 5. Create ask order for NFT
//         let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
//         orderbook::create_ask(
//             &mut book,
//             &mut seller_kiosk,
//             100,
//             nft_id,
//             ctx(&mut scenario),
//         );

//         transfer::public_share_object(seller_kiosk);
//         test_scenario::next_tx(&mut scenario, buyer());

//         let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
//         let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

//         // 6. Create bid for NFT
//         let coin = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));

//         let trade_opt = orderbook::create_bid(
//             &mut book,
//             &mut buyer_kiosk,
//             100,
//             &mut coin,
//             ctx(&mut scenario),
//         );

//         let trade = option::destroy_some(trade_opt);

//         test_scenario::next_tx(&mut scenario, seller());
//         let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

//         let request = orderbook::finish_trade(
//             &mut book,
//             orderbook::trade_id(&trade),
//             &mut seller_kiosk,
//             &mut buyer_kiosk,
//             ctx(&mut scenario),
//         );

//         let sui_request = ob_transfer_request::into_sui<Foo>(request, &tx_policy, ctx(&mut scenario));
//         transfer_policy::confirm_request<Foo>(&tx_policy, sui_request);

//         coin::burn_for_testing(coin);
//         transfer::public_transfer(publisher, creator());
//         transfer::public_transfer(mint_cap, creator());
//         transfer::public_transfer(policy_cap, creator());
//         test_scenario::return_shared(tx_policy);
//         test_scenario::return_shared(seller_kiosk);
//         test_scenario::return_shared(buyer_kiosk);
//         test_scenario::return_shared(book);
//         test_scenario::end(scenario);
//     }

//     #[test]
//     fun test_trade_from_sui_kiosk() {
//         let scenario = test_scenario::begin(creator());

//         // 1. Create Collection, TransferPolicy and Orderbook
//         let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
//         let publisher = test_utils::get_publisher(ctx(&mut scenario));

//         let (tx_policy, policy_cap) = transfer_policy::new<Foo>(&publisher, ctx(&mut scenario));
//         test_utils::create_external_orderbook<Foo>(&tx_policy, &mut scenario);

//         transfer::public_share_object(collection);
//         transfer::public_share_object(tx_policy);

//         // 3. Create Buyer Kiosk
//         test_scenario::next_tx(&mut scenario, buyer());
//         let (buyer_kiosk, buyer_cap) = kiosk::new(ctx(&mut scenario));

//         transfer::public_share_object(buyer_kiosk);

//         // 4. Create Seller Kiosk
//         test_scenario::next_tx(&mut scenario, seller());
//         let (seller_kiosk, seller_cap) = kiosk::new(ctx(&mut scenario));

//         // 4. Add NFT to Seller Kiosk
//         let nft = test_utils::get_foo_nft(ctx(&mut scenario));
//         let nft_id = typed_id::new(&nft);
//         kiosk::place(&mut seller_kiosk, &seller_cap, nft);

//         // 5. Create ask order for NFT
//         ob_kiosk::install_extension(&mut seller_kiosk, seller_cap, ctx(&mut scenario));
//         ob_kiosk::register_nft(&mut seller_kiosk, nft_id, ctx(&mut scenario));

//         let book = test_scenario::take_shared<Orderbook<Foo, SUI>>(&mut scenario);
//         orderbook::create_ask(
//             &mut book,
//             &mut seller_kiosk,
//             100,
//             typed_id::to_id(nft_id),
//             ctx(&mut scenario),
//         );

//         transfer::public_share_object(seller_kiosk);
//         test_scenario::next_tx(&mut scenario, buyer());

//         let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
//         let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

//         // 6. Create bid for NFT
//         let coin = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));
//         ob_kiosk::install_extension(&mut buyer_kiosk, buyer_cap, ctx(&mut scenario));

//         let trade_opt = orderbook::create_bid(
//             &mut book,
//             &mut buyer_kiosk,
//             100,
//             &mut coin,
//             ctx(&mut scenario),
//         );

//         let trade = option::destroy_some(trade_opt);

//         test_scenario::next_tx(&mut scenario, seller());
//         let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

//         let request = orderbook::finish_trade(
//             &mut book,
//             orderbook::trade_id(&trade),
//             &mut seller_kiosk,
//             &mut buyer_kiosk,
//             ctx(&mut scenario),
//         );

//         let sui_request = ob_transfer_request::into_sui<Foo>(request, &tx_policy, ctx(&mut scenario));
//         transfer_policy::confirm_request<Foo>(&tx_policy, sui_request);

//         // 7. Leave OriginByte
//         let seller_token = test_scenario::take_from_address<OwnerToken>(
//             &scenario, seller()
//         );

//         test_scenario::next_tx(&mut scenario, seller());
//         ob_kiosk::uninstall_extension(&mut seller_kiosk, seller_token, ctx(&mut scenario));

//         coin::burn_for_testing(coin);
//         transfer::public_transfer(publisher, buyer());
//         transfer::public_transfer(mint_cap, creator());
//         transfer::public_transfer(policy_cap, creator());
//         test_scenario::return_shared(tx_policy);
//         test_scenario::return_shared(seller_kiosk);
//         test_scenario::return_shared(buyer_kiosk);
//         test_scenario::return_shared(book);
//         test_scenario::end(scenario);
//     }
// }
