/// Implements a simple NFT collection contract
module examples::example_simple {
    use std::string::{Self, String};
    use std::option;

    use sui::display;
    use sui::url::{Self, Url};
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::collection;
    use nft_protocol::witness;
    use nft_protocol::display_info;
    use nft_protocol::mint_cap::MintCap;

    /// One time witness is only instantiated in the init method
    struct EXAMPLE_SIMPLE has drop {}

    struct SimpleNft has key, store {
        id: UID,
        name: String,
        description: String,
        url: Url,
    }

    /// Used for authorization of other protected actions.
    ///
    /// `Witness` must not be freely exposed to any contract.
    struct Witness has drop {}

    // === Contract functions ===

    /// Called during contract publishing
    fun init(otw: EXAMPLE_SIMPLE, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);

        // Init Collection & MintCap with unlimited supply
        let (collection, mint_cap) = collection::create_with_mint_cap<EXAMPLE_SIMPLE, SimpleNft>(
            &otw, option::none(), ctx
        );

        // Init Publisher
        let publisher = sui::package::claim(otw, ctx);

        // Init Display
        let display = display::new<SimpleNft>(&publisher, ctx);
        display::add(&mut display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::add(&mut display, string::utf8(b"description"), string::utf8(b"{description}"));
        display::add(&mut display, string::utf8(b"image_url"), string::utf8(b"https://{url}"));
        display::update_version(&mut display);
        transfer::public_transfer(display, tx_context::sender(ctx));

        // Get the Delegated Witness
        let dw = witness::from_witness(Witness {});

        collection::add_domain(
            dw,
            &mut collection,
            display_info::new(
                string::utf8(b"Simple"),
                string::utf8(b"Simple collection on Sui"),
            )
        );

        transfer::public_transfer(mint_cap, sender);
        transfer::public_transfer(publisher, sender);
        transfer::public_share_object(collection);
    }

    /// Mint `Nft`
    public entry fun mint_nft(
        name: String,
        description: String,
        url: vector<u8>,
        _mint_cap: &MintCap<SimpleNft>,
        ctx: &mut TxContext,
    ) {
        let nft = SimpleNft {
            id: object::new(ctx),
            name,
            description,
            url: url::new_unsafe_from_bytes(url),
        };

        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

    // === Integration test ===

    #[test_only]
    use sui::test_scenario::{Self, ctx};
    #[test_only]
    use nft_protocol::collection::Collection;

    #[test_only]
    const USER: address = @0xA1C04;

    #[test]
    fun it_inits_collection() {
        let scenario = test_scenario::begin(USER);

        init(EXAMPLE_SIMPLE {}, ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);

        assert!(test_scenario::has_most_recent_shared<Collection<SimpleNft>>(), 0);

        let mint_cap = test_scenario::take_from_address<MintCap<SimpleNft>>(
            &scenario, USER,
        );

        mint_nft(
            string::utf8(b"Simple NFT"),
            string::utf8(b"A simple NFT on Sui"),
            b"originbyte.io",
            &mint_cap,
            ctx(&mut scenario)
        );

        test_scenario::return_to_address(USER, mint_cap);
        test_scenario::next_tx(&mut scenario, USER);

        assert!(test_scenario::has_most_recent_for_address<SimpleNft>(USER), 0);

        test_scenario::end(scenario);
    }
}
