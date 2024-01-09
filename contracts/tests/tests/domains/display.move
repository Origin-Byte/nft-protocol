#[test_only]
#[lint_allow(share_owned)]
module ob_tests::test_display {
    use std::ascii;
    use std::string;

    use sui::transfer;
    use sui::vec_map;
    use sui::test_scenario::{Self, ctx};
    use sui::object::{Self, UID};

    use nft_protocol::url;
    use nft_protocol::attributes;
    use nft_protocol::display_info;
    use nft_protocol::symbol;

    struct Foo has key, store {
        id: UID,
    }
    struct Witness has drop {}

    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_nft_display() {
        let scenario = test_scenario::begin(CREATOR);
        let ctx = ctx(&mut scenario);

        let nft = Foo { id: object::new(ctx) };

        display_info::add_domain(
            &mut nft.id,
            display_info::new(
                string::utf8(b"Suimarines-234"),
                string::utf8(b"Collection of Suimarines"),
            ),
        );

        // If domain does not exist this function call will fail
        display_info::borrow_domain(&nft.id);

        transfer::public_transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun add_nft_url() {
        let scenario = test_scenario::begin(CREATOR);
        let ctx = ctx(&mut scenario);

        let nft = Foo { id: object::new(ctx) };

        url::add_domain(
            &mut nft.id,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        // If domain does not exist this function call will fail
        url::borrow_domain(&nft.id);

        transfer::public_transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun add_nft_symbol() {
        let scenario = test_scenario::begin(CREATOR);
        let ctx = ctx(&mut scenario);

        let nft = Foo { id: object::new(ctx) };

        symbol::add_domain(
            &mut nft.id,
            symbol::new(string::utf8(b"SUIM-234")),
        );

        // If domain does not exist this function call will fail
        symbol::borrow_domain(&nft.id);

        transfer::public_transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun add_attributes() {
        let scenario = test_scenario::begin(CREATOR);
        let ctx = ctx(&mut scenario);

        let nft = Foo { id: object::new(ctx) };

        let attributes = vec_map::empty();
        vec_map::insert(
            &mut attributes, ascii::string(b"color"),
            ascii::string(b"yellow"),
        );

        attributes::add_domain(
            &mut nft.id,
            attributes::new(attributes),
        );

        // If domain does not exist this function call will fail
        attributes::borrow_domain(&nft.id);

        transfer::public_transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }
}
