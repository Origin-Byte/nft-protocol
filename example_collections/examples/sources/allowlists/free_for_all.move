/// A allowlist which permits any collection to add itself and any authority
/// to use it to transfer.
///
/// Basically any collection which adds itself to this allowlist is saying:
/// we're ok with anyone transferring NFTs.
module examples::free_for_all {
    use sui::tx_context::TxContext;
    use sui::package::{Self, Publisher};

    use nft_protocol::witness::{Self, from_witness, Witness as DelegatedWitness};
    use nft_protocol::collection::Collection;
    use nft_protocol::transfer_allowlist_domain;
    use nft_protocol::transfer_allowlist::{Self, Allowlist};

    struct FREE_FOR_ALL has drop {}

    struct Witness has drop {}

    fun init(otw: FREE_FOR_ALL, ctx: &mut TxContext) {
        transfer_allowlist::init_allowlist(from_witness<FREE_FOR_ALL, Witness>(Witness {}), ctx);

        package::claim_and_keep(otw, ctx);
    }

    /// TODO: add policy rule
    public entry fun insert_collection<C>(
        pub: &Publisher,
        collection: &mut Collection<C>,
        allowlist: &mut Allowlist,
    ) {
        assert!(package::from_package<C>(pub), 0);

        let delegated_witness: DelegatedWitness<C> = witness::from_publisher(pub);
        transfer_allowlist_domain::add_id(delegated_witness, collection, allowlist);

        transfer_allowlist::insert_collection(
            from_witness<FREE_FOR_ALL, Witness>(Witness {}), delegated_witness, allowlist
        );
    }

    #[test_only]
    use sui::test_scenario::{Self, ctx};
    #[test_only]
    use sui::transfer;
    #[test_only]
    use nft_protocol::collection;
    #[test_only]
    use std::option;

    #[test_only]
    const USER: address = @0xA1C04;
    #[test_only]
    struct SomeRandomType has drop {}

    #[test]
    fun test_example_free_for_all() {
        let scenario = test_scenario::begin(USER);

        init(FREE_FOR_ALL {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let publisher = test_scenario::take_from_address<Publisher>(
            &scenario,
            USER,
        );

        let delegated_witness = witness::from_witness(Witness {});

        let (collection, mint_cap) = collection::create_with_mint_cap<FREE_FOR_ALL, SomeRandomType>(
            &FREE_FOR_ALL {}, option::none(), ctx(&mut scenario)
        );

        collection::add_domain(
            delegated_witness,
            &mut collection,
            transfer_allowlist_domain::empty(),
        );

        let wl: Allowlist = test_scenario::take_shared(&scenario);

        insert_collection(&publisher, &mut collection, &mut wl);

        transfer::public_transfer(mint_cap, USER);
        transfer::public_transfer(publisher, USER);
        transfer::public_transfer(collection, USER);
        test_scenario::return_shared(wl);
        test_scenario::end(scenario);
    }
}
