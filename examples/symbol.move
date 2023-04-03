/// Implements a contract that mints NFTs with a globally unique symbol and
/// allows associating them with collections
module nft_protocol::example_symbol {
    use std::string::{Self, String};

    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set::{Self, VecSet};

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::display::{Self, DisplayDomain};
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
    fun init(witness: EXAMPLE_SYMBOL, ctx: &mut TxContext) {
        let (mint_cap, collection) = nft::new_collection(&witness, ctx);

        collection::add_domain(
            Witness {},
            &mut collection,
            display::new(
                string::utf8(b"Symbol"),
                string::utf8(b"Collection of unique symbols on Sui"),
            )
        );

        collection::add_domain(
            Witness {},
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
        let nft: Nft<EXAMPLE_SYMBOL> = nft::new(
            Witness {},
            domain.symbol, // name
            sui::url::new_unsafe_from_bytes(b""), // url
            ctx,
        );

        nft::add_domain(Witness {}, &mut nft, domain);

        nft
    }

    /// Extracts `SymbolDomain` by burning `Nft`
    public fun delete_nft(nft: Nft<EXAMPLE_SYMBOL>): SymbolDomain {
        nft::remove_domain<EXAMPLE_SYMBOL, Witness, DisplayDomain>(
            Witness {}, &mut nft,
        );

        let symbol: SymbolDomain = nft::remove_domain(
            Witness {}, &mut nft,
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
}
