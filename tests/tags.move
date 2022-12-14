#[test_only]
module nft_protocol::test_tags {
    use std::string;

    use sui::transfer::transfer;
    // use sui::object;
    use sui::url;
    use sui::vec_map;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::nft::{Self};
    use nft_protocol::display;

    struct Witness has drop {}

    struct Foo has drop {}

    struct DomainA has store {}

    const OWNER: address = @0xA1C05;
    const FAKE_OWNER: address = @0xA1C11;

    #[test]
    fun add_nft_display() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::new<Foo>(OWNER, ctx);

        display::add_display_domain(
            &mut nft,
            string::utf8(b"Suimarines-234"),
            string::utf8(b"Collection of Suimarines"),
            ctx
        );

        transfer(nft, OWNER);

        test_scenario::end(scenario);
    }

    // #[test]
    // fun add_collection_display() {
    // }

    #[test]
    fun add_nft_url() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::new<Foo>(OWNER, ctx);

        display::add_url_domain(
            &mut nft,
            url::new_unsafe_from_bytes(b"https://originbyte.io/"),
            ctx
        );

        transfer(nft, OWNER);

        test_scenario::end(scenario);
    }

    // #[test]
    // fun add_collection_url() {
    // }

    #[test]
    fun add_nft_symbol() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::new<Foo>(OWNER, ctx);

        display::add_symbol_domain(
            &mut nft,
            string::utf8(b"SUIM-234"),
            ctx
        );

        transfer(nft, OWNER);

        test_scenario::end(scenario);
    }

    // #[test]
    // fun add_collection_symbol() {
    // }

    #[test]
    fun add_attributes() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::new<Foo>(OWNER, ctx);

        let attributes = vec_map::empty();
        vec_map::insert(
            &mut attributes, string::utf8(b"color"),
            string::utf8(b"yellow"),
        );

        display::add_attributes_domain(
            &mut nft,
            attributes,
            ctx
        );

        transfer(nft, OWNER);

        test_scenario::end(scenario);
    }
}
