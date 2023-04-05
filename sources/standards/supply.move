/// Module containing `Supply` type
///
/// `Supply` is an unprotected type tracking the current supply and enforcing a
/// maximum limit.
module nft_protocol::supply {
    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::utils::{Self, Marker};

    /// `Supply` was not defined
    ///
    /// Call `supply::add_domain` to add `Supply`.
    const EUndefinedSupply: u64 = 1;

    /// `Supply` already defined
    ///
    /// Call `supply::borrow_domain` to borrow domain.
    const EExistingSupply: u64 = 2;

    /// Could not increment supply due to breached limit
    const ENoAvailableSupply: u64 = 3;

    /// Cannot set minimum supply below the current issued supply
    const EInvalidMinimumSupply: u64 = 4;

    /// Current issued supply was non-zero
    const ENonZeroSupply: u64 = 5;

    /// `Supply` tracks supply parameters
    struct Supply has store, drop {
        max: u64,
        current: u64,
    }

    /// Creates a new `Supply` object
    public fun new(max: u64): Supply {
        Supply { max: max, current: 0 }
    }

    /// Maximum supply
    public fun get_max(supply: &Supply): u64 {
        supply.max
    }

    /// Current supply
    public fun get_current(supply: &Supply): u64 {
        supply.current
    }

    /// Return remaining supply
    public fun get_supply(supply: &Supply): u64 {
        supply.max - supply.current
    }

    /// Increases maximum supply
    ///
    /// #### Panics
    ///
    /// Panics if supply is frozen.
    public fun increase_maximum(supply: &mut Supply, value: u64) {
        supply.max = supply.max + value;
    }

    /// Decreases maximum supply
    ///
    /// #### Panics
    ///
    /// Panics if supply is frozen or if new maximum supply is smaller than
    /// current supply.
    public fun decrease_maximum(supply: &mut Supply, value: u64) {
        assert!(
            supply.max - value > supply.current,
            EInvalidMinimumSupply,
        );
        supply.max = supply.max - value;
    }

    /// Increments current supply
    ///
    /// #### Panics
    ///
    /// Panics if new maximum supply exceeds maximum.
    public fun increment(supply: &mut Supply, value: u64) {
        assert!(
            supply.current + value <= supply.max,
            ENoAvailableSupply,
        );
        supply.current = supply.current + value;
    }

    /// Decrements current supply
    public fun decrement(supply: &mut Supply, value: u64) {
        supply.current = supply.current - value;
    }

    /// Creates a new `Supply` which is split from the current `Supply`
    ///
    /// The extend value is used as the maximum supply for the new `Supply`,
    /// while the current supply of the existing supply is incremented by the
    /// value.
    ///
    /// Existing `Supply` will be automatically frozen if not already frozen.
    ///
    /// #### Panics
    ///
    /// Panics if not frozen or if value will cause maximum supply to be
    /// exceeded.
    public fun split(supply: &mut Supply, value: u64): Supply {
        decrease_maximum(supply, value);
        new(value)
    }

    /// Merge `Supply` into another
    ///
    /// Does not require that either `Supply` is frozen, since splitting supply
    /// requires that both supplies are frozen, thus merging will only make
    /// sense with frozen supplies.
    public fun merge(supply: &mut Supply, other: Supply) {
        let Supply { max, current } = other;
        increase_maximum(supply, max);
        increment(supply, current);
    }

    // === Interoperability ===

    /// Returns whether `Supply` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<Supply>, Supply>(
            nft, utils::marker(),
        )
    }

    /// Borrows `Supply` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &Supply {
        assert_supply(nft);
        df::borrow(nft, utils::marker<Supply>())
    }

    /// Mutably borrows `Supply` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut Supply {
        assert_supply(nft);
        df::borrow_mut(nft, utils::marker<Supply>())
    }

    /// Adds `Supply` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: Supply,
    ) {
        assert_no_supply(nft);
        df::add(nft, utils::marker<Supply>(), domain);
    }

    /// Remove `Supply` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` domain doesnt exist
    public fun remove_domain(nft: &mut UID): Supply {
        assert_supply(nft);
        df::remove(nft, utils::marker<Supply>())
    }

    // === Assertions ===

    /// Asserts that current supply is zero
    ///
    /// #### Panics
    ///
    /// Panics if supply is non-zero.
    public fun assert_zero(supply: &Supply) {
        assert!(supply.current == 0, ENonZeroSupply)
    }

    /// Asserts that `Supply` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` is not registered
    public fun assert_supply(nft: &UID) {
        assert!(has_domain(nft), EUndefinedSupply);
    }

    /// Asserts that `Supply` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` is registered
    public fun assert_no_supply(nft: &UID) {
        assert!(!has_domain(nft), EExistingSupply);
    }
}
