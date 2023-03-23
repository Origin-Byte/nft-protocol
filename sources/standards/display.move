/// Module of NFT domains for displaying standard information
///
/// Current display domains are:
///     - DisplayDomain (For NFTs and Collections)
///     - UrlDomain (For NFTs and Collections)
///     - SymbolDomain (For Collections)
///     - Attributes (For NFTs)
module nft_protocol::display_domain {
    use std::string::String;
    use std::option::{Self, Option};

    use sui::object::ID;

    use nft_protocol::witness;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::witness::Witness as DelegatedWitness;
    use nft_protocol::collection::{Self, Collection};

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    struct DisplayDomain has drop, store {
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
    ): DisplayDomain {
        DisplayDomain { name, description }
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

    public fun add_display_domain<C, W>(
        witness: &W,
        nft: &mut Nft<C>,
        name: String,
        description: String,
    ) {
        nft::add_domain(
            witness, nft, new_display_domain(name, description),
        );
    }

    public fun add_collection_display_domain<C, W>(
        witness: &W,
        collection: &mut Collection<C>,
        name: String,
        description: String,
    ) {
        collection::add_domain(
            witness, collection, new_display_domain(name, description)
        );
    }

    public fun remove_display_domain<C, W>(
        witness: &W,
        nft: &mut Nft<C>,
    ): DisplayDomain {
        remove_display_domain_delegated(witness::from_witness(witness), nft)
    }

    public fun remove_display_domain_delegated<C>(
        _witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
    ): DisplayDomain {
        nft::remove_domain<C, Witness, DisplayDomain>(Witness {}, nft)
    }

    // === SymbolDomain ===

    struct SymbolDomain has store {
        symbol: String,
    }

    /// Gets symbol of `SymbolDomain`
    public fun symbol(domain: &SymbolDomain): &String {
        &domain.symbol
    }

    /// Creates new `SymbolDomain` with a symbol
    public fun new_symbol_domain(symbol: String): SymbolDomain {
        SymbolDomain { symbol }
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

    public fun add_symbol_domain<C, W>(
        witness: &W,
        nft: &mut Nft<C>,
        symbol: String,
    ) {
        nft::add_domain(witness, nft, new_symbol_domain(symbol));
    }

    public fun add_collection_symbol_domain<C, W>(
        witness: &W,
        nft: &mut Collection<C>,
        symbol: String,
    ) {
        collection::add_domain(witness, nft, new_symbol_domain(symbol));
    }

    // === CollectionIdDomain ===

    struct CollectionIdDomain has store {
        collection_id: ID,
    }

    /// Gets name of `CollectionIdDomain`
    public fun collection_id(domain: &CollectionIdDomain): &ID {
        &domain.collection_id
    }

    /// Creates a new `CollectionIdDomain` with name
    public fun new_collection_id_domain(
        collection_id: ID,
    ): CollectionIdDomain {
        CollectionIdDomain { collection_id }
    }

    /// Sets name of `CollectionIdDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_collection_id<C>(
        _witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        collection_id: ID,
    ) {
        let domain: &mut CollectionIdDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.collection_id = collection_id;
    }

    // ====== Interoperability ===

    public fun collection_id_domain<C>(
        nft: &Nft<C>,
    ): &CollectionIdDomain {
        nft::borrow_domain(nft)
    }

    public fun add_collection_id_domain<C, W>(
        witness: &W,
        nft: &mut Nft<C>,
        collection_id: ID,
    ) {
        nft::add_domain(
            witness, nft, new_collection_id_domain(collection_id),
        );
    }
}
