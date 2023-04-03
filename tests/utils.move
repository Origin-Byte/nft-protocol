#[test_only]
module nft_protocol::test_utils {
    use nft_protocol::collection;
    use nft_protocol::witness;
    use nft_protocol::transfer_allowlist::{Self, Allowlist};

    use sui::object::{Self, UID, ID};
    use sui::test_scenario::{Self, Scenario, ctx};
    use sui::transfer::{public_transfer, public_share_object};

    struct Foo has key, store {
        id: UID,
    }

    struct Witness has drop {}

    public fun witness(): Witness {
        Witness {}
    }

    public fun create_collection_and_allowlist(
        creator: address,
        scenario: &mut Scenario,
    ): (ID, ID, ID) {
        let (cap, col) =
            collection::create<Witness, Foo>(&Witness {}, ctx(scenario));

        let col_id = object::id(&col);
        let cap_id = object::id(&cap);

        public_share_object(col);
        test_scenario::next_tx(scenario, creator);

        transfer_allowlist::init_allowlist(&Witness {}, ctx(scenario));

        test_scenario::next_tx(scenario, creator);

        let wl: Allowlist = test_scenario::take_shared(scenario);
        let wl_id = object::id(&wl);

        transfer_allowlist::insert_collection<Foo, Witness>(
            &mut wl,
            &Witness {},
            witness::from_witness<Foo, Witness>(&Witness {}),
        );

        public_transfer(cap, creator);
        test_scenario::return_shared(wl);

        (col_id, cap_id, wl_id)
    }
}
