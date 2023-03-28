#[test_only]
module nft_protocol::test_creators {
    use sui::transfer;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::creators;
    use nft_protocol::collection;

    struct Foo has drop {}
    struct Witness has drop {}

    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_attribution() {
        let scenario = test_scenario::begin(CREATOR);

        let (mint_cap, collection) =
            collection::create(&Foo {}, ctx(&mut scenario));

        collection::add_domain(
            &Witness {},
            &mut collection,
            creators::from_address<Foo, Witness>(&Witness {}, CREATOR),
        );
        creators::assert_domain(&collection);

        transfer::public_share_object(collection);
        transfer::public_transfer(mint_cap, CREATOR);

        test_scenario::end(scenario);
    }
}
