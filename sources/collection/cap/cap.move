//! Module contaning two supply `Cap` types, namely `Limited` and `Unlimited`.
//! 
//! `Limited` collections can have a cap on the maximum supply and keep track 
//! of the current supply, whilst `Unlimited` collection have no supply 
//! constraints nor they keep track of the number of minted objects.
//! 
//! Despite the name, `Limited` Collections can be set to have indeterminate 
//! supply cap, and if so, they only differ from Unlimited supply in that
//! they keep track of the current supply.
module nft_protocol::cap {
    use std::option::Option;
    use nft_protocol::supply::{Self, Supply};
    
    use nft_protocol::supply::{Self, Supply};

    struct Limited has store {
        supply: Supply,
    }
    struct Unlimited has store {}

    public fun create_limited(
        max_supply: Option<u64>,
        frozen: bool,
    ): Limited {
        Limited {
            supply: supply::new(max_supply, frozen)
        }
    }

    public fun create_unlimited(
    ): Unlimited {
        Unlimited {}
    }

    public fun supply(
        cap: &Limited
    ): &Supply {
        &cap.supply
    }

    public fun supply_mut(
        cap: &mut Limited
    ): &mut Supply {
        &mut cap.supply
    }

    public fun destroy_capped(cap: Limited) {
        assert!(supply::current(&cap.supply) == 0, 0);
        let Limited { supply } = cap;
        supply::destroy(supply);
    }
}
