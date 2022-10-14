//! Module contaning two supply `Cap` types, namely `Limited` and `Unlimited`.
//! 
//! `Limited` collections can have a cap on the maximum supply and keep track 
//! of the current supply, whilst `Unlimited` collection have no supply 
//! constraints nor they keep track of the number of minted objects.
//! 
//! Despite the name, `Limited` Collections can be set to have indeterminate 
//! supply cap, and if so, they only differ from Unlimited supply in that
//! they keep track of the current supply.
module nft_protocol::supply_policy {
    use std::option::{Self, Option};
    use nft_protocol::supply::{Self, Supply};

    struct SupplyPolicy has store {
        regulated: bool, 
        supply: Option<Supply>,
    }

    public fun create_regulated(
        max_supply: Option<u64>,
        frozen: bool,
    ): SupplyPolicy {
        SupplyPolicy {
            regulated: true,
            supply: option::some(supply::new(max_supply, frozen)),
        }
    }

    public fun create_unregulated(
    ): SupplyPolicy {
        SupplyPolicy {
            regulated: false,
            supply: option::none(),
        }
    }

    public fun supply(
        policy: &SupplyPolicy
    ): &Supply {
        assert!(policy.regulated == true, 0);
        option::borrow(&policy.supply)
    }

    public fun supply_mut(
        policy: &mut SupplyPolicy
    ): &mut Supply {
        assert!(policy.regulated == true, 0);
        option::borrow_mut(&mut policy.supply)
    }

    public fun cap_supply(policy: &mut SupplyPolicy, value: u64) {
        assert!(policy.regulated == true, 0);
        supply::cap_supply(option::borrow_mut(&mut policy.supply), value);
    }

    /// Increases the `supply.max` by the `value` amount for 
    /// `Limited` collections. Invokes `supply::increase_cap()`
    public fun increase_max_supply(
        policy: &mut SupplyPolicy,
        value: u64,
    ) {
        assert!(!regulated(policy), 0);

        supply::increase_cap(
            supply_mut(policy),
            value
        )
    }

    /// Decreases the `supply.cap` by the `value` amount for 
    /// `Limited` collections. This function call fails if one attempts
    /// to decrease the supply cap to a value below the current supply.
    /// Invokes `supply::decrease_cap()`
    public fun decrease_max_supply(
        policy: &mut SupplyPolicy,
        value: u64
    ) {
        assert!(!regulated(policy), 0);

        supply::decrease_cap(
            supply_mut(policy),
            value
        )
    }

    /// Increase `supply.current` for `Limited`
    public fun increase_supply(
        policy: &mut SupplyPolicy,
        value: u64
    ) {
        assert!(!regulated(policy), 0);

        supply::increase_supply(
            supply_mut(policy),
            value
        )
    }

    public fun decrease_supply(
        policy: &mut SupplyPolicy,
        value: u64
    ) {
        supply::decrease_supply(
            supply_mut(policy),
            value
        )
    }

    public fun destroy_capped(policy: SupplyPolicy) {
        // One can only destroy a SupplyPolicy that is not blind
        assert!(policy.regulated == true, 0);

        assert!(supply::current(option::borrow(&policy.supply)) == 0, 0);
        let SupplyPolicy {
            regulated: _,
            supply
        } = policy;

        supply::destroy(option::extract(&mut supply));
        option::destroy_none(supply);
    }

    public fun regulated(
        policy: &SupplyPolicy,
    ): bool {
        policy.regulated
    }
}
