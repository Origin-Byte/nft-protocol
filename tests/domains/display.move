#[test_only]
module nft_protocol::test_display {
    use std::string;

    use sui::transfer;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::nft;
    use nft_protocol::witness;
    use nft_protocol::collection;
    use nft_protocol::display::{Self, DisplayDomain, SymbolDomain};

    struct Foo has drop {}
    struct Witness has drop {}

    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_nft_display() {
        let scenario = test_scenario::begin(CREATOR);
        let ctx = ctx(&mut scenario);

        let nft = nft::test_mint<Foo>(CREATOR, ctx);

        display::add_display_domain(
            witness::from_witness(&Witness {}),
            &mut nft,
            string::utf8(b"Suimarines-234"),
            string::utf8(b"Collection of Suimarines"),
            ctx
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
            witness::from_witness(&Witness {}),
            &mut collection,
            string::utf8(b"Suimarines-234"),
            string::utf8(b"Collection of Suimarines"),
            ctx(&mut scenario)
        );

        // If domain does not exist this function call will fail
        collection::borrow_domain<Foo, DisplayDomain>(&collection);

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
            witness::from_witness(&Witness {}),
            &mut nft,
            string::utf8(b"SUIM-234"),
            ctx
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
            witness::from_witness(&Witness {}),
            &mut collection,
            string::utf8(b"SUIM"),
            ctx(&mut scenario)
        );

        // If domain does not exist this function call will fail
        collection::borrow_domain<Foo, SymbolDomain>(&collection);

        transfer::share_object(collection);
        transfer::transfer(mint_cap, CREATOR);
        test_scenario::end(scenario);
    }
}
