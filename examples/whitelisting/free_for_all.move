#[test_only]
/// A allowlist which permits any collection to add itself and any authority
/// to use it to transfer.
///
/// Basically any collection which adds itself to this allowlist is saying:
/// we're ok with anyone transferring NFTs.
module nft_protocol::example_free_for_all {
    use sui::transfer;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::transfer_allowlist::{Self, Allowlist};


    const USER: address = @0xA1C04;

    struct Foo has drop {}
    struct Witness has drop {}

    #[test]
    fun it_inserts_collection() {
        let scenario = test_scenario::begin(USER);

        transfer_allowlist::init_allowlist(&Witness {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let wl: Allowlist = test_scenario::take_shared(&scenario);

        let col_cap = transfer_allowlist::create_collection_cap<Foo, Witness>(
            &Witness {}, ctx(&mut scenario),
        );

        transfer_allowlist::insert_collection(
            &Witness {}, &col_cap, &mut wl,
        );

        transfer::transfer(col_cap, USER);
        test_scenario::return_shared(wl);
        test_scenario::end(scenario);
    }
}
