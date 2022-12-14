#[test_only]
module nft_protocol::test_tags {
    use sui::transfer::transfer;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::nft::{Self};
    use nft_protocol::tags;

    struct Witness has drop {}

    struct Foo has drop {}

    struct DomainA has store {}

    const OWNER: address = @0xA1C05;
    const FAKE_OWNER: address = @0xA1C11;

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

        transfer(nft, OWNER);

        test_scenario::end(scenario);
    }

    // #[test]
    // fun add_collection_tags() {}
}
