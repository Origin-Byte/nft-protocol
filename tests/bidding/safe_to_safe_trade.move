#[test_only]
module nft_protocol::test_bidding_safe_to_safe_trade {
    //! This test focuses on integration between bidding contract, Safe,
    //! a whitelist and royalty collection.
    //!
    //! We simulate a trade between two Safes, end to end, including royalty
    //! collection.

    use nft_protocol::bidding;
    use nft_protocol::collection::Collection;
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::royalty;
    // use nft_protocol::safe::{Self, Safe};
    use nft_protocol::safe::{Self, Safe, OwnerCap};
    use nft_protocol::transfer_whitelist::{Whitelist};
    use sui::sui::SUI;
    use sui::coin;
    use sui::balance;
    use std::vector;
    use sui::tx_context::TxContext;
    use sui::object::ID;
    use sui::test_scenario::{Self, Scenario, ctx};
    use sui::transfer::transfer;
    use nft_protocol::test_utils_2::{create_collection_and_whitelist};
    use nft_protocol::test_ob_utils::{Self as test_ob};

    const BUYER: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;
    const SELLER: address = @0xA1C04;

    const OFFER_SUI: u64 = 100;

    struct Foo has drop {} // collection
    struct Witness has drop {} // collection witness, must be named witness
    struct WhitelistWitness has drop {}

    #[test]
    fun it_works() {
        let scenario = test_scenario::begin(CREATOR);

        create_collection_and_whitelist(
            Foo {},
            Witness {},
            &mut scenario,
        );

        test_scenario::next_tx(&mut scenario, SELLER);

        let (seller_safe_id, seller_owner_cap_id) = test_ob::create_safe(
            &mut scenario, SELLER
        );

        let nft_id = test_ob::create_and_deposit_nft(
            &mut scenario,
            SELLER,
        );

        test_scenario::next_tx(&mut scenario, SELLER);

        let seller_safe = test_scenario::take_shared_by_id<Safe>(
            &mut scenario,
            seller_safe_id,
        );

        assert!(safe::has_nft<Foo>(nft_id, &seller_safe), 2);

        let seller_owner_cap = test_scenario::take_from_address_by_id<OwnerCap>(
            &mut scenario,
            SELLER,
            seller_owner_cap_id,
        );

        test_scenario::next_tx(&mut scenario, SELLER);

        let transfer_cap = safe::create_transfer_cap(
            nft_id,
            &seller_owner_cap,
            &mut seller_safe,
            ctx(&mut scenario),
        );

        test_scenario::return_shared(seller_safe);
        test_scenario::next_tx(&mut scenario, BUYER);

        let (buyer_safe_id, _buyer_owner_cap_id) = test_ob::create_safe(&mut scenario, BUYER);

        bid_for_nft(&mut scenario, safe::transfer_cap_nft(&transfer_cap));

        test_scenario::next_tx(&mut scenario, SELLER);

        sell_nft(
            &mut scenario,
            transfer_cap,
            seller_safe_id,
            buyer_safe_id,
        );

        // safe::burn_transfer_cap(transfer_cap, &mut safe);
        test_scenario::return_to_address(SELLER, seller_owner_cap);

        test_scenario::end(scenario);
    }

    // #[test]
    // fun it_works_with_royalties() {
    //     let scenario = test_scenario::begin(CREATOR);

    //     let (col_id, _, _) = create_collection_and_whitelist(
    //         Foo {},
    //         Witness {},
    //         &mut scenario,
    //     );

    //     test_scenario::next_tx(&mut scenario, SELLER);

    //     let (safe_id, owner_cap_id) = test_ob::create_safe(&mut scenario, SELLER);

    //     let nft_id = test_ob::create_and_deposit_nft(
    //         &mut scenario,
    //         SELLER,
    //     );

    //     test_scenario::next_tx(&mut scenario, SELLER);

    //     let safe = test_scenario::take_shared_by_id<Safe>(
    //         &mut scenario,
    //         safe_id,
    //     );

    //     let owner_cap = test_scenario::take_from_address_by_id<OwnerCap>(
    //         &mut scenario,
    //         SELLER,
    //         owner_cap_id,
    //     );

    //     let transfer_cap = safe::create_transfer_cap(
    //         nft_id,
    //         &owner_cap,
    //         &mut safe,
    //         ctx(&mut scenario),
    //     );

    //     bid_for_nft(&mut scenario, safe::transfer_cap_nft(&transfer_cap));

    //     sell_nft(&mut scenario, transfer_cap);

    //     test_scenario::next_tx(&mut scenario, SELLER);

    //     let trade_payment = test_scenario::take_shared<TradePayment<Foo, SUI>>(&mut scenario);

    //     let collection = test_scenario::take_shared_by_id<Collection<Foo>>(
    //         &mut scenario,
    //         col_id,
    //     );

    //     collect_proportional_royalty<Foo, SUI>(
    //         &mut trade_payment,
    //         &mut collection,
    //         ctx(&mut scenario),
    //     );

    //     test_scenario::return_shared(safe);
    //     test_scenario::return_shared(collection);
    //     test_scenario::return_to_address(SELLER, owner_cap);
    //     test_scenario::return_to_address(SELLER, trade_payment);

    //     test_scenario::end(scenario);
    // }

    public entry fun collect_proportional_royalty<C, FT>(
        payment: &mut TradePayment<C, FT>,
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ) {
        let b = royalties::balance_mut(Witness {}, payment);

        let domain = royalty::royalty_domain(collection);
        let royalty_owed =
            royalty::calculate_proportional_royalty(domain, balance::value(b));

        royalty::collect_royalty(collection, b, royalty_owed);
        royalties::transfer_remaining_to_beneficiary(Witness {}, payment, ctx);
    }

    fun bid_for_nft(scenario: &mut Scenario, nft_id: ID) {
        let buyer_owner_cap = safe::create_safe(ctx(scenario));

        test_scenario::next_tx(scenario, BUYER);

        let wallet = coin::mint_for_testing(OFFER_SUI, ctx(scenario));

        bidding::create_bid<SUI>(
            nft_id,
            safe::owner_cap_safe(&buyer_owner_cap),
            OFFER_SUI,
            &mut wallet,
            ctx(scenario),
        );

        coin::destroy_zero(wallet);
        transfer(buyer_owner_cap, BUYER);
    }

    fun sell_nft(
        scenario: &mut Scenario,
        transfer_cap: safe::TransferCap,
        seller_safe_id: ID,
        buyer_safe_id: ID,
    ) {
        let nft_id = safe::transfer_cap_nft(&transfer_cap);

        test_scenario::next_tx(scenario, SELLER);

        let bid: bidding::Bid<SUI> = test_scenario::take_shared(scenario);

        let seller_safe: Safe = test_scenario::take_shared_by_id(
            scenario,
            seller_safe_id,
        );

        let buyer_safe: Safe = test_scenario::take_shared_by_id(
            scenario,
            buyer_safe_id,
        );

        let wl: Whitelist = test_scenario::take_shared(scenario);

        assert!(!safe::has_nft<Foo>(nft_id, &buyer_safe), 0);
        assert!(safe::has_nft<Foo>(nft_id, &seller_safe), 0);

        // bidding::sell_nft<Foo, SUI>(
        //     &mut bid,
        //     transfer_cap,
        //     &mut seller_safe,
        //     &mut buyer_safe,
        //     &wl,
        //     ctx(scenario),
        // );

        // assert!(safe::has_nft<Foo>(nft_id, &buyer_safe), 0);
        // assert!(!safe::has_nft<Foo>(nft_id, &seller_safe), 0);

        safe::burn_transfer_cap(transfer_cap, &mut seller_safe);
        test_scenario::return_shared(buyer_safe);
        test_scenario::return_shared(seller_safe);
        test_scenario::return_shared(wl);
        test_scenario::return_shared(bid);

        // test_scenario::next_tx(scenario, SELLER);
    }

    fun user_safe_id(scenario: &Scenario, user: address): ID {
        let owner_cap_id = vector::pop_back(
            &mut test_scenario::ids_for_address<safe::OwnerCap>(user)
        );
        let owner_cap: safe::OwnerCap =
            test_scenario::take_from_address_by_id(scenario, user, owner_cap_id);

        let safe_id = safe::owner_cap_safe(&owner_cap);

        test_scenario::return_to_address(user, owner_cap);

        safe_id
    }
}
