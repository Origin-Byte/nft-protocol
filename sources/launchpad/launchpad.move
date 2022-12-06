//! Module of a `Launchpad` type and its associated `Slot`s.
//!
//! The slot acts as the object that configures the primary NFT release
//! strategy, that is the primary market sale. Primary market sales can take
//! many shapes, depending on the business level requirements.
module nft_protocol::launchpad {
    // TODO: Function to delete a slot
    use std::vector;

    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, ID , UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use nft_protocol::proceeds::{Self, Proceeds};
    use nft_protocol::object_box::{Self, ObjectBox};

    struct Launchpad has key, store {
        id: UID,
        /// The address of the launchpad administrator
        admin: address,
        /// Receiver of launchpad fees
        receiver: address,
        /// Permissionless launchpads allow for anyone to create their
        /// slots, therefore being immediately approved.
        auto_approval: bool,
        default_fee: ObjectBox,
    }

    struct Slot has key, store {
        id: UID,
        launchpad: ID,
        /// Signals if the Slot has been approved by the launchpad administrator.
        is_approved: bool,
        /// Boolean indicating if the sale is live
        live: bool,
        /// The address of the slot administrator, that is, the Nft creator
        admin: address,
        /// The address of the receiver of funds
        receiver: address,
        /// Vector of all markets outlets that, each outles holding IDs owned by the slot
        markets: vector<ObjectBox>,
        /// Proceeds object holds the balance of Fungible Tokens acquired from
        /// the sale of the Slot
        proceeds: Proceeds,
        /// Field with Object Box holding a Custom Fee implementation if any.
        /// In case this box is empty the calculation will applied on the
        /// default fee object in the associated launchpad
        custom_fee: ObjectBox,
    }

    struct CreateSlotEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    struct DeleteSlotEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    // === Launchpad Admin Functions ===

    /// Initialises a `Launchpad` object and shares it
    public entry fun init_launchpad(
        admin: address,
        receiver: address,
        auto_approval: bool,
        default_fee: ObjectBox,
        ctx: &mut TxContext,
    ) {
        let uid = object::new(ctx);

        let launchpad = Launchpad {
            id: uid,
            admin,
            receiver,
            auto_approval,
            default_fee,
        };

        transfer::share_object(launchpad);
    }

    // Approved a given Launchpad Slot
    public entry fun approve_slot(
        launchpad: &Launchpad,
        slot: &mut Slot,
        ctx: &mut TxContext,
    ) {
        assert_slot(launchpad, slot);
        assert_launchpad_admin(launchpad, ctx);

        slot.is_approved = true;
    }

    /// Adds a fee object to the Slot's `custom_fee`
    public entry fun add_fee<FeeType: key + store>(
        launchpad: &Launchpad,
        slot: &mut Slot,
        fee: FeeType,
        ctx: &mut TxContext,
    ) {
        assert_launchpad_admin(launchpad, ctx);

        assert!(
            object_box::is_empty(
                &slot.custom_fee
            ),
            err::generic_box_full(),
        );

        object_box::add<FeeType>(&mut slot.custom_fee, fee);
    }

    // === Creator / Slot Admin Functions ===

    /// Initialises a `Slot` object and registers it in the `Launchpad` object.
    /// Depending if the Launchpad alllows for auto-approval, the launchpad
    /// admin might have to call `approve_slot` in order to validate the slot.
    public entry fun init_slot<FT>(
        launchpad: &Launchpad,
        slot_admin: address,
        receiver: address,
        ctx: &mut TxContext,
    ) {
        let approval = false;

        let is_admin = tx_context::sender(ctx) == launchpad.admin;

        // If the launchpad is permissionless then slots are automatically
        // approved. If the launchpad is permissioned, then the slot is
        // automatically approved only if the sender is the launchpad
        // administrator.
        if (launchpad.auto_approval == true || is_admin) {
            approval = true;
        };

        let uid = object::new(ctx);
        let markets = vector::empty();

        let slot = Slot {
            id: uid,
            launchpad: launchpad_id(launchpad),
            is_approved: approval,
            live: false,
            admin: slot_admin,
            receiver,
            markets,
            proceeds: proceeds::empty<FT>(ctx),
            custom_fee: object_box::empty(ctx),
        };

        transfer::share_object(slot);
    }

    /// Toggle the Slot's `live` to `true` therefore making the NFT sale live.
    /// The Slot can only be live if has been approved.
    public entry fun sale_on(
        slot: &mut Slot,
        ctx: &mut TxContext,
    ) {
        assert_slot_admin(slot, ctx);
        assert_slot_approved(slot);

        slot.live = true
    }

    /// Toggle the Slot's `live` to `false` therefore
    /// pausing or stopping the NFT sale.
    public entry fun sale_off(
        slot: &mut Slot,
        ctx: &mut TxContext,
    ) {
        assert_slot_admin(slot, ctx);

        slot.live = false
    }

    // === Launchpad or Slot Admin Functions ===

    /// Adds a sale outlet `Outlet` to `sales` field
    public entry fun add_market(
        launchpad: &Launchpad,
        slot: &mut Slot,
        market: ObjectBox,
        ctx: &mut TxContext,
    ) {
        assert_slot(launchpad, slot);
        assert_launchpad_or_slot_admin(launchpad, slot, ctx);

        vector::push_back(&mut slot.markets, market);
    }

    // === NFT Buyer Functions ===

    // public entry fun redeem_nft(
    //     slot: &Slot,
    //     certificate: NftCertificate,

    // ) {}

    // === Public Functions for Upstream modules ===

    public fun pay<FT>(
        launchpad: &Launchpad,
        slot: &mut Slot,
        funds: Coin<FT>,
        qty_sold: u64,
    ) {
        assert_slot(launchpad, slot);

        let balance = coin::into_balance(funds);

        let proceeds = proceeds_mut(slot,);

        proceeds::add(
            proceeds,
            balance,
            qty_sold,
        );
    }

    // === Launchpad Getters & Other Functions ===

    /// Get the Slot `id`
    public fun launchpad_id(
        launchpad: &Launchpad,
    ): ID {
        object::uid_to_inner(&launchpad.id)
    }

    /// Get the Slot `id` as reference
    public fun launchpad_id_ref(
        launchpad: &Launchpad,
    ): &ID {
        object::uid_as_inner(&launchpad.id)
    }

    /// Get the Slot's `receiver` address
    public fun launchpad_receiver(
        launchpad: &Launchpad,
    ): address {
        launchpad.receiver
    }

    /// Get the Slot's `admin` address
    public fun launchpad_admin(
        launchpad: &Launchpad,
    ): address {
        launchpad.admin
    }

    public fun default_fee(
        launchpad: &Launchpad,
    ): &ObjectBox {
        &launchpad.default_fee
    }

    public fun is_auto_approved(
        launchpad: &Launchpad,
    ): bool {
        launchpad.auto_approval
    }

    // === Slot Getters & Other Functions ===

    /// Get the Slot `id`
    public fun slot_id(
        slot: &Slot,
    ): ID {
        object::uid_to_inner(&slot.id)
    }

    /// Get the Slot `id` as reference
    public fun slot_id_ref(
        slot: &Slot,
    ): &ID {
        object::uid_as_inner(&slot.id)
    }

    /// Get the Slot's `live`
    public fun live(
        slot: &Slot,
    ): bool {
        slot.live
    }

    /// Get the Slot's `receiver` address
    public fun slot_receiver(
        slot: &Slot,
    ): address {
        slot.receiver
    }

    /// Get the Slot's `admin` address
    public fun slot_admin(
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

    public fun proceeds(
        slot: &Slot,
    ): &Proceeds {
        &slot.proceeds
    }

    public fun slot_has_custom_fee(
        slot: &Slot,
    ): bool {
        !object_box::is_empty(&slot.custom_fee)
    }

    public fun custom_fee(
        slot: &Slot,
    ): &ObjectBox {
        &slot.custom_fee
    }

    public fun proceeds_mut(
        slot: &mut Slot,
    ): &mut Proceeds {
        &mut slot.proceeds
    }

    // === Assertions ===

    public fun assert_slot(
        launchpad: &Launchpad,
        slot: &Slot,
    ) {
        assert!(
            launchpad_id(launchpad) == slot.launchpad,
            err::launchpad_slot_mismatch()
        );
    }

    public fun assert_slot_approved(
        slot: &Slot,
    ) {
        assert!(
            slot.is_approved,
            err::slot_not_approved()
        );
    }

    public fun assert_launchpad_admin(
        launchpad: &Launchpad,
        ctx: &mut TxContext,
    ) {
        assert!(
            tx_context::sender(ctx) == launchpad.admin,
            err::wrong_launchpad_admin()
        );
    }

    public fun assert_slot_admin(
        slot: &Slot,
        ctx: &mut TxContext,
    ) {
        assert!(
            tx_context::sender(ctx) == slot.admin,
            err::wrong_slot_admin()
        );
    }

    public fun assert_default_fee(
        slot: &Slot,
    ) {
        assert!(
            !object_box::is_empty(
                &slot.custom_fee
            ),
            err::has_custom_fee_policy(),
        );
    }

    public fun assert_launchpad_or_slot_admin(
        launchpad: &Launchpad,
        slot: &Slot,
        ctx: &mut TxContext,
    ) {
        let is_launchpad_admin = tx_context::sender(ctx) == launchpad.admin;
        let is_slot_admin = tx_context::sender(ctx) == slot.admin;

        assert!(
            is_launchpad_admin || is_slot_admin,
            err::wrong_admin(),
        );
    }
}
