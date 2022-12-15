#[test_only]
module nft_protocol::test_tags {
    use sui::transfer::transfer;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::nft;
    use nft_protocol::tags::{Self, TagDomain};
    use nft_protocol::collection::{Self, Collection, MintCap};
    use nft_protocol::test_utils_2::create_collection_and_whitelist;

    struct Witness has drop {}
    struct Foo has drop {}

    const OWNER: address = @0xA1C05;
    const FAKE_OWNER: address = @0xA1C11;
    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_nft_tags() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::new<Foo>(OWNER, ctx);

        let tags = tags::empty(ctx);

        tags::add_tag(&mut tags, tags::profile_picture());

        tags::add_tag_domain(
            &mut nft,
            tags,
            ctx
        );

        // If domain does not exist this function call will fail
        nft::borrow_domain<Foo, TagDomain>(&nft);

        transfer(nft, OWNER);

        test_scenario::end(scenario);
    }

    #[test]
    fun add_collection_tags() {
        let scenario = test_scenario::begin(CREATOR);

        let (col_id, cap_id, _wl_id) = create_collection_and_whitelist(
            Foo {},
            Witness {},
            &mut scenario,
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        let collection = test_scenario::take_shared_by_id<Collection<Foo>>(
            &scenario, col_id
        );

        let mint_cap = test_scenario::take_from_address_by_id<MintCap<Foo>>(
            &scenario, CREATOR, cap_id
        );

        let tags = tags::empty(ctx(&mut scenario));

        tags::add_tag(&mut tags, tags::art());
        tags::add_tag(&mut tags, tags::profile_picture());
        tags::add_tag(&mut tags, tags::collectible());
        tags::add_tag(&mut tags, tags::game_asset());

        tags::add_collection_tag_domain(
            &mut collection,
            &mint_cap,
            tags,
        );

        // If domain does not exist this function call will fail
        collection::borrow_domain<Foo, TagDomain>(&collection);

        test_scenario::return_shared(collection);
        test_scenario::return_to_address(CREATOR, mint_cap);

        test_scenario::end(scenario);
    }
}
