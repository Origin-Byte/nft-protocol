#[test_only]
module nft_protocol::test_display {
    use std::string;

    use sui::transfer::transfer;
    use sui::url;
    use sui::vec_map;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::nft;
    use nft_protocol::collection::{Self, Collection, MintCap};
    use nft_protocol::test_utils::create_collection_and_allowlist_with_type;
    use nft_protocol::display::{
        Self, DisplayDomain, UrlDomain, SymbolDomain, AttributesDomain
    };

    struct Witness has drop {}
    struct Foo has drop {}

    const OWNER: address = @0xA1C05;
    const FAKE_OWNER: address = @0xA1C11;
    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_nft_display() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::new(&Witness {}, OWNER, ctx);

        display::add_display_domain(
            &mut nft,
            string::utf8(b"Suimarines-234"),
            string::utf8(b"Collection of Suimarines"),
            ctx
        );

        // If domain does not exist this function call will fail
        nft::borrow_domain<Foo, DisplayDomain>(&nft);

        transfer(nft, OWNER);

        test_scenario::end(scenario);
    }

    #[test]
    fun add_collection_display() {
        let scenario = test_scenario::begin(CREATOR);

        let (col_id, cap_id, _wl_id) = create_collection_and_allowlist_with_type(
            Foo {},
            Witness {},
            CREATOR,
            &mut scenario,
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        let collection = test_scenario::take_shared_by_id<Collection<Foo>>(
            &scenario, col_id
        );

        let mint_cap = test_scenario::take_from_address_by_id<MintCap<Foo>>(
            &scenario, CREATOR, cap_id
        );

        display::add_collection_display_domain(
            &mut collection,
            &mint_cap,
            string::utf8(b"Suimarines-234"),
            string::utf8(b"Collection of Suimarines"),
            ctx(&mut scenario)
        );

        // If domain does not exist this function call will fail
        collection::borrow_domain<Foo, DisplayDomain>(&collection);

        test_scenario::return_shared(collection);
        test_scenario::return_to_address(CREATOR, mint_cap);

        test_scenario::end(scenario);
    }

    #[test]
    fun add_nft_url() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::new(&Witness {}, OWNER, ctx);

        display::add_url_domain(
            &mut nft,
            url::new_unsafe_from_bytes(b"https://originbyte.io/"),
            ctx(&mut scenario),
        );

        // If domain does not exist this function call will fail
        nft::borrow_domain<Foo, UrlDomain>(&nft);

        transfer(nft, OWNER);

        test_scenario::end(scenario);
    }

    #[test]
    fun add_collection_url() {
        let scenario = test_scenario::begin(CREATOR);

        let (col_id, cap_id, _wl_id) = create_collection_and_allowlist_with_type(
            Foo {},
            Witness {},
            CREATOR,
            &mut scenario,
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        let collection = test_scenario::take_shared_by_id<Collection<Foo>>(
            &scenario, col_id
        );

        let mint_cap = test_scenario::take_from_address_by_id<MintCap<Foo>>(
            &scenario, CREATOR, cap_id
        );

        display::add_collection_url_domain(
            &mut collection,
            &mint_cap,
            url::new_unsafe_from_bytes(b"https://originbyte.io/"),
            ctx(&mut scenario)
        );

        // If domain does not exist this function call will fail
        collection::borrow_domain<Foo, UrlDomain>(&collection);

        test_scenario::return_shared(collection);
        test_scenario::return_to_address(CREATOR, mint_cap);

        test_scenario::end(scenario);
    }

    #[test]
    fun add_nft_symbol() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::new(&Witness {}, OWNER, ctx);

        display::add_symbol_domain(
            &mut nft,
            string::utf8(b"SUIM-234"),
            ctx
        );

        // If domain does not exist this function call will fail
        nft::borrow_domain<Foo, SymbolDomain>(&nft);

        transfer(nft, OWNER);

        test_scenario::end(scenario);
    }

    #[test]
    fun add_collection_symbol() {
        let scenario = test_scenario::begin(CREATOR);

        let (col_id, cap_id, _wl_id) = create_collection_and_allowlist_with_type(
            Foo {},
            Witness {},
            CREATOR,
            &mut scenario,
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        let collection = test_scenario::take_shared_by_id<Collection<Foo>>(
            &scenario, col_id
        );

        let mint_cap = test_scenario::take_from_address_by_id<MintCap<Foo>>(
            &scenario, CREATOR, cap_id
        );

        display::add_collection_symbol_domain(
            &mut collection,
            &mint_cap,
            string::utf8(b"SUIM"),
            ctx(&mut scenario)
        );

        // If domain does not exist this function call will fail
        collection::borrow_domain<Foo, SymbolDomain>(&collection);

        test_scenario::return_shared(collection);
        test_scenario::return_to_address(CREATOR, mint_cap);

        test_scenario::end(scenario);
    }

    #[test]
    fun add_attributes() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::new(&Witness {}, OWNER, ctx);

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

        // If domain does not exist this function call will fail
        nft::borrow_domain<Foo, AttributesDomain>(&nft);

        transfer(nft, OWNER);

        test_scenario::end(scenario);
    }
}
