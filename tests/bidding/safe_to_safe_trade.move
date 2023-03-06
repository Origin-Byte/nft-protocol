#[test_only]
/// This test focuses on integration between bidding contract, Safe,
/// a allowlist and royalty collection.
///
/// We simulate a trade between two Safes, end to end.
module nft_protocol::test_bidding_safe_to_safe_trade {
    use sui::coin;
    use sui::balance;
    use sui::sui::SUI;
    use sui::object::ID;
    use sui::tx_context::TxContext;
    use sui::test_scenario::{Self, Scenario, ctx};

    use nft_protocol::bidding;
    use nft_protocol::royalty::{Self, RoyaltyDomain};
    use nft_protocol::safe::{Self, Safe, OwnerCap};
    use nft_protocol::transfer_allowlist::Allowlist;
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::test_utils::{Self as utils};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::mint_cap::MintCap;
    use nft_protocol::royalty_strategy_bps::{BpsRoyaltyStrategy};

    const BUYER: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;
    const SELLER: address = @0xA1C04;

    const OFFER_SUI: u64 = 100;

    struct Foo has drop {} // collection
    struct Witness has drop {} // collection witness, must be named witness
    struct AllowlistWitness has drop {}

    #[test]
    fun it_works() {
        let scenario = test_scenario::begin(SELLER);

        utils::create_collection_and_allowlist_with_type(
            &Foo {},
            &Witness {},
            CREATOR,
            &mut scenario,
        );

        let (seller_safe_id, seller_owner_cap_id) = utils::create_safe(
            &mut scenario, SELLER
        );

        let nft_id = utils::mint_and_deposit_nft<Foo>(
            &mut scenario,
            SELLER,
        );

        test_scenario::next_tx(&mut scenario, SELLER);

        let seller_safe = test_scenario::take_shared_by_id<Safe>(
            &mut scenario,
            seller_safe_id,
        );

        assert!(safe::has_nft<Foo>(nft_id, &seller_safe), 0);

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

        let (buyer_safe_id, _buyer_owner_cap_id) = utils::create_safe(&mut scenario, BUYER);

        bid_for_nft(
            &mut scenario,
            safe::transfer_cap_nft(&transfer_cap),
            buyer_safe_id,
        );

        test_scenario::next_tx(&mut scenario, SELLER);

        sell_nft<Foo>(
            &mut scenario,
            transfer_cap,
            seller_safe_id,
            buyer_safe_id,
        );

        test_scenario::return_to_address(SELLER, seller_owner_cap);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_works_with_royalties() {
        let scenario = test_scenario::begin(CREATOR);

        let (col_id, mint_cap_id, _) = utils::create_collection_and_allowlist_with_type(
            &Foo {},
            &Witness {},
            CREATOR,
            &mut scenario,
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        let collection = test_scenario::take_shared_by_id<Collection<Foo>>(
            &mut scenario,
            col_id,
        );

        let mint_cap = test_scenario::take_from_address_by_id<MintCap<Foo>>(
            &mut scenario,
            CREATOR,
            mint_cap_id,
        );

        let royalty = royalty::from_address(CREATOR, ctx(&mut scenario));
        royalty::add_proportional_royalty(&mut royalty, 100);
        royalty::add_royalty_domain<Foo, Witness>(
            &Witness {}, &mut collection, royalty,
        );

        // If domain does not exist this function call will fail
        collection::borrow_domain<Foo, RoyaltyDomain>(&collection);

        test_scenario::next_tx(&mut scenario, SELLER);

        let (seller_safe_id, seller_owner_cap_id) = utils::create_safe(
            &mut scenario, SELLER
        );

        let nft_id = utils::mint_and_deposit_nft<Foo>(
            &mut scenario,
            SELLER,
        );

        test_scenario::next_tx(&mut scenario, SELLER);

        let seller_safe = test_scenario::take_shared_by_id<Safe>(
            &mut scenario,
            seller_safe_id,
        );

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

        let (buyer_safe_id, _) = utils::create_safe(&mut scenario, BUYER);

        bid_for_nft(
            &mut scenario,
            safe::transfer_cap_nft(&transfer_cap),
            buyer_safe_id,
        );

        test_scenario::next_tx(&mut scenario, SELLER);

        sell_nft<Foo>(
            &mut scenario,
            transfer_cap,
            seller_safe_id,
            buyer_safe_id,
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        let trade_payment = test_scenario::take_shared<TradePayment<Foo, SUI>>(
            &mut scenario
        );

        assert!(balance::value(royalties::amount(&trade_payment)) == 100, 0);

        collect_proportional_royalty<Foo, SUI>(
            &mut trade_payment,
            &mut collection,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, CREATOR);


        assert!(balance::value(royalties::amount(&trade_payment)) == 0, 0);

        // TODO: Add Assertion to test that roylaty amount is 1% of the
        // trade price.. Waiting for decimal module to be written
        // let seller_coins = test_scenario::take_from_address<Coin<SUI>>(
        //     &mut scenario, SELLER,
        // );

        // debug::print(&seller_coins);

        test_scenario::return_shared(collection);
        test_scenario::return_shared(trade_payment);
        test_scenario::return_to_address(CREATOR, mint_cap);
        test_scenario::return_to_address(SELLER, seller_owner_cap);
        // test_scenario::return_to_address(SELLER, seller_coins);

        test_scenario::end(scenario);
    }

    public fun collect_proportional_royalty<C, FT>(
        payment: &mut TradePayment<C, FT>,
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ) {
        let domain = royalty::royalty_domain(collection);

        assert!(
            royalty::contains_strategy<BpsRoyaltyStrategy>(domain), 0
        );

        let royalty_owed =
            royalty::calculate_proportional_royalty(
                domain, balance::value(royalties::amount(payment))
        );

        let b = royalties::balance_mut(Witness {}, payment);

        royalty::collect_royalty(collection, b, royalty_owed);
        royalties::transfer_remaining_to_beneficiary(Witness {}, payment, ctx);
    }

    fun bid_for_nft(
        scenario: &mut Scenario,
        nft_id: ID,
        buyer_safe_id: ID,
    ) {
        test_scenario::next_tx(scenario, BUYER);

        let wallet = coin::mint_for_testing(OFFER_SUI, ctx(scenario));

        bidding::create_bid<SUI>(
            nft_id,
            buyer_safe_id,
            OFFER_SUI,
            &mut wallet,
            ctx(scenario),
        );

        coin::destroy_zero(wallet);
    }

    fun sell_nft<C>(
        scenario: &mut Scenario,
        transfer_cap: safe::TransferCap,
        seller_safe_id: ID,
        buyer_safe_id: ID,
    ) {
        let nft_id = safe::transfer_cap_nft(&transfer_cap);
        safe::assert_transfer_cap_of_native_nft(&transfer_cap);

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

        let wl: Allowlist = test_scenario::take_shared(scenario);

        assert!(!safe::has_nft<C>(nft_id, &buyer_safe), 0);
        assert!(safe::has_nft<C>(nft_id, &seller_safe), 0);

        bidding::sell_nft<C, SUI>(
            &mut bid,
            transfer_cap,
            &mut seller_safe,
            &mut buyer_safe,
            &wl,
            ctx(scenario),
        );

        assert!(safe::has_nft<Foo>(nft_id, &buyer_safe), 0);
        assert!(!safe::has_nft<Foo>(nft_id, &seller_safe), 0);

        test_scenario::return_shared(buyer_safe);
        test_scenario::return_shared(seller_safe);
        test_scenario::return_shared(wl);
        test_scenario::return_shared(bid);

        test_scenario::next_tx(scenario, SELLER);
    }
}
