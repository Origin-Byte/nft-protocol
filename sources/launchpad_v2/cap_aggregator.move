module nft_protocol::cap_aggregator {
    use std::ascii::String;
    use std::option::{Self, Option};
    use std::type_name::{Self, TypeName};

    use sui::event;
    use sui::vec_set::{Self, VecSet};
    use sui::transfer;
    use sui::balance::{Self, Balance};
    use sui::object::{Self, ID , UID};
    use sui::dynamic_object_field as dof;
    use sui::dynamic_field as df;
    use sui::tx_context::{Self, TxContext};
    use sui::object_table::{Self, ObjectTable};
    use sui::object_bag::{Self, ObjectBag};

    use nft_protocol::err;
    use nft_protocol::utils;
    use nft_protocol::inventory::{Self, Inventory};
    use nft_protocol::warehouse::{Self, Warehouse, RedeemCommitment};
    use nft_protocol::marketplace::{Self as mkt, Marketplace};
    use nft_protocol::proceeds::{Self, Proceeds};
    use nft_protocol::venue::{Self, Venue};
    use nft_protocol::launchpad_v2::{Self, LaunchCap};

    use originmate::typed_id::{Self, TypedID};
    use originmate::object_box::{Self as obox, ObjectBox};

    struct CapAggregator has key, store {
        id: UID,
        // The idea here is to add dynamic fields to the cap with launchpad IDs
    }

    struct CapKeys has store, copy, drop {
        cap_id: ID,
    }

    struct DataKeys has store, copy, drop {
        data_id: ID,
    }

    // public fun new(
    //     marketplace_caps: &mut CapAggregator,
    //     marketplace_data: &mut MarketplaceData,
    //     ctx: &mut TxContext,
    // ) {
    //     let (cap, data) = launchpad_v2::new(ctx);

    //     df::add(
    //         &mut marketplace_caps.id,
    //         CapKeys { cap_id: object::id(&cap)},
    //         option::some(cap)
    //     );


    //     df::add(
    //         &mut marketplace_data.id,
    //         DataKeys { data_id: object::id(&data)},
    //         option::some(data)
    //     );
    // }

}
