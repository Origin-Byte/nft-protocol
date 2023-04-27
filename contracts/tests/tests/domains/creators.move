#[test_only]
module ob_tests::test_creators {
    use sui::transfer;
    use sui::vec_set;
    use sui::test_scenario::{Self, ctx};

    use ob_witness::witness;
    use nft_protocol::creators::{Self, Creators};
    use nft_protocol::collection::{Self, Collection};

    struct Foo {}
    struct Witness has drop {}

    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_attribution() {
        let scenario = test_scenario::begin(CREATOR);

        let delegated_witness = witness::from_witness(Witness {});

        let collection: Collection<Foo> = collection::create(
            delegated_witness, ctx(&mut scenario),
        );

        collection::add_domain(
            delegated_witness,
            &mut collection,
            creators::new(vec_set::singleton(CREATOR)),
        );

        collection::assert_domain<Foo, Creators>(&collection);

        transfer::public_share_object(collection);

        test_scenario::end(scenario);
    }
}
