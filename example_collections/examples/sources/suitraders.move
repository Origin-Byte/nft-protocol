module examples::suitraders {
    use std::ascii;
    use std::option;
    use std::string::{Self, String};

    use sui::url::{Self, Url};
    use sui::display;
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::vec_set;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::mint_cap;
    use nft_protocol::mint_event;
    use nft_protocol::creators;
    use nft_protocol::attributes::{Self, Attributes};
    use nft_protocol::collection;
    use nft_protocol::display_info;
    use ob_utils::display as ob_display;
    use nft_protocol::mint_cap::MintCap;
    use nft_protocol::royalty_strategy_bps;
    use nft_protocol::tags;
    use ob_permissions::witness;

    use ob_launchpad::listing;
    use ob_launchpad::fixed_price;
    use ob_launchpad::dutch_auction;
    use ob_launchpad::warehouse::{Self, Warehouse};

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

    fun init(otw: SUITRADERS, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);

        // Init Collection & MintCap with unlimited supply
        let (collection, mint_cap) = collection::create_with_mint_cap<SUITRADERS, Suitrader>(
            &otw, option::none(), ctx
        );

        // Init Publisher
        let publisher = sui::package::claim(otw, ctx);

        // Init Display
        let tags = vector[tags::art(), tags::game_asset()];

        let display = display::new<Suitrader>(&publisher, ctx);
        display::add(&mut display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::add(&mut display, string::utf8(b"description"), string::utf8(b"{description}"));
        display::add(&mut display, string::utf8(b"image_url"), string::utf8(b"https://{url}"));
        display::add(&mut display, string::utf8(b"attributes"), string::utf8(b"{attributes}"));
        display::add(&mut display, string::utf8(b"tags"), ob_display::from_vec(tags));
        display::update_version(&mut display);
        transfer::public_transfer(display, tx_context::sender(ctx));

        // Get the Delegated Witness
        let dw = witness::from_witness(Witness {});

        // Add name and description to Collection
        collection::add_domain(
            dw,
            &mut collection,
            display_info::new(
                string::utf8(b"Suimarines"),
                string::utf8(b"A unique NFT collection of Suimarines on Sui"),
            ),
        );

        // Creators domain
        collection::add_domain(
            dw,
            &mut collection,
            creators::new(vec_set::singleton(sender)),
        );

        // Royalties
        royalty_strategy_bps::create_domain_and_add_strategy(
            dw, &mut collection, 100, ctx,
        );

        // Setup primary market. Note that this step can also be done
        // not in the init function but on the client side by calling
        // the launchpad functions directly
        let listing = listing::new(
            tx_context::sender(ctx),
            tx_context::sender(ctx),
            ctx,
        );

        let inventory_id = listing::create_warehouse<Suitrader>(
            &mut listing, ctx
        );

        fixed_price::init_venue<Suitrader, sui::sui::SUI>(
            &mut listing,
            inventory_id,
            false, // is whitelisted
            500, // price
            ctx,
        );

        dutch_auction::init_venue<Suitrader, sui::sui::SUI>(
            &mut listing,
            inventory_id,
            false, // is whitelisted
            100, // reserve price
            ctx,
        );

        transfer::public_transfer(publisher, sender);
        transfer::public_transfer(mint_cap, sender);
        transfer::public_share_object(listing);
        transfer::public_share_object(collection);
    }

    public entry fun mint_nft(
        name: String,
        description: String,
        url: vector<u8>,
        attribute_keys: vector<ascii::String>,
        attribute_values: vector<ascii::String>,
        mint_cap: &MintCap<Suitrader>,
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


        mint_event::emit_mint(
            witness::from_witness(Witness {}),
            mint_cap::collection_id(mint_cap),
            &nft,
        );

        warehouse::deposit_nft(warehouse, nft);
    }

    #[test_only]
    use sui::test_scenario::{Self, ctx};
    #[test_only]
    use nft_protocol::collection::Collection;

    #[test_only]
    const CREATOR: address = @0xA1C04;

    #[test]
    fun it_inits_collection() {
        let scenario = test_scenario::begin(CREATOR);

        init(SUITRADERS {}, ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, CREATOR);

        assert!(test_scenario::has_most_recent_shared<Collection<Suitrader>>(), 0);

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

        let mint_cap = test_scenario::take_from_address<MintCap<Suitrader>>(
            &scenario,
            CREATOR,
        );

        let warehouse = warehouse::new<Suitrader>(ctx(&mut scenario));

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
