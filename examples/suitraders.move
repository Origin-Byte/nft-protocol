module nft_protocol::suitraders {
    use std::ascii;
    use std::option;
    use std::string::{Self, String};

    use sui::url::{Self, Url};
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::vec_set;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::mint_event;
    use nft_protocol::creators;
    use nft_protocol::attributes::{Self, Attributes};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::display_info;
    use nft_protocol::mint_cap::{Self, MintCap};
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

    struct Suitrader has key, store {
        id: UID,
        name: String,
        description: String,
        url: Url,
        attributes: Attributes,
    }

    fun init(witness: SUITRADERS, ctx: &mut TxContext) {
        let publisher = sui::package::claim(witness, ctx);

        let delegated_witness = witness::from_witness(Witness {});
        let sender = tx_context::sender(ctx);

        let collection: Collection<SUITRADERS> =
            collection::create(delegated_witness, ctx);

        // Creates an unregulated mint cap
        let mint_cap = mint_cap::new_from_publisher<Suitrader, SUITRADERS>(
            &publisher, &collection, option::none(), ctx,
        );

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

        let inventory_id = nft_protocol::listing::create_warehouse<Suitrader>(
            &mut listing, ctx
        );

        nft_protocol::fixed_price::init_venue<Suitrader, sui::sui::SUI>(
            &mut listing,
            inventory_id,
            false, // is whitelisted
            500, // price
            ctx,
        );

        nft_protocol::dutch_auction::init_venue<Suitrader, sui::sui::SUI>(
            &mut listing,
            inventory_id,
            false, // is whitelisted
            100, // reserve price
            ctx,
        );

        transfer::public_transfer(publisher, tx_context::sender(ctx));
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
        mint_cap: &mut MintCap<Suitrader>,
        warehouse: &mut Warehouse<Suitrader>,
        ctx: &mut TxContext,
    ) {
        let nft = Suitrader {
            id: object::new(ctx),
            name,
            description,
            url: url::new_unsafe_from_bytes(url),
            attributes: attributes::from_vec(attribute_keys, attribute_values)
        };

        mint_event::mint(mint_cap, &nft);
        warehouse::deposit_nft(warehouse, nft);
    }

    #[test_only]
    use sui::test_scenario::{Self, ctx};

    #[test_only]
    const CREATOR: address = @0xA1C04;

    #[test]
    fun it_inits_collection() {
        let scenario = test_scenario::begin(CREATOR);
        init(SUITRADERS {}, ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, CREATOR);

        assert!(test_scenario::has_most_recent_shared<Collection<SUITRADERS>>(), 0);

        let mint_cap = test_scenario::take_from_address<MintCap<Suitrader>>(
            &scenario, CREATOR,
        );

        test_scenario::return_to_address(CREATOR, mint_cap);
        test_scenario::next_tx(&mut scenario, CREATOR);

        test_scenario::end(scenario);
    }

    #[test]
    fun it_mints_nft() {
        let scenario = test_scenario::begin(CREATOR);
        init(SUITRADERS {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);

        let  mint_cap = test_scenario::take_from_address<MintCap<Nft<SUITRADERS>>>(
            &scenario,
            CREATOR,
        );

        let warehouse = warehouse::new<Nft<SUITRADERS>>(ctx(&mut scenario));

        mint_nft(
            string::utf8(b"SuiTudor Jones"),
            string::utf8(b"GOAT level trader"),
            b"https://originbyte.io/",
            vector[ascii::string(b"avg_return")],
            vector[ascii::string(b"24%")],
            &mut mint_cap,
            &mut warehouse,
            ctx(&mut scenario)
        );

        transfer::public_transfer(warehouse, CREATOR);
        test_scenario::return_to_address(CREATOR, mint_cap);
        test_scenario::end(scenario);
    }
}
