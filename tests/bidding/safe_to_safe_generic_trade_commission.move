#[test_only]
module nft_protocol::test_bidding_safe_to_safe_generic_trade_commission {
    use sui::coin::{Self, Coin};
    use sui::object::{Self, ID};
    use sui::sui::SUI;
    use sui::test_scenario::{Self, Scenario, ctx};
    use nft_protocol::bidding;
    use nft_protocol::safe::{Self, Safe, TransferCap};
    use nft_protocol::test_utils::{Self as utils};
    use originmate::box::{Self, Box};

    const SELL_BENEFICIARY: address = @0xA1C08;
    const BUY_BENEFICIARY: address = @0xA1C07;
    const BUYER: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;
    const SELLER: address = @0xA1C04;

    const OFFER_SUI: u64 = 100;
    const SELL_COMMISSION_SUI: u64 = 10;
    const BUY_COMMISSION_SUI: u64 = 10;

    struct Witness has drop {} // collection witness, must be named witness

    #[test]
    fun it_works() {
        let scenario = test_scenario::begin(CREATOR);

        let (seller_safe_id, transfer_cap) = setup_seller(&mut scenario);

        test_scenario::next_tx(&mut scenario, BUYER);
        let (buyer_safe_id, _) = utils::create_safe(&mut scenario, BUYER);
        bid_for_nft(
            &mut scenario,
            safe::transfer_cap_nft(&transfer_cap),
            buyer_safe_id
        );

        test_scenario::next_tx(&mut scenario, SELLER);
        sell_generic_nft(
            &mut scenario,
            transfer_cap,
            seller_safe_id,
            buyer_safe_id,
        );

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

    fun setup_seller(scenario: &mut Scenario): (ID, TransferCap) {
        test_scenario::next_tx(scenario, SELLER);
        let (seller_safe_id, _) = utils::create_safe(scenario, SELLER);

        test_scenario::next_tx(scenario, SELLER);
        let (seller_owner_cap, seller_safe) = utils::owner_cap_and_safe(scenario, SELLER);
        // we use box bcs we need some type which is not exposed by our pkg
        box::box(SELLER, true, ctx(scenario));
        test_scenario::next_tx(scenario, SELLER);
        let nft: Box<bool> = test_scenario::take_from_sender(scenario);
        let nft_id = object::id(&nft);
        safe::deposit_generic_nft(
            nft, &mut seller_safe, ctx(scenario),
        );
        test_scenario::next_tx(scenario, SELLER);

        let transfer_cap = safe::create_transfer_cap(
            nft_id,
            &seller_owner_cap,
            &mut seller_safe,
            ctx(scenario),
        );

        test_scenario::return_shared(seller_safe);
        test_scenario::next_tx(scenario, BUYER);

        test_scenario::next_tx(scenario, SELLER);
        test_scenario::return_to_address(SELLER, seller_owner_cap);

        (seller_safe_id, transfer_cap)
    }

    fun sell_generic_nft(
        scenario: &mut Scenario,
        transfer_cap: safe::TransferCap,
        seller_safe_id: ID,
        buyer_safe_id: ID,
    ) {
        let nft_id = safe::transfer_cap_nft(&transfer_cap);
        assert!(safe::transfer_cap_is_nft_generic(&transfer_cap), 0);

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

        assert!(!safe::has_generic_nft<Box<bool>>(nft_id, &buyer_safe), 1);
        assert!(safe::has_generic_nft<Box<bool>>(nft_id, &seller_safe), 2);

        bidding::sell_generic_nft_with_commission<Box<bool>, SUI>(
            &mut bid,
            transfer_cap,
            SELL_BENEFICIARY,
            SELL_COMMISSION_SUI,
            &mut seller_safe,
            &mut buyer_safe,
            ctx(scenario),
        );

        assert!(safe::has_generic_nft<Box<bool>>(nft_id, &buyer_safe), 3);
        assert!(!safe::has_generic_nft<Box<bool>>(nft_id, &seller_safe), 4);

        test_scenario::return_shared(buyer_safe);
        test_scenario::return_shared(seller_safe);
        test_scenario::return_shared(bid);

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
