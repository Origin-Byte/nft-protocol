#[test_only]
module ob_tests::test_utils {
    use std::option::{none, some};
    use std::type_name;
    use std::vector;

    use sui::sui::SUI;
    use sui::tx_context::TxContext;
    use sui::object::{Self, UID, ID};
    use sui::package::{Self, Publisher};
    use sui::transfer_policy::{TransferPolicy, TransferPolicyCap};
    use sui::test_scenario::{Scenario, ctx};

    use ob_witness::witness::Witness as DelegatedWitness;
    use liquidity_layer::bidding;
    use liquidity_layer::orderbook;
    use nft_protocol::mint_cap::MintCap;
    use nft_protocol::collection::{Self, Collection};
    use ob_request::request::{Policy, PolicyCap, WithNft};
    use ob_request::withdraw_request::{Self, WITHDRAW_REQ};
    use ob_request::transfer_request;

    use ob_allowlist::allowlist::{Self, Allowlist, AllowlistOwnerCap};

    use ob_launchpad_v2::launchpad::{Self, Listing, LaunchCap};
    use ob_launchpad_v2::venue::{Self, Venue};
    use ob_launchpad_v2::fixed_bid::{Self, Witness as FixedBidWit};
    use ob_launchpad_v2::pseudorand_redeem::{Witness as PseudoRandomWit};
    use ob_launchpad_v2::schedule;
    use ob_launchpad_v2::warehouse::{Self, Warehouse, Witness as WarehouseWit};

    const MARKETPLACE: address = @0xA1C08;
    const CREATOR: address = @0xA1C04;
    const BUYER: address = @0xA1C10;
    const SELLER: address = @0xA1C15;
    const FAKE_ADDRESS: address = @0xA1C45;

    struct Foo has key, store {
        id: UID,
        index: u64,
    }

    // Mock OTW
    struct TEST_UTILS has drop {}

    struct Witness has drop {}

    public fun witness(): Witness { Witness {} }

    public fun marketplace(): address { MARKETPLACE }
    public fun creator(): address { CREATOR }
    public fun buyer(): address { BUYER }
    public fun seller(): address { SELLER }
    public fun fake_address(): address { FAKE_ADDRESS }

    #[test_only]
    public fun index(foo: &Foo): u64 {
        foo.index
    }

    #[test_only]
    public fun init_collection_foo(
        ctx: &mut TxContext
    ): (Collection<Foo>, MintCap<Foo>) {
        collection::create_with_mint_cap<TEST_UTILS, Foo>(
            &TEST_UTILS {}, none(), ctx
        )
    }

    #[test_only]
    public fun get_foo_nft(ctx: &mut TxContext): Foo {
        Foo { id: object::new(ctx), index: 0}
    }

    #[test_only]
    public fun get_foo_nft_with_index(index: u64, ctx: &mut TxContext): Foo {
        Foo { id: object::new(ctx), index }
    }

    public fun mint_foo_nft_to_warehouse(
        warehouse: &mut Warehouse<Foo>, supply: u64, ctx: &mut TxContext
    ) {
        let i = 1;
        while (supply > 0) {
            warehouse::deposit_nft(warehouse, get_foo_nft_with_index(i, ctx));

            supply = supply - 1;
            i = i + 1;
        };
    }

    public fun batch_mint_foo_nft_to_warehouse(
        warehouse: &mut Warehouse<Foo>, supply: u64, ctx: &mut TxContext
    ) {
        let nfts = vector::empty();
        let i = 1;

        while (supply > 0) {
            vector::push_back(&mut nfts, get_foo_nft_with_index(i, ctx));

            supply = supply - 1;
            i = i + 1;
        };

        warehouse::deposit_nfts(warehouse, nfts);
    }

    public fun create_dummy_venue(listing: &mut Listing, launch_cap: &LaunchCap, ctx: &mut TxContext): Venue {
        venue::new(
            listing,
            launch_cap,
            // Market type
            type_name::get<FixedBidWit>(),
            // Inventory Type
            type_name::get<WarehouseWit>(),
            // Inventory Retrieval Method
            type_name::get<PseudoRandomWit>(),
            // NFT Retrieval Method
            type_name::get<PseudoRandomWit>(),
            ctx,
        )
    }

    #[test_only]
    public fun get_publisher(ctx: &mut TxContext): Publisher {
        package::test_claim<TEST_UTILS>(TEST_UTILS {}, ctx)
    }

    #[test_only]
    public fun init_transfer_policy(publisher: &Publisher, ctx: &mut TxContext): (TransferPolicy<Foo>, TransferPolicyCap<Foo>) {
        transfer_request::init_policy<Foo>(publisher, ctx)
    }

    #[test_only]
    public fun init_withdrawable_policy(publisher: &Publisher, ctx: &mut TxContext): (Policy<WithNft<Foo, WITHDRAW_REQ>>, PolicyCap) {
        withdraw_request::init_policy<Foo>(publisher, ctx)
    }

    #[test_only]
    public fun create_orderbook<T: key + store>(
        witness: DelegatedWitness<T>,
        transfer_policy: &TransferPolicy<T>,
        scenario: &mut Scenario
    ): ID {
        let ob = orderbook::new_unprotected<T, SUI>(witness, transfer_policy, ctx(scenario));
        let ob_id = object::id(&ob);

        orderbook::share(ob);

        ob_id
    }

    #[test_only]
    public fun create_external_orderbook<T: key + store>(
        transfer_policy: &TransferPolicy<T>,
        scenario: &mut Scenario
    ) {
        orderbook::create_for_external<T, SUI>(transfer_policy, ctx(scenario));
    }

    #[test_only]
    public fun create_fixed_bid_launchpad(scenario: &mut Scenario): (Listing, LaunchCap, Venue) {
        // 1. Create a Launchpad Listing
        let (listing, launch_cap) = launchpad::new(ctx(scenario));

        // 2. Create Sales Venue
        let venue = venue::new(
            &mut listing,
            &launch_cap,
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

    #[test_only]
    public fun create_allowlist(scenario: &mut Scenario): (Allowlist, AllowlistOwnerCap) {
        let (al, al_cap) = allowlist::new(ctx(scenario));

        // orderbooks can perform trades with our allowlist
        allowlist::insert_authority<orderbook::Witness>(&al_cap, &mut al);
        // bidding contract can perform trades too
        allowlist::insert_authority<bidding::Witness>(&al_cap, &mut al);

        (al, al_cap)
    }
}
