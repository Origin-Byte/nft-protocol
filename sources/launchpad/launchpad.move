//! Module of a generic `Slot` type.
//!
//! It acts as a generic interface for Launchpads and it allows for
//! the creation of arbitrary domain specific implementations.
//!
//! The slot acts as the object that configures the primary NFT release
//! strategy, that is the primary market sale. Primary market sales can take
//! many shapes, depending on the business level requirements.
module nft_protocol::launchpad {
    use std::vector;

    use sui::transfer;
    use sui::table::{Self, Table};
    use sui::object::{Self, ID , UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use nft_protocol::outlet::{Outlet};
    use nft_protocol::box::{Self, Box};
    use nft_protocol::object_box::{Self, ObjectBox};

    struct Launchpad has key, store{
        id: UID,
        /// The address of the administrator
        admin: address,
        permissionless: bool,
        proceeds: Table<ID, Box>,
    }

    struct Slot has key, store{
        id: UID,
        /// The ID of the Collections object
        collections: vector<ID>,
        /// Boolean indicating if the sale is live
        live: bool,
        /// The address of the administrator
        admin: address,
        /// The address of the receiver of funds
        receiver: address,
        /// Vector of all markets outlets that, each outles holding IDs owned by the slot
        markets: vector<ObjectBox>,
        /// Field determining if NFTs are embedded or looose.
        /// Embedded NFTs will be directly owned by the Slot whilst
        /// loose NFTs will be minted on the fly under the authorithy of the
        /// launchpad.
        is_embedded: bool,
        fee: u64,
    }

    struct CreateSlotEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    struct DeleteSlotEvent has copy, drop {
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
            proceeds: table::new<ID, Box>(ctx),
        };
    }

    // === Slot Functions ===

    /// Initialises a `Slot` object and adds it to the `Launchpad` object
    public fun init_slot<C: store + drop>(
        launchpad: &mut Launchpad,
        slot_admin: address,
        collections: vector<ID>,
        receiver: address,
        is_embedded: bool,
        fee: u64,
        ctx: &mut TxContext,
    ) {
        // If the launchpad is permissionless, anyone can call this function
        // and create its slot. If not, only the launchpad admin can create the
        // slot
        if (launchpad.permissionless == false) {
            assert!(
                tx_context::sender(ctx) == launchpad.admin,
                err::wrong_launchpad_admin()
            );
        };

        let uid = object::new(ctx);
        let id = object::uid_to_inner(&uid);

        let markets = vector::empty();

        let slot = Slot {
            id: uid,
            collections,
            live: false,
            admin: slot_admin,
            receiver,
            markets,
            is_embedded,
            fee,
        };

        table::add(
            &mut launchpad.proceeds,
            id,
            box::new(
                balance::zero<C>(),
                ctx,
            ),
        );

        transfer::share_object(slot);
    }

    // === Modifier Functions ===

    /// Toggle the Slot's `live` to `true` therefore
    /// making the NFT sale live.
    public fun sale_on(
        slot: &mut Slot,
        ctx: &mut TxContext,
    ) {
        assert!(
            tx_context::sender(ctx) == slot.admin,
            err::wrong_launchpad_admin()
        );

        slot.live = true
    }

    /// Toggle the Slot's `live` to `false` therefore
    /// pausing or stopping the NFT sale.
    public fun sale_off(
        slot: &mut Slot,
        ctx: &mut TxContext,
    ) {
        assert!(
            tx_context::sender(ctx) == slot.admin,
            err::wrong_launchpad_admin()
        );

        slot.live = false
    }

    /// Adds a sale outlet `Outlet` to `sales` field
    public fun add_market(
        slot: &mut Slot,
        market: ObjectBox,
    ) {
        vector::push_back(&mut slot.markets, market);
    }

    // === Getter Functions ===

    /// Get the Slot `id`
    public fun id(
        slot: &Slot,
    ): ID {
        object::uid_to_inner(&slot.id)
    }

    /// Get the Slot `id` as reference
    public fun id_ref(
        slot: &Slot,
    ): &ID {
        object::uid_as_inner(&slot.id)
    }

    /// Get the Slot's `collection_id`
    public fun collections(
        slot: &Slot,
    ): &vector<ID> {
        &slot.collections
    }

    /// Get the Slot's `live`
    public fun live(
        slot: &Slot,
    ): bool {
        slot.live
    }

    /// Get the Slot's `receiver` address
    public fun receiver(
        slot: &Slot,
    ): address {
        slot.receiver
    }

    /// Get the Slot's `admin` address
    public fun admin(
        slot: &Slot,
    ): address {
        slot.admin
    }

    /// Get the Slot's sale `Outlet` address
    public fun sales(
        slot: &Slot,
    ): &vector<ObjectBox> {
        &slot.markets
    }

    /// Get the Slot's `sales` address mutably
    public fun sales_mut(
        slot: &mut Slot,
    ): &mut vector<ObjectBox> {
        &mut slot.markets
    }

    // /// Get the Slot's `sale` address
    // public fun market(
    //     slot: &Slot,
    //     index: u64,
    // ): &Generic {
    //     vector::borrow(&slot.markets, index)
    // }

    // /// Get the Slot's `sale` address mutably
    // public fun market_mut(
    //     slot: &mut Slot,
    //     index: u64,
    // ): &mut Generic {
    //     vector::borrow_mut(&mut slot.markets, index)
    // }

    /// Get the Slot's `is_embedded` bool
    public fun is_embedded(
        slot: &Slot,
    ): bool {
        slot.is_embedded
    }

    /// Get the Slot's `fee` amount
    public fun fee(
        slot: &Slot,
    ): u64 {
        slot.fee
    }

    public fun proceeds<C: key + store>(
        launchpad: &Launchpad,
        slot_id: ID,
    ): &Balance<C> {
        let box = box::borrow_object<Balance<C>>(
            table::borrow<ID, Box>(&launchpad.proceeds, slot_id)
        );

        box
    }

    public fun proceeds_mut<C: key + store>(
        launchpad: &mut Launchpad,
        slot_id: ID,
    ): &mut Balance<C> {
        let box = box::borrow_object_mut<Balance<C>>(
            table::borrow_mut<ID, Box>(&mut launchpad.proceeds, slot_id)
        );

        box
    }
}
