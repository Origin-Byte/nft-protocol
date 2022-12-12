// #[test_only]
// module nft_protocol::test_ob_cancel_position {
//     // TODO: open a new bid and cancel it
//     // open a new ask and cancel it
//     // open a new bid with commission and cancel it
//     // open a new ask with commission and cancel it
//     // use nft_protocol::unprotected_safe::{Self as u_safe, TransferCap};
//     // use sui::test_scenario::{Self, ctx};
//     // use sui::tx_context;

//     // use nft_protocol::test_ob_utils as test_ob;

//     const BUYER: address = @0xA1C06;
//     const CREATOR: address = @0xA1C05;
//     const SELLER: address = @0xA1C04;

//     const OFFER_SUI: u64 = 100;

//     struct Foo has drop {} // collection
//     struct Witness has drop {} // collection witness, must be named witness
//     struct WhitelistWitness has drop {}

//     // #[test]
//     // fun it_cancels_bid() {
//     //     // TODO: Assert balance in coins
//     //     let scenario = test_scenario::begin(CREATOR);
//     //     let _sender = tx_context::sender(ctx(&mut scenario));

//     //     // test_ob::create_collection_and_whitelist(&mut scenario);

//     //     // test_ob::create_ob(&mut scenario);

//     //     // Creates transfer cap and sends it to orderbook
//     //     // let _nft_id = test_ob::create_seller_safe_and_make_an_offer_for_nft_id(
//     //     //     &mut scenario
//     //     // );

//     //     // // sends transfer cap back to sender
//     //     // test_ob::cancel_bid(&mut scenario);

//     //     // let transfer_cap = test_scenario::take_from_address<TransferCap>(
//     //     //     &mut scenario,
//     //     //     sender
//     //     // );

//     //     // u_safe::assert_nft_of_transfer_cap(&nft_id, &transfer_cap);

//     //     // test_scenario::return_to_sender(&scenario, transfer_cap);

//     //     test_scenario::end(scenario);
//     // }
// }
