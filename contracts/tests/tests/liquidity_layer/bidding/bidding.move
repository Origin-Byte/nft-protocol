#[test_only]
/// This test focuses on integration between bidding contract, Kiosk,
/// a allowlist and royalty collection.
///
/// We simulate a trade between two Safes, end to end.
///
/// In this test, we use a generic collection, which means that the NFT is not
/// wrapped in our protocol's [`nft::Nft`] type.
module ob_tests::test_bidding_safe_to_safe_generic_trade {
    use sui::coin;
    use sui::kiosk::Kiosk;
    use sui::transfer_policy::TransferPolicy;
    use sui::object::{Self};
    use sui::sui::SUI;
    use sui::test_scenario::{Self, ctx};
    use liquidity_layer::bidding::{Self, Bid};
    use ob_kiosk::ob_kiosk::{Self};
    use sui::transfer;
    use ob_tests::test_utils::{Self, Foo,  seller, buyer, creator, fake_address};
    use ob_permissions::witness;
    use ob_request::transfer_request;

    const OFFER_SUI: u64 = 100;

    struct Witness has drop {} // collection witness, must be named witness

    #[test]
    fun test_successfull_bid() {
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

        transfer::public_share_object(seller_kiosk);

        // 5. Create bid for NFT
        test_scenario::next_tx(&mut scenario, buyer());

        let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

        let coins = coin::mint_for_testing<SUI>(OFFER_SUI, ctx(&mut scenario));

        bidding::create_bid(
            object::id(&buyer_kiosk),
            nft_id,
            OFFER_SUI,
            &mut coins,
            ctx(&mut scenario),
        );


        // 6. Accept Bid for NFT
        test_scenario::next_tx(&mut scenario, seller());

        let bid = test_scenario::take_shared<Bid<SUI>>(&mut scenario);
        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

        let request = bidding::sell_nft_from_kiosk(
            &mut bid,
            &mut seller_kiosk,
            &mut buyer_kiosk,
            nft_id,
            ctx(&mut scenario),
        );

        transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

        coin::burn_for_testing(coins);
        transfer::public_transfer(publisher, creator());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        test_scenario::return_shared(tx_policy);
        test_scenario::return_shared(seller_kiosk);
        test_scenario::return_shared(buyer_kiosk);
        test_scenario::return_shared(bid);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_kiosk::ob_kiosk::ENotAuthorized)]
    fun fail_accept_bid_if_not_seller() {
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

        transfer::public_share_object(seller_kiosk);

        // 5. Create bid for NFT
        test_scenario::next_tx(&mut scenario, buyer());

        let seller_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);
        let buyer_kiosk = test_scenario::take_shared<Kiosk>(&mut scenario);

        let coins = coin::mint_for_testing<SUI>(OFFER_SUI, ctx(&mut scenario));

        bidding::create_bid(
            object::id(&buyer_kiosk),
            nft_id,
            OFFER_SUI,
            &mut coins,
            ctx(&mut scenario),
        );


        // 6. Accept Bid for NFT
        test_scenario::next_tx(&mut scenario, fake_address());

        let bid = test_scenario::take_shared<Bid<SUI>>(&mut scenario);
        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);

        let request = bidding::sell_nft_from_kiosk(
            &mut bid,
            &mut seller_kiosk,
            &mut buyer_kiosk,
            nft_id,
            ctx(&mut scenario),
        );

        transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

        coin::burn_for_testing(coins);
        transfer::public_transfer(publisher, creator());
        transfer::public_transfer(mint_cap, creator());
        transfer::public_transfer(policy_cap, creator());
        test_scenario::return_shared(tx_policy);
        test_scenario::return_shared(seller_kiosk);
        test_scenario::return_shared(buyer_kiosk);
        test_scenario::return_shared(bid);
        test_scenario::end(scenario);
    }

}
