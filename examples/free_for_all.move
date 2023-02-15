/// A allowlist which permits any collection to add itself and any authority
/// to use it to transfer.
///
/// Basically any collection which adds itself to this allowlist is saying:
/// we're ok with anyone transferring NFTs.
module nft_protocol::free_for_all_allowlist {
    use sui::tx_context::TxContext;

    use nft_protocol::transfer_allowlist::{Self, Allowlist, CollectionControlCap};

    struct Witness has drop {}

    fun init(ctx: &mut TxContext) {
        transfer_allowlist::init_allowlist(&Witness {}, ctx);
    }

    fun insert_collection<C>(
        col_cap: &CollectionControlCap<C>,
        allowlist: &mut Allowlist,
    ) {
        transfer_allowlist::insert_collection_with_cap(
            &Witness {}, col_cap, allowlist,
        );
    }

    #[test_only]
    use sui::test_scenario::{Self, ctx};
    #[test_only]
    use sui::transfer;
    #[test_only]
    use nft_protocol::witness;

    #[test_only]
    struct Foo has drop {}

    #[test_only]
    const USER: address = @0xA1C04;

    #[test]
    fun it_inserts_collection() {
        let scenario = test_scenario::begin(USER);

        init(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let wl: Allowlist = test_scenario::take_shared(&scenario);

        let col_cap = transfer_allowlist::create_collection_cap<Foo>(
            witness::from_witness(&Witness {}), ctx(&mut scenario),
        );

        insert_collection(&col_cap, &mut wl);

        transfer::transfer(col_cap, USER);
        test_scenario::return_shared(wl);
        test_scenario::end(scenario);
    }
}
