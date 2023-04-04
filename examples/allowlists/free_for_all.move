/// A allowlist which permits any collection to add itself and any authority
/// to use it to transfer.
///
/// Basically any collection which adds itself to this allowlist is saying:
/// we're ok with anyone transferring NFTs.
module nft_protocol::origin_sui {
    use std::option;

    use sui::tx_context::TxContext;
    use sui::package::{Self, Publisher};

    use nft_protocol::mint_cap;
    use nft_protocol::witness;
    use nft_protocol::collection::Collection;
    use nft_protocol::transfer_allowlist_domain;
    use nft_protocol::transfer_allowlist::{Self, Allowlist};

    struct ORIGIN_SUI has drop {}

    struct Witness has drop {}

    fun init(witness: ORIGIN_SUI, ctx: &mut TxContext) {
        transfer_allowlist::init_allowlist(&Witness {}, ctx);

        package::claim_and_keep(witness, ctx);
    }

    public entry fun insert_collection<C>(
        pub: &Publisher,
        collection: &mut Collection<C>,
        allowlist: &mut Allowlist,
    ) {
        assert!(package::from_package<C>(pub), 0);

        let delegated_witness = witness::from_publisher(pub);
        transfer_allowlist_domain::add_id(delegated_witness, collection, allowlist);

        let delegated_witness = witness::from_witness<ORIGIN_SUI, Witness>(Witness {});

        transfer_allowlist::insert_collection(
            allowlist, &Witness {}, delegated_witness,
        );
    }

    #[test_only]
    use sui::test_scenario::{Self, ctx};
    #[test_only]
    use sui::transfer;
    #[test_only]
    use nft_protocol::collection;

    #[test_only]
    const USER: address = @0xA1C04;

    #[test]
    fun test_example_free_for_all() {
        let scenario = test_scenario::begin(USER);

        init(ORIGIN_SUI {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let publisher = test_scenario::take_from_address<Publisher>(
            &scenario,
            USER,
        );

        let delegated_witness = witness::from_witness(Witness {});

        let collection: Collection<ORIGIN_SUI> =
            collection::create(delegated_witness, ctx(&mut scenario));

        let mint_cap = mint_cap::new(
            delegated_witness,
            &collection,
            option::none(),
            ctx(&mut scenario)
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
