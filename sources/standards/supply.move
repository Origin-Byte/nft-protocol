/// Module containing `Supply` type
///
/// `Supply` tracks the supply of a given object type or an accumualtion of
/// actions. It tracks the current supply and guarantees that it cannot surpass
/// the maximum supply defined. Among others, this is used to keep track of
/// NFT supply for collections.
///
/// A `Collection` with a defined `Supply` has a regulated supply.
/// Collections can have a ceiling on the maximum supply and keep track
/// of the current supply, whilst unregulated policies have no supply
/// constraints nor they keep track of the number of minted objects.
module nft_protocol::supply_domain {
    use nft_protocol::err;

    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::supply;
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::consumable_witness::{Self as cw, ConsumableWitness};
    use nft_protocol::utils::{assert_with_consumable_witness, UidType};

    /// No field object `Attributes` defined as a dynamic field.
    const EUNDEFINED_SUPPLY_FIELD: u64 = 1;

    /// Field object `Attributes` already defined as dynamic field.
    const ESUPPLY_FIELD_ALREADY_EXISTS: u64 = 2;

    /// Field object `Supply` is set as frozen.
    const ESUPPLY_FROZEN: u64 = 3;


    /// `Supply` tracks supply parameters
    ///
    /// `Supply` can be frozen, therefore making it impossible to change the
    /// maximum supply.
    struct Supply<phantom T> has store {
        mint_cap: MintCap<T>,
        supply: supply::Supply,
        frozen: bool,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Key struct used to store Attributes in dynamic fields
    struct SupplyKey has store, copy, drop {}


    // === Insert with ConsumableWitness ===


    /// Adds `Supply` as a dynamic field with key `SupplyKey`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Supply`.
    ///
    /// #### Panics
    ///
    /// * `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    /// * `MintCap` is regulated, expect the root `MintCap` created at
    /// `Collection` initialization, which is the only `MintCap` with
    /// unregulated supply.
    public fun add_supply<T: key>(
        consumable: ConsumableWitness<T>,
        object_uid: &mut UID,
        object_type: UidType<T>,
        mint_cap: MintCap<T>,
        supply: u64,
        frozen: bool,
    ) {
        assert_has_not_supply(object_uid);
        assert_with_consumable_witness(object_uid, object_type);

        let attributes = new(mint_cap, supply, frozen);

        cw::consume<T, Supply<T>>(consumable, &mut attributes);
        df::add(object_uid, SupplyKey {}, attributes);
    }


    // === Get for call from external Module ===


    /// Creates a `Supply`
    ///
    /// #### Panics
    ///
    /// Panics if `MintCap` is regulated as we expect the root `MintCap`
    /// created at `Collection` initialization to be provided. This will
    /// be the only `MintCap` with unregulated supply.
    fun new<T>(
        mint_cap: MintCap<T>,
        supply: u64,
        frozen: bool,
    ): Supply<T> {
        mint_cap::assert_unregulated(&mint_cap);
        Supply { mint_cap, supply: supply::new(supply), frozen }
    }


    // === Field Borrow Functions ===


    /// Borrows immutably the `Supply` field.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `SupplyKey` does not exist.
    public fun borrow_supply<T>(
        object_uid: &UID,
    ): &Supply<T> {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_supply(object_uid);
        df::borrow(object_uid, SupplyKey {})
    }

    /// Borrows Mutably the `Supply` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Supply`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `SupplyKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun borrow_supply_mut<T: key>(
        consumable: ConsumableWitness<T>,
        object_uid: &mut UID,
        object_type: UidType<T>
    ): &mut Supply<T> {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_supply(object_uid);
        assert_with_consumable_witness(object_uid, object_type);

        let supply = df::borrow_mut<SupplyKey, Supply<T>>(
            object_uid,
            SupplyKey {}
        );
        cw::consume<T, Supply<T>>(consumable, supply);

        supply
    }


    // === Writer Functions ===

    /// Increases maximum supply in `Supply` field in the object of type `T`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    ///
    /// Panics if supply is frozen.
    public fun increase_supply_ceil<T: key>(
        consumable: ConsumableWitness<T>,
        object_uid: &mut UID,
        object_type: UidType<T>,
        value: u64,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_supply(object_uid);
        assert_with_consumable_witness(object_uid, object_type);

        let supply = df::borrow_mut<SupplyKey, Supply<T>>(
            object_uid,
            SupplyKey {}
        );

        cw::consume<T, Supply<T>>(consumable, supply);
        increase_supply_ceil_(supply, value)
    }

    /// Decreases maximum supply in `Supply` field in the object of type `T`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    ///
    /// Panics if supply is frozen.
    ///
    /// Panics if value is supperior to current supply.
    public fun decrease_supply_ceil<T: key>(
        consumable: ConsumableWitness<T>,
        object_uid: &mut UID,
        object_type: UidType<T>,
        value: u64,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_supply(object_uid);
        assert_with_consumable_witness(object_uid, object_type);

        let supply = df::borrow_mut<SupplyKey, Supply<T>>(
            object_uid,
            SupplyKey {}
        );

        cw::consume<T, Supply<T>>(consumable, supply);
        decrease_supply_ceil_(supply, value)
    }

    /// Freezes supply in `Supply` field in the object of type `T`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    ///
    /// Panics if supply is frozen already.
    public fun freeze_supply<T: key>(
        consumable: ConsumableWitness<T>,
        object_uid: &mut UID,
        object_type: UidType<T>,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_supply(object_uid);
        assert_with_consumable_witness(object_uid, object_type);

        let supply = df::borrow_mut<SupplyKey, Supply<T>>(
            object_uid,
            SupplyKey {}
        );

        cw::consume<T, Supply<T>>(consumable, supply);
        freeze_supply_(supply)
    }


    // === Getter Functions & Static Mutability Accessors ===


    /// Increments current supply. This function should be called when an NFT
    /// is minted, if it's type has a supply.
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if new maximum supply exceeds maximum.
    public fun increment_<T>(supply: &mut Supply<T>, value: u64) {
        supply::increment(&mut supply.supply, value);
    }

    /// Decrements current supply. This function should be called when an NFT
    /// is burned, if it's type has a supply.
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if new maximum supply exceeds maximum.
    public fun decrement_<T>(supply: &mut Supply<T>, value: u64) {
        supply::increment(&mut supply.supply, value)
    }

    /// Freezes supply in `Supply` field object.
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if already frozen
    public fun freeze_supply_<T>(supply: &mut Supply<T>) {
        assert_not_frozen(supply);
        supply.frozen = true;
    }

    // TODO: Is the name not duplicated?
    /// Increases maximum supply
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if supply is frozen.
    public fun increase_supply_ceil_<T>(supply: &mut Supply<T>, value: u64) {
        assert_not_frozen(supply);
        supply::increase_maximum(&mut supply.supply, value);
    }

    // TODO: Is the name not duplicated?
    /// Decreases maximum supply
    ///
    /// #### Panics
    ///
    /// Panics if supply is frozen or if new maximum supply is smaller than
    /// current supply.
    public fun decrease_supply_ceil_<T>(supply: &mut Supply<T>, value: u64) {
        assert_not_frozen(supply);
        supply::decrease_maximum(&mut supply.supply, value)
    }

    /// Returns maximum supply
    public fun get_max<T>(supply: &Supply<T>): u64 {
        supply::current(&supply.supply)
    }

    /// Returns current supply
    public fun get_current<T>(supply: &Supply<T>): u64 {
        supply::current(&supply.supply)
    }

    /// Returns remaining supply
    public fun get_remaining_supply<T>(supply: &Supply<T>): u64 {
        supply::supply(&supply.supply)
    }

    public fun is_frozen<T>(supply: &Supply<T>): bool {
        supply.frozen
    }


    // === Assertions & Helpers ===


    /// Checks that a given NFT has a dynamic field with `AttributesKey`
    public fun has_supply(
        object_uid: &UID,
    ): bool {
        df::exists_(object_uid, SupplyKey {})
    }

    /// Asserts that current supply is zero
    public fun assert_zero_current_supply<T>(supply: &Supply<T>) {
        assert!(get_current(supply) == 0, err::supply_is_not_zero())
    }

    /// Asserts that supply is frozen
    public fun assert_frozen<T>(supply: &Supply<T>) {
        assert!(supply.frozen, err::supply_not_frozen())
    }

    /// Asserts that supply is not frozen
    public fun assert_not_frozen<T>(supply: &Supply<T>) {
        assert!(!supply.frozen, ESUPPLY_FROZEN)
    }

    public fun assert_has_supply(object_uid: &UID) {
        assert!(has_supply(object_uid), EUNDEFINED_SUPPLY_FIELD);
    }

    public fun assert_has_not_supply(object_uid: &UID) {
        assert!(!has_supply(object_uid), ESUPPLY_FIELD_ALREADY_EXISTS);
    }

    public fun assert_enough_supply<T>(quantity: u64, supply: &Supply<T>) {
        assert!(
            quantity >= get_remaining_supply(supply),
            ESUPPLY_FIELD_ALREADY_EXISTS
        );
    }
}
