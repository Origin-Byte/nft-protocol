#[test_only]
module nft_protocol::test_utils {
    use std::option;

    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::package;

    use nft_protocol::witness;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::mint_cap::MintCap;

    const MARKETPLACE: address = @0xA1C08;
    const CREATOR: address = @0xA1C04;
    const BUYER: address = @0xA1C10;
    const SELLER: address = @0xA1C15;
    const FAKE_ADDRESS: address = @0xA1C45;

    struct Foo has key, store {
        id: UID,
    }

    // Mock OTW
    struct TEST_UTILS has drop {}

    struct Witness has drop {}

    public fun witness(): Witness { Witness {} }

    public fun marketplace(): address { MARKETPLACE }
    public fun creator(): address { CREATOR }
    public fun buyer(): address { BUYER }
    public fun seller(): address { SELLER }
    public fun fake_address(): address { FAKE_ADDRESS }

    public fun init_collection_foo(
        ctx: &mut TxContext
    ): (Collection<Foo>, MintCap<Foo>) {
        collection::create_with_mint_cap<Foo>(
            witness::from_witness(Witness {}), option::none(), ctx
        )
    }

    public fun get_random_nft(ctx: &mut TxContext): Foo {
        Foo { id: object::new(ctx)}
    }

    public fun get_package(scenario: &mut Scenario): Publisher {
        package::test_claim<TEST_UTILS>(TEST_UTILS {}, ctx(&mut scenario))

    }


    // TODO: This will be reintroduced
    // public fun create_collection_and_allowlist(
    //     creator: address,
    //     scenario: &mut Scenario,
    // ): (ID, ID, ID) {
    //     let delegated_witness = witness::from_witness(Witness {});

    //     let collection: Collection<Foo> = collection::create(
    //         delegated_witness, ctx(scenario),
    //     );

    //     let mint_cap = mint_cap::new_unlimited(
    //         delegated_witness, &collection, ctx(scenario),
    //     );

    //     let col_id = object::id(&collection);
    //     let cap_id = object::id(&mint_cap);

    //     public_share_object(collection);
    //     test_scenario::next_tx(scenario, creator);

    //     transfer_allowlist::init_allowlist(&Witness {}, ctx(scenario));

    //     test_scenario::next_tx(scenario, creator);

    //     let wl: Allowlist = test_scenario::take_shared(scenario);
    //     let wl_id = object::id(&wl);

    //     transfer_allowlist::insert_collection<Foo, Witness>(
    //         &mut wl,
    //         &Witness {},
    //         witness::from_witness<Foo, Witness>(Witness {}),
    //     );

    //     public_transfer(mint_cap, creator);
    //     test_scenario::return_shared(wl);

    //     (col_id, cap_id, wl_id)
    // }
}
