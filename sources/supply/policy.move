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
        is_blind: bool, 
        supply: Option<Supply>,
    }

    public fun create_limited(
        max_supply: Option<u64>,
        frozen: bool,
    ): SupplyPolicy {
        SupplyPolicy {
            is_blind: false,
            supply: option::some(supply::new(max_supply, frozen)),
        }
    }

    public fun create_unlimited(
    ): SupplyPolicy {
        SupplyPolicy {
            is_blind: true,
            supply: option::none(),
        }
    }

    public fun supply(
        policy: &SupplyPolicy
    ): &Supply {
        assert!(policy.is_blind == false, 0);
        option::borrow(&policy.supply)
    }

    public fun supply_mut(
        policy: &mut SupplyPolicy
    ): &mut Supply {
        assert!(policy.is_blind == false, 0);
        option::borrow_mut(&mut policy.supply)
    }

    public fun destroy_capped(policy: SupplyPolicy) {
        // One can only destroy a SupplyPolicy that is not blind
        assert!(policy.is_blind == false, 0);

        assert!(supply::current(option::borrow(&policy.supply)) == 0, 0);
        let SupplyPolicy {
            is_blind: _,
            supply
        } = policy;

        supply::destroy(option::extract(&mut supply));
        option::destroy_none(supply);
    }

    public fun is_blind(
        policy: &SupplyPolicy,
    ): bool {
        policy.is_blind
    }
}
