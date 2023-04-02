module nft_protocol::launchpad_v2 {
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

    use originmate::typed_id::{Self, TypedID};
    use originmate::object_box::{Self as obox, ObjectBox};

    struct MarketplaceData {
        id: UID,
        // Idea is to add LaunchData as a dynamic field
    }

    struct Listing has key, store {
        id: UID,
        launch_caps: VecSet<ID>,
        collection: Option<TypeName>,
        venues: VecSet<ID>,
        warehouses: VecSet<ID>,
    }

    struct LaunchCap has key, store {
        id: UID,
        listing_id: ID,
        clonable: bool,
    }

    /// Initialises a launchpad by creating an object and returns it.
    public fun new(
        ctx: &mut TxContext,
    ): (LaunchCap, Listing) {
        let cap_id = object::new(ctx);
        let listing_id = object::new(ctx);

        // event::emit(CreateListingEvent {
        //     listing_id: object::uid_to_inner(&id),
        // });

        let launch_caps = vec_set::singleton(object::uid_to_inner(&cap_id));

        let cap = LaunchCap {
            id: cap_id,
            listing_id: object::uid_to_inner(&listing_id),
            clonable: true,
        };

        let data = Listing {
            id: listing_id,
            launch_caps,
            // Has to be added separately
            collection: option::none(),
            venues: vec_set::empty(),
            warehouses: vec_set::empty(),
        };

        (cap, data)
    }


    // TODO: Use publisher object for this.
    public fun add_collection<W>(cap: &LaunchCap) {}

    public fun clone_launch_cap(
        cap: &LaunchCap,
        listing: &Listing,
        clonable: bool,
        ctx: &mut TxContext,
    ) {
        assert_launch_cap(cap, listing);
        let cap_id = object::new(ctx);

        let cap = LaunchCap {
            id: cap_id,
            listing_id: object::id(listing),
            clonable,
        };
    }

    public fun listing_id(launch_cap: &LaunchCap): ID {
        object::uid_to_inner(&launch_cap.id)
    }

    public fun assert_launch_cap(cap: &LaunchCap, listing: &Listing) {
        // TODO: Shall we check the other way around as well, if cap.listing_id matches?
        assert!(vec_set::contains(&listing.launch_caps, &object::id(cap)), 0);
    }


}
