#[test_only]
module launchpad_v2::test_auth {
    // use std::option::some;
    // use std::type_name;
    // use std::vector;
    // use std::string;
    // use std::debug;
    // debug::print(&string::utf8(b"a"));

    use sui::test_scenario::{Self, ctx};
    use sui::object;
    use sui::transfer;
    // use sui::ecdsa_k1;
    // use sui::test_random;

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

        // let private_key = vector[97, 17, 58, 230, 96, 70, 48, 20, 251, 160, 38, 129, 37, 210, 116, 14, 22, 177, 25, 235, 219, 66, 97, 1, 162, 210, 169, 178, 83, 23, 129, 1];
        let public_key = vector[4, 137, 194, 123, 149, 93, 112, 123, 52, 237, 189, 68, 235, 102, 144, 35, 71, 32, 177, 118, 166, 26, 229, 160, 26, 238, 116, 84, 34, 207, 169, 150, 49, 79, 14, 11, 135, 9, 140, 120, 187, 221, 21, 53, 81, 22, 206, 204, 64, 36, 230, 54, 134, 26, 40, 29, 104, 65, 239, 251, 132, 33, 106, 107, 172];

        // let seed = vector::singleton(1_u8);
        // let generator = test_random::new(seed);
        // let rand = test_random::next_bytes(&mut generator, 10);

        launchpad_auth::add_pubkey(
            &launch_cap,
            &mut venue,
            copy public_key,
            ctx(&mut scenario),
        );

        // Prepare the verification tx
        let msg = b"10xA5C08";

        let signature = vector[211, 25, 221, 200, 201, 64, 250, 32, 4, 15, 107, 53, 208, 93, 179, 91, 8, 2, 138, 8, 41, 28, 100, 150, 95, 1, 131, 199, 70, 142, 142, 153, 9, 36, 4, 12, 215, 120, 136, 165, 161, 62, 59, 129, 49, 129, 135, 215, 110, 156, 79, 253, 97, 133, 195, 173, 122, 141, 121, 188, 125, 106, 39, 154];

        let auth_request = auth_request::new(
            object::id(&venue),
            venue::get_auth_policy(&venue),
            ctx(&mut scenario),
        );

        launchpad_auth::verify(
            &venue,
            &signature,
            &msg,
            1, // SHA256
            &mut auth_request,
            ctx(&mut scenario),
        );

        auth_request::consume_test(auth_request);

        transfer::public_share_object(listing);
        transfer::public_share_object(venue);
        transfer::public_transfer(launch_cap, marketplace());

        test_scenario::end(scenario);
    }
}
