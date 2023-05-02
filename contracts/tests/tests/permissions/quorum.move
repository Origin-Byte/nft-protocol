#[test_only]
module ob_tests::quorum {

    // use ob_utils::utils::{Self};
    // use sui::test_scenario as ts;
    // use ob_permissions::quorum::{Self, Quorum, VERSION};
    // use sui::transfer;
    // use sui::object::{Self};

    // const QUORUM: address = @0x1234;

    // const ADMIN_ADDR_1: address = @0x1;
    // const ADMIN_ADDR_2: address = @0x2;
    // const MEMBER_ADDR_1: address = @0x1337;
    // const MEMBER_ADDR_2: address = @0x1338;

    // struct Foo has drop {}

    // #[test]
    // public fun test_create_basic() {
    //     let scenario = ts::begin(QUORUM);  
    //     let delegate_uid_1 = ts::new_object(&mut scenario);
    //     let delegate_uid_2 = ts::new_object(&mut scenario);

    //     let admins = utils::vec_set_from_vec(&vector[ADMIN_ADDR_1, ADMIN_ADDR_2]);
    //     let members = utils::vec_set_from_vec(&vector[MEMBER_ADDR_1, MEMBER_ADDR_2]);
    //     let delegates = utils::vec_set_from_vec(&vector[object::uid_to_inner(&delegate_uid_1), object::uid_to_inner(&delegate_uid_2)]);

    //     let ctx = ts::ctx(&mut scenario);
    //     let quorum: Quorum<Foo> = quorum::create(&Foo {}, admins, members, delegates, ctx);

    //     assert!(quorum.version == VERSION, 0);
    //     assert!(quorum.admins == admins, 1);
    //     assert!(quorum.members == members, 2);
    //     assert!(quorum.delegates == delegates, 3);
    //     assert!(quorum.admin_count == 2, 4);

    //     object::delete(delegate_uid_1);
    //     object::delete(delegate_uid_2);
    //     transfer::public_share_object(quorum);
    //     ts::end(scenario);
    // }

    
}