#[test_only]
module nft_protocol::test_tags {
    use sui::transfer;
    use sui::test_scenario::{Self, ctx};
    use sui::object::{Self, UID};

    use nft_protocol::tags;

    struct Foo has key, store {
        id: UID,
    }

    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_nft_tags() {
        let scenario = test_scenario::begin(CREATOR);
        let ctx = ctx(&mut scenario);

        let nft = Foo { id: object::new(ctx) };

        let tags = tags::empty(ctx);
        tags::add_tag(&mut tags, tags::profile_picture());

        tags::add_domain(
            &mut nft.id,
            tags,
        );

        // If domain does not exist this function call will fail
        tags::borrow_domain(&nft.id);

        transfer::public_transfer(nft, CREATOR);

        test_scenario::end(scenario);
    }
}
