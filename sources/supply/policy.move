//! Module contaning `SupplyPolicy` type.
//! 
//! A `SupplyPolicy` can be regulated or unregulated. Regulated policies
//! can have a ceiling on the maximum supply and keep track 
//! of the current supply, whilst unregulated policies have no supply 
//! constraints nor they keep track of the number of minted objects.
module nft_protocol::supply_policy {
    use std::option::{Self, Option};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::err;

    struct SupplyPolicy has store {
        regulated: bool, 
        supply: Option<Supply>,
    }

    public fun create_regulated(
        max_supply: u64,
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
        assert!(policy.regulated == true, err::supply_policy_mismatch());
        option::borrow(&policy.supply)
    }

    public fun supply_mut(
        policy: &mut SupplyPolicy
    ): &mut Supply {
        assert!(policy.regulated == true, err::supply_policy_mismatch());
        option::borrow_mut(&mut policy.supply)
    }

    public fun ceil_supply(policy: &mut SupplyPolicy, value: u64) {
        assert!(policy.regulated == true, err::supply_policy_mismatch());
        supply::ceil_supply(option::borrow_mut(&mut policy.supply), value);
    }

    /// Increases the `supply.max` by the `value` amount for 
    /// regulated policies. Invokes `supply::increase_cap()`
    public fun increase_max_supply(
        policy: &mut SupplyPolicy,
        value: u64,
    ) {
        assert!(!regulated(policy), err::supply_policy_mismatch());

        supply::increase_ceil(
            supply_mut(policy),
            value
        )
    }

    /// Decreases the `supply.cap` by the `value` amount for 
    /// regulated policies. This function call fails if one attempts
    /// to decrease the supply cap to a value below the current supply.
    /// Invokes `supply::decrease_cap()`
    public fun decrease_max_supply(
        policy: &mut SupplyPolicy,
        value: u64
    ) {
        assert!(!regulated(policy), err::supply_policy_mismatch());

        supply::decrease_ceil(
            supply_mut(policy),
            value
        )
    }

    /// Increase `supply.current` for regulated policies
    public fun increment_supply(
        policy: &mut SupplyPolicy,
        value: u64
    ) {
        assert!(regulated(policy), err::supply_policy_mismatch());

        supply::increment_supply(
            supply_mut(policy),
            value
        )
    }

    public fun decrement_supply(
        policy: &mut SupplyPolicy,
        value: u64
    ) {
        assert!(regulated(policy), err::supply_policy_mismatch());

        supply::decrement_supply(
            supply_mut(policy),
            value
        )
    }

    public fun destroy_regulated(policy: SupplyPolicy) {
        // One can only destroy a SupplyPolicy that is regulated
        assert!(policy.regulated == true, err::supply_policy_mismatch());

        assert!(
            supply::current(option::borrow(&policy.supply)) == 0,
            err::supply_is_not_zero()
        );

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