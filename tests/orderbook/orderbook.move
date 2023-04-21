#[test_only]
/// This test focuses on integration between OB, Safe, a allowlist and
/// royalty collection.
///
/// We simulate a trade between two Safes, end to end, including royalty
/// collection.
module nft_protocol::test_ob_kiok_to_kiosk_trade {
    // TODO:
    // fun it_fails_if_buyer_safe_eq_seller_safe()
    // fun it_fails_if_buyer_safe_eq_seller_safe_with_generic_collection()
    // fun it_fails_if_buyer_safe_eq_seller_safe_with_generic_collection() {
    use nft_protocol::ob_kiosk::{Self, OwnerToken};
    use nft_protocol::request::{Policy, WithNft};
    use nft_protocol::ob_transfer_request::{Self, OB_TRANSFER_REQUEST};
    use nft_protocol::orderbook::{Self, Orderbook, TradeIntermediate};
    use nft_protocol::test_utils::{Self, Foo,  seller, buyer, creator};
    // use std::debug;
    // use std::string;
    use sui::coin;
    use sui::transfer_policy::{Self, TransferPolicy};
    use sui::sui::SUI;
    use sui::object;
    use sui::kiosk;
    use sui::kiosk::Kiosk;
    use sui::transfer;
    use sui::test_scenario::{Self, ctx};
    use originmate::typed_id;


    const OFFER_SUI: u64 = 100;

    #[test]
    fun test_trade_in_ob_kiosk() {
        let scenario = test_scenario::begin(creator());

        // 1. Create Collection, TransferPolicy and Orderbook
        let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));
        test_utils::create_orderbook<Foo>(&mut scenario);

        transfer::public_share_object(collection);
        transfer::public_share_object(tx_policy);

        // 3. Create Buyer Kiosk
        test_scenario::next_tx(&mut scenario, buyer());
        let buyer_kiosk = ob_kiosk::new(ctx(&mut scenario));

        transfer::public_share_object(buyer_kiosk);

        // 4. Create Seller Kiosk
        test_scenario::next_tx(&mut scenario, seller());
        let seller_kiosk = ob_kiosk::new(ctx(&mut scenario));

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

        orderbook::create_bid(
            &mut book,
            &mut buyer_kiosk,
            100,
            &mut coin,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, seller());
        let trade = test_scenario::take_shared<TradeIntermediate<Foo, SUI>>(&mut scenario);
        let tx_policy = test_scenario::take_shared<Policy<WithNft<Foo, OB_TRANSFER_REQUEST>>>(&mut scenario);

        let request = orderbook::finish_trade(
            &mut book,
            &mut trade,
            &mut seller_kiosk,
            &mut buyer_kiosk,
            ctx(&mut scenario),
        );

        ob_transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

        coin::burn_for_testing(coin);
        transfer::public_transfer(publisher, creator());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        test_scenario::return_shared(tx_policy);
        test_scenario::return_shared(seller_kiosk);
        test_scenario::return_shared(buyer_kiosk);
        test_scenario::return_shared(trade);
        test_scenario::return_shared(book);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_trade_with_sui_policy() {
        let scenario = test_scenario::begin(creator());

        // 1. Create Collection, TransferPolicy and Orderbook
        let (collection, mint_cap) = test_utils::init_collection_foo(ctx(&mut scenario));
        let publisher = test_utils::get_publisher(ctx(&mut scenario));

        let (tx_policy, policy_cap) = transfer_policy::new<Foo>(&publisher, ctx(&mut scenario));
        test_utils::create_orderbook<Foo>(&mut scenario);

        transfer::public_share_object(collection);
        transfer::public_share_object(tx_policy);

        // 3. Create Buyer Kiosk
        test_scenario::next_tx(&mut scenario, buyer());
        let buyer_kiosk = ob_kiosk::new(ctx(&mut scenario));

        transfer::public_share_object(buyer_kiosk);

        // 4. Create Seller Kiosk
        test_scenario::next_tx(&mut scenario, seller());
        let seller_kiosk = ob_kiosk::new(ctx(&mut scenario));

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

        orderbook::create_bid(
            &mut book,
            &mut buyer_kiosk,
            100,
            &mut coin,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, seller());
        let trade = test_scenario::take_shared<TradeIntermediate<Foo, SUI>>(&mut scenario);
        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

        let request = orderbook::finish_trade(
            &mut book,
            &mut trade,
            &mut seller_kiosk,
            &mut buyer_kiosk,
            ctx(&mut scenario),
        );

        let sui_request = ob_transfer_request::into_sui<Foo>(request, ctx(&mut scenario));
        transfer_policy::confirm_request<Foo>(&tx_policy, sui_request);

        coin::burn_for_testing(coin);
        transfer::public_transfer(publisher, creator());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        test_scenario::return_shared(tx_policy);
        test_scenario::return_shared(seller_kiosk);
        test_scenario::return_shared(buyer_kiosk);
        test_scenario::return_shared(trade);
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
        test_utils::create_orderbook<Foo>(&mut scenario);

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
            100,
            typed_id::to_id(nft_id),
            ctx(&mut scenario),
        );

        transfer::public_share_object(seller_kiosk);
        test_scenario::next_tx(&mut scenario, buyer());

        let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

        // 6. Create bid for NFT
        let coin = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));
        ob_kiosk::install_extension(&mut buyer_kiosk, buyer_cap, ctx(&mut scenario));

        orderbook::create_bid(
            &mut book,
            &mut buyer_kiosk,
            100,
            &mut coin,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, seller());
        let trade = test_scenario::take_shared<TradeIntermediate<Foo, SUI>>(&mut scenario);
        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

        let request = orderbook::finish_trade(
            &mut book,
            &mut trade,
            &mut seller_kiosk,
            &mut buyer_kiosk,
            ctx(&mut scenario),
        );

        let sui_request = ob_transfer_request::into_sui<Foo>(request, ctx(&mut scenario));
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
        test_scenario::return_shared(trade);
        test_scenario::return_shared(book);
        test_scenario::end(scenario);
    }
}
