/// Implements a simple NFT collection contract
module nft_protocol::example_simple {
    use std::string::{Self, String};
    use std::option;

    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::collection;
    use nft_protocol::witness::{Self, Witness as DelegatedWitness};
    use nft_protocol::mint_cap;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::display_info;
    use nft_protocol::mint_cap::MintCap;

    /// One time witness is only instantiated in the init method
    struct EXAMPLE_SIMPLE has drop {}

    /// Used for authorization of other protected actions.
    ///
    /// `Witness` must not be freely exposed to any contract.
    struct Witness has drop {}

    // === Contract functions ===

    /// Called during contract publishing
    fun init(witness: EXAMPLE_SIMPLE, ctx: &mut TxContext) {
        let delegated_witness = witness::from_witness(witness);

        let collection: Collection<EXAMPLE_SIMPLE> =
            collection::create(delegated_witness, ctx);

        let mint_cap =
            mint_cap::new(delegated_witness, &collection, option::none(), ctx);

        nft::add_collection_domain(
            Witness {},
            &mut collection,
            display_info::new(
                string::utf8(b"Simple"),
                string::utf8(b"Simple collection on Sui"),
            )
        );

        transfer::public_transfer(mint_cap, tx_context::sender(ctx));
        transfer::public_share_object(collection);
    }

    /// Mint `Nft`
    public entry fun mint_nft(
        name: String,
        description: String,
        url: vector<u8>,
        _mint_cap: &MintCap<EXAMPLE_SIMPLE>,
        ctx: &mut TxContext,
    ) {
        let delegated_witness = witness::from_witness(Witness {});
        let url = sui::url::new_unsafe_from_bytes(url);

        let nft: Nft<EXAMPLE_SIMPLE> = nft::new(
            delegated_witness, name, url, ctx,
        );

        nft::add_domain(
            delegated_witness, &mut nft, display_info::new(name, description),
        );

        nft::add_domain(delegated_witness, &mut nft, url);

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

        assert!(test_scenario::has_most_recent_shared<Collection<Nft<EXAMPLE_SIMPLE>>>(), 0);

        let mint_cap = test_scenario::take_from_address<MintCap<Nft<EXAMPLE_SIMPLE>>>(
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

        assert!(test_scenario::has_most_recent_for_address<Nft<EXAMPLE_SIMPLE>>(USER), 0);

        test_scenario::end(scenario);
    }
}
