#[test_only]
module ob_launchpad_v2::test_utils {
    use std::option::some;
    use std::type_name;

    use sui::test_scenario::{Scenario, ctx};
    use sui::sui::SUI;

    use ob_launchpad_v2::launchpad::{Self, Listing, LaunchCap};
    use ob_launchpad_v2::venue::{Self, Venue};
    use ob_launchpad_v2::fixed_bid::{Self, Witness as FixedBidWit};
    use ob_launchpad_v2::warehouse::{Witness as WarehouseWit};
    use ob_launchpad_v2::pseudorand_redeem::{Witness as PseudoRandomWit};
    use ob_launchpad_v2::schedule;

    use nft_protocol::utils_supply::Self as supply;

    #[test_only]
    public fun create_fixed_bid_launchpad(scenario: &mut Scenario): (Listing, LaunchCap, Venue) {
        // 1. Create a Launchpad Listing
        let (listing, launch_cap) = launchpad::new(ctx(scenario));

        // 2. Create Sales Venue
        let venue = venue::new(
            &mut listing,
            &launch_cap,
            some(supply::new(1_000)),
            // Market type
            type_name::get<FixedBidWit>(),
            // Inventory Type
            type_name::get<WarehouseWit>(),
            // Inventory Retrieval Method
            type_name::get<PseudoRandomWit>(),
            // NFT Retrieval Method
            type_name::get<PseudoRandomWit>(),
            ctx(scenario),
        );

        // 3. Add market module
        fixed_bid::init_market<SUI>(&launch_cap, &mut venue, 100, 10, ctx(scenario));

        // 4. Add launchpad schedule
        schedule::add_schedule(
            &launch_cap,
            &mut venue,
            // Start Time: Monday, 20 April 2020 00:00:00
            some(1587340800),
            // Stop Time: Saturday, 25 April 2020 00:00:00
            some(1587772800),
        );

        (listing, launch_cap, venue)
    }
}
