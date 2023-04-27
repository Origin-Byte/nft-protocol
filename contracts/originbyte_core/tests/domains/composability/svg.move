#[test_only]
module nft_protocol::test_composable_svg {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::vec_map;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::svg;
    use nft_protocol::composable_svg as c_svg;

    /// Root NFT
    struct Avatar has key, store {
        id: UID,
    }

    struct DummyAvatar {}

    /// Child NFT to compose under `Avatar`
    struct Hat has key, store {
        id: UID,
    }

    /// Child NFT to compose under `Avatar`
    struct Glasses has key, store {
        id: UID,
    }

    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_svg() {
        let scenario = test_scenario::begin(CREATOR);

        let object = object::new(ctx(&mut scenario));

        c_svg::add_new(&mut object);
        c_svg::assert_composable_svg(&object);
        let svg = c_svg::remove_domain(&mut object);
        c_svg::delete(svg);

        c_svg::add_from_attributes(&mut object, vec_map::empty());
        c_svg::assert_composable_svg(&object);
        let svg = c_svg::remove_domain(&mut object);
        c_svg::delete(svg);

        object::delete(object);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = c_svg::EExistingComposableSvg)]
    fun add_svg_twice() {
        let scenario = test_scenario::begin(CREATOR);

        let object = object::new(ctx(&mut scenario));

        c_svg::add_new(&mut object);
        c_svg::add_new(&mut object);

        object::delete(object);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = c_svg::EUndefinedComposableSvg)]
    fun try_remove_svg() {
        let scenario = test_scenario::begin(CREATOR);

        let object = object::new(ctx(&mut scenario));

        let svg = c_svg::remove_domain(&mut object);
        c_svg::delete(svg);

        object::delete(object);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = c_svg::EUndefinedComposableSvg)]
    fun try_borrow_svg() {
        let scenario = test_scenario::begin(CREATOR);

        let object = object::new(ctx(&mut scenario));
        c_svg::borrow_domain(&object);

        object::delete(object);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = c_svg::EUndefinedComposableSvg)]
    fun try_borrow_svg_mut() {
        let scenario = test_scenario::begin(CREATOR);

        let object = object::new(ctx(&mut scenario));
        c_svg::borrow_domain_mut(&mut object);

        object::delete(object);
        test_scenario::end(scenario);
    }

    #[test]
    fun register_nft() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        c_svg::add_new(&mut nft.id);

        let child = object::new(ctx(&mut scenario));
        c_svg::register_nft(&mut nft.id, object::uid_to_inner(&child));

        object::delete(child);
        transfer::transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = c_svg::EUndefinedNft)]
    fun try_deregister_nft_undefined() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        c_svg::add_new(&mut nft.id);

        let child = object::new(ctx(&mut scenario));
        c_svg::deregister_nft(&mut nft.id, object::uid_to_inner(&child));

        object::delete(child);
        transfer::transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun deregister_nft() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        c_svg::add_new(&mut nft.id);

        let child = object::new(ctx(&mut scenario));
        let child_id = object::uid_to_inner(&child);

        c_svg::register_nft(&mut nft.id, child_id);
        c_svg::deregister_nft(&mut nft.id, child_id);

        object::delete(child);
        transfer::transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = c_svg::ERenderIncomplete)]
    fun try_render_nft_incomplete() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        c_svg::add_new(&mut nft.id);

        let child_0 = object::new(ctx(&mut scenario));
        svg::add_empty(&mut child_0);
        c_svg::register_nft(&mut nft.id, object::uid_to_inner(&child_0));

        let child_1 = object::new(ctx(&mut scenario));
        svg::add_empty(&mut child_1);
        c_svg::register_nft(&mut nft.id, object::uid_to_inner(&child_1));

        // Begin render
        let rg = c_svg::start_render_nft(&nft.id);
        c_svg::render_child(&mut rg, &child_0);

        c_svg::finish_render_nft(rg, &mut nft.id);

        object::delete(child_0);
        object::delete(child_1);
        transfer::transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = c_svg::EInvalidChild)]
    fun try_render_nft_twice() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        c_svg::add_new(&mut nft.id);

        let child_0 = object::new(ctx(&mut scenario));
        svg::add_empty(&mut child_0);
        c_svg::register_nft(&mut nft.id, object::uid_to_inner(&child_0));

        let child_1 = object::new(ctx(&mut scenario));
        svg::add_empty(&mut child_1);
        c_svg::register_nft(&mut nft.id, object::uid_to_inner(&child_1));

        // Begin render
        let rg = c_svg::start_render_nft(&nft.id);
        c_svg::render_child(&mut rg, &child_0);
        c_svg::render_child(&mut rg, &child_0);

        c_svg::finish_render_nft(rg, &mut nft.id);

        object::delete(child_0);
        object::delete(child_1);
        transfer::transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun render_nft() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        c_svg::add_new(&mut nft.id);

        let child_0 = object::new(ctx(&mut scenario));
        svg::add_new(&mut child_0, b"<text>Hello, Sui!</text>");
        c_svg::register_nft(&mut nft.id, object::uid_to_inner(&child_0));

        let child_1 = object::new(ctx(&mut scenario));
        c_svg::register_nft(&mut nft.id, object::uid_to_inner(&child_1));

        // Begin render
        let rg = c_svg::start_render_nft(&nft.id);

        c_svg::render_child(&mut rg, &child_0);
        c_svg::render_child_external(
            &mut rg, &mut child_1, b"<text>Hello, Originbyte!</text>",
        );

        c_svg::finish_render_nft(rg, &mut nft.id);

        // Check render result
        let svg = c_svg::borrow_svg_nft(&nft.id);
        assert!(
            svg == &b"<svg xmlns=\"http://www.w3.org/2000/svg\"><g><text>Hello, Sui!</text></g><g><text>Hello, Originbyte!</text></g></svg>",
            0
        );

        object::delete(child_0);
        object::delete(child_1);
        transfer::transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }
}
