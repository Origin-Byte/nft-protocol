module nft_protocol::supply {
    use std::option::{Self, Option};

    struct Supply has store {
        frozen: bool,
        max: Option<u64>,
        current: u64,
    }

    // === Supply <-> morphing and accessors  ===

    public fun max(supply: &Supply): Option<u64> {
        supply.max
    }

    public fun current(supply: &Supply): u64 {
        supply.current
    }

    public fun cap_supply(supply: &mut Supply, value: u64) {
        assert!(option::is_none(&supply.max), 0);
        option::fill(&mut supply.max, value);
    }

    public fun increase_supply(supply: &mut Supply, value: u64) {
        assert!(!option::is_none(&supply.max), 0);
        assert!(supply.current <= *option::borrow(&supply.max), 0);
        supply.current = supply.current + value;
    }

    public fun decrease_supply(supply: &mut Supply, value: u64) {
        assert!(supply.current > value, 0);
        supply.current = supply.current - value;
    }

    public fun increase_cap(supply: &mut Supply, value: u64) {
        assert!(!option::is_none(&supply.max), 0);
        assert!(supply.frozen == false, 0);
        
        let cap = option::extract(&mut supply.max);
        option::fill(&mut supply.max, cap + value);
    }

    public fun decrease_cap(supply: &mut Supply, value: u64) {
        assert!(!option::is_none(&supply.max), 0);
        assert!(supply.frozen == false, 0);
        
        // Decrease in supply cap cannot result in supply cap smaller
        // than current supply
        assert!(*option::borrow(&supply.max) - value > supply.current, 0);
        
        let max = option::extract(&mut supply.max);
        option::fill(&mut supply.max, max + value);
    }

    public fun destroy(supply: Supply) {
        // TODO: Confirm this is secure
        assert!(supply.current == 0, 0);
        let Supply { frozen: _, max: _, current: _ } = supply;
    }

    public fun new(max: Option<u64>, frozen: bool): Supply {
        Supply { frozen: frozen, max: max, current: 0 }
    }
}