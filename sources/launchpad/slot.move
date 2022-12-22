/// Module for an NFT release `Slot`
///
/// After the creation of the `Launchpad` a `Slot` for the NFT release needs
/// to be created. Whilst the `Launchpad` stipulates a default fee policy,
/// the launchpad admin can decide to create a custom fee policy for each
/// release `Slot`.
///
/// The slot acts as the object that configures the primary NFT release
/// strategy, that is the primary market sale. Primary market sales can take
/// many shapes, depending on the business level requirements.
module nft_protocol::slot {
    // TODO: Consider adding a function redeem_certificate with `nft_id` as
    // a parameter
    use sui::transfer;
    use sui::balance::Balance;
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
        /// `Launchpad` ID to which the `Slot` this certificate is assigned
        ///
        /// Intended for discoverability
        launchpad_id: ID,
        /// `Slot` ID to which the `Market` this certificate is assigned
        ///
        /// Intended for discoverability
        slot_id: ID,
        /// `Market` from which this certificate can withdraw an `Nft`
        market_id: ID,
        /// ID of the `Nft` which can be withdrawn using this certificate
        nft_id: ID,
    }

    /// Issue `NftCertificate`
    ///
    /// Requires that sender is the `Slot` admin
    public fun issue_nft_certificate(
        launchpad: &Launchpad,
        slot: &mut Slot,
        market_id: ID,
        ctx: &mut TxContext,
    ): NftCertificate {
        assert_slot_launchpad_match(launchpad, slot);
        assert_slot_admin(slot, ctx);

        let inventory = inventory_mut(slot, market_id);
        let nft_id = inventory::pop_nft_from_sale(inventory);

        NftCertificate {
            id: object::new(ctx),
            launchpad_id: object::id(launchpad),
            slot_id: object::id(slot),
            market_id,
            nft_id,
        }
    }

    /// Issue `NftCertificate`
    ///
    /// Does not require that sender is the `Slot` admin allowing markets to
    /// issue certificates.
    public fun issue_nft_certificate_internal<
        Market: key + store,
        Witness: drop
    >(
        _witness: Witness,
        launchpad: &Launchpad,
        slot: &mut Slot,
        market_id: ID,
        ctx: &mut TxContext,
    ): NftCertificate {
        assert_slot_launchpad_match(launchpad, slot);

        utils::assert_same_module_as_witness<Market, Witness>();
        assert_market<Market>(slot, market_id);

        let inventory = inventory_mut(slot, market_id);
        let nft_id = inventory::pop_nft_from_sale(inventory);

        NftCertificate {
            id: object::new(ctx),
            launchpad_id: object::id(launchpad),
            slot_id: object::id(slot),
            market_id,
            nft_id,
        }
    }

    public entry fun transfer_nft_certificate(
        launchpad: &Launchpad,
        slot: &mut Slot,
        market_id: ID,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let certificate = issue_nft_certificate(
            launchpad,
            slot,
            market_id,
            ctx,
        );
        transfer::transfer(certificate, recipient);
    }

    public fun burn_nft_certificate(
        certificate: NftCertificate,
    ) {
        let NftCertificate {
            id,
            launchpad_id: _,
            slot_id: _,
            market_id: _,
            nft_id: _,
        } = certificate;

        object::delete(id);
    }

    // === WhitelistCertificate ===

    /// Whitin a release `Slot`, each market has its own whitelist policy.
    /// As an example, creators can create tiered sales based on the NFT rarity,
    /// and then whitelist only the rare NFT sale. They can then emit whitelist
    /// tokens and send them to users who have completed a set of defined actions.
    struct WhitelistCertificate has key, store {
        id: UID,
        /// `Launchpad` ID intended for discoverability
        launchpad_id: ID,
        /// `Slot` from which this certificate can withdraw an `Nft`
        slot_id: ID,
        /// `Inventory` from which this certificate can withdraw an `Nft`
        market_id: ID,
    }

    public fun issue_whitelist_certificate(
        launchpad: &Launchpad,
        slot: &Slot,
        market_id: ID,
        ctx: &mut TxContext,
    ): WhitelistCertificate {
        assert_slot_launchpad_match(launchpad, slot);
        assert_slot_admin(slot, ctx);

        let certificate = WhitelistCertificate {
            id: object::new(ctx),
            launchpad_id: object::id(launchpad),
            slot_id: object::id(slot),
            market_id,
        };

        certificate
    }

    public entry fun transfer_whitelist_certificate(
        launchpad: &Launchpad,
        slot: &Slot,
        market_id: ID,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let certificate = issue_whitelist_certificate(
            launchpad,
            slot,
            market_id,
            ctx,
        );
        transfer::transfer(certificate, recipient);
    }

    public fun burn_whitelist_certificate(
        certificate: WhitelistCertificate,
    ) {
        let WhitelistCertificate {
            id,
            launchpad_id: _,
            slot_id: _,
            market_id: _,
        } = certificate;

        object::delete(id);
    }

    // === Slot ===

    struct Slot has key, store {
        id: UID,
        launchpad_id: ID,
        /// Boolean indicating if the `Slot` is live
        live: bool,
        /// The address of the `Slot` administrator
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
            launchpad_id: object::id(launchpad),
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
        slot: &mut Slot,
        balance: Balance<FT>,
        qty_sold: u64,
    ) {
        let proceeds = proceeds_mut(slot);
        proceeds::add(proceeds, balance, qty_sold);
    }

    /// Adds NFT as a dynamic child object with its ID as key
    public fun redeem_nft<C>(
        certificate: NftCertificate,
        slot: &mut Slot,
    ): Nft<C> {
        assert_nft_certificate_slot(object::id(slot), &certificate);
        assert_contains_nft<C>(slot, certificate.nft_id);

        let inventory = inventory_mut(slot, certificate.market_id);

        let nft = inventory::redeem_nft(inventory, certificate.nft_id);

        burn_nft_certificate(certificate);

        nft
    }

    public entry fun transfer_nft<C>(
        certificate: NftCertificate,
        slot: &mut Slot,
        recipient: address,
    ) {
        let nft = redeem_nft<C>(certificate, slot);
        transfer::transfer(nft, recipient);
    }

    /// === Admin functions ===

    /// Adds a fee object to the Slot's `custom_fee`
    ///
    /// Can only be called by the `Launchpad` admin
    public entry fun add_fee<FeeType: key + store>(
        launchpad: &Launchpad,
        slot: &mut Slot,
        fee: FeeType,
        ctx: &mut TxContext,
    ) {
        assert_slot_launchpad_match(launchpad, slot);
        lp::assert_launchpad_admin(launchpad, ctx);
        assert!(
            obox::is_empty(&slot.custom_fee),
            err::generic_box_full(),
        );

        obox::add<FeeType>(&mut slot.custom_fee, fee);
    }

    /// Adds a new Market to `markets` and Inventory to `inventories` tables
    public entry fun add_market<Market: key + store>(
        slot: &mut Slot,
        market: Market,
        inventory: Inventory,
        ctx: &mut TxContext,
    ) {
        assert_slot_admin(slot, ctx);

        let market_id = object::id(&market);

        object_bag::add<ID, Market>(
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

    /// Adds NFT as a dynamic child object with its ID as key
    public entry fun add_nft<C>(
        slot: &mut Slot,
        market_id: ID,
        nft: Nft<C>,
        ctx: &mut TxContext,
    ) {
        assert_slot_admin(slot, ctx);

        let nft_id = object::id(&nft);

        let inventory = inventory_mut(slot, market_id);
        inventory::register_nft_for_sale(inventory, nft_id);

        dof::add(&mut slot.id, nft_id, nft);
    }

    /// Toggle the Slot's `live` to `true` therefore making the NFT sale live
    public entry fun sale_on(
        slot: &mut Slot,
        ctx: &mut TxContext,
    ) {
        assert_slot_admin(slot, ctx);
        slot.live = true
    }

    /// Toggle the Slot's `live` to `false` therefore pausing or stopping the
    /// NFT sale
    ///
    /// Can also be turned off by the Launchpad admin
    public entry fun sale_off(
        launchpad: &Launchpad,
        slot: &mut Slot,
        ctx: &mut TxContext,
    ) {
        assert_slot_launchpad_match(launchpad, slot);
        assert_correct_admin(launchpad, slot, ctx);
        slot.live = false
    }

    // === Getter functions ===

    /// Get the Slot's `live`
    public fun is_live(slot: &Slot): bool {
        slot.live
    }

    /// Get the Slot's `receiver` address
    public fun receiver(slot: &Slot): address {
        slot.receiver
    }

    /// Get the Slot's `admin` address
    public fun admin(slot: &Slot): address {
        slot.admin
    }

    public fun contains_custom_fee(slot: &Slot): bool {
        !obox::is_empty(&slot.custom_fee)
    }

    public fun custom_fee(slot: &Slot): &ObjectBox {
        &slot.custom_fee
    }

    public fun proceeds(slot: &Slot): &Proceeds {
        &slot.proceeds
    }

    public fun proceeds_mut(slot: &mut Slot): &mut Proceeds {
        &mut slot.proceeds
    }

    /// Get the Slot's sale `market` table
    public fun markets(slot: &Slot): &ObjectBag {
        &slot.markets
    }

    /// Get the Slot's `market`
    public fun market<Market: key + store>(
        slot: &Slot,
        market_id: ID,
    ): &Market {
        assert_market<Market>(slot, market_id);
        object_bag::borrow<ID, Market>(&slot.markets, market_id)
    }

    /// Get the Slot's `market` mutably
    ///
    /// This will require that sender is a `Slot` admin, for non admin mutable
    /// access use `market_internal_mut`.
    public fun market_mut<Market: key + store>(
        slot: &mut Slot,
        market_id: ID,
        ctx: &mut TxContext,
    ): &mut Market {
        assert_slot_admin(slot, ctx);
        assert_market<Market>(slot, market_id);
        object_bag::borrow_mut<ID, Market>(&mut slot.markets, market_id)
    }

    /// Get the Slot's `market` mutably
    ///
    /// Does not require that sender is a `Slot` admin, limited for use only in
    /// the module that defined the market type.
    public fun market_internal_mut<Market: key + store, Witness: drop>(
        _witness: Witness,
        slot: &mut Slot,
        market_id: ID,
    ): &mut Market {
        utils::assert_same_module_as_witness<Market, Witness>();
        assert_market<Market>(slot, market_id);
        object_bag::borrow_mut<ID, Market>(&mut slot.markets, market_id)
    }

    /// Get the Slot's `Inventory`
    public fun inventory(slot: &Slot, market_id: ID): &Inventory {
        assert_inventory(slot, market_id);
        object_table::borrow(&slot.inventories, market_id)
    }

    /// Get the Slot's `Inventory` mutably
    fun inventory_mut(slot: &mut Slot, market_id: ID): &mut Inventory {
        assert_inventory(slot, market_id);
        object_table::borrow_mut(&mut slot.inventories, market_id)
    }

    // === Assertions ===

    public fun assert_slot_launchpad_match(launchpad: &Launchpad, slot: &Slot) {
        assert!(
            object::id(launchpad) == slot.launchpad_id,
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
        if (lp::is_permissioned(launchpad)) {
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

    public fun assert_contains_nft<C>(slot: &Slot, nft_id: ID) {
        assert!(
            dof::exists_with_type<ID, Nft<C>>(&slot.id, nft_id),
            err::undefined_nft_id()
        );
    }

    public fun assert_nft_certificate_slot(
        slot_id: ID,
        certificate: &NftCertificate,
    ) {
        assert!(
            certificate.slot_id == slot_id,
            err::incorrect_nft_certificate()
        )
    }

    public fun assert_whitelist_certificate_market(
        market_id: ID,
        certificate: &WhitelistCertificate,
    ) {
        // Infer that whitelist token corresponds to correct sale inventory
        assert!(
            certificate.market_id == market_id,
            err::incorrect_whitelist_certificate()
        );
    }
}
