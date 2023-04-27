#[test_only]
module nft_protocol::test_composable_nft {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::test_scenario::{Self, ctx};

    use ob_witness::witness;
    use nft_protocol::collection;
    use nft_protocol::nft_bag::{Self, NftBag};
    use nft_protocol::composable_nft::{Self as c_nft, Composition};

    struct Witness has drop {}

    /// Root NFT
    struct Avatar has key, store {
        id: UID,
    }

    /// Root static NFT
    struct AvatarStatic has key, store {
        id: UID,
        composition: Composition<Avatar>,
        nft_bag: NftBag,
    }

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
    #[expected_failure(abort_code = c_nft::EExistingRelationship)]
    fun try_new_composition() {
        let scenario = test_scenario::begin(CREATOR);

        let composition = c_nft::new_composition<Avatar>();
        c_nft::add_relationship<Avatar, Hat>(&mut composition, 1);
        c_nft::add_relationship<Avatar, Hat>(&mut composition, 2);

        c_nft::delete(composition);
        test_scenario::end(scenario);
    }

    #[test]
    fun new_composition() {
        let scenario = test_scenario::begin(CREATOR);

        let composition = c_nft::new_composition<Avatar>();
        c_nft::add_relationship<Avatar, Hat>(&mut composition, 1);
        c_nft::add_relationship<Avatar, Glasses>(&mut composition, 1);

        let child_type = std::type_name::get<Hat>();
        let _ = c_nft::borrow_limit_mut(&mut composition, &child_type);

        c_nft::delete(composition);
        test_scenario::end(scenario);
    }

    #[test]
    fun add_composition() {
        let scenario = test_scenario::begin(CREATOR);

        let object = object::new(ctx(&mut scenario));

        c_nft::add_new_composition<Avatar>(&mut object);
        c_nft::assert_composition<Avatar>(&object);
        c_nft::assert_no_composition<Hat>(&object);

        let _ = c_nft::borrow_domain_mut<Avatar>(&mut object);

        let composition = c_nft::remove_domain<Avatar>(&mut object);
        c_nft::delete(composition);

        object::delete(object);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = c_nft::EExistingComposition)]
    fun add_composition_twice() {
        let scenario = test_scenario::begin(CREATOR);

        let object = object::new(ctx(&mut scenario));

        c_nft::add_new_composition<Avatar>(&mut object);
        c_nft::add_new_composition<Avatar>(&mut object);

        object::delete(object);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = c_nft::EUndefinedComposition)]
    fun try_remove_composition() {
        let scenario = test_scenario::begin(CREATOR);

        let object = object::new(ctx(&mut scenario));

        let composition = c_nft::remove_domain<Avatar>(&mut object);
        c_nft::delete(composition);

        object::delete(object);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = c_nft::EUndefinedComposition)]
    fun try_borrow_composition() {
        let scenario = test_scenario::begin(CREATOR);

        let object = object::new(ctx(&mut scenario));
        c_nft::borrow_domain<Avatar>(&object);

        object::delete(object);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = c_nft::EUndefinedComposition)]
    fun try_borrow_composition_mut() {
        let scenario = test_scenario::begin(CREATOR);

        let object = object::new(ctx(&mut scenario));
        c_nft::borrow_domain_mut<Avatar>(&mut object);

        object::delete(object);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = c_nft::EChildNotComposable)]
    fun try_compose_nft_undefined() {
        let scenario = test_scenario::begin(CREATOR);

        let composition = c_nft::new_composition<Avatar>();

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));

        c_nft::compose_into_nft(
            &composition,
            &mut nft.id,
            Hat { id: object::new(ctx(&mut scenario)) },
        );

        transfer::transfer(nft, CREATOR);
        c_nft::delete(composition);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = c_nft::EExceededLimit)]
    fun try_compose_nft_limit() {
        let scenario = test_scenario::begin(CREATOR);

        let composition = c_nft::new_composition<Avatar>();
        c_nft::add_relationship<Avatar, Hat>(&mut composition, 1);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));

        c_nft::compose_into_nft(
            &composition,
            &mut nft.id,
            Hat { id: object::new(ctx(&mut scenario)) },
        );

        c_nft::compose_into_nft(
            &composition,
            &mut nft.id,
            Hat { id: object::new(ctx(&mut scenario)) },
        );

        transfer::transfer(nft, CREATOR);
        c_nft::delete(composition);
        test_scenario::end(scenario);
    }

    #[test]
    fun compose_nft() {
        let scenario = test_scenario::begin(CREATOR);

        let composition = c_nft::new_composition<Avatar>();
        c_nft::add_relationship<Avatar, Hat>(&mut composition, 1);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));

        c_nft::compose_into_nft(
            &composition,
            &mut nft.id,
            Hat { id: object::new(ctx(&mut scenario)) },
        );

        transfer::transfer(nft, CREATOR);
        c_nft::delete(composition);
        test_scenario::end(scenario);
    }

    #[test]
    fun compose_nft_with_nft_schema() {
        let scenario = test_scenario::begin(CREATOR);

        let composition = c_nft::new_composition<Avatar>();
        c_nft::add_relationship<Avatar, Hat>(&mut composition, 1);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));
        c_nft::add_domain(&mut nft.id, composition);

        c_nft::compose_with_nft_schema<Avatar, Hat>(
            &mut nft.id,
            Hat { id: object::new(ctx(&mut scenario)) },
        );

        transfer::transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun compose_nft_with_collection_schema() {
        let scenario = test_scenario::begin(CREATOR);

        let composition = c_nft::new_composition<Avatar>();
        c_nft::add_relationship<Avatar, Hat>(&mut composition, 1);

        let delegated_witness =
            witness::from_witness<Avatar, Witness>(Witness {});
        let collection =
            collection::create(delegated_witness, ctx(&mut scenario));

        collection::add_domain(
            delegated_witness, &mut collection, composition,
        );

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));

        c_nft::compose_with_collection_schema<Avatar, Avatar, Hat>(
            &collection,
            &mut nft.id,
            Hat { id: object::new(ctx(&mut scenario)) },
        );

        transfer::public_share_object(collection);
        transfer::transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = c_nft::EChildNotComposable)]
    fun try_decompose_nft_undefined() {
        let scenario = test_scenario::begin(CREATOR);

        let composition = c_nft::new_composition<Avatar>();
        c_nft::add_relationship<Avatar, Hat>(&mut composition, 1);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));

        let child = Hat { id: object::new(ctx(&mut scenario)) };
        let child_id = object::id(&child);

        c_nft::compose_into_nft(&composition, &mut nft.id, child);

        // Test decompose for NFT that exists but with incorrect composition
        let fake_composition = c_nft::new_composition<Avatar>();
        let child = c_nft::decompose_from_nft<Avatar, Hat>(
            &fake_composition, &mut nft.id, child_id,
        );

        transfer::transfer(child, CREATOR);
        transfer::transfer(nft, CREATOR);
        c_nft::delete(composition);
        c_nft::delete(fake_composition);
        test_scenario::end(scenario);
    }

    #[test]
    fun decompose_nft() {
        let scenario = test_scenario::begin(CREATOR);

        let composition = c_nft::new_composition<Avatar>();
        c_nft::add_relationship<Avatar, Hat>(&mut composition, 1);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));

        let child = Hat { id: object::new(ctx(&mut scenario)) };
        let child_id = object::id(&child);

        c_nft::compose_into_nft(&composition, &mut nft.id, child);

        let child = c_nft::decompose_from_nft<Avatar, Hat>(
            &composition, &mut nft.id, child_id,
        );

        transfer::transfer(child, CREATOR);
        transfer::transfer(nft, CREATOR);
        c_nft::delete(composition);
        test_scenario::end(scenario);
    }

    #[test]
    fun decompose_nft_with_nft_schema() {
        let scenario = test_scenario::begin(CREATOR);

        let composition = c_nft::new_composition<Avatar>();
        c_nft::add_relationship<Avatar, Hat>(&mut composition, 1);

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));
        c_nft::add_domain(&mut nft.id, composition);

        let child = Hat { id: object::new(ctx(&mut scenario)) };
        let child_id = object::id(&child);

        c_nft::compose_with_nft_schema<Avatar, Hat>(
            &mut nft.id, child,
        );

        let child = c_nft::decompose_with_nft_schema<Avatar, Hat>(
            &mut nft.id, child_id,
        );

        transfer::transfer(child, CREATOR);
        transfer::transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun decompose_nft_with_collection_schema() {
        let scenario = test_scenario::begin(CREATOR);

        let composition = c_nft::new_composition<Avatar>();
        c_nft::add_relationship<Avatar, Hat>(&mut composition, 1);

        let delegated_witness =
            witness::from_witness<Avatar, Witness>(Witness {});
        let collection =
            collection::create(delegated_witness, ctx(&mut scenario));

        collection::add_domain(
            delegated_witness, &mut collection, composition,
        );

        let nft = Avatar { id: object::new(ctx(&mut scenario)) };
        nft_bag::add_new(&mut nft.id, ctx(&mut scenario));

        let child = Hat { id: object::new(ctx(&mut scenario)) };
        let child_id = object::id(&child);

        c_nft::compose_with_collection_schema<Avatar, Avatar, Hat>(
            &collection, &mut nft.id, child,
        );

        let child = c_nft::decompose_with_collection_schema<Avatar, Avatar, Hat>(
            &collection, &mut nft.id, child_id,
        );

        transfer::public_share_object(collection);
        transfer::transfer(child, CREATOR);
        transfer::transfer(nft, CREATOR);
        test_scenario::end(scenario);
    }
}
