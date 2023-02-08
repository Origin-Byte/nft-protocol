#[test_only]
module nft_protocol::test_url {
    use std::ascii;

    use sui::transfer;
    use sui::url;
    use sui::vec_map;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::nft;
    use nft_protocol::witness;
    use nft_protocol::collection;
    use nft_protocol::url::{Self as url_domain};
    use nft_protocol::attributes::{Self, AttributesDomain};

    struct Foo has drop {}
    struct Witness has drop {}

    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_nft_url() {
        let scenario = test_scenario::begin(CREATOR);
        let ctx = ctx(&mut scenario);

        let nft = nft::test_mint<Foo>(CREATOR, ctx);

        url_domain::add(
            witness::from_witness(&Witness {}),
            &mut nft,
            url::new_unsafe_from_bytes(b"https://originbyte.io/"),
            ctx(&mut scenario),
        );

        url_domain::assert_url(&nft);

        transfer::transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun add_collection_url() {
        let scenario = test_scenario::begin(CREATOR);

        let (mint_cap, collection) =
            collection::create(&Foo {}, ctx(&mut scenario));

        url_domain::add_collection(
            witness::from_witness(&Witness {}),
            &mut collection,
            url::new_unsafe_from_bytes(b"https://originbyte.io/"),
            ctx(&mut scenario)
        );

        url_domain::assert_collection_url(&collection);

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
            &mut attributes, ascii::string(b"color"),
            ascii::string(b"yellow"),
        );

        attributes::add(
            witness::from_witness(&Witness {}),
            &mut nft,
            attributes,
            ctx
        );

        // If domain does not exist this function call will fail
        nft::borrow_domain<Foo, AttributesDomain>(&nft);

        transfer::transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }
}