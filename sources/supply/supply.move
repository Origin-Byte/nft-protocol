module nft_protocol::supply {
    use nft_protocol::err;

    const U64_MAX: u64 = 18446744073709551615;

    struct Supply has store {
        frozen: bool,
        max: u64,
        current: u64,
    }

    // === Supply <-> morphing and accessors  ===

    public fun max(supply: &Supply): u64 {
        supply.max
    }

    public fun current(supply: &Supply): u64 {
        supply.current
    }

    public fun ceil_supply(supply: &mut Supply, value: u64) {
        assert!(supply.max == U64_MAX, err::supply_is_limited());
        supply.max = value;
    }

    public fun increase_ceil(supply: &mut Supply, value: u64) {
        assert!(supply.max != U64_MAX, err::supply_is_unlimited());
        assert!(supply.frozen == false, err::frozen_supply());

        supply.max = supply.max + value;
    }

    public fun decrease_ceil(supply: &mut Supply, value: u64) {
        assert!(supply.max != U64_MAX, err::supply_is_unlimited());
        assert!(supply.frozen == false, err::frozen_supply());

        // Decrease in supply cap cannot result in supply cap smaller
        // than current supply
        assert!(
            supply.max - value > supply.current,
            err::max_supply_cannot_be_below_current_supply()
        );

        supply.max = supply.max - value;
    }

    public fun increment_supply(supply: &mut Supply, value: u64) {
        assert!(
            supply.current + value <= supply.max,
            err::supply_maxed_out()
        );

        supply.current = supply.current + value;
    }

    public fun decrement_supply(supply: &mut Supply, value: u64) {
        assert!(supply.current > value, err::current_supply_cannot_be_negative());
        supply.current = supply.current - value;
    }

    public fun destroy(supply: Supply) {
        assert!(supply.current == 0, err::supply_is_not_zero());
        let Supply { frozen: _, max: _, current: _ } = supply;
    }

    public fun new(max: u64, frozen: bool): Supply {
        Supply { frozen: frozen, max: max, current: 0 }
    }
}
