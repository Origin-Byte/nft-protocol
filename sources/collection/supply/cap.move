module nft_protocol::cap {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::supply::{Self, Supply};
    use std::option::{Self, Option};

    struct Limited has store {
        supply: Supply,
    }
    struct Unlimited has store {}

    public fun create_limited(
        max_supply: u64,
        frozen: bool,
    ): Limited {
        Limited {
            supply: supply::new(option::some(max_supply), frozen)
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
