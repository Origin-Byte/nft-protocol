#[test_only]
module nft_protocol::test_ob_cancel_position {
    // TODO: open a new bid and cancel it
    // open a new ask and cancel it
    // open a new bid with commission and cancel it
    // open a new ask with commission and cancel it
    use nft_protocol::unprotected_safe::{TransferCap};
    // use nft_protocol::unprotected_safe::{Self as u_safe, TransferCap};
    use sui::test_scenario::{Self, ctx};
    use sui::tx_context;

    use nft_protocol::test_ob_utils as test_ob;

    const BUYER: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;
    const SELLER: address = @0xA1C04;

    const OFFER_SUI: u64 = 100;

    struct Foo has drop {} // collection
    struct Witness has drop {} // collection witness, must be named witness
    struct WhitelistWitness has drop {}

    #[test]
    fun it_cancels_ask() {
        // TODO: Assert balance in coins
        let scenario = test_scenario::begin(CREATOR);
        let sender = tx_context::sender(ctx(&mut scenario));

        test_ob::create_collection_and_whitelist(&mut scenario);

        let _ob_id = test_ob::create_ob(&mut scenario);

        let (seller_safe_id , seller_owner_cap_id) = test_ob::create_safe(
            &mut scenario,
            SELLER,
        );

        // Creates transfer cap and sends it to orderbook
        let nft_id = test_ob::create_and_deposit_nft(
            &mut scenario,
            seller_safe_id,
            seller_owner_cap_id,
            SELLER,
        );

        let transfer_cap_id = test_ob::create_ask(
            &mut scenario,
            seller_safe_id,
            seller_owner_cap_id,
            nft_id,
            SELLER,
            OFFER_SUI,
        );

        // This call should supposedly send the transfer cap back to sender
        test_ob::cancel_ask(&mut scenario, nft_id, SELLER, OFFER_SUI);

        test_scenario::next_tx(&mut scenario, sender);

        let transfer_cap = test_scenario::take_from_address_by_id<TransferCap>(
            &mut scenario,
            sender,
            transfer_cap_id,
        );

        // u_safe::assert_nft_of_transfer_cap(&nft_id, &transfer_cap);
        test_scenario::return_to_sender(&scenario, transfer_cap);

        test_scenario::end(scenario);
    }

    // #[test]
    // fun it_cancels_bid() {
    //     // TODO: Assert balance in coins
    //     let scenario = test_scenario::begin(CREATOR);
    //     let sender = tx_context::sender(ctx(&mut scenario));

    //     test_ob::create_collection_and_whitelist(&mut scenario);

    //     let _ob_id = test_ob::create_ob(&mut scenario);

    //     let (seller_safe_id , seller_owner_cap_id) = test_ob::create_safe(
    //         &mut scenario,
    //         SELLER,
    //     );

    //     // Creates transfer cap and sends it to orderbook
    //     let nft_id = test_ob::create_and_deposit_nft(
    //         &mut scenario,
    //         seller_safe_id,
    //         seller_owner_cap_id,
    //     );

    //     let transfer_cap_id = test_ob::make_sell_offer_for_nft(
    //         &mut scenario,
    //         seller_safe_id,
    //         seller_owner_cap_id,
    //         nft_id,
    //     );

    //     // This call should supposedly send the transfer cap back to sender
    //     test_ob::cancel_bid(&mut scenario, nft_id);

    //     let transfer_cap = test_scenario::take_from_address_by_id<TransferCap>(
    //         &mut scenario,
    //         sender,
    //         transfer_cap_id,
    //     );

    //     // u_safe::assert_nft_of_transfer_cap(&nft_id, &transfer_cap);
    //     test_scenario::return_to_sender(&scenario, transfer_cap);

    //     test_scenario::end(scenario);
    // }
}
