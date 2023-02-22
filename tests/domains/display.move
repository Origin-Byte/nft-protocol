#[test_only]
module nft_protocol::test_display {
    use std::string;

    use sui::transfer;
    use sui::url;
    use sui::vec_map;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::nft;
    use nft_protocol::collection;
    use nft_protocol::display::{
        Self, DisplayDomain, UrlDomain, SymbolDomain, AttributesDomain
    };

    struct Foo has drop {}
    struct Witness has drop {}

    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_nft_display() {
        let scenario = test_scenario::begin(CREATOR);
        let ctx = ctx(&mut scenario);

        let nft = nft::test_mint<Foo>(CREATOR, ctx);

        display::add_display_domain(
            &Witness {},
            &mut nft,
            string::utf8(b"Suimarines-234"),
            string::utf8(b"Collection of Suimarines"),
        );

        // If domain does not exist this function call will fail
        nft::borrow_domain<Foo, DisplayDomain>(&nft);

        transfer::transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun add_collection_display() {
        let scenario = test_scenario::begin(CREATOR);

        let (mint_cap, collection) =
            collection::create(&Foo {}, ctx(&mut scenario));

        display::add_collection_display_domain(
            &Witness {},
            &mut collection,
            string::utf8(b"Suimarines-234"),
            string::utf8(b"Collection of Suimarines"),
        );

        // If domain does not exist this function call will fail
        collection::borrow_domain<Foo, DisplayDomain>(&collection);

        transfer::share_object(collection);
        transfer::transfer(mint_cap, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun add_nft_url() {
        let scenario = test_scenario::begin(CREATOR);
        let ctx = ctx(&mut scenario);

        let nft = nft::test_mint<Foo>(CREATOR, ctx);

        display::add_url_domain(
            &Witness {},
            &mut nft,
            url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        // If domain does not exist this function call will fail
        nft::borrow_domain<Foo, UrlDomain>(&nft);

        transfer::transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun add_collection_url() {
        let scenario = test_scenario::begin(CREATOR);

        let (mint_cap, collection) =
            collection::create(&Foo {}, ctx(&mut scenario));

        display::add_collection_url_domain(
            &Witness {},
            &mut collection,
            url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        // If domain does not exist this function call will fail
        collection::borrow_domain<Foo, UrlDomain>(&collection);

        transfer::share_object(collection);
        transfer::transfer(mint_cap, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun add_nft_symbol() {
        let scenario = test_scenario::begin(CREATOR);
        let ctx = ctx(&mut scenario);

        let nft = nft::test_mint<Foo>(CREATOR, ctx);

        display::add_symbol_domain(
            &Witness {},
            &mut nft,
            string::utf8(b"SUIM-234"),
        );

        // If domain does not exist this function call will fail
        nft::borrow_domain<Foo, SymbolDomain>(&nft);

        transfer::transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun add_collection_symbol() {
        let scenario = test_scenario::begin(CREATOR);

        let (mint_cap, collection) =
            collection::create(&Foo {}, ctx(&mut scenario));

        display::add_collection_symbol_domain(
            &Witness {},
            &mut collection,
            string::utf8(b"SUIM"),
        );

        // If domain does not exist this function call will fail
        collection::borrow_domain<Foo, SymbolDomain>(&collection);

        transfer::share_object(collection);
        transfer::transfer(mint_cap, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun add_attributes() {
        let scenario = test_scenario::begin(CREATOR);
        let ctx = ctx(&mut scenario);

        let nft = nft::test_mint<Foo>(CREATOR, ctx);

        let attributes = vec_map::empty();
        vec_map::insert(
            &mut attributes, string::utf8(b"color"),
            string::utf8(b"yellow"),
        );

        display::add_attributes_domain(
            &Witness {},
            &mut nft,
            attributes,
        );

        // If domain does not exist this function call will fail
        nft::borrow_domain<Foo, AttributesDomain>(&nft);

        transfer::transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }
}
