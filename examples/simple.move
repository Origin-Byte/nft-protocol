/// Implements a simple NFT collection contract
module nft_protocol::example_simple {
    use std::string::{Self, String};
    use std::option;

    use sui::url::{Self, Url};
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::collection;
    use nft_protocol::witness;
    use nft_protocol::mint_cap;
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
    fun init(witness: EXAMPLE_SIMPLE, ctx: &mut TxContext) {
        let publisher = sui::package::claim(witness, ctx);
        let delegated_witness = witness::from_witness(Witness {});

        let collection: Collection<EXAMPLE_SIMPLE> =
            collection::create(delegated_witness, ctx);

        // Creates an unregulated mint cap
        let mint_cap = mint_cap::new_from_publisher<SimpleNft, EXAMPLE_SIMPLE>(
            &publisher, &collection, option::none(), ctx,
        );

        collection::add_domain(
            delegated_witness,
            &mut collection,
            display_info::new(
                string::utf8(b"Simple"),
                string::utf8(b"Simple collection on Sui"),
            )
        );

        transfer::public_transfer(mint_cap, tx_context::sender(ctx));
        transfer::public_transfer(publisher, tx_context::sender(ctx));
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
    fun test_example_simple() {
        let scenario = test_scenario::begin(USER);

        init(EXAMPLE_SIMPLE {}, ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);

        assert!(test_scenario::has_most_recent_shared<Collection<EXAMPLE_SIMPLE>>(), 0);

        let mint_cap = test_scenario::take_from_address<MintCap<SimpleNft>>(
            &scenario, USER,
        );

        mint_nft(
            string::utf8(b"Simple NFT"),
            string::utf8(b"A simple NFT on Sui"),
            b"https://originbyte.io/",
            &mint_cap,
            ctx(&mut scenario)
        );

        test_scenario::return_to_address(USER, mint_cap);
        test_scenario::next_tx(&mut scenario, USER);

        assert!(test_scenario::has_most_recent_for_address<SimpleNft>(USER), 0);

        test_scenario::end(scenario);
    }
}
