//! Module of a generic `Trebuchet` type.
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
    use nft_protocol::outlet::{Outlet};
    use nft_protocol::generic::{Self, Generic};

    struct Launchpad has key, store{
        id: UID,
        /// The address of the administrator
        admin: address,
        permissionless: bool,
        launches: ObjectTable<ID, Trebuchet>,
    }

    struct Trebuchet has key, store{
        id: UID,
        /// The ID of the Collections object
        collections: vector<ID>,
        /// Boolean indicating if the sale is live
        live: bool,
        /// The address of the administrator
        admin: address,
        /// The address of the receiver of funds
        receiver: address,
        /// Vector of all markets outlets that, each outles holding IDs owned by the slingshot
        markets: vector<Generic>,
        /// Field determining if NFTs are embedded or looose.
        /// Embedded NFTs will be directly owned by the Trebuchet whilst
        /// loose NFTs will be minted on the fly under the authorithy of the
        /// launchpad.
        is_embedded: bool,
        fee: u64,
    }

    struct CreateTrebuchetEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    struct DeleteTrebuchetEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    // === Launchpad Functions ===

    /// Initialises a `Launchpad` object and adds it to the `Launchpad` object
    public fun init_launchpad(
        admin: address,
        permissionless: bool,
        ctx: &mut TxContext,
    ) {
        let uid = object::new(ctx);

        let id = object::uid_to_inner(&uid);

        let launchpad = Launchpad {
            id: uid,
            admin,
            permissionless,
            launches: object_table::new<ID, Trebuchet>(ctx),
        };
    }

    // === Trebuchet Functions ===

    /// Initialises a `Trebuchet` object and adds it to the `Launchpad` object
    public fun init_trebuchet(
        launchpad: &mut Launchpad,
        admin: address,
        collections: vector<ID>,
        receiver: address,
        is_embedded: bool,
        fee: u64,
        ctx: &mut TxContext,
    ) {
        let uid = object::new(ctx);

        let id = object::uid_to_inner(&uid);

        if (launchpad.permissionless == false) {
            assert!(
                tx_context::sender(ctx) == launchpad.admin,
                err::wrong_launchpad_admin()
            );
        };

        let markets = vector::empty();

        let slingshot = Trebuchet {
            id: uid,
            collections,
            live: false,
            admin,
            receiver,
            markets,
            is_embedded,
            fee,
        };

        object_table::add(&mut launchpad.launches, id, slingshot);
    }

    // /// Burn the `Trebuchet`
    // public fun delete(
    //     slingshot: Trebuchet,
    //     ctx: &mut TxContext,
    // ): vector<Outlet> {
    //     assert!(
    //         tx_context::sender(ctx) == admin(&slingshot),
    //         err::wrong_launchpad_admin()
    //     );

    //     let Trebuchet {
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

    /// Toggle the Trebuchet's `live` to `true` therefore
    /// making the NFT sale live.
    public fun sale_on(
        _launchpad: &mut Launchpad,
        slingshot: &mut Trebuchet,
    ) {
        slingshot.live = true
    }

    /// Toggle the Trebuchet's `live` to `false` therefore
    /// pausing or stopping the NFT sale.
    public fun sale_off(
        _launchpad: &mut Launchpad,
        slingshot: &mut Trebuchet,
    ) {
        slingshot.live = false
    }

    /// Adds a sale outlet `Outlet` to `sales` field
    public fun add_market(
        _launchpad: &mut Launchpad,
        slingshot: &mut Trebuchet,
        market: Generic,
    ) {
        vector::push_back(&mut slingshot.markets, market);
    }

    // === Getter Functions ===

    /// Get the Trebuchet `id`
    public fun id(
        _launchpad: &Launchpad,
        slingshot: &Trebuchet,
    ): ID {
        object::uid_to_inner(&slingshot.id)
    }

    /// Get the Trebuchet `id` as reference
    public fun id_ref(
        _launchpad: &Launchpad,
        slingshot: &Trebuchet,
    ): &ID {
        object::uid_as_inner(&slingshot.id)
    }

    /// Get the Trebuchet's `collection_id`
    public fun collections(
        _launchpad: &Launchpad,
        slingshot: &Trebuchet,
    ): &vector<ID> {
        &slingshot.collections
    }

    /// Get the Trebuchet's `live`
    public fun live(
        _launchpad: &Launchpad,
        slingshot: &Trebuchet,
    ): bool {
        slingshot.live
    }

    /// Get the Trebuchet's `receiver` address
    public fun receiver(
        _launchpad: &Launchpad,
        slingshot: &Trebuchet,
    ): address {
        slingshot.receiver
    }

    /// Get the Trebuchet's `admin` address
    public fun admin(
        _launchpad: &Launchpad,
        slingshot: &Trebuchet,
    ): address {
        slingshot.admin
    }

    /// Get the Trebuchet's sale `Outlet` address
    public fun sales(
        _launchpad: &Launchpad,
        slingshot: &Trebuchet,
    ): &vector<Generic> {
        &slingshot.markets
    }

    /// Get the Trebuchet's `sales` address mutably
    public fun sales_mut(
        _launchpad: &mut Launchpad,
        slingshot: &mut Trebuchet,
    ): &mut vector<Generic> {
        &mut slingshot.markets
    }

    /// Get the Trebuchet's `sale` address
    public fun market(
        _launchpad: &Launchpad,
        slingshot: &Trebuchet,
        index: u64,
    ): &Generic {
        vector::borrow(&slingshot.markets, index)
    }

    /// Get the Trebuchet's `sale` address mutably
    public fun market_mut(
        _launchpad: &mut Launchpad,
        slingshot: &mut Trebuchet,
        index: u64,
    ): &mut Generic {
        vector::borrow_mut(&mut slingshot.markets, index)
    }

    /// Get the Trebuchet's `is_embedded` bool
    public fun is_embedded(
        _launchpad: &Launchpad,
        slingshot: &Trebuchet,
    ): bool {
        slingshot.is_embedded
    }

     /// Get the Trebuchet's `fee` amount
    public fun fee(
        _launchpad: &Launchpad,
        slingshot: &Trebuchet,
    ): u64 {
        slingshot.fee
    }
}
