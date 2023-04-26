#[test_only]
module launchpad_v2::test_auth {
    // use std::option::some;
    // use std::type_name;
    // use std::vector;
    // use std::string;
    use std::debug;

    use sui::test_scenario::{Self, ctx};
    use sui::object;
    use sui::ed25519;
    use sui::transfer;

    use launchpad_v2::venue::{Self};
    use launchpad_v2::launchpad_auth;
    use launchpad_v2::test_utils;
    use launchpad_v2::auth_request;

    use nft_protocol::test_utils::marketplace;

    const SENDER: address = @0xA5C08;

    #[test]
    public fun create_authenticated_launchpad() {
        let scenario = test_scenario::begin(marketplace());

        // 1. Create a Launchpad Listing and Venue
        let (listing, launch_cap, venue) = test_utils::create_fixed_bid_launchpad(&mut scenario);

        // Prepare the verification tx
        let msg = b"Hello";
        let public_key = vector[144, 157, 10, 117, 111, 110, 175, 74, 57, 90, 241, 231, 48, 166, 88, 218, 140, 243, 96, 5, 34, 76, 129, 142, 88, 49, 99, 24, 118, 68, 76, 86];
        let signature = vector[210, 72, 78, 110, 137, 148, 77, 128, 57, 122, 43, 45, 110, 249, 166, 110, 107, 88, 176, 76, 197, 194, 188, 30, 33, 186, 41, 41, 160, 167, 118, 151, 121, 221, 100, 90, 221, 153, 171, 91, 221, 35, 17, 52, 201, 205, 120, 238, 105, 134, 242, 111, 145, 140, 5, 195, 85, 104, 53, 14, 181, 141, 72, 7];

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
        transfer::public_transfer(launch_cap, marketplace());

        test_scenario::end(scenario);
    }

    #[test]
    public fun create_ed25519() {
        let scenario = test_scenario::begin(marketplace());

        // let private_key = vector[97, 17, 58, 230, 96, 70, 48, 20, 251, 160, 38, 129, 37, 210, 116, 14, 22, 177, 25, 235, 219, 66, 97, 1, 162, 210, 169, 178, 83, 23, 129, 1];
        // let public_key = vector[133, 163, 78, 225, 53, 40, 208, 254, 179, 253, 85, 234, 92, 59, 52, 50, 196, 80, 211, 38, 86, 237, 167, 65, 155, 235, 226, 226, 22, 57, 220, 145, 121, 33, 107, 33, 149, 251, 157, 2, 253, 16, 90, 218, 119, 35, 80, 254, 132, 171, 1, 49, 150, 147, 36, 120, 136, 55, 136, 235, 127, 111, 97, 163];

        // Prepare the verification tx
        let msg = b"Hello";
        let public_key = vector[144, 157, 10, 117, 111, 110, 175, 74, 57, 90, 241, 231, 48, 166, 88, 218, 140, 243, 96, 5, 34, 76, 129, 142, 88, 49, 99, 24, 118, 68, 76, 86];
        let signature = vector[210, 72, 78, 110, 137, 148, 77, 128, 57, 122, 43, 45, 110, 249, 166, 110, 107, 88, 176, 76, 197, 194, 188, 30, 33, 186, 41, 41, 160, 167, 118, 151, 121, 221, 100, 90, 221, 153, 171, 91, 221, 35, 17, 52, 201, 205, 120, 238, 105, 134, 242, 111, 145, 140, 5, 195, 85, 104, 53, 14, 181, 141, 72, 7];

        let verf = ed25519::ed25519_verify(&signature, &public_key, &msg);

        debug::print(&verf);

        debug::print(&public_key);


        test_scenario::end(scenario);
    }


}
