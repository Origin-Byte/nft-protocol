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
module nft_protocol::supply {
    use nft_protocol::err;

    use sui::object::UID;
    use sui::dynamic_field as df;

    friend nft_protocol::warehouse;

    /// No field object `Attributes` defined as a dynamic field.
    const EUNDEFINED_SUPPLY_FIELD: u64 = 1;

    /// Field object `Attributes` already defined as dynamic field.
    const ESUPPLY_FIELD_ALREADY_EXISTS: u64 = 2;


    /// `Supply` tracks supply parameters
    ///
    /// `Supply` can be frozen, therefore making it impossible to change the
    /// maximum supply.
    struct Supply has store, drop {
        frozen: bool,
        max: u64,
        current: u64,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Key struct used to store Attributes in dynamic fields
    struct SupplyKey has store, copy, drop {}


    // === Insert with module specific Witness ===


    /// Adds `Supply` as a dynamic field with key `SupplyKey`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun add_supply<T: key>(
        object_uid: &mut UID,
        max: u64,
        frozen: bool,
    ) {
        assert_has_not_supply(object_uid);

        let supply = new(max, frozen);
        df::add(object_uid, SupplyKey {}, supply);
    }


    // === Get for call from external Module ===


    /// Creates a new `Supply`
    public fun new(max: u64, frozen: bool): Supply {
        Supply { frozen: frozen, max: max, current: 0 }
    }


    // === Field Borrow Functions ===


    /// Borrows immutably the `Supply` field.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `SupplyKey` does not exist.
    public fun borrow_supply(
        object_uid: &UID,
    ): &Supply {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_supply(object_uid);
        df::borrow(object_uid, SupplyKey {})
    }

    /// Borrows Mutably the `Supply` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `SupplyKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun borrow_supply_mut<T: key>(
        object_uid: &mut UID,
    ): &mut Supply {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_supply(object_uid);

        df::borrow_mut(object_uid, SupplyKey {})
    }


    // === Writer Functions ===


    /// Increases maximum supply in `Supply` field in the object of type `T`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    ///
    /// Panics if supply is frozen.
    public fun increase_supply_ceil<T: key>(
        object_uid: &mut UID,
        value: u64,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_supply(object_uid);

        let supply = df::borrow_mut<SupplyKey, Supply>(
            object_uid,
            SupplyKey {}
        );

        assert_not_frozen(supply);
        supply.max = supply.max + value;
    }

    /// Decreases maximum supply in `Supply` field in the object of type `T`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    ///
    /// Panics if value is supperior to current supply.
    public fun decrease_supply_ceil<T: key>(
        object_uid: &mut UID,
        value: u64,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_supply(object_uid);

        let supply = df::borrow_mut<SupplyKey, Supply>(
            object_uid,
            SupplyKey {}
        );

        assert_not_frozen(supply);
        assert!(
            supply.max - value > supply.current,
            err::max_supply_cannot_be_below_current_supply()
        );
        supply.max = supply.max - value;
    }

    /// Freezes supply in `Supply` field in the object of type `T`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
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
        object_uid: &mut UID,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_supply(object_uid);

        let supply = df::borrow_mut<SupplyKey, Supply>(
            object_uid,
            SupplyKey {}
        );

        assert_not_frozen(supply);
        supply.frozen = true;
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
    public fun increment(supply: &mut Supply, value: u64) {
        assert!(
            supply.current + value <= supply.max,
            err::supply_maxed_out()
        );
        supply.current = supply.current + value;
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
    public fun decrement(supply: &mut Supply, value: u64) {
        supply.current = supply.current - value;
    }

    /// Freezes supply in `Supply` field object.
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if already frozen
    public fun freeze_supply_(supply: &mut Supply) {
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
    public fun increase_supply_ceil_(supply: &mut Supply, value: u64) {
        assert_not_frozen(supply);
        supply.max = supply.max + value;
    }

    // TODO: Is the name not duplicated?
    /// Decreases maximum supply
    ///
    /// #### Panics
    ///
    /// Panics if supply is frozen or if new maximum supply is smaller than
    /// current supply.
    public fun decrease_supply_ceil_(supply: &mut Supply, value: u64) {
        assert_not_frozen(supply);
        assert!(
            supply.max - value > supply.current,
            err::max_supply_cannot_be_below_current_supply()
        );
        supply.max = supply.max - value;
    }

    /// Merge two `Supply` to one
    ///
    /// Ideally, the merged `Supply` will have been extended from the original
    /// `Supply`, as otherwise it may not be possible to merge the two
    /// supplies.
    ///
    /// Any excess supply on the merged `Supply` will be decremented from the
    /// original supply.
    ///
    /// #### Panics
    ///
    /// Panics if total supply will cause maximum or zero supply to be
    /// exceeded.
    public fun merge(supply: &mut Supply, other: Supply) {
        let excess = other.max - other.current;
        decrement(supply, excess);
        increment(supply, other.current);
    }

    /// Split one `Supply` into two.
    ///
    /// #### Panics
    ///
    /// Panics if `split_max` is superior to `Supply.max`
    /// Panics if `split_current` is superior to `Supply.current`
    /// Panics if the result leads to `current > max`
    public fun split(
        supply: &mut Supply,
        split_max: u64,
    ): Supply {
        decrease_supply_ceil_(supply, split_max);
        let new_supply = new(split_max, false);

        new_supply
    }

    /// Returns maximum supply
    public fun get_max(supply: &Supply): u64 {
        supply.max
    }

    /// Returns current supply
    public fun get_current(supply: &Supply): u64 {
        supply.current
    }

    /// Returns `true` if frozen
    public fun is_frozen(supply: &Supply): bool {
        supply.frozen
    }

    /// Returns remaining supply
    public fun get_remaining_supply(supply: &Supply): u64 {
        supply.max - supply.current
    }


    // === Assertions & Helpers ===


    /// Checks that a given NFT has a dynamic field with `AttributesKey`
    public fun has_supply(
        object_uid: &UID,
    ): bool {
        df::exists_(object_uid, SupplyKey {})
    }

    /// Asserts that current supply is zero
    public fun assert_zero_current_supply(supply: &Supply) {
        assert!(supply.current == 0, err::supply_is_not_zero())
    }

    /// Asserts that supply is frozen
    public fun assert_frozen(supply: &Supply) {
        assert!(supply.frozen, err::supply_not_frozen())
    }

    /// Asserts that supply is not frozen
    public fun assert_not_frozen(supply: &Supply) {
        assert!(!supply.frozen, err::supply_frozen())
    }

    public fun assert_has_supply(object_uid: &UID) {
        assert!(has_supply(object_uid), EUNDEFINED_SUPPLY_FIELD);
    }

    public fun assert_has_not_supply(object_uid: &UID) {
        assert!(!has_supply(object_uid), ESUPPLY_FIELD_ALREADY_EXISTS);
    }
}
