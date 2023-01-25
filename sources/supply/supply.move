/// Module containing `Supply` type
///
/// `Supply` tracks the supply of a given object type or an accumualtion of
/// actions. It tracks the current supply and guarantees that it cannot surpass
/// the maximum supply defined. Among others, this is used to keep track of
/// NFT supply for collections.
module nft_protocol::supply {
    use nft_protocol::err;

    /// `Supply` tracks supply parameters
    ///
    /// `Supply` can be frozen, therefore making it impossible to change the
    /// maximum supply.
    struct Supply has store, drop {
        frozen: bool,
        max: u64,
        current: u64,
    }

    /// Creates a new `Supply` object
    public fun new(max: u64, frozen: bool): Supply {
        Supply { frozen: frozen, max: max, current: 0 }
    }

    /// Maximum supply
    public fun max(supply: &Supply): u64 {
        supply.max
    }

    /// Current supply
    public fun current(supply: &Supply): u64 {
        supply.current
    }

    /// Increases maximum supply
    ///
    /// #### Panics
    ///
    /// Panics if supply is frozen.
    public fun increase_maximum(supply: &mut Supply, value: u64) {
        assert_not_frozen(supply);
        supply.max = supply.max + value;
    }

    /// Decreases maximum supply
    ///
    /// #### Panics
    ///
    /// Panics if supply is frozen or if new maximum supply is smaller than
    /// current supply.
    public fun decrease_maximum(supply: &mut Supply, value: u64) {
        assert_not_frozen(supply);
        assert!(
            supply.max - value > supply.current,
            err::max_supply_cannot_be_below_current_supply()
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
            err::supply_maxed_out()
        );
        supply.current = supply.current + value;
    }

    /// Decrements current supply
    public fun decrement(supply: &mut Supply, value: u64) {
        supply.current = supply.current - value;
    }

    /// Freeze `Supply`
    ///
    /// #### Panics
    ///
    /// Panics if already frozen
    public fun freeze_supply(supply: &mut Supply) {
        assert_not_frozen(supply);
        supply.frozen = true;
    }

    /// Creates a new `Supply` which is extended from the current `Supply`
    ///
    /// The extend value is used as the maximum supply for the new `Supply`,
    /// while the current supply of the existing supply is incremented by the
    /// value.
    ///
    /// The existing `Supply` must be frozen, thus the extended `Supply` will
    /// also be frozen.
    ///
    /// #### Panics
    ///
    /// Panics if not frozen or if value will cause maximum supply to be
    /// exceeded.
    public fun extend(supply: &mut Supply, value: u64): Supply {
        assert_frozen(supply);
        increment(supply, value);
        new(value, true)
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

    // === Assertions ===

    /// Asserts that current supply is zero
    public fun assert_zero(supply: &Supply) {
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
}
