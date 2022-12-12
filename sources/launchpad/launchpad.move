//! Module of a `Launchpad` type and its associated `Slot`s.
//!
//! The slot acts as the object that configures the primary NFT release
//! strategy, that is the primary market sale. Primary market sales can take
//! many shapes, depending on the business level requirements.
module nft_protocol::launchpad {
    // TODO: Function to delete a slot
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, ID , UID};
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use sui::object_table::{Self, ObjectTable};
    use sui::object_bag::{Self, ObjectBag};

    use nft_protocol::err;
    use nft_protocol::nft::NFT;
    use nft_protocol::proceeds::{Self, Proceeds};
    use nft_protocol::object_box::{Self as obox, ObjectBox};
    use nft_protocol::inventory::{Self, Inventory};

    struct Launchpad has key, store {
        id: UID,
        /// The address of the launchpad administrator
        admin: address,
        /// Receiver of launchpad fees
        receiver: address,
        /// Permissionless launchpads allow for anyone to create their
        /// slots, therefore being immediately approved.
        permissioned: bool,
        default_fee: ObjectBox,
    }

    struct Slot has key, store {
        id: UID,
        launchpad: ID,
        /// Boolean indicating if the sale is live
        live: bool,
        /// The address of the slot administrator, that is, the Nft creator
        admin: address,
        /// The address of the receiver of funds
        receiver: address,
        /// Vector of all markets outlets that, each outles holding IDs
        /// owned by the slot
        markets: ObjectBag,
        inventories: ObjectTable<ID, Inventory>,
        /// Proceeds object holds the balance of Fungible Tokens acquired from
        /// the sale of the Slot
        proceeds: Proceeds,
        /// Field with Object Box holding a Custom Fee implementation if any.
        /// In case this box is empty the calculation will applied on the
        /// default fee object in the associated launchpad
        custom_fee: ObjectBox,
    }

    /// This object acts as an intermediate step between the payment
    /// and the transfer of the NFT. The user first has to call
    /// `buy_nft_certificate` which mints and transfers the `NftCertificate` to
    /// the user. This object will dictate which NFT the userwill receive by
    /// calling the endpoint `claim_nft`
    struct NftCertificate has key, store {
        id: UID,
        launchpad_id: ID,
        slot_id: ID,
        nft_id: ID,
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
        let launchpad = init_launchpad_(
            admin,
            receiver,
            auto_approval,
            default_fee,
            ctx,
        );

        transfer::share_object(launchpad);
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
            obox::is_empty(
                &slot.custom_fee
            ),
            err::generic_box_full(),
        );

        obox::add<FeeType>(&mut slot.custom_fee, fee);
    }

    /// Initialises a `Launchpad` object and returns it
    public fun init_launchpad_(
        admin: address,
        receiver: address,
        permissioned: bool,
        default_fee: ObjectBox,
        ctx: &mut TxContext,
    ): Launchpad {
        let uid = object::new(ctx);

        Launchpad {
            id: uid,
            admin,
            receiver,
            permissioned,
            default_fee,
        }
    }

    // === Creator / Slot Admin Functions ===

    /// Initialises a `Slot` object and registers it in the `Launchpad` object
    /// and shares it.
    /// Depending if the Launchpad allows for auto-approval, the launchpad
    /// admin might have to call `approve_slot` in order to validate the slot.
    public entry fun init_slot(
        launchpad: &Launchpad,
        slot_admin: address,
        receiver: address,
        ctx: &mut TxContext,
    ) {
        let slot = init_slot_(
            launchpad,
            slot_admin,
            receiver,
            ctx,
        );

        transfer::share_object(slot);
    }

    /// Toggle the Slot's `live` to `true` therefore making the NFT sale live.
    /// The Slot can only be live if has been approved.
    public entry fun sale_on(
        slot: &mut Slot,
        ctx: &mut TxContext,
    ) {
        assert_slot_admin(slot, ctx);

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

    /// Initialises a `Slot` object and registers it in the `Launchpad` object
    /// and returns it.
    /// Depending if the Launchpad alllows for auto-approval, the launchpad
    /// admin might have to call `approve_slot` in order to validate the slot.
    public fun init_slot_(
        launchpad: &Launchpad,
        slot_admin: address,
        receiver: address,
        ctx: &mut TxContext,
    ): Slot {
        // If the launchpad is permissioned then slots can only be inserted
        // by the administrator. If the launchpad is permissionless, then
        // anyone can just add slots to it.
        if (launchpad.permissioned == true) {
            assert_launchpad_admin(launchpad, ctx);
        };

        let uid = object::new(ctx);
        let markets = object_bag::new(ctx);
        let inventories = object_table::new<ID, Inventory>(ctx);

        Slot {
            id: uid,
            launchpad: object::id(launchpad),
            live: false,
            admin: slot_admin,
            receiver,
            markets,
            inventories,
            proceeds: proceeds::empty(ctx),
            custom_fee: obox::empty(ctx),
        }
    }

    // === Launchpad or Slot Admin Functions ===

    /// Adds a new Market to `markets` and Inventory to `inventories` tables
    public entry fun add_market<M: key + store>(
        launchpad: &Launchpad,
        slot: &mut Slot,
        market: M,
        inventory: Inventory,
        ctx: &mut TxContext,
    ) {
        assert_slot(launchpad, slot);
        assert_launchpad_or_slot_admin(launchpad, slot, ctx);

        let market_id = object::id(&market);

        object_bag::add<ID, M>(
            &mut slot.markets,
            market_id,
            market,
        );

        object_table::add<ID, Inventory>(
            &mut slot.inventories,
            market_id,
            inventory,
        );
    }

    // === NFT Certificate Functions ===

    // TODO: need to add a function with nft_id as function parameter
    public fun issue_nft_certificate(
        launchpad: &Launchpad,
        slot: &mut Slot,
        market_id: ID,
        ctx: &mut TxContext,
    ): NftCertificate {
        assert_slot(launchpad, slot);
        let inventory = inventory_mut(slot, market_id);

        let nft_id = inventory::pop_nft(inventory);

        let certificate = NftCertificate {
            id: object::new(ctx),
            launchpad_id: object::id(launchpad),
            slot_id: object::id(slot),
            nft_id,
        };

        certificate
    }

    public fun burn_certificate(
        certificate: NftCertificate,
    ) {
        let NftCertificate {
            id,
            launchpad_id: _,
            slot_id: _,
            nft_id: _,
        } = certificate;

        object::delete(id);
    }

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

    /// Adds NFT as a dynamic child object with its ID as key.
    public fun add_nft<C>(
        slot: &mut Slot,
        market_id: ID,
        nft: NFT<C>,
    ) {
        let inventory = inventory_mut(slot, market_id);

        inventory::add_nft(inventory, object::id(&nft));

        dof::add(
            &mut slot.id,
            object::id(&nft),
            nft,
        );
    }

    /// Adds NFT as a dynamic child object with its ID as key.
    public entry fun redeem_nft<C>(
        certificate: NftCertificate,
        slot: &mut Slot,
        recipient: address,
    ) {
        let nft = dof::remove<ID, NFT<C>>(
            &mut slot.id,
            certificate.nft_id,
        );

        transfer::transfer(nft, recipient);
        burn_certificate(certificate);
    }

    // === Launchpad Getters & Other Functions ===

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

    public fun is_permissioned(
        launchpad: &Launchpad,
    ): bool {
        launchpad.permissioned
    }

    // === Slot Getters & Other Functions ===

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

    /// Get the Slot's sale `market` table
    public fun markets(
        slot: &Slot,
    ): &ObjectBag {
        &slot.markets
    }

    /// Get the Slot's `market`
    public fun market<M: key + store>(
        slot: &Slot,
        market_id: ID,
    ): &M {
        object_bag::borrow<ID, M>(&slot.markets, market_id)
    }

    /// Get the Slot's `market` mutably
    public fun market_mut<M: key + store>(
        slot: &mut Slot,
        market_id: ID,
        ctx: &mut TxContext,
    ): &mut M {
        assert_slot_admin(slot, ctx);

        object_bag::borrow_mut<ID, M>(&mut slot.markets, market_id)
    }

    /// Get the Slot's `inventory`
    public fun inventory(
        slot: &Slot,
        market_id: ID,
    ): &Inventory {
        object_table::borrow<ID, Inventory>(&slot.inventories, market_id)
    }

    /// Get the Slot's `market` mutably
    fun inventory_mut(
        slot: &mut Slot,
        market_id: ID,
    ): &mut Inventory {
        object_table::borrow_mut<ID, Inventory>(
            &mut slot.inventories,
            market_id
        )
    }

    public fun proceeds(
        slot: &Slot,
    ): &Proceeds {
        &slot.proceeds
    }

    public fun slot_has_custom_fee(
        slot: &Slot,
    ): bool {
        !obox::is_empty(&slot.custom_fee)
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
            object::id(launchpad) == slot.launchpad,
            err::launchpad_slot_mismatch()
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
            !obox::is_empty(
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
            err::wrong_launchpad_or_slot_admin(),
        );
    }

    public fun assert_market_is_whitelisted(
        slot: &Slot,
        market_id: ID,
    ) {
        let inventory = inventory(slot, market_id);

        assert!(
            inventory::whitelisted(inventory),
            err::sale_is_not_whitelisted()
        );
    }

    public fun assert_market_is_not_whitelisted(
        slot: &Slot,
        market_id: ID,
    ) {
        let inventory = inventory(slot, market_id);

        assert!(
            !inventory::whitelisted(inventory),
            err::sale_is_not_whitelisted()
        );
    }

    public fun assert_is_whitelisted(
        inventory: &Inventory,
    ) {
        assert!(
            inventory::whitelisted(inventory),
            err::sale_is_not_whitelisted()
        );
    }

    public fun assert_is_not_whitelisted(
        inventory: &Inventory,
    ) {
        assert!(
            !inventory::whitelisted(inventory),
            err::sale_is_not_whitelisted()
        );
    }
}
