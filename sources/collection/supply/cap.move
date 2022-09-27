module nft_protocol::collection_cap {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::supply::{Self, Supply};
    use std::option::{Self, Option};

    // struct Cap<T> has store {
    //     cap: T,
    // }

    // struct Limited has store {
    //     supply: Supply,
    // }
    // struct Unlimited has store {}

    struct Capped has store {
        supply: Supply,
    }
    struct Uncapped has store {}

    // public fun create_cap<T: store>(
    //     max_supply: Option<u64>,
    // ): Cap<T> {

    //     if (option::is_none(&max_supply)) {
    //         return Cap {
    //             cap: Unlimited {}
    //         };
    //     } else {
    //         return Cap {
    //             cap: Limited {
    //                 supply: supply::new(max_supply)
    //             }
    //         };
    //     }
    // }

    public fun create_capped(
        max_supply: u64,
    ): Capped {
        Capped {
            supply: supply::new(option::some(max_supply))
        }
    }

    public fun create_uncapped(
    ): Uncapped {
        Uncapped {}
    }

    public fun supply(
        cap: &Capped
    ): &Supply {
        &cap.supply
    }

    public fun supply_mut(
        cap: &mut Capped
    ): &mut Supply {
        &mut cap.supply
    }

    public fun destroy_capped(cap: Capped) {
        assert!(supply::current(&cap.supply) == 0, 0);
        let Capped { supply } = cap;
        supply::destroy(supply);
    }
}
