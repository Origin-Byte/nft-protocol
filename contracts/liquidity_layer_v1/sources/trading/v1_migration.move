// module liquidity_layer_v1::v1_migration {
//     use std::ascii::String;
//     use std::option::{Self, Option};
//     use std::type_name;
//     use std::vector;

//     use sui::transfer_policy::TransferPolicy;
//     use sui::balance::{Self, Balance};
//     use sui::coin::{Self, Coin};
//     use sui::event;
//     use sui::package::{Self, Publisher};
//     use sui::kiosk::{Self, Kiosk};
//     use sui::object::{Self, ID, UID};
//     use sui::transfer::share_object;
//     use sui::tx_context::{Self, TxContext};
//     use sui::dynamic_field as df;

//     use ob_permissions::witness::Witness as DelegatedWitness;
//     use ob_kiosk::ob_kiosk;
//     use ob_request::transfer_request::{Self, TransferRequest};

//     use liquidity_layer_v1::orderbook::{Self, Orderbook};



//     /// Cancel all bids permissionlesly
//     ///
//     /// Requires that Orderbook is frozen thus this order would not be able to
//     /// execute eitherway.
//     ///
//     /// Allows migrations to newer versions to be performed seamlessly
//     /// by cancelling and returning all funds to market participants.
//     public entry fun cancel_bids_permissionless<T: key + store, FT>(
//         book: &mut Orderbook<T, FT>,
//         ctx: &mut TxContext,
//     ) {
//         assert!(is_frozen(book), EOrderbookNotFrozen);

//         while (!crit_bit::is_empty(&book.bids)) {
//             let price = crit_bit::min_key(&book.bids);
//             let price_level = crit_bit::pop(&mut book.bids, price);

//             while (!vector::is_empty(&price_level)) {
//                 let bid = vector::pop_back(&mut price_level);
//                 let owner = bid.owner;

//                 let coin = coin::zero(ctx);
//                 refund_bid(bid, book, &mut coin);
//                 transfer::public_transfer(coin, owner);
//             };

//             vector::destroy_empty(price_level);
//         }
//     }


//     /// Cancel ask permissionlesly
//     ///
//     /// Requires that Orderbook is frozen thus this order would not be able to
//     /// execute eitherway.
//     ///
//     /// Allows migrations to newer versions to be performed seamlessly
//     /// by cancelling and returning all funds to market participants.
//     public entry fun cancel_ask_permissionless<T: key + store, FT>(
//         book: &mut Orderbook<T, FT>,
//         seller_kiosk: &mut Kiosk,
//         nft_price_level: u64,
//         nft_id: ID,
//     ) {
//         assert!(is_frozen(book), EOrderbookNotFrozen);
//         cancel_ask_(book, seller_kiosk, nft_price_level, nft_id);
//     }




// }
