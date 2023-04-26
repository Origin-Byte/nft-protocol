#[test_only]
module launchpad_v2::test_auth {
    use std::option::some;
    use std::type_name;
    use std::vector;
    // use std::string;
    // use std::debug;
    // debug::print(&string::utf8(b"a"));

    use sui::test_scenario::{Self, ctx};
    use sui::sui::SUI;
    use sui::transfer;
    use sui::ecdsa_k1;
    use sui::test_random;

    use launchpad_v2::launchpad::{Self};
    use launchpad_v2::venue::{Self};
    use launchpad_v2::fixed_bid::{Self, Witness as FixedBidWit};
    use launchpad_v2::dutch_auction::{Self, Witness as DutchAuctionWit};
    use launchpad_v2::warehouse::{Witness as WarehouseWit};
    use launchpad_v2::pseudorand_redeem::{Witness as PseudoRandomWit};
    use launchpad_v2::launchpad_auth;
    use launchpad_v2::test_utils;


    use nft_protocol::test_utils::marketplace;
    use nft_protocol::utils_supply::Self as supply;

    #[test]
    public fun create_authenticated_launchpad() {
        let scenario = test_scenario::begin(marketplace());

        // 1. Create a Launchpad Listing and Venue
        let (listing, launch_cap, venue) = test_utils::create_fixed_bid_launchpad(&mut scenario);

        // launch_cap: &LaunchCap,
        // venue: &mut Venue,
        // pubkey: vector<u8>,
        // ctx: &mut TxContext,

        let seed = vector::singleton(1_u8);
        let generator = test_random::new(seed);
        let rand = test_random::next_bytes(&mut generator, 10);

        launchpad_auth::add_pubkey(
            &launch_cap,
            &mut venue,

        );

        transfer::public_share_object(listing);
        transfer::public_share_object(venue);
        transfer::public_transfer(launch_cap, marketplace());

        test_scenario::end(scenario);
    }
}
