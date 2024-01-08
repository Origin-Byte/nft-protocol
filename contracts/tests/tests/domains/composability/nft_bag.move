#[test_only]
#[lint_allow(share_owned)]
module ob_tests::test_nft_bag {
    use std::vector;
    use std::type_name;

    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::vec_map;
    use sui::test_scenario::{Self, ctx};
    use sui::tx_context;

    use nft_protocol::nft_bag;

    /// Root NFT
    struct Avatar has key, store {
        id: UID,
    }

    /// Child NFT to compose under `Avatar`
    struct Hat has key, store {
        id: UID,
    }

    /// Authority for composing `Hat`
    struct AuthHat has drop {}

    /// Child NFT to compose under `Avatar`
    struct Glasses has key, store {
        id: UID,
    }

    /// Authority for composing `Glasses`
    struct AuthGlasses has drop {}

    /// Authority for composing nothing
    struct AuthDummy has drop {}

    struct Witness has drop {}

    const CREATOR: address = @0xA1C04;

    #[test]
    fun add_nft_bag() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };

        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));
        nft_bag::assert_nft_bag(&nft.id);

        let nft_bag = nft_bag::remove_domain(&mut nft.id);
        nft_bag::delete(nft_bag);

        let Avatar { id } = nft;
        object::delete(id);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft_bag::EExistingNftBag)]
    fun add_nft_bag_twice() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };

        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));

        transfer::public_transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft_bag::EUndefinedNftBag)]
    fun try_remove_nft_bag() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };

        let nft_bag = nft_bag::remove_domain(&mut nft.id);
        nft_bag::delete(nft_bag);

        transfer::public_transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft_bag::EUndefinedNftBag)]
    fun try_borrow_nft_bag() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };

        nft_bag::borrow_domain(&nft.id);

        transfer::public_transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft_bag::EUndefinedNftBag)]
    fun try_borrow_nft_bag_mut() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };

        nft_bag::borrow_domain_mut(&mut nft.id);

        transfer::public_transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft_bag::ENotEmpty)]
    fun try_delete_nft_bag() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));

        nft_bag::compose_into_nft(
            AuthHat {},
            &mut nft.id,
            Hat { id: object::new(ctx(&mut scenario))},
        );

        let nft_bag = nft_bag::remove_domain(&mut nft.id);
        nft_bag::delete(nft_bag);

        transfer::public_transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun compose_nft() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));

        let child_nft = Hat { id: object::new(ctx(&mut scenario))};
        let child_nft_id = object::id(&child_nft);

        nft_bag::compose_into_nft(
            AuthHat {}, &mut nft.id, child_nft,
        );

        nft_bag::borrow_nft<Hat>(&nft.id, child_nft_id);
        nft_bag::borrow_nft_mut<Hat>(&mut nft.id, child_nft_id);

        transfer::public_transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft_bag::EUndefinedNft)]
    fun try_borrow_composed_nft() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));

        let addr = tx_context::fresh_object_address(ctx(&mut scenario));
        nft_bag::borrow_nft<Hat>(&nft.id, object::id_from_address(addr));

        transfer::public_transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft_bag::EUndefinedNft)]
    fun try_borrow_composed_nft_mut() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));

        let addr = tx_context::fresh_object_address(ctx(&mut scenario));
        nft_bag::borrow_nft_mut<Hat>(&mut nft.id, object::id_from_address(addr));

        transfer::public_transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft_bag::EUndefinedNft)]
    fun try_decompose_undefined() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));

        let addr = tx_context::fresh_object_address(ctx(&mut scenario));
        nft_bag::decompose_from_nft_and_transfer<Hat, AuthHat>(
            AuthHat {},
            &mut nft.id,
            object::id_from_address(addr),
            ctx(&mut scenario),
        );

        transfer::public_transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft_bag::EInvalidAuthority)]
    fun try_decompose_invalid_authority() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));

        let child_nft = Hat { id: object::new(ctx(&mut scenario))};
        let child_nft_id = object::id(&child_nft);

        nft_bag::compose_into_nft(
            AuthHat {}, &mut nft.id, child_nft,
        );

        nft_bag::decompose_from_nft_and_transfer<Hat, AuthGlasses>(
            AuthGlasses {}, &mut nft.id, child_nft_id, ctx(&mut scenario),
        );

        transfer::public_transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft_bag::EInvalidType)]
    fun try_decompose_invalid_type() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));

        let child_nft = Hat { id: object::new(ctx(&mut scenario))};
        let child_nft_id = object::id(&child_nft);

        nft_bag::compose_into_nft(
            AuthHat {}, &mut nft.id, child_nft,
        );

        nft_bag::decompose_from_nft_and_transfer<Glasses, AuthHat>(
            AuthHat {}, &mut nft.id, child_nft_id, ctx(&mut scenario),
        );

        transfer::public_transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[lint_allow(collection_equality)]
    fun decompose_nft() {
        let scenario = test_scenario::begin(CREATOR);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));

        let nft_0 = Hat { id: object::new(ctx(&mut scenario))};
        let nft_id_0 = object::id(&nft_0);
        nft_bag::compose_into_nft(AuthHat {}, &mut nft.id, nft_0);

        let nft_1 = Glasses { id: object::new(ctx(&mut scenario))};
        let nft_id_1 = object::id(&nft_1);
        nft_bag::compose_into_nft(AuthGlasses {}, &mut nft.id, nft_1);

        let nft_2 = Hat { id: object::new(ctx(&mut scenario))};
        let nft_id_2 = object::id(&nft_2);
        nft_bag::compose_into_nft(AuthHat {}, &mut nft.id, nft_2);

        // Validate expected structure
        let nft_bag = nft_bag::borrow_domain_mut(&mut nft.id);

        assert!(nft_bag::count<AuthDummy>(nft_bag) == 0, 0);
        assert!(nft_bag::count<AuthHat>(nft_bag) == 2, 0);
        assert!(nft_bag::count<AuthGlasses>(nft_bag) == 1, 0);

        let expected_authorities = vector::empty();
        vector::push_back(&mut expected_authorities, type_name::get<AuthHat>());
        vector::push_back(&mut expected_authorities, type_name::get<AuthGlasses>());

        assert!(nft_bag::get_authorities(nft_bag) == &expected_authorities, 0);

        let expected_nfts = vec_map::empty();
        vec_map::insert(&mut expected_nfts, nft_id_0, 0);
        vec_map::insert(&mut expected_nfts, nft_id_1, 1);
        vec_map::insert(&mut expected_nfts, nft_id_2, 0);

        assert!(nft_bag::get_nfts(nft_bag) == &expected_nfts, 0);

        // Decompose NFTs and validate structure changes
        nft_bag::decompose_and_transfer<Glasses, AuthGlasses>(
            AuthGlasses {}, nft_bag, nft_id_1, ctx(&mut scenario),
        );

        // Validate that authorities do not change
        assert!(nft_bag::get_authorities(nft_bag) == &expected_authorities, 0);

        let expected_nfts = vec_map::empty();
        vec_map::insert(&mut expected_nfts, nft_id_0, 0);
        vec_map::insert(&mut expected_nfts, nft_id_2, 0);

        assert!(nft_bag::get_nfts(nft_bag) == &expected_nfts, 0);

        // Validate that NFTs are deposited
        nft_bag::decompose_from_nft_and_transfer<Hat, AuthHat>(
            AuthHat {}, &mut nft.id, nft_id_0, ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        assert!(
            test_scenario::has_most_recent_for_address<Glasses>(CREATOR), 0,
        );
        assert!(test_scenario::has_most_recent_for_address<Hat>(CREATOR), 0);

        transfer::public_transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }
}
