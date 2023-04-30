#[test_only]
module ob_tests::test_frozen_publisher {
    use std::string;

    use sui::transfer;
    use sui::display;
    use sui::test_utils as sui_tests;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::collection::{Self, Collection};
    use ob_permissions::frozen_publisher;
    use nft_protocol::tags;
    use nft_protocol::nft_protocol::NFT_PROTOCOL;
    use ob_utils::display::{Self as ob_display};
    use ob_permissions::witness;

    use ob_tests::test_utils::{Foo, creator};

    #[test]
    fun create_collection_display_with_frozen_pub() {
        let scenario = test_scenario::begin(creator());

        let delegated_witness = witness::test_dw();

        let collection: Collection<Foo> = collection::create(
            delegated_witness, ctx(&mut scenario),
        );

        let tags = vector[tags::art(), tags::collectible()];

        let otw = sui_tests::create_one_time_witness<NFT_PROTOCOL>();
        let frozen_pub = frozen_publisher::get_frozen_publisher_for_test(otw, ctx(&mut scenario));

        let display = collection::new_display(
            delegated_witness,
            &frozen_pub,
            ctx(&mut scenario),
        );

        display::add(&mut display, string::utf8(b"collection_name"), string::utf8(b"Foo"));
        display::add(&mut display, string::utf8(b"tags"), ob_display::from_vec(tags));

        display::update_version(&mut display);
        transfer::public_transfer(display, creator());

        frozen_publisher::public_freeze_object(frozen_pub);
        transfer::public_share_object(collection);
        test_scenario::end(scenario);
    }
}
