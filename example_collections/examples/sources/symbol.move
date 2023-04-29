/// Implements a contract that mints NFTs with a globally unique symbol and
/// allows associating them with collections
module examples::example_symbol {
    use std::string::{Self, String};

    use sui::display;
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set::{Self, VecSet};

    use ob_permissions::witness;
    use ob_utils::display_info;
    use nft_protocol::collection::{Self, Collection};

    /// One time witness is only instantiated in the init method
    struct EXAMPLE_SYMBOL has drop {}

    struct ExampleNft has key, store {
        id: UID,
        symbol: Symbol,
    }

    /// Used for authorization of other protected actions.
    ///
    /// `Witness` must not be freely exposed to any contract.
    struct Witness has drop {}

    /// Domain holding a globally unique symbol
    struct SymbolCap has key, store {
        id: UID,
        /// Unique symbol
        symbol: String,
    }

    struct Symbol has store {
        /// Unique symbol
        symbol: String,
    }

    /// Collection domain responsible for storing symbols already registered
    struct Registry has store {
        /// Registered symbols
        symbols: VecSet<String>,
    }

    /// Adds registration to `RegistryDomain` and returns unique `SymbolDomain`
    fun register(
        registry: &mut Registry,
        symbol: String,
        ctx: &mut TxContext,
    ): SymbolCap {
        vec_set::insert(&mut registry.symbols, symbol);
        SymbolCap { id: object::new(ctx), symbol }
    }

    // === Contract functions ===

    /// Called during contract publishing
    fun init(otw: EXAMPLE_SYMBOL, ctx: &mut TxContext) {

        // Setup `Display`
        let publisher = sui::package::claim(otw, ctx);

        let display = display::new<SymbolCap>(&publisher, ctx);
        display::add(&mut display, string::utf8(b"name"), string::utf8(b"{symbol}"));
        display::update_version(&mut display);
        transfer::public_transfer(display, tx_context::sender(ctx));

        let delegated_witness = witness::from_witness(Witness {});

        let collection: Collection<EXAMPLE_SYMBOL> =
            collection::create(delegated_witness, ctx);

        collection::add_domain(
            delegated_witness,
            &mut collection,
            display_info::new(
                string::utf8(b"Symbol"),
                string::utf8(b"Collection of unique symbols on Sui"),
            )
        );

        collection::add_domain(
            delegated_witness,
            &mut collection,
            Registry { symbols: vec_set::empty() },
        );

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_share_object(collection);
    }

    /// Mint `Nft` with `Symbol` from unique `SymbolCap`
    public fun mint_nft(
        cap: &SymbolCap,
        ctx: &mut TxContext,
    ): ExampleNft {
        let nft = ExampleNft {
            id: object::new(ctx),
            symbol: Symbol {symbol: cap.symbol}
        };

        nft
    }

    /// Call to mint an globally unique NFT Symbol
    public entry fun mint_symbol(
        collection: &mut Collection<EXAMPLE_SYMBOL>,
        symbol: String,
        ctx: &mut TxContext,
    ) {
        let delegated_witness = witness::from_witness(Witness {});

        let registry: &mut Registry =
            collection::borrow_domain_mut(delegated_witness, collection);

        let cap = register(registry, symbol, ctx);

        transfer::public_transfer(cap, tx_context::sender(ctx));
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
