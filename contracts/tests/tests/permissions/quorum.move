#[test_only]
module ob_tests::quorum {

    use ob_utils::utils::{Self};
    use sui::test_scenario as ts;
    use ob_permissions::quorum::{Self, Quorum};
    use sui::transfer;
    use sui::object::{Self};
    use sui::vec_set::{Self};

    const QUORUM: address = @0x1234;

    const ADMIN_ADDR_1: address = @0x1;
    const ADMIN_ADDR_2: address = @0x2;
    const MEMBER_ADDR_1: address = @0x1337;
    const MEMBER_ADDR_2: address = @0x1338;

    struct Foo has drop {}

   
    #[test]
    fun test_assert_admin() {
        let scenario = ts::begin(QUORUM);  
        let admins = utils::vec_set_from_vec(&vector[ts::sender(&mut scenario)]);
        let ctx = ts::ctx(&mut scenario);
        let quorum: Quorum<Foo> = quorum::create(&Foo {}, admins, vec_set::empty(), vec_set::empty(), ctx);    

        quorum::assert_admin(&quorum, ctx);

        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = quorum::ENotAnAdmin)]
    fun test_assert_admin_fail() {
        let scenario = ts::begin(QUORUM);  
        let ctx = ts::ctx(&mut scenario);
        let quorum: Quorum<Foo> = quorum::create(&Foo {}, vec_set::empty(), vec_set::empty(), vec_set::empty(), ctx);    

        quorum::assert_admin(&quorum, ctx);

        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    #[test]
    fun test_assert_member() {
        let scenario = ts::begin(QUORUM);
        let members = utils::vec_set_from_vec(&vector[ts::sender(&mut scenario)]);  
        let ctx = ts::ctx(&mut scenario);
        let quorum: Quorum<Foo> = quorum::create(&Foo {}, vec_set::empty(), members, vec_set::empty(), ctx);    

        quorum::assert_member(&quorum, ctx);

        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = quorum::ENotAMember)]
    fun test_assert_member_fail() {
        let scenario = ts::begin(QUORUM);  
        let ctx = ts::ctx(&mut scenario);
        let quorum: Quorum<Foo> = quorum::create(&Foo {}, vec_set::empty(), vec_set::empty(), vec_set::empty(), ctx);    

        quorum::assert_member(&quorum, ctx);

        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    #[test]
    fun test_assert_member_or_admin() {
        let scenario = ts::begin(QUORUM);
        let members = utils::vec_set_from_vec(&vector[ts::sender(&mut scenario)]);  
        let ctx = ts::ctx(&mut scenario);
        let quorum: Quorum<Foo> = quorum::create(&Foo {}, vec_set::empty(), members, vec_set::empty(), ctx);    

        quorum::assert_member_or_admin(&quorum, ctx);

        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = quorum::ENotAnAdminNorMember)]
    fun test_assert_member_or_admin_fail() {
        let scenario = ts::begin(QUORUM);  
        let ctx = ts::ctx(&mut scenario);
        let quorum: Quorum<Foo> = quorum::create(&Foo {}, vec_set::empty(), vec_set::empty(), vec_set::empty(), ctx);    

        quorum::assert_member_or_admin(&quorum, ctx);

        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    #[test]
    fun test_assert_delegate() {
        let scenario = ts::begin(QUORUM);  
        let delegate_uid_1 = ts::new_object(&mut scenario);
        let delegates = utils::vec_set_from_vec(&vector[object::uid_to_inner(&delegate_uid_1)]);

        let ctx = ts::ctx(&mut scenario);
        let quorum: Quorum<Foo> = quorum::create(&Foo {}, vec_set::empty(), vec_set::empty(), delegates, ctx);    

        quorum::assert_delegate(&quorum, &delegate_uid_1);

        object::delete(delegate_uid_1);
        transfer::public_share_object(quorum);
        ts::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = quorum::EInvalidDelegate)]
    fun test_assert_delegate_fail() {
        let scenario = ts::begin(QUORUM);  
        let delegate_uid_1 = ts::new_object(&mut scenario);
        let delegate_uid_2 = ts::new_object(&mut scenario);
        let delegates = utils::vec_set_from_vec(&vector[object::uid_to_inner(&delegate_uid_1)]);

        let ctx = ts::ctx(&mut scenario);
        let quorum: Quorum<Foo> = quorum::create(&Foo {}, vec_set::empty(), vec_set::empty(), delegates, ctx);    

        quorum::assert_delegate(&quorum, &delegate_uid_2);

        object::delete(delegate_uid_1);
        object::delete(delegate_uid_2);
        transfer::public_share_object(quorum);
        ts::end(scenario);
    }
}