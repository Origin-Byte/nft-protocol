module nft_protocol::slot {
    // TODO: Consider adding a function redeem_certificate with `nft_id` as
    // a parameter
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, ID , UID};
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use sui::object_table::{Self, ObjectTable};
    use sui::object_bag::{Self, ObjectBag};

    use nft_protocol::err;
    use nft_protocol::utils;
    use nft_protocol::nft::Nft;
    use nft_protocol::launchpad::{Self as lp, Launchpad};
    use nft_protocol::proceeds::{Self, Proceeds};
    use nft_protocol::object_box::{Self as obox, ObjectBox};
    use nft_protocol::inventory::{Self, Inventory};

    // === NftCertificate ===

    /// This object acts as an intermediate step between the payment
    /// and the transfer of the NFT. The user first has to call
    /// `buy_nft_certificate` which mints and transfers the `NftCertificate` to
    /// the user. This object will dictate which NFT will the user receive by
    /// calling the endpoint `claim_nft`
    struct NftCertificate has key, store {
        id: UID,
        launchpad_id: ID,
        slot_id: ID,
        nft_id: ID,
    }

    public fun issue_nft_certificate(
        launchpad: &Launchpad,
        slot: &mut Slot,
        market_id: ID,
        ctx: &mut TxContext,
    ): NftCertificate {
        assert_slot_launchpad_match(launchpad, slot);
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

    // === Slot ===

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

    struct CreateSlotEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    struct DeleteSlotEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    /// Initialises a `Slot` object and registers it in the `Launchpad` object
    /// and returns it.
    /// Depending if the Launchpad alllows for auto-approval, the launchpad
    /// admin might have to call `approve_slot` in order to validate the slot.
    public fun new(
        launchpad: &Launchpad,
        slot_admin: address,
        receiver: address,
        ctx: &mut TxContext,
    ): Slot {
        // If the launchpad is permissioned then slots can only be inserted
        // by the administrator. If the launchpad is permissionless, then
        // anyone can just add slots to it.
        if (lp::is_permissioned(launchpad)) {
            lp::assert_launchpad_admin(launchpad, ctx);
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
        let slot = new(
            launchpad,
            slot_admin,
            receiver,
            ctx,
        );

        transfer::share_object(slot);
    }

    /// === Public functions ===

    public fun pay<FT>(
        launchpad: &Launchpad,
        slot: &mut Slot,
        funds: Coin<FT>,
        qty_sold: u64,
    ) {
        assert_slot_launchpad_match(launchpad, slot);

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
        nft: Nft<C>,
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
        let nft = dof::remove<ID, Nft<C>>(
            &mut slot.id,
            certificate.nft_id,
        );

        transfer::transfer(nft, recipient);
        burn_certificate(certificate);
    }

    /// === Admin functions ===

    /// Adds a fee object to the Slot's `custom_fee`
    public entry fun add_fee<FeeType: key + store>(
        slot: &mut Slot,
        fee: FeeType,
    ) {
        assert!(
            obox::is_empty(&slot.custom_fee),
            err::generic_box_full(),
        );

        obox::add<FeeType>(&mut slot.custom_fee, fee);
    }

    /// Adds a new Market to `markets` and Inventory to `inventories` tables
    public entry fun add_market<M: key + store>(
        launchpad: &Launchpad,
        slot: &mut Slot,
        market: M,
        inventory: Inventory,
        ctx: &mut TxContext,
    ) {
        assert_slot_launchpad_match(launchpad, slot);
        assert_correct_admin(launchpad, slot, ctx);

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

    // === Getter functions ===

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

    public fun contains_custom_fee(
        slot: &Slot,
    ): bool {
        !obox::is_empty(&slot.custom_fee)
    }

    public fun custom_fee(
        slot: &Slot,
    ): &ObjectBox {
        &slot.custom_fee
    }

    public fun proceeds(
        slot: &Slot,
    ): &Proceeds {
        &slot.proceeds
    }

    public fun proceeds_mut(
        slot: &mut Slot,
    ): &mut Proceeds {
        &mut slot.proceeds
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
        assert_market<M>(slot, market_id);
        object_bag::borrow<ID, M>(&slot.markets, market_id)
    }

    /// Get the Slot's `market` mutably
    ///
    /// This will require that sender is a `Slot` admin, for non admin mutable
    /// access use `market_internal_mut`.
    public fun market_mut<M: key + store>(
        slot: &mut Slot,
        market_id: ID,
        ctx: &mut TxContext,
    ): &mut M {
        assert_slot_admin(slot, ctx);
        assert_market<M>(slot, market_id);
        object_bag::borrow_mut<ID, M>(&mut slot.markets, market_id)
    }

    /// Get the Slot's `market` mutably
    ///
    /// Does not require that sender is a `Slot` admin, limited for use only in
    /// the module that defined the market type.
    public fun market_internal_mut<M: key + store, W: drop>(
        _witness: W,
        slot: &mut Slot,
        market_id: ID,
    ): &mut M {
        utils::assert_same_module_as_witness<W, M>();
        assert_market<M>(slot, market_id);
        object_bag::borrow_mut<ID, M>(&mut slot.markets, market_id)
    }

    /// Get the Slot's `inventory`
    public fun inventory(slot: &Slot, market_id: ID): &Inventory {
        assert_inventory(slot, market_id);
        object_table::borrow(&slot.inventories, market_id)
    }

    /// Get the Slot's `market` mutably
    fun inventory_mut(slot: &mut Slot, market_id: ID): &mut Inventory {
        assert_inventory(slot, market_id);
        object_table::borrow_mut(&mut slot.inventories, market_id)
    }

    // === Assertions ===

    public fun assert_slot_launchpad_match(launchpad: &Launchpad, slot: &Slot) {
        assert!(
            object::id(launchpad) == slot.launchpad,
            err::launchpad_slot_mismatch()
        );
    }

    public fun assert_slot_admin(slot: &Slot, ctx: &mut TxContext) {
        assert!(
            tx_context::sender(ctx) == slot.admin,
            err::wrong_slot_admin()
        );
    }

    public fun assert_correct_admin(
        launchpad: &Launchpad,
        slot: &Slot,
        ctx: &mut TxContext,
    ) {
        if (lp::is_permissioned(launchpad) == true) {
            lp::assert_launchpad_admin(launchpad, ctx);
        } else {
            assert_slot_admin(slot, ctx);
        }
    }

    public fun assert_is_live(slot: &Slot) {
        assert!(slot.live, err::slot_not_live());
    }

    public fun assert_default_fee(slot: &Slot) {
        assert!(
            !obox::is_empty(&slot.custom_fee),
            err::has_custom_fee_policy(),
        );
    }

    public fun assert_inventory(slot: &Slot, market_id: ID) {
        assert!(
            object_table::contains(&slot.inventories, market_id),
            err::undefined_market(),
        );
    }

    public fun assert_market<M: key + store>(slot: &Slot, market_id: ID) {
        assert!(
            object_bag::contains_with_type<ID, M>(&slot.markets, market_id),
            err::undefined_market(),
        );
    }

    public fun assert_market_is_whitelisted(slot: &Slot, market_id: ID ) {
        let inventory = inventory(slot, market_id);

        assert!(
            inventory::is_whitelisted(inventory),
            err::sale_is_not_whitelisted()
        );
    }

    public fun assert_market_is_not_whitelisted(slot: &Slot, market_id: ID) {
        let inventory = inventory(slot, market_id);

        assert!(
            !inventory::is_whitelisted(inventory),
            err::sale_is_whitelisted()
        );
    }
}
