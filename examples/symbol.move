/// Implements a contract that mints NFTs with a globally unique symbol and
/// allows associating them with collections
module nft_protocol::example_symbol {
    use std::string::{Self, String};
    use std::option;

    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set::{Self, VecSet};

    use nft_protocol::mint_cap;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::display_info::{Self, DisplayInfo};
    use nft_protocol::collection::{Self, Collection};

    /// One time witness is only instantiated in the init method
    struct EXAMPLE_SYMBOL has drop {}

    /// Used for authorization of other protected actions.
    ///
    /// `Witness` must not be freely exposed to any contract.
    struct Witness has drop {}

    /// Domain holding a globally unique symbol
    struct SymbolDomain has store {
        /// Unique symbol
        symbol: String,
    }

    /// Collection domain responsible for storing symbols already registered
    struct RegistryDomain has store {
        /// Registered symbols
        symbols: VecSet<String>,
    }

    /// Adds registration to `RegistryDomain` and returns unique `SymbolDomain`
    fun register(
        registry: &mut RegistryDomain, symbol: String,
    ): SymbolDomain {
        vec_set::insert(&mut registry.symbols, symbol);
        SymbolDomain { symbol }
    }

    // === Contract functions ===

    /// Called during contract publishing
    fun init(_witness: EXAMPLE_SYMBOL, ctx: &mut TxContext) {
        let collection: Collection<Nft<EXAMPLE_SYMBOL>> =
            nft::create_collection(Witness {}, ctx);

        let delegated_witness = nft::delegate_witness<EXAMPLE_SYMBOL, Witness>(
            Witness {}
        );

        let mint_cap =mint_cap::new_from_delegated<Nft<EXAMPLE_SYMBOL>>(
            delegated_witness,
            &collection,
            option::none(),
            ctx
        );

        collection::add_domain_delegated(
            delegated_witness,
            &mut collection,
            display_info::new(
                string::utf8(b"Symbol"),
                string::utf8(b"Collection of unique symbols on Sui"),
            )
        );

        collection::add_domain_delegated(
            delegated_witness,
            &mut collection,
            RegistryDomain { symbols: vec_set::empty() },
        );

        transfer::public_transfer(mint_cap, tx_context::sender(ctx));
        transfer::public_share_object(collection);
    }

    /// Mint `Nft` from `SymbolDomain`
    public fun mint_nft(
        domain: SymbolDomain,
        ctx: &mut TxContext,
    ): Nft<EXAMPLE_SYMBOL> {
        let delegated_witness = nft::delegate_witness(Witness {});

        let nft: Nft<EXAMPLE_SYMBOL> = nft::new(
            Witness {},
            domain.symbol, // name
            sui::url::new_unsafe_from_bytes(b""), // url
            ctx,
        );

        nft::add_domain(delegated_witness, &mut nft, domain);

        nft
    }

    /// Extracts `SymbolDomain` by burning `Nft`
    public fun delete_nft(nft: Nft<EXAMPLE_SYMBOL>): SymbolDomain {
        let delegated_witness = nft::delegate_witness(Witness {});

        let _: DisplayInfo = nft::remove_domain(delegated_witness, &mut nft);

        let symbol: SymbolDomain = nft::remove_domain(
            delegated_witness, &mut nft,
        );

        nft::delete(nft);

        symbol
    }

    /// Call to mint an NFT with globally unique symbol
    public entry fun mint_symbol(
        collection: &mut Collection<Nft<EXAMPLE_SYMBOL>>,
        symbol: String,
        ctx: &mut TxContext,
    ) {
        let registry: &mut RegistryDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        let nft = mint_nft(register(registry, symbol), ctx);

        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

    /// Associate `SymbolDomain` to `Collection`
    public entry fun associate<T>(
        collection: &mut Collection<T>,
        nft: Nft<EXAMPLE_SYMBOL>,
    ) {
        let domain = delete_nft(nft);
        collection::add_domain(Witness {}, collection, domain);
    }

    /// Disassociate `SymbolDomain` from `Collection`
    public fun disassociate<T, W>(
        _witness: &W,
        collection: &mut Collection<T>,
        ctx: &mut TxContext,
    ) {
        nft_protocol::utils::assert_same_module_as_witness<T, W>();

        let domain: SymbolDomain = collection::remove_domain(Witness {}, collection);
        let nft = mint_nft(domain, ctx);

        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

    #[test_only]
    use sui::test_scenario::{Self, ctx};
    #[test_only]
    const USER: address = @0xA1C04;

    #[test]
    fun it_inits_collection() {
        let scenario = test_scenario::begin(USER);
        init(EXAMPLE_SYMBOL {}, ctx(&mut scenario));

        test_scenario::end(scenario);
    }
}
