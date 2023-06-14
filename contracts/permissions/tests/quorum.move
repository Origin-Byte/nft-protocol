#[test_only]
module ob_permissions::test_quorum {
    use sui::object;
    use sui::vec_set;
    use sui::transfer;

    use ob_utils::utils;
    use ob_permissions::quorum::{Self, Quorum, admins, delegates, admin_count, members, quorum_id, extension_token_id};
    use sui::test_scenario::{Self as ts};

    struct Witness has drop {}

    struct Foo has drop {}

    const QUORUM: address = @0x1234;
    const ADMIN_ADDR_1: address = @0x1;
    const ADMIN_ADDR_2: address = @0x2;
    const MEMBER_ADDR_1: address = @0x1337;
    const MEMBER_ADDR_2: address = @0x1338;

    #[test]
    fun test_create_basic() {
        let scenario = ts::begin(QUORUM);
        let delegate_uid_1 = ts::new_object(&mut scenario);
        let delegate_uid_2 = ts::new_object(&mut scenario);

        let admins = utils::vec_set_from_vec(&vector[ADMIN_ADDR_1, ADMIN_ADDR_2]);
        let members = utils::vec_set_from_vec(&vector[MEMBER_ADDR_1, MEMBER_ADDR_2]);
        let delegates = utils::vec_set_from_vec(&vector[object::uid_to_inner(&delegate_uid_1), object::uid_to_inner(&delegate_uid_2)]);

        let ctx = ts::ctx(&mut scenario);
        let quorum: Quorum<Foo> = quorum::create(&Foo {}, admins, members, delegates, ctx);

        assert!(admins(&quorum) == &admins, 1);
        assert!(members(&quorum) == &members, 2);
        assert!(delegates(&quorum) == &delegates, 3);
        assert!(admin_count(&quorum) == 2, 4);

        object::delete(delegate_uid_1);
        object::delete(delegate_uid_2);
        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    #[test]
    fun test_create_for_extension() {
        let scenario = ts::begin(QUORUM);
        let delegate_uid_1 = ts::new_object(&mut scenario);
        let delegate_uid_2 = ts::new_object(&mut scenario);

        let admins = utils::vec_set_from_vec(&vector[ADMIN_ADDR_1, ADMIN_ADDR_2]);
        let members = utils::vec_set_from_vec(&vector[MEMBER_ADDR_1, MEMBER_ADDR_2]);
        let delegates = utils::vec_set_from_vec(&vector[object::uid_to_inner(&delegate_uid_1), object::uid_to_inner(&delegate_uid_2)]);

        let ctx = ts::ctx(&mut scenario);
        let (quorum, ext_token) = quorum::create_for_extension(&Foo {}, admins, members, delegates, ctx);

        assert!(admins(&quorum) == &admins, 1);
        assert!(members(&quorum) == &members, 2);
        assert!(delegates(&quorum) == &delegates, 3);
        assert!(admin_count(&quorum) == 2, 4);
        assert!(quorum_id(&quorum) == extension_token_id(&ext_token), 6);

        // consume extension token
        quorum::destroy_ext_for_testing(ext_token);
        object::delete(delegate_uid_1);
        object::delete(delegate_uid_2);
        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

     #[test]
    fun test_init_quorum() {
        let scenario = ts::begin(QUORUM);
        let delegate_uid_1 = ts::new_object(&mut scenario);
        let delegate_uid_2 = ts::new_object(&mut scenario);

        let admins = utils::vec_set_from_vec(&vector[ADMIN_ADDR_1, ADMIN_ADDR_2]);
        let members = utils::vec_set_from_vec(&vector[MEMBER_ADDR_1, MEMBER_ADDR_2]);
        let delegates = utils::vec_set_from_vec(&vector[object::uid_to_inner(&delegate_uid_1), object::uid_to_inner(&delegate_uid_2)]);

        let ctx = ts::ctx(&mut scenario);
        let _quorum_id = quorum::init_quorum(&Foo {}, admins, members, delegates, ctx);

        ts::next_tx(&mut scenario, QUORUM);
        let quorum = ts::take_shared<Quorum<Foo>>(&mut scenario);

        assert!(admins(&quorum) == &admins, 1);
        assert!(members(&quorum) == &members, 2);
        assert!(delegates(&quorum) == &delegates, 3);
        assert!(admin_count(&quorum) == 2, 4);

        object::delete(delegate_uid_1);
        object::delete(delegate_uid_2);
        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    #[test]
    fun test_singleton() {
        let scenario = ts::begin(QUORUM);
        let delegate_uid_1 = ts::new_object(&mut scenario);
        let delegate_uid_2 = ts::new_object(&mut scenario);

        let ctx = ts::ctx(&mut scenario);
        let quorum = quorum::singleton(&Foo {}, ADMIN_ADDR_1, ctx);

        assert!(admins(&quorum) == &utils::vec_set_from_vec(&vector[ADMIN_ADDR_1]), 1);
        assert!(members(&quorum) == &vec_set::empty(), 2);
        assert!(delegates(&quorum) == &vec_set::empty(), 3);
        assert!(admin_count(&quorum) == 1, 4);
        object::delete(delegate_uid_1);
        object::delete(delegate_uid_2);
        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    // cannot move out because deconstruction is not allowed outside module

    #[test]
    fun test_assert_extension_token() {
        let scenario = ts::begin(QUORUM);
        let ctx = ts::ctx(&mut scenario);
        let (quorum, ext_token) = quorum::create_for_extension(&Foo {}, vec_set::empty(), vec_set::empty(), vec_set::empty(), ctx);

        quorum::assert_extension_token(&quorum, &ext_token);

        quorum::destroy_ext_for_testing(ext_token);
        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = quorum::EQuorumExtensionMismatch)]
    fun test_assert_extension_token_fail() {
        let scenario = ts::begin(QUORUM);
        let ctx = ts::ctx(&mut scenario);
        let (quorum, ext_token) = quorum::create_for_extension(&Foo {}, vec_set::empty(), vec_set::empty(), vec_set::empty(), ctx);
        let (quorum_2, ext_token_2) = quorum::create_for_extension(&Foo {}, vec_set::empty(), vec_set::empty(), vec_set::empty(), ctx);

        quorum::assert_extension_token(&quorum, &ext_token_2);

        // consume extension token
        quorum::destroy_ext_for_testing(ext_token);
        quorum::destroy_ext_for_testing(ext_token_2);
        transfer::public_share_object(quorum);
        transfer::public_share_object(quorum_2);
        ts::end(scenario);
    }

     // === Admin Functions Tests ===

    #[test]
    fun test_vote_add_admin_success() {
        let scenario = ts::begin(QUORUM);
        let sender = ts::sender(&mut scenario);
        let admins = utils::vec_set_from_vec(&vector[sender]);
        let ctx = ts::ctx(&mut scenario);
        let quorum: Quorum<Foo> = quorum::create(&Foo {}, admins, vec_set::empty(), vec_set::empty(), ctx);

        quorum::vote_add_admin(&mut quorum, ADMIN_ADDR_1, ctx);

        assert!(vec_set::contains(admins(&quorum), &sender), 1);
        assert!(vec_set::contains(admins(&quorum), &ADMIN_ADDR_1), 2);
        assert!(admin_count(&quorum) == 2, 3);

        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = quorum::ENotAnAdmin)]
    fun test_vote_add_admin_fail() {
        let scenario = ts::begin(QUORUM);
        let ctx = ts::ctx(&mut scenario);
        let quorum: Quorum<Foo> = quorum::create(&Foo {}, vec_set::empty(), vec_set::empty(), vec_set::empty(), ctx);

        quorum::vote_add_admin(&mut quorum, ADMIN_ADDR_1, ctx);

        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    #[test]
    fun test_vote_remove_admin_remove_self() {
        let scenario = ts::begin(QUORUM);
        let sender = ts::sender(&mut scenario);
        let admins = utils::vec_set_from_vec(&vector[sender]);
        let ctx = ts::ctx(&mut scenario);
        let quorum: Quorum<Foo> = quorum::create(&Foo {}, admins, vec_set::empty(), vec_set::empty(), ctx);

        quorum::vote_remove_admin(&mut quorum, sender, ctx);

        assert!(!vec_set::contains(admins(&quorum), &sender), 1);
        assert!(admin_count(&quorum) == 0, 3);

        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    #[test]
    fun test_vote_add_then_remove_admin() {
        let scenario_val = ts::begin(QUORUM);
        let scenario = &mut scenario_val;
        let quorum: Quorum<Foo>;
        //let sender = ts::sender(scenario);
        let admins = utils::vec_set_from_vec(&vector[ts::sender(scenario)]);
        {
            let ctx = ts::ctx(scenario);
            quorum = quorum::create(&Foo {}, admins, vec_set::empty(), vec_set::empty(), ctx);
        };
        {
            let ctx = ts::ctx(scenario);
            quorum::vote_add_admin(&mut quorum, ADMIN_ADDR_1, ctx);
            quorum::vote_add_admin(&mut quorum, ADMIN_ADDR_2, ctx);
            assert!(vec_set::contains(admins(&quorum), &ts::sender(scenario)), 1);
            assert!(vec_set::contains(admins(&quorum), &ADMIN_ADDR_1), 2);
            assert!(admin_count(&quorum) == 2, 3);
        };
        ts::next_tx(scenario, ADMIN_ADDR_1);
        {
            let ctx = ts::ctx(scenario);
            quorum::vote_add_admin(&mut quorum, ADMIN_ADDR_2, ctx);
            assert!(vec_set::contains(admins(&quorum), &ts::sender(scenario)), 4);
            assert!(vec_set::contains(admins(&quorum), &ADMIN_ADDR_1), 5);
            assert!(vec_set::contains(admins(&quorum), &ADMIN_ADDR_2), 6);
            assert!(admin_count(&quorum) == 3, 3);
        };
        ts::next_tx(scenario, QUORUM);
        {
            let ctx = ts::ctx(scenario);
            quorum::vote_remove_admin(&mut quorum, ADMIN_ADDR_1, ctx);
            assert!(vec_set::contains(admins(&quorum), &ts::sender(scenario)), 7);
            assert!(vec_set::contains(admins(&quorum), &ADMIN_ADDR_1), 8);
            assert!(admin_count(&quorum) == 3, 9);
        };
        ts::next_tx(scenario, ADMIN_ADDR_2);
        {
            let ctx = ts::ctx(scenario);
            quorum::vote_remove_admin(&mut quorum, ADMIN_ADDR_1, ctx);
            assert!(vec_set::contains(admins(&quorum), &ts::sender(scenario)), 10);
            assert!(!vec_set::contains(admins(&quorum), &ADMIN_ADDR_1), 11);
            assert!(admin_count(&quorum) == 2, 12);
        };
        quorum::destroy_for_testing(quorum);
        ts::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = vec_set::EKeyAlreadyExists)]
    fun test_assert_admin_fail_duplicate() {
        let scenario = ts::begin(QUORUM);
        let sender = ts::sender(&mut scenario);
        let ctx = ts::ctx(&mut scenario);
        let quorum = quorum::singleton(&Foo {}, sender, ctx);

        quorum::vote_add_admin(&mut quorum, sender, ctx);
        quorum::vote_add_admin(&mut quorum, sender, ctx);
        quorum::assert_admin(&quorum, ctx);

        quorum::destroy_for_testing(quorum);
        ts::end(scenario);
    }


   #[test]
    fun test_add_admin_with_extension_success() {
        let scenario = ts::begin(QUORUM);
        let sender = ts::sender(&mut scenario);
        let admins = utils::vec_set_from_vec(&vector[sender]);
        let ctx = ts::ctx(&mut scenario);
        let (quorum, ext_token) = quorum::create_for_extension(&Foo {}, admins, vec_set::empty(), vec_set::empty(), ctx);

        quorum::add_admin_with_extension(&mut quorum, &ext_token, ADMIN_ADDR_1);

        assert!(vec_set::contains(admins(&quorum), &sender), 1);
        assert!(vec_set::contains(admins(&quorum), &ADMIN_ADDR_1), 2);
        assert!(admin_count(&quorum) == 2, 3);

        // consume extension token
        quorum::destroy_ext_for_testing(ext_token);
        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    // === Delegate Functions Tests ===

     fun test_vote_add_delegate_success() {
        let scenario = ts::begin(QUORUM);
        let sender = ts::sender(&mut scenario);
        let admins = utils::vec_set_from_vec(&vector[sender]);
        let delegate_uid_1 = ts::new_object(&mut scenario);
        let delegate_inner_id_1 = object::uid_to_inner(&delegate_uid_1);

        let ctx = ts::ctx(&mut scenario);
        let quorum: Quorum<Foo> = quorum::create(&Foo {}, admins, vec_set::empty(), vec_set::empty(), ctx);

        quorum::vote_add_delegate(&mut quorum, delegate_inner_id_1, ctx);

        assert!(vec_set::contains(delegates(&quorum), &delegate_inner_id_1), 1);

        object::delete(delegate_uid_1);
        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = quorum::ENotAnAdmin)]
    fun test_vote_add_delegate_fail() {
        let scenario = ts::begin(QUORUM);
        let delegate_uid_1 = ts::new_object(&mut scenario);
        let delegate_inner_id_1 = object::uid_to_inner(&delegate_uid_1);
        let ctx = ts::ctx(&mut scenario);
        let quorum: Quorum<Foo> = quorum::create(&Foo {}, vec_set::empty(), vec_set::empty(), vec_set::empty(), ctx);

        quorum::vote_add_delegate(&mut quorum, delegate_inner_id_1, ctx);

        object::delete(delegate_uid_1);
        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    #[test]
    fun test_vote_remove_delegate_success() {
        let scenario = ts::begin(QUORUM);
        let sender = ts::sender(&mut scenario);
        let admins = utils::vec_set_from_vec(&vector[sender]);

        let delegate_uid_1 = ts::new_object(&mut scenario);
        let delegate_inner_id_1 = object::uid_to_inner(&delegate_uid_1);
        let delegates = utils::vec_set_from_vec(&vector[delegate_inner_id_1]);

        let ctx = ts::ctx(&mut scenario);
        let quorum: Quorum<Foo> = quorum::create(&Foo {}, admins, vec_set::empty(), delegates, ctx);

        quorum::vote_remove_delegate(&mut quorum, delegate_inner_id_1, ctx);

        assert!(!vec_set::contains(delegates(&quorum), &delegate_inner_id_1), 1);

        object::delete(delegate_uid_1);
        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

}
