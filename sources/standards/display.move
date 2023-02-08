/// Module of NFT domains for displaying standard information
///
/// Current display domains are:
///     - DisplayDomain (For NFTs and Collections)
///     - UrlDomain (For NFTs and Collections)
///     - SymbolDomain (For Collections)
///     - Attributes (For NFTs)
module nft_protocol::display {
    use std::string::String;
    use std::option::{Self, Option};

    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::witness::Witness as DelegatedWitness;
    use nft_protocol::collection::{Self, Collection};

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    struct DisplayDomain has key, store {
        id: UID,
        name: String,
        description: String,
    }

    /// Gets name of `DisplayDomain`
    public fun name(domain: &DisplayDomain): &String {
        &domain.name
    }

    /// Gets description of `DisplayDomain`
    public fun description(domain: &DisplayDomain): &String {
        &domain.description
    }

    /// Creates a new `DisplayDomain` with name and description
    public fun new_display_domain(
        name: String,
        description: String,
        ctx: &mut TxContext,
    ): DisplayDomain {
        DisplayDomain { id: object::new(ctx), name, description }
    }

    /// Sets name of `DisplayDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_name<C>(
        _witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        name: String,
    ) {
        let domain: &mut DisplayDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.name = name;
    }

    /// Sets description of `DisplayDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_description<C>(
        _witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        description: String,
    ) {
        let domain: &mut DisplayDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.description = description;
    }

    // ====== Interoperability ===

    public fun display_domain<C>(
        nft: &Nft<C>,
    ): &DisplayDomain {
        nft::borrow_domain(nft)
    }

    public fun collection_display_domain<C>(
        nft: &Collection<C>,
    ): &DisplayDomain {
        collection::borrow_domain(nft)
    }

    public fun add_display_domain<C>(
        witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
        name: String,
        description: String,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(
            witness, nft, new_display_domain(name, description, ctx),
        );
    }

    public fun add_collection_display_domain<C>(
        witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        name: String,
        description: String,
        ctx: &mut TxContext,
    ) {
        collection::add_domain(
            witness, collection, new_display_domain(name, description, ctx)
        );
    }

    // === SymbolDomain ===

    struct SymbolDomain has key, store {
        id: UID,
        symbol: String,
    }

    /// Gets symbol of `SymbolDomain`
    public fun symbol(domain: &SymbolDomain): &String {
        &domain.symbol
    }

    /// Creates new `SymbolDomain` with a symbol
    public fun new_symbol_domain(
        symbol: String,
        ctx: &mut TxContext,
    ): SymbolDomain {
        SymbolDomain { id: object::new(ctx), symbol }
    }

    /// Sets name of `DisplayDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_symbol<C>(
        _witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        symbol: String,
    ) {
        let domain: &mut SymbolDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.symbol = symbol;
    }

    // ====== Interoperability ===

    public fun display_symbol<C>(nft: &Nft<C>): Option<String> {
        if (!nft::has_domain<C, SymbolDomain>(nft)) {
            return option::none()
        };

        option::some(*symbol(nft::borrow_domain<C, SymbolDomain>(nft)))
    }

    public fun display_collection_symbol<C>(
        nft: &Collection<C>
    ): Option<String> {
        if (!collection::has_domain<C, SymbolDomain>(nft)) {
            return option::none()
        };

        option::some(*symbol(collection::borrow_domain<C, SymbolDomain>(nft)))
    }

    public fun add_symbol_domain<C>(
        witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
        symbol: String,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(
            witness, nft, new_symbol_domain(symbol, ctx),
        );
    }

    public fun add_collection_symbol_domain<C>(
        witness: DelegatedWitness<C>,
        nft: &mut Collection<C>,
        symbol: String,
        ctx: &mut TxContext,
    ) {
        collection::add_domain(witness, nft, new_symbol_domain(symbol, ctx));
    }
}
