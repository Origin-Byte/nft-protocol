module nft_protocol::suitraders {
    use std::ascii;
    use std::option;
    use std::string::{Self, String};

    use sui::transfer;
    use sui::vec_set;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::attributes;
    use nft_protocol::collection_id;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::creators;
    use nft_protocol::display_info;
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::royalty_strategy_bps;
    use nft_protocol::tags;
    use nft_protocol::warehouse::{Self, Warehouse};
    use nft_protocol::witness;

    /// One time witness is only instantiated in the init method
    struct SUITRADERS has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(_witness: SUITRADERS, ctx: &mut TxContext) {
        let delegated_witness = witness::from_witness(Witness {});
        let sender = tx_context::sender(ctx);

        let collection: Collection<SUITRADERS> =
            collection::create(delegated_witness, ctx);

        let mint_cap =
            mint_cap::new<SUITRADERS>(delegated_witness, &collection, option::none(), ctx);

        collection::add_domain(
            delegated_witness,
            &mut collection,
            creators::new(vec_set::singleton(sender)),
        );

        // Register custom domains
        collection::add_domain(
            delegated_witness,
            &mut collection,
            display_info::new(
                string::utf8(b"Suimarines"),
                string::utf8(b"A unique NFT collection of Suimarines on Sui"),
            ),
        );

        royalty_strategy_bps::create_domain_and_add_strategy(
            delegated_witness, &mut collection, 100, ctx,
        );

        let tags = tags::empty(ctx);
        tags::add_tag(&mut tags, tags::art());
        collection::add_domain(delegated_witness, &mut collection, tags);

        let listing = nft_protocol::listing::new(
            tx_context::sender(ctx),
            tx_context::sender(ctx),
            ctx,
        );

        let inventory_id = nft_protocol::listing::create_warehouse<Nft<SUITRADERS>>(
            &mut listing, ctx
        );

        nft_protocol::fixed_price::init_venue<Nft<SUITRADERS>, sui::sui::SUI>(
            &mut listing,
            inventory_id,
            false, // is whitelisted
            500, // price
            ctx,
        );

        nft_protocol::dutch_auction::init_venue<Nft<SUITRADERS>, sui::sui::SUI>(
            &mut listing,
            inventory_id,
            false, // is whitelisted
            100, // reserve price
            ctx,
        );

        transfer::public_transfer(mint_cap, tx_context::sender(ctx));
        transfer::public_share_object(listing);
        transfer::public_share_object(collection);
    }

    public entry fun mint_nft(
        name: String,
        description: String,
        url: vector<u8>,
        attribute_keys: vector<ascii::String>,
        attribute_values: vector<ascii::String>,
        mint_cap: &mut MintCap<SUITRADERS>,
        warehouse: &mut Warehouse<Nft<SUITRADERS>>,
        ctx: &mut TxContext,
    ) {
        let delegated_witness = witness::from_witness(Witness {});
        let url = sui::url::new_unsafe_from_bytes(url);

        let nft = nft::from_mint_cap(mint_cap, name, url, ctx);

        nft::add_domain(
            delegated_witness, &mut nft, display_info::new(name, description),
        );

        nft::add_domain(delegated_witness, &mut nft, url);

        nft::add_domain(
            delegated_witness,
            &mut nft,
            attributes::from_vec(attribute_keys, attribute_values),
        );

        nft::add_domain(
            delegated_witness, &mut nft, collection_id::from_mint_cap(mint_cap),
        );

        warehouse::deposit_nft(warehouse, nft);
    }

    #[test_only]
    use sui::test_scenario::{Self, ctx};

    #[test_only]
    const USER: address = @0xA1C04;

    #[test]
    fun test_examples_suitraders() {
        let scenario = test_scenario::begin(USER);

        init(SUITRADERS {}, ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);

        assert!(test_scenario::has_most_recent_shared<Collection<SUITRADERS>>(), 0);

        let mint_cap = test_scenario::take_from_address<MintCap<SUITRADERS>>(
            &scenario, USER,
        );

        // TODO: Add mint function test

        test_scenario::return_to_address(USER, mint_cap);
        test_scenario::next_tx(&mut scenario, USER);

        test_scenario::end(scenario);
    }
}
