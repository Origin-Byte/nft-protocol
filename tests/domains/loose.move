#[test_only]
module nft_protocol::test_loose {
    use std::string::{Self, String};
    use std::option::{Self, Option};

    use sui::url::Url;
    use sui::sui::SUI;
    use sui::coin;
    use sui::object::{Self, ID};
    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::witness;
    use nft_protocol::listing;
    use nft_protocol::collection;
    use nft_protocol::fixed_price;
    use nft_protocol::display;
    use nft_protocol::metadata;
    use nft_protocol::supply_domain;
    use nft_protocol::mint_cap::MintCap;
    use nft_protocol::metadata_bag::{Self, MetadataBagDomain};

    struct Foo has drop {}
    struct Witness has drop {}

    const CREATOR: address = @0xA1C04;
    const BUYER: address = @0xA1C05;

    #[test]
    fun add_templates_to_collection() {
        let scenario = test_scenario::begin(CREATOR);

        let (mint_cap, collection) =
            collection::create(&Foo {}, ctx(&mut scenario));

        let templates =
            metadata_bag::new_metadata_bag<Foo>(ctx(&mut scenario));

        // Add template with limited supply
        mint_nft_template(
            string::utf8(b"Wizard"),
            string::utf8(b"An in-game wizard"),
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io"),
            &mint_cap,
            option::some(100), // supply
            &mut templates,
            ctx(&mut scenario),
        );

        // Add template with unlimited supply
        mint_nft_template(
            string::utf8(b"Peasant"),
            string::utf8(b"An in-game peasant"),
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io"),
            &mint_cap,
            option::none(), // supply
            &mut templates,
            ctx(&mut scenario),
        );

        collection::add_domain(
            &Witness {},
            &mut collection,
            templates,
        );

        transfer::share_object(collection);
        transfer::transfer(mint_cap, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun add_templates_to_collection_and_mint_nft() {
        let scenario = test_scenario::begin(CREATOR);

        let (mint_cap, collection) =
            collection::create(&Foo {}, ctx(&mut scenario));

        let templates =
            metadata_bag::new_metadata_bag<Foo>(ctx(&mut scenario));

        // Add template with limited supply
        let temp_id_1 = mint_nft_template(
            string::utf8(b"Wizard"),
            string::utf8(b"An in-game wizard"),
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io"),
            &mint_cap,
            option::some(100), // supply
            &mut templates,
            ctx(&mut scenario),
        );

        let delegated_witness = witness::from_witness<Foo, Witness>(&Witness {});

        collection::add_domain(
            &Witness {},
            &mut collection,
            templates,
        );

        supply_domain::regulate(
            &Witness {},
            &mut collection,
            1,
            false, // frozen
        );

        test_scenario::next_tx(&mut scenario, CREATOR);

        let listing = listing::new(
            CREATOR, CREATOR, ctx(&mut scenario)
        );

        let supply = option::some(100);

        // TODO: What happens if supply is above what has been defined in the template?
        let inventory_id = listing::create_factory(
            delegated_witness,
            &mint_cap,
            &mut collection,
            temp_id_1,
            supply,
            &mut listing,
            ctx(&mut scenario),
        );

        let venue_id = fixed_price::create_venue<Foo, SUI>(
            &mut listing,
            inventory_id,
            false, // whitelisting
            100, // price
            ctx(&mut scenario),
        );

        // 5. Buy the NFT
        test_scenario::next_tx(&mut scenario, BUYER);

        let wallet = coin::mint_for_testing<SUI>(100, ctx(&mut scenario));
        fixed_price::buy_nft<Foo, SUI>(
            &mut listing,
            venue_id,
            &mut wallet,
            ctx(&mut scenario),
        );

        // 6. Verify NFT was bought
        test_scenario::next_tx(&mut scenario, BUYER);

        let bought_nft = test_scenario::take_from_address<Nft<Foo>>(
            &scenario, CREATOR
        );

        // assert!(nft_id == object::id(&bought_nft), 0);

        transfer::share_object(listing);
        transfer::transfer(wallet, BUYER);
        transfer::share_object(collection);
        transfer::transfer(mint_cap, CREATOR);

        test_scenario::return_to_address(BUYER, bought_nft);
        test_scenario::end(scenario);
    }

    public fun mint_nft_template<C>(
        name: String,
        description: String,
        url: Url,
        mint_cap: &MintCap<C>,
        supply: Option<u64>,
        metadata_bag: &mut MetadataBagDomain<C>,
        ctx: &mut TxContext,
    ): ID {
        let nft = nft::from_mint_cap(mint_cap, name, url, ctx);

        display::add_display_domain(&Witness {}, &mut nft, name, description);

        let metadata = if (option::is_none(&supply)) {
            metadata::new_unregulated(nft, ctx)
        } else {
            metadata::new_regulated(nft, *option::borrow(&supply), ctx)
        };

        let metadata_id = object::id(&metadata);

        metadata_bag::add_metadata(mint_cap, metadata_bag, metadata);

        metadata_id
    }
}
