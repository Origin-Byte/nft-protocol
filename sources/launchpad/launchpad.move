//! Module of a `Launchpad` type and its associated `Slot`s.
//!
//! It acts as a generic interface for Launchpads and it allows for
//! the creation of arbitrary domain specific implementations.
//!
//! The slot acts as the object that configures the primary NFT release
//! strategy, that is the primary market sale. Primary market sales can take
//! many shapes, depending on the business level requirements.
module nft_protocol::launchpad {
    use std::vector;
    use std::type_name;

    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::table::{Self, Table};
    use sui::object::{Self, ID , UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use nft_protocol::utils;
    use nft_protocol::proceeds::{Self, Proceeds};
    use nft_protocol::box::{Self, Box};
    use nft_protocol::object_box::{Self, ObjectBox};

    struct Launchpad has key, store{
        id: UID,
        /// The address of the administrator
        admin: address,
        receiver: address,
        permissionless: bool,
        proceeds: Table<ID, Box>,
        // TODO: Shouldn't this be ObjectTable??
        fee_policies: Table<ID, ObjectBox>,
        default_fee: u64,
    }

    struct Slot has key, store {
        id: UID,
        launchpad: ID,
        is_approved: bool,
        /// The ID of the Collections object
        collections: vector<ID>,
        /// Boolean indicating if the sale is live
        live: bool,
        /// The address of the slot administrator, that is, the Nft creator
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
        receiver: address,
        permissionless: bool,
        default_fee: u64,
        ctx: &mut TxContext,
    ) {
        let uid = object::new(ctx);

        let id = object::uid_to_inner(&uid);

        let launchpad = Launchpad {
            id: uid,
            admin,
            receiver,
            permissionless,
            proceeds: table::new<ID, Box>(ctx),
            fee_policies: table::new<ID, ObjectBox>(ctx),
            default_fee,
        };
    }

    // === Slot Functions ===

    /// Initialises a `Slot` object and registers it in the `Launchpad` object
    public fun init_slot<C: store + drop>(
        launchpad: &mut Launchpad,
        slot_admin: address,
        collections: vector<ID>,
        receiver: address,
        is_embedded: bool,
        ctx: &mut TxContext,
    ) {
        let approval = false;

        let is_admin = tx_context::sender(ctx) == launchpad.admin;

        // If the launchpad is permissionless then slots are automatically
        // approved. If the launchpad is permissioned, then the slot is
        // automatically approved only if the sender is the launchpad
        // administrator.
        if (launchpad.permissionless == true || is_admin) {
            approval = true;
        };

        let uid = object::new(ctx);
        let id = object::uid_to_inner(&uid);

        let markets = vector::empty();

        let slot = Slot {
            id: uid,
            launchpad: launchpad_id(launchpad),
            is_approved: approval,
            collections,
            live: false,
            admin: slot_admin,
            receiver,
            markets,
            is_embedded,
        };

        table::add(
            &mut launchpad.proceeds,
            id,
            box::new(
                proceeds::create<C>(
                    balance::zero<C>(), receiver, ctx
                ),
            ctx,
            ),
        );

        transfer::share_object(slot);
    }

    public fun approve_slot<C: store + drop>(
        launchpad: &Launchpad,
        slot: &mut Slot,
        ctx: &mut TxContext,
    ) {
        assert_slot(launchpad, slot);
        assert_launchpad_admin(launchpad, ctx);

        slot.is_approved = true;
    }

    /// Toggle the Slot's `live` to `true` therefore
    /// making the NFT sale live.
    public fun sale_on(
        slot: &mut Slot,
        ctx: &mut TxContext,
    ) {
        assert!(
            tx_context::sender(ctx) == slot.admin,
            err::wrong_slot_admin()
        );

        slot.live = true
    }

    /// Toggle the Slot's `live` to `false` therefore
    /// pausing or stopping the NFT sale.
    public fun sale_off(
        slot: &mut Slot,
        ctx: &mut TxContext,
    ) {
        assert_slot_admin(slot, ctx);

        slot.live = false
    }

    /// Adds a sale outlet `Outlet` to `sales` field
    public fun add_market(
        launchpad: &Launchpad,
        slot: &mut Slot,
        market: ObjectBox,
        ctx: &mut TxContext,
    ) {
        assert_slot(launchpad, slot);

        if (launchpad.permissionless == false) {
            assert_launchpad_admin(launchpad, ctx);
        };
        vector::push_back(&mut slot.markets, market);
    }

    /// Adds a sale outlet `Outlet` to `sales` field
    public fun add_fee<FeeType: key + store>(
        launchpad: &mut Launchpad,
        slot_id: ID,
        fee: FeeType,
        ctx: &mut TxContext,
    ) {
        assert_launchpad_admin(launchpad, ctx);

        table::add(
            &mut launchpad.fee_policies,
            slot_id,
            object_box::new(
                fee,
            ctx,
            ),
        );
    }

    public fun pay<FT: key + store>(
        launchpad: &mut Launchpad,
        slot: &mut Slot,
        funds: Coin<FT>,
        price: u64,
        ctx: &mut TxContext,
    ) {
        assert_slot(launchpad, slot);

        assert!(coin::value(&funds) > price, err::coin_amount_below_price());

        let change = coin::split<FT>(
            &mut funds,
            price,
            ctx,
        );

        let balance = coin::into_balance(funds);

        let proceeds = proceeds_mut<FT>(
            launchpad,
            slot_id(slot),
        );

        balance::join(proceeds::balance_mut(proceeds), balance);

    }

    public entry fun collect_fee<FT>(
        launchpad: &mut Launchpad,
        slot: &Slot,
        ctx: &mut TxContext,
    ) {
        assert_slot(launchpad, slot);
        assert_default_fee(launchpad, slot);

        let proceeds = proceeds_mut<FT>(
            launchpad,
            slot_id(slot),
        );

        let fee_balance = balance::split<FT>(
            proceeds::balance_mut(proceeds),
            balance::value(proceeds::balance(proceeds)) * launchpad.default_fee,
        );

        let fee = coin::from_balance(fee_balance, ctx);

        transfer::transfer(
            fee,
            launchpad.receiver,
        )

    }

    // === Getter Functions ===object::uid_to_inner(&launchpad.id)

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

    /// Get the Slot's `is_embedded` bool
    public fun is_embedded(
        slot: &Slot,
    ): bool {
        slot.is_embedded
    }

    public fun proceeds<FT>(
        launchpad: &Launchpad,
        slot_id: ID,
    ): &Proceeds<FT> {
        let box = box::borrow_object<Proceeds<FT>>(
            table::borrow<ID, Box>(&launchpad.proceeds, slot_id)
        );

        box
    }

    // TODO: Only module from market can call this function
    public fun proceeds_mut<FT>(
        launchpad: &mut Launchpad,
        slot_id: ID,
    ): &mut Proceeds<FT> {
        // let (package_a, module_a, _) = utils::get_package_module_type<FeeType>();

        // assert!(
        //     module_a ==
        // )

        let box = box::borrow_object_mut<Proceeds<FT>>(
            table::borrow_mut<ID, Box>(&mut launchpad.proceeds, slot_id)
        );

        box
    }

    public fun assert_slot(
        launchpad: &Launchpad,
        slot: &Slot,
    ) {
        assert!(
            launchpad_id(launchpad) == slot.launchpad,
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
        launchpad: &Launchpad,
        slot: &Slot,
    ) {
        table::contains<ID, ObjectBox>(&launchpad.fee_policies, slot_id(slot));
    }
}
