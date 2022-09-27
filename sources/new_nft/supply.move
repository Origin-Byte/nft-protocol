module nft_protocol::supply {
    use std::option::{Self, Option};

    struct Supply has store {
        cap: Option<u64>,
        current: u64,
    }

    // === Supply <-> morphing and accessors  ===

    public fun cap(supply: &Supply): Option<u64> {
        supply.cap
    }

    public fun current(supply: &Supply): u64 {
        supply.current
    }

    public fun cap_supply(supply: &mut Supply, value: u64) {
        assert!(option::is_none(&supply.cap), 0);
        option::fill(&mut supply.cap, value);
    }

    public fun increase_supply(supply: &mut Supply, value: u64) {
        assert!(!option::is_none(&supply.cap), 0);
        assert!(supply.current <= *option::borrow(&supply.cap), 0);
        supply.current = supply.current + value;
    }

    public fun decrease_supply(supply: &mut Supply, value: u64) {
        assert!(supply.current > value, 0);
        supply.current = supply.current - value;
    }

    public fun increase_cap(supply: &mut Supply, value: u64) {
        assert!(!option::is_none(&supply.cap), 0);
        
        let cap = option::extract(&mut supply.cap);
        option::fill(&mut supply.cap, cap + value);
    }

    public fun decrease_cap(supply: &mut Supply, value: u64) {
        assert!(!option::is_none(&supply.cap), 0);
        
        // Decrease in supply cap cannot result in supply cap smaller
        // than current supply
        assert!(*option::borrow(&supply.cap) - value > supply.current, 0);
        
        let cap = option::extract(&mut supply.cap);
        option::fill(&mut supply.cap, cap + value);
    }

    public fun destroy(supply: Supply) {
        assert!(supply.current == 0, 0);
        let Supply { cap: _, current: _ } = supply;
    }

    public fun new(cap: Option<u64>): Supply {
        Supply { cap: cap, current: 0 }
    }
}