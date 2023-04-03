#[test_only]
module nft_protocol::test_creators {
    use sui::transfer;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::creators::{Self};
    use nft_protocol::collection::{Self, Collection};

    struct Foo {}
    struct Witness has drop {}

    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_attribution() {
        let scenario = test_scenario::begin(CREATOR);

        let collection: Collection<Foo> = collection::create<Foo, Witness>(
            Witness {}, ctx(&mut scenario),
        );

        collection::add_domain(
            Witness {},
            &mut collection,
            creators::from_address<Foo, Witness>(Witness {}, CREATOR),
        );

        // collection::assert_domain<Foo, Creators<Collection<Foo>>>(&collection);

        transfer::public_share_object(collection);

        test_scenario::end(scenario);
    }
}
