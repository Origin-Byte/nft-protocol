#[test_only]
module nft_protocol::test_royalty {
    use sui::transfer;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::collection::{Self, Collection};
    use ob_witness::witness;
    use nft_protocol::royalty_strategy_bps;
    use nft_protocol::royalty::RoyaltyDomain;

    struct Foo has drop {}
    struct Witness has drop {}

    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_royalty() {
        let scenario = test_scenario::begin(CREATOR);

        let delegated_witness = witness::from_witness(Witness {});

        let collection: Collection<Foo> = collection::create(
            delegated_witness, ctx(&mut scenario),
        );

        royalty_strategy_bps::create_domain_and_add_strategy(
            delegated_witness, &mut collection, 100, ctx(&mut scenario),
        );

        collection::assert_domain<Foo, RoyaltyDomain>(&collection);

        transfer::public_share_object(collection);

        test_scenario::end(scenario);
    }
}
