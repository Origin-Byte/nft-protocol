#[test_only]
module ob_launchpad_v2::test_auth {
    // use std::option::some;
    // use std::type_name;
    // use std::vector;
    // use std::string;
    use std::debug;
    // use std::ascii;
    // use std::vector;

    use sui::test_scenario::{Self, ctx};
    use sui::object;
    use sui::bcs;
    // use sui::address as sui_address;
    // use sui::ed25519;
    use sui::transfer;

    use ob_launchpad_v2::venue::{Self};
    use ob_launchpad_v2::launchpad_auth;
    use ob_launchpad_v2::test_utils;
    use ob_launchpad_v2::auth_request;

    const SENDER: address = @0xA5C08;
    const MARKETPLACE: address = @0xA1C08;

    #[test]
    public fun it_works() {
        let scenario = test_scenario::begin(SENDER);

        // 1. Create a Launchpad Listing and Venue
        let (listing, launch_cap, venue) = test_utils::create_fixed_bid_launchpad(&mut scenario);

        let _counter = bcs::to_bytes(&1_u64);
        let _sender = bcs::to_bytes(&SENDER);

        // Prepare the verification tx
        let msg = b"00000000000000000000000000000000000000000000000000000000000a5c08";
        let public_key = vector[51, 162, 43, 242, 237, 43, 157, 244, 90, 56, 10, 125, 5, 66, 211, 69, 231, 34, 7, 21, 141, 115, 110, 83, 163, 242, 128, 60, 64, 230, 137, 86];
        let signature = vector[168, 104, 15, 53, 64, 166, 52, 0, 217, 94, 88, 48, 244, 21, 215, 151, 59, 227, 237, 82, 195, 172, 7, 181, 210, 145, 104, 121, 77, 85, 66, 127, 8, 168, 129, 41, 181, 81, 161, 89, 105, 240, 111, 180, 12, 238, 214, 4, 33, 43, 158, 188, 121, 131, 162, 16, 148, 65, 74, 215, 62, 149, 220, 12];

        launchpad_auth::add_pubkey(
            &launch_cap,
            &mut venue,
            copy public_key,
            ctx(&mut scenario),
        );

        let auth_request = auth_request::new(
            object::id(&venue),
            venue::get_auth_policy(&venue),
            ctx(&mut scenario),
        );

        launchpad_auth::verify(
            &venue,
            &signature,
            &msg,
            &mut auth_request,
            ctx(&mut scenario),
        );

        auth_request::consume_test(auth_request);

        transfer::public_share_object(listing);
        transfer::public_share_object(venue);
        transfer::public_transfer(launch_cap, MARKETPLACE);

        test_scenario::end(scenario);
    }

    #[test]
    public fun split_msg_with_bcs() {
        // Prepare the verification tx


        // 1. Try Peel with counter

        // let counter = 5;
        // let counter_bcs = bcs::to_bytes(&counter);

        // debug::print(&counter);
        // debug::print(&counter_bcs);


        // let counter_bcs_ = bcs::new(counter_bcs);
        // let res = bcs::peel_u8(&mut counter_bcs_);

        // debug::print(&res);
        // debug::print(&counter_bcs_);

        // 2.

        let msg = b"0x00000000000000000000000000000000000000000000000000000000000a5c08";
        let msg_bcs = bcs::to_bytes(&msg);

        let msg_bcs_ = bcs::new(msg_bcs);
        let res = bcs::peel_u8(&mut msg_bcs_);

        debug::print(&res);
        debug::print(&msg_bcs_);


    }
}
