#[test_only]
module nft_protocol::test_tags {
    use sui::transfer;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::nft;
    use nft_protocol::witness;
    use nft_protocol::collection;
    use nft_protocol::tags::{Self, TagDomain};

    struct Foo has drop {}
    struct Witness has drop {}

    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_nft_tags() {
        let scenario = test_scenario::begin(CREATOR);
        let ctx = ctx(&mut scenario);

        let nft = nft::test_mint<Foo>(CREATOR, ctx);

        let tags = tags::empty(ctx);

        tags::add_tag(&mut tags, tags::profile_picture());

        tags::add_tag_domain(
            &mut nft,
            tags,
            ctx
        );

        // If domain does not exist this function call will fail
        nft::borrow_domain<Foo, TagDomain>(&nft);

        transfer::transfer(nft, CREATOR);

        test_scenario::end(scenario);
    }

    #[test]
    fun add_collection_tags() {
        let scenario = test_scenario::begin(CREATOR);

        let (mint_cap, collection) =
            collection::create(&Foo {}, ctx(&mut scenario));

        let tags = tags::empty(ctx(&mut scenario));

        tags::add_tag(&mut tags, tags::art());
        tags::add_tag(&mut tags, tags::profile_picture());
        tags::add_tag(&mut tags, tags::collectible());
        tags::add_tag(&mut tags, tags::game_asset());

        tags::add_collection_tag_domain(
            witness::from_witness(&Foo {}),
            &mut collection,
            tags,
        );

        // If domain does not exist this function call will fail
        collection::borrow_domain<Foo, TagDomain>(&collection);

        transfer::share_object(collection);
        transfer::transfer(mint_cap, CREATOR);

        test_scenario::end(scenario);
    }
}
