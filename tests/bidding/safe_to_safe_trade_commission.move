#[test_only]
module nft_protocol::test_bidding_safe_to_safe_trade_commission {
    use sui::coin::{Self, Coin};
    use sui::object::ID;
    use sui::sui::SUI;
    use sui::test_scenario::{Self, Scenario, ctx};

    use nft_protocol::bidding;
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::safe::{Self, Safe, OwnerCap};
    use nft_protocol::test_utils::{Self as utils};
    use nft_protocol::transfer_allowlist::Allowlist;

    const SELL_BENEFICIARY: address = @0xA1C08;
    const BUY_BENEFICIARY: address = @0xA1C07;
    const BUYER: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;
    const SELLER: address = @0xA1C04;

    const OFFER_SUI: u64 = 100;
    const SELL_COMMISSION_SUI: u64 = 10;
    const BUY_COMMISSION_SUI: u64 = 10;

    #[test]
    fun it_works() {
        let scenario = test_scenario::begin(CREATOR);

        utils::create_collection_and_allowlist(
            CREATOR, &mut scenario,
        );

        test_scenario::next_tx(&mut scenario, SELLER);

        let (seller_safe_id, seller_owner_cap_id) = utils::create_safe(
            &mut scenario, SELLER
        );

        let nft_id = utils::mint_and_deposit_nft(&mut scenario, SELLER);

        test_scenario::next_tx(&mut scenario, SELLER);

        let seller_safe = test_scenario::take_shared_by_id<Safe>(
            &mut scenario,
            seller_safe_id,
        );

        assert!(safe::has_nft<utils::Foo>(nft_id, &seller_safe), 0);

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

        sell_nft<utils::Foo>(
            &mut scenario,
            transfer_cap,
            seller_safe_id,
            buyer_safe_id,
        );

        test_scenario::return_to_address(SELLER, seller_owner_cap);
        test_scenario::end(scenario);
    }

    fun bid_for_nft(
        scenario: &mut Scenario,
        nft_id: ID,
        buyer_safe_id: ID,
    ) {
        test_scenario::next_tx(scenario, BUYER);

        let wallet =
            coin::mint_for_testing(OFFER_SUI + BUY_COMMISSION_SUI, ctx(scenario));

        bidding::create_bid_with_commission<SUI>(
            nft_id,
            buyer_safe_id,
            OFFER_SUI,
            BUY_BENEFICIARY,
            BUY_COMMISSION_SUI,
            &mut wallet,
            ctx(scenario),
        );

        coin::destroy_zero(wallet);
    }

    fun sell_nft<T: key + store>(
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

        let wl: Allowlist = test_scenario::take_shared(scenario);

        assert!(!safe::has_nft<T>(nft_id, &buyer_safe), 0);
        assert!(safe::has_nft<T>(nft_id, &seller_safe), 1);

        bidding::sell_nft_with_commission<T, SUI>(
            &mut bid,
            transfer_cap,
            SELL_BENEFICIARY,
            SELL_COMMISSION_SUI,
            &mut seller_safe,
            &mut buyer_safe,
            &wl,
            ctx(scenario),
        );

        assert!(safe::has_nft<utils::Foo>(nft_id, &buyer_safe), 2);
        assert!(!safe::has_nft<utils::Foo>(nft_id, &seller_safe), 3);

        test_scenario::return_shared(buyer_safe);
        test_scenario::return_shared(seller_safe);
        test_scenario::return_shared(wl);
        test_scenario::return_shared(bid);

        test_scenario::next_tx(scenario, CREATOR);
        let payment: TradePayment<utils::Foo, SUI> = test_scenario::take_shared(scenario);
        royalties::transfer_remaining_to_beneficiary(utils::witness(), &mut payment, ctx(scenario));
        test_scenario::return_shared(payment);

        test_scenario::next_tx(scenario, SELL_BENEFICIARY);
        let commission: Coin<SUI> = test_scenario::take_from_sender(scenario);
        assert!(coin::value(&commission) == SELL_COMMISSION_SUI, 4);
        test_scenario::return_to_sender(scenario, commission);

        test_scenario::next_tx(scenario, BUY_BENEFICIARY);
        let commission: Coin<SUI> = test_scenario::take_from_sender(scenario);
        assert!(coin::value(&commission) == BUY_COMMISSION_SUI, 4);
        test_scenario::return_to_sender(scenario, commission);

        test_scenario::next_tx(scenario, SELLER);
    }
}
