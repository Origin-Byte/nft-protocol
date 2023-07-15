#[test_only]
/// Tests trading compatibility with locked NFTs
module liquidity_layer_v1::test_orderbook_locked {
    use std::option;

    use sui::package;
    use sui::coin;
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::sui::SUI;
    use sui::kiosk::{Self, Kiosk};
    use sui::test_scenario::{Self, Scenario, ctx};
    use sui::transfer_policy::TransferPolicy;

    use ob_permissions::witness;
    use ob_kiosk::ob_kiosk;

    use liquidity_layer_v1::orderbook::{Self, TradeInfo, Orderbook};

    const CREATOR: address = @0xA1C03;
    const BUYER: address = @0xA1C04;
    const SELLER: address = @0xA1C05;

    struct Foo has key, store {
        id: UID
    }

    struct Witness has drop {}
    struct TEST_ORDERBOOK_LOCKED has drop {}

    #[test_only]
    /// Initializes `Orderbook` and `TransferPolicy`
    fun init_ob(scenario: &mut Scenario) {
        let publisher = package::test_claim<TEST_ORDERBOOK_LOCKED>(TEST_ORDERBOOK_LOCKED {}, ctx(scenario));
        let (tx_policy, policy_cap) = ob_request::transfer_request::init_policy<Foo>(&publisher, ctx(scenario));

        let delegated_witness = witness::from_witness(Witness {});

        let ob = orderbook::new_unprotected<Foo, SUI>(delegated_witness, &tx_policy, ctx(scenario));
        orderbook::share(ob);

        transfer::public_share_object(tx_policy);
        transfer::public_transfer(publisher, CREATOR);
        transfer::public_transfer(policy_cap, CREATOR);

        test_scenario::next_tx(scenario, CREATOR);
    }

    #[test_only]
    /// Initializes non-OB `Orderbook` and `TransferPolicy`
    fun init_non_ob(scenario: &mut Scenario) {
        let publisher = package::test_claim<TEST_ORDERBOOK_LOCKED>(TEST_ORDERBOOK_LOCKED {}, ctx(scenario));
        let (tx_policy, policy_cap) = sui::transfer_policy::new<Foo>(&publisher, ctx(scenario));

        orderbook::create_for_external<Foo, SUI>(&tx_policy, ctx(scenario));

        transfer::public_share_object(tx_policy);
        transfer::public_transfer(publisher, CREATOR);
        transfer::public_transfer(policy_cap, CREATOR);

        test_scenario::next_tx(scenario, CREATOR);
    }

    #[test_only]
    /// Generates a trade on the `Orderbook` that has to be finished
    fun init_trade(
        orderbook: &mut Orderbook<Foo, SUI>,
        seller_kiosk: &mut Kiosk,
        buyer_kiosk: &mut Kiosk,
        nft_id: ID,
        scenario: &mut Scenario,
    ): TradeInfo {
        test_scenario::next_tx(scenario, SELLER);

        orderbook::create_ask(
            orderbook,
            seller_kiosk,
            1_000_000,
            nft_id,
            ctx(scenario),
        );

        test_scenario::next_tx(scenario, BUYER);

        let coin = coin::mint_for_testing<SUI>(1_000_000, ctx(scenario));
        let trade_opt = orderbook::create_bid(
            orderbook,
            buyer_kiosk,
            1_000_000,
            &mut coin,
            ctx(scenario),
        );
        let trade = option::destroy_some(trade_opt);
        coin::burn_for_testing(coin);

        test_scenario::next_tx(scenario, CREATOR);

        trade
    }

    fun init_kiosk_for_address(for: address, scenario: &mut Scenario): Kiosk {
        test_scenario::next_tx(scenario, for);
        let (buyer_kiosk, buyer_kiosk_cap) = kiosk::new(ctx(scenario));
        transfer::public_transfer(buyer_kiosk_cap, for);

        test_scenario::next_tx(scenario, CREATOR);

        buyer_kiosk
    }

    #[test]
    fun test_transfer_locked_to_unlocked() {
        let scenario = test_scenario::begin(CREATOR);

        // 1. Create prerequisites
        init_ob(&mut scenario);
        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);
        let orderbook = test_scenario::take_shared<Orderbook<Foo, SUI>>(&scenario);
        let (buyer_kiosk, _) = ob_kiosk::new_for_address(BUYER, ctx(&mut scenario));
        let (seller_kiosk, _) = ob_kiosk::new_for_address(SELLER, ctx(&mut scenario));

        // 2. Add NFT to seller kiosk
        let nft = Foo { id: object::new(ctx(&mut scenario)) };
        let nft_id = object::id(&nft);
        ob_kiosk::deposit_locked(&mut seller_kiosk, &tx_policy, nft, ctx(&mut scenario));

        // 3. Perform trade on NFT and finish
        let trade = init_trade(&mut orderbook, &mut seller_kiosk, &mut buyer_kiosk, nft_id, &mut scenario);

        let request = orderbook::finish_trade(
            &mut orderbook,
            orderbook::trade_id(&trade),
            &mut seller_kiosk,
            &mut buyer_kiosk,
            ctx(&mut scenario),
        );
        ob_request::transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));
        test_scenario::return_shared(tx_policy);

        // 4. Verify unlocked
        assert!(!kiosk::is_locked(&buyer_kiosk, nft_id), 0);

        transfer::public_transfer(seller_kiosk, CREATOR);
        transfer::public_transfer(buyer_kiosk, CREATOR);
        test_scenario::return_shared(orderbook);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_locked_to_unlocked_non_ob_buyer() {
        let scenario = test_scenario::begin(CREATOR);

        // 1. Create prerequisites
        init_non_ob(&mut scenario);
        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);
        let orderbook = test_scenario::take_shared<Orderbook<Foo, SUI>>(&scenario);
        let buyer_kiosk = init_kiosk_for_address(BUYER, &mut scenario);
        let (seller_kiosk, _) = ob_kiosk::new_for_address(SELLER, ctx(&mut scenario));

        // 2. Add NFT to seller kiosk
        let nft = Foo { id: object::new(ctx(&mut scenario)) };
        let nft_id = object::id(&nft);
        ob_kiosk::deposit_locked(&mut seller_kiosk, &tx_policy, nft, ctx(&mut scenario));

        // 3. Perform trade on NFT and finish
        let trade = init_trade(&mut orderbook, &mut seller_kiosk, &mut buyer_kiosk, nft_id, &mut scenario);

        let request = orderbook::finish_trade(
            &mut orderbook,
            orderbook::trade_id(&trade),
            &mut seller_kiosk,
            &mut buyer_kiosk,
            ctx(&mut scenario),
        );
        ob_request::transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));
        test_scenario::return_shared(tx_policy);

        // 4. Verify unlocked
        assert!(!kiosk::is_locked(&buyer_kiosk, nft_id), 0);

        transfer::public_transfer(seller_kiosk, CREATOR);
        transfer::public_transfer(buyer_kiosk, CREATOR);
        test_scenario::return_shared(orderbook);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_locked_to_locked() {
        let scenario = test_scenario::begin(CREATOR);

        // 1. Create prerequisites
        init_ob(&mut scenario);
        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);
        let orderbook = test_scenario::take_shared<Orderbook<Foo, SUI>>(&scenario);
        let (buyer_kiosk, _) = ob_kiosk::new_for_address(BUYER, ctx(&mut scenario));
        let (seller_kiosk, _) = ob_kiosk::new_for_address(SELLER, ctx(&mut scenario));

        // 2. Add NFT to seller kiosk
        let nft = Foo { id: object::new(ctx(&mut scenario)) };
        let nft_id = object::id(&nft);
        ob_kiosk::deposit_locked(&mut seller_kiosk, &tx_policy, nft, ctx(&mut scenario));

        // 3. Perform trade on NFT and finish
        let trade = init_trade(&mut orderbook, &mut seller_kiosk, &mut buyer_kiosk, nft_id, &mut scenario);

        let request = orderbook::finish_trade_locked(
            &mut orderbook,
            orderbook::trade_id(&trade),
            &mut seller_kiosk,
            &mut buyer_kiosk,
            &tx_policy,
            ctx(&mut scenario),
        );
        ob_request::transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));
        test_scenario::return_shared(tx_policy);

        // 4. Verify locked
        assert!(kiosk::is_locked(&buyer_kiosk, nft_id), 0);

        transfer::public_transfer(seller_kiosk, CREATOR);
        transfer::public_transfer(buyer_kiosk, CREATOR);
        test_scenario::return_shared(orderbook);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_locked_to_locked_non_ob_buyer() {}

    #[test]
    fun test_transfer_unlocked_to_locked() {
        let scenario = test_scenario::begin(CREATOR);

        // 1. Create prerequisites
        init_ob(&mut scenario);
        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);
        let orderbook = test_scenario::take_shared<Orderbook<Foo, SUI>>(&scenario);
        let (buyer_kiosk, _) = ob_kiosk::new_for_address(BUYER, ctx(&mut scenario));
        let (seller_kiosk, _) = ob_kiosk::new_for_address(SELLER, ctx(&mut scenario));

        // 2. Add NFT to seller kiosk
        let nft = Foo { id: object::new(ctx(&mut scenario)) };
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

        // 3. Perform trade on NFT and finish
        let trade = init_trade(&mut orderbook, &mut seller_kiosk, &mut buyer_kiosk, nft_id, &mut scenario);

        let request = orderbook::finish_trade_locked(
            &mut orderbook,
            orderbook::trade_id(&trade),
            &mut seller_kiosk,
            &mut buyer_kiosk,
            &tx_policy,
            ctx(&mut scenario),
        );
        ob_request::transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));
        test_scenario::return_shared(tx_policy);

        // 4. Verify locked
        assert!(kiosk::is_locked(&buyer_kiosk, nft_id), 0);

        transfer::public_transfer(seller_kiosk, CREATOR);
        transfer::public_transfer(buyer_kiosk, CREATOR);
        test_scenario::return_shared(orderbook);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_unlocked_to_locked_non_ob_buyer() {}

    #[test]
    fun test_transfer_locked_to_inherit() {
        let scenario = test_scenario::begin(CREATOR);

        // 1. Create prerequisites
        init_ob(&mut scenario);
        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);
        let orderbook = test_scenario::take_shared<Orderbook<Foo, SUI>>(&scenario);
        let (buyer_kiosk, _) = ob_kiosk::new_for_address(BUYER, ctx(&mut scenario));
        let (seller_kiosk, _) = ob_kiosk::new_for_address(SELLER, ctx(&mut scenario));

        // 2. Add NFT to seller kiosk
        let nft = Foo { id: object::new(ctx(&mut scenario)) };
        let nft_id = object::id(&nft);
        ob_kiosk::deposit_locked(&mut seller_kiosk, &tx_policy, nft, ctx(&mut scenario));

        // 3. Perform trade on NFT and finish
        let trade = init_trade(&mut orderbook, &mut seller_kiosk, &mut buyer_kiosk, nft_id, &mut scenario);

        let request = orderbook::finish_trade_inherit(
            &mut orderbook,
            orderbook::trade_id(&trade),
            &mut seller_kiosk,
            &mut buyer_kiosk,
            &tx_policy,
            ctx(&mut scenario),
        );
        ob_request::transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));
        test_scenario::return_shared(tx_policy);

        // 4. Verify locked
        assert!(kiosk::is_locked(&buyer_kiosk, nft_id), 0);

        transfer::public_transfer(seller_kiosk, CREATOR);
        transfer::public_transfer(buyer_kiosk, CREATOR);
        test_scenario::return_shared(orderbook);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_locked_to_inherit_non_ob_buyer() {}

    #[test]
    fun test_transfer_unlocked_to_inherit() {
        let scenario = test_scenario::begin(CREATOR);

        // 1. Create prerequisites
        init_ob(&mut scenario);
        let tx_policy = test_scenario::take_shared<TransferPolicy<Foo>>(&mut scenario);
        let orderbook = test_scenario::take_shared<Orderbook<Foo, SUI>>(&scenario);
        let (buyer_kiosk, _) = ob_kiosk::new_for_address(BUYER, ctx(&mut scenario));
        let (seller_kiosk, _) = ob_kiosk::new_for_address(SELLER, ctx(&mut scenario));

        // 2. Add NFT to seller kiosk
        let nft = Foo { id: object::new(ctx(&mut scenario)) };
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut seller_kiosk, nft, ctx(&mut scenario));

        // 3. Perform trade on NFT and finish
        let trade = init_trade(&mut orderbook, &mut seller_kiosk, &mut buyer_kiosk, nft_id, &mut scenario);

        let request = orderbook::finish_trade_inherit(
            &mut orderbook,
            orderbook::trade_id(&trade),
            &mut seller_kiosk,
            &mut buyer_kiosk,
            &tx_policy,
            ctx(&mut scenario),
        );
        ob_request::transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));
        test_scenario::return_shared(tx_policy);

        // 4. Verify unlocked
        assert!(!kiosk::is_locked(&buyer_kiosk, nft_id), 0);

        transfer::public_transfer(seller_kiosk, CREATOR);
        transfer::public_transfer(buyer_kiosk, CREATOR);
        test_scenario::return_shared(orderbook);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_unlocked_to_inherit_non_ob_buyer() {}

    #[test]
    fun test_request_payment() {}
}