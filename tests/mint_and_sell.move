#[test_only]
module nft_protocol::mint_and_sell {
    use std::string;
    use std::vector;

    use sui::url;
    use sui::sui::SUI;
    use sui::tx_context;
    use sui::transfer;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::nft;
    use nft_protocol::tags;
    use nft_protocol::royalty;
    use nft_protocol::display;
    use nft_protocol::flat_fee;
    use nft_protocol::fixed_price;
    use nft_protocol::collection;
    use nft_protocol::creators;
    use nft_protocol::listing::{Self, Listing};
    use nft_protocol::marketplace::{Self, Marketplace};
    use nft_protocol::warehouse;

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

        let (mint_cap, collection) = collection::create(
            &Foo {}, ctx(&mut scenario),
        );

        collection::add_domain(
            &mut collection,
            &mut mint_cap,
            creators::from_address(tx_context::sender(ctx(&mut scenario)))
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

        let royalty = royalty::from_address(CREATOR, ctx(&mut scenario));
        royalty::add_proportional_royalty(&mut royalty, 100);
        royalty::add_royalty_domain(&mut collection, &mut mint_cap, royalty);

        let tags = tags::empty(ctx(&mut scenario));
        tags::add_tag(&mut tags, tags::art());
        tags::add_collection_tag_domain(&mut collection, &mut mint_cap, tags);

        transfer::share_object(collection);
        transfer::transfer(mint_cap, CREATOR);

        // 2. Create marketplace and add Listing
        test_scenario::next_tx(&mut scenario, MARKETPLACE);

        marketplace::init_marketplace(
            MARKETPLACE,
            MARKETPLACE,
            flat_fee::new(0, ctx(&mut scenario)),
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let marketplace = test_scenario::take_shared<Marketplace>(&scenario);

        listing::init_listing(
            CREATOR,
            CREATOR,
            ctx(&mut scenario),
        );

        // TODO: Add link marketplace to listing

        test_scenario::next_tx(&mut scenario, MARKETPLACE);
        let listing = test_scenario::take_shared<Listing>(&scenario);

        // 3. Create warehouse and mint NFT to it
        test_scenario::next_tx(&mut scenario, CREATOR);
        let warehouse = warehouse::new(ctx(&mut scenario));

        let nft = nft::new<Foo, Witness>(
            &Witness {},
            tx_context::sender(ctx(&mut scenario)),
            ctx(&mut scenario),
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

        warehouse::deposit_nft(&mut warehouse, nft);

        // 4. Init Market in Marketplace Listing
        fixed_price::create_market_on_warehouse<SUI>(
            &mut warehouse,
            false,
            100,
            ctx(&mut scenario),
        );

        listing::add_warehouse(&mut listing, warehouse, ctx(&mut scenario));

        // Return objects and end test
        test_scenario::return_shared(marketplace);
        test_scenario::return_shared(listing);

        test_scenario::end(scenario);
    }
}
