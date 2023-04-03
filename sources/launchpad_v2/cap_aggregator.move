module nft_protocol::cap_aggregator {
    use sui::object::{ID , UID};

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
