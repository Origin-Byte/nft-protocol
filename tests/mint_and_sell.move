#[test_only]
module nft_protocol::mint_and_sell {
    use std::string;
    use std::vector;

    use sui::url;
    use sui::sui::SUI;
    use sui::tx_context;
    use sui::transfer::transfer;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::nft;
    use nft_protocol::tags;
    use nft_protocol::royalty;
    use nft_protocol::display;
    use nft_protocol::flat_fee;
    use nft_protocol::fixed_price;
    use nft_protocol::collection;
    use nft_protocol::attribution;
    use nft_protocol::slot::{Self, Slot};
    use nft_protocol::launchpad::{Self, Launchpad};
    use nft_protocol::inventory::{Self, Inventory};

    struct Witness has drop {}

    struct Foo has drop {}

    struct DomainA has store {}

    const OWNER: address = @0xA1C05;
    const CREATOR: address = @0xA1C05;
    const MARKETPLACE: address = @0xA1C20;

    #[test]
    public fun it_works() {
        // 1. Create collection and add domains
        let scenario = test_scenario::begin(CREATOR);

        let (mint_cap, collection) = collection::create<Foo>(
            &Foo {},
            ctx(&mut scenario),
        );

        collection::add_domain(
            &mut collection,
            &mut mint_cap,
            attribution::from_address(tx_context::sender(ctx(&mut scenario)))
        );

        // Register custom domains
        display::add_collection_display_domain(
            &mut collection,
            &mut mint_cap,
            string::utf8(b"Suimarines"),
            string::utf8(b"A unique NFT collection of Suimarines on Sui"),
        );

        display::add_collection_url_domain(
            &mut collection,
            &mut mint_cap,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        display::add_collection_symbol_domain(
            &mut collection,
            &mut mint_cap,
            string::utf8(b"SUIM")
        );

        let royalty = royalty::new(ctx(&mut scenario));
        royalty::add_proportional_royalty(
            &mut royalty,
            nft_protocol::royalty_strategy_bps::new(100),
        );
        royalty::add_royalty_domain(&mut collection, &mut mint_cap, royalty);

        let tags = tags::empty(ctx(&mut scenario));
        tags::add_tag(&mut tags, tags::art());
        tags::add_collection_tag_domain(&mut collection, &mut mint_cap, tags);

        collection::share<Foo>(collection);
        transfer(mint_cap, CREATOR);

        // 2. Create launchpad and add Slot
        test_scenario::next_tx(&mut scenario, MARKETPLACE);

        launchpad::init_launchpad(
            MARKETPLACE,
            MARKETPLACE,
            true,
            flat_fee::new(0, ctx(&mut scenario)),
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let launchpad = test_scenario::take_shared<Launchpad>(&scenario);

        slot::init_slot(
            &launchpad,
            CREATOR,
            CREATOR,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let slot = test_scenario::take_shared<Slot>(&scenario);

        // 3. Create inventory and mint NFT to it
        test_scenario::next_tx(&mut scenario, CREATOR);
        inventory::create_for_sender(false, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);
        let inventory = test_scenario::take_from_address<Inventory>(
            &scenario, CREATOR
        );

        let nft = nft::new<Foo>(
            tx_context::sender(ctx(&mut scenario)), ctx(&mut scenario)
        );

        display::add_display_domain(
            &mut nft,
            string::utf8(b"Foo"),
            string::utf8(b"A wild Foo appears"),
            ctx(&mut scenario),
        );

        display::add_url_domain(
            &mut nft,
            url::new_unsafe_from_bytes(b"https://originbyte.io/"),
            ctx(&mut scenario),
        );

        let attribute_keys = vector::empty();
        let attribute_values = vector::empty();

        display::add_attributes_domain_from_vec(
            &mut nft,
            attribute_keys,
            attribute_values,
            ctx(&mut scenario),
        );

        inventory::add_nft(&mut inventory, nft);

        // 4. Init Market in Launchpad Slot
        fixed_price::init_market_with_inventory<SUI>(
            &mut slot,
            inventory,
            100,
            ctx(&mut scenario),
        );

        // Return objects and end test
        test_scenario::return_shared(launchpad);
        test_scenario::return_shared(slot);

        test_scenario::end(scenario);
    }
}
