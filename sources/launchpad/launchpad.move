//! Module of a generic `Slingshot` type.
//!
//! It acts as a generic interface for Launchpads and it allows for
//! the creation of arbitrary domain specific implementations.
//!
//! The slingshot acts as the object that configures the primary NFT release
//! strategy, that is the primary market sale. Primary market sales can take
//! many shapes, depending on the business level requirements.
module nft_protocol::launchpad {
    use std::vector;

    use sui::object::{Self, ID , UID};
    use sui::tx_context::{Self, TxContext};
    use sui::object_table::{Self, ObjectTable};

    use nft_protocol::err;
    use nft_protocol::sale::{Outlet};
    use nft_protocol::generic::Generic;

    struct Launchpad<phantom T> has key, store{
        id: UID,
        /// The address of the administrator
        admin: address,
        launches: ObjectTable<ID, Slingshot>,
    }

    struct Slingshot has key, store{
        id: UID,
        /// The ID of the Collections object
        collections: vector<ID>,
        /// Boolean indicating if the sale is live
        live: bool,
        /// The address of the administrator
        admin: address,
        /// The address of the receiver of funds
        receiver: address,
        /// Vector of all Sale outlets that, each outles holding IDs owned by the slingshot
        sales: vector<Outlet>,
        /// Field determining if NFTs are embedded or looose.
        /// Embedded NFTs will be directly owned by the Slingshot whilst
        /// loose NFTs will be minted on the fly under the authorithy of the
        /// launchpad.
        is_embedded: bool,
        fee_config: Generic,
    }

    struct CreateSlingshotEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    struct DeleteSlingshotEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    // === Launchpad Functions ===

    /// Initialises a `Launchpad` object and adds it to the `Launchpad` object
    public fun init_launchpad<T: drop>(
        launchpad: &mut Launchpad<T>,
        admin: address,
        ctx: &mut TxContext,
    ) {
        let uid = object::new(ctx);

        let id = object::uid_to_inner(&uid);

        assert!(
            tx_context::sender(ctx) == launchpad.admin,
            err::wrong_launchpad_admin()
        );

        let launchpad = Launchpad {
            id: uid,
            admin,
            launches:
        };

        object_table::add(&mut launchpad.launches, id, slingshot);
    }

    // === Slingshot Functions ===

    /// Initialises a `Slingshot` object and adds it to the `Launchpad` object
    public fun init_slingshot<T: drop>(
        launchpad: &mut Launchpad<T>,
        sales: vector<Outlet>,
        admin: address,
        collections: vector<ID>,
        receiver: address,
        is_embedded: bool,
        fee_config: Generic,
        ctx: &mut TxContext,
    ) {
        let uid = object::new(ctx);

        let id = object::uid_to_inner(&uid);

        assert!(
            tx_context::sender(ctx) == launchpad.admin,
            err::wrong_launchpad_admin()
        );

        let slingshot = Slingshot {
            id: uid,
            collections,
            live: false,
            admin,
            receiver,
            sales,
            is_embedded,
            fee_config,
        };

        object_table::add(&mut launchpad.launches, id, slingshot);
    }

    // /// Burn the `Slingshot`
    // public fun delete<T: drop>(
    //     slingshot: Slingshot,
    //     ctx: &mut TxContext,
    // ): vector<Outlet> {
    //     assert!(
    //         tx_context::sender(ctx) == admin(&slingshot),
    //         err::wrong_launchpad_admin()
    //     );

    //     let Slingshot {
    //         id,
    //         collection_id: _,
    //         live: _,
    //         admin: _,
    //         receiver: _,
    //         sales,
    //         is_embedded: _,
    //     } = slingshot;

    //     object::delete(id);

    //     sales
    // }

    // === Modifier Functions ===

    /// Toggle the Slingshot's `live` to `true` therefore
    /// making the NFT sale live.
    public fun sale_on<T>(
        slingshot: &mut Slingshot,
    ) {
        slingshot.live = true
    }

    /// Toggle the Slingshot's `live` to `false` therefore
    /// pausing or stopping the NFT sale.
    public fun sale_off<T>(
        slingshot: &mut Slingshot,
    ) {
        slingshot.live = false
    }

    /// Adds a sale outlet `Outlet` to `sales` field
    public fun add_sale_outlet<T>(
        slingshot: &mut Slingshot,
        sale: Outlet,
    ) {
        vector::push_back(&mut slingshot.sales, sale);
    }

    // === Getter Functions ===

    /// Get the Slingshot `id`
    public fun id<T>(
        slingshot: &Slingshot,
    ): ID {
        object::uid_to_inner(&slingshot.id)
    }

    /// Get the Slingshot `id` as reference
    public fun id_ref<T>(
        slingshot: &Slingshot,
    ): &ID {
        object::uid_as_inner(&slingshot.id)
    }

    /// Get the Slingshot's `collection_id`
    public fun collections<T>(
        slingshot: &Slingshot,
    ): &vector<ID> {
        &slingshot.collections
    }

    /// Get the Slingshot's `live`
    public fun live<T>(
        slingshot: &Slingshot,
    ): bool {
        slingshot.live
    }

    /// Get the Slingshot's `receiver` address
    public fun receiver<T>(
        slingshot: &Slingshot,
    ): address {
        slingshot.receiver
    }

    /// Get the Slingshot's `admin` address
    public fun admin<T>(
        slingshot: &Slingshot,
    ): address {
        slingshot.admin
    }

    /// Get the Slingshot's sale `Outlet` address
    public fun sales<T>(
        slingshot: &Slingshot,
    ): &vector<Outlet> {
        &slingshot.sales
    }

    /// Get the Slingshot's `sales` address mutably
    public fun sales_mut<T>(
        slingshot: &mut Slingshot,
    ): &mut vector<Outlet> {
        &mut slingshot.sales
    }

    /// Get the Slingshot's `sale` address
    public fun Sale(
        slingshot: &Slingshot,
        index: u64,
    ): &Outlet {
        vector::borrow(&slingshot.sales, index)
    }

    /// Get the Slingshot's `sale` address mutably
    public fun sale_mut<T>(
        slingshot: &mut Slingshot,
        index: u64,
    ): &mut Outlet {
        vector::borrow_mut(&mut slingshot.sales, index)
    }

    /// Get the Slingshot's `is_embedded` bool
    public fun is_embedded<T>(
        slingshot: &Slingshot,
    ): bool {
        slingshot.is_embedded
    }
}
