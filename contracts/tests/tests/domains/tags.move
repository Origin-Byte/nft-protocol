#[test_only]
module ob_tests::test_tags {
    use std::string;
    use sui::transfer;
    use sui::package;
    use sui::display;
    use sui::test_scenario::{Self, ctx};
    use sui::object::UID;

    use nft_protocol::tags;
    use nft_protocol::display as ob_display;

    struct Foo has key, store {
        id: UID,
    }

    struct TEST_TAGS has drop {}

    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_nft_tags() {
        let scenario = test_scenario::begin(CREATOR);
        let publisher = package::test_claim(TEST_TAGS {}, ctx(&mut scenario));

        let tags = vector[tags::art(), tags::collectible()];

        let display = display::new<Foo>(&publisher, ctx(&mut scenario));
        display::add(&mut display, string::utf8(b"tags"), ob_display::from_vec(tags));
        display::update_version(&mut display);

        let fields = display::fields(&display);
        let fields_str = ob_display::from_vec_map_ref(fields, false);

        assert!(fields_str == string::utf8(b"{\"tags\": [\"Art\",\"Collectible\"]}"), 0);

        transfer::public_transfer(display, CREATOR);
        transfer::public_transfer(publisher, CREATOR);

        test_scenario::end(scenario);
    }
}
