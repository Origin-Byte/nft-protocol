/// Module of NFT domains for displaying standard information
///
/// Current display domains are:
///     - DisplayInfo (For NFTs and Collections)
///     - UrlDomain (For NFTs and Collections)
///     - Symbol (For Collections)
///     - Attributes (For NFTs)
module nft_protocol::display {
    use std::string::String;

    use nft_protocol::witness::Witness as DelegatedWitness;
    use nft_protocol::collection::{Self, Collection};

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    struct DisplayInfo has drop, store {
        name: String,
        description: String,
    }

    /// Gets name of `DisplayInfo`
    public fun name(domain: &DisplayInfo): &String {
        &domain.name
    }

    /// Gets description of `DisplayInfo`
    public fun description(domain: &DisplayInfo): &String {
        &domain.description
    }

    /// Creates a new `DisplayInfo` with name and description
    public fun new_display_domain(
        name: String,
        description: String,
    ): DisplayInfo {
        DisplayInfo { name, description }
    }

    /// Sets name of `DisplayInfo`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_name<T>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        name: String,
    ) {
        let domain: &mut DisplayInfo =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.name = name;
    }

    /// Sets description of `DisplayInfo`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_description<T>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        description: String,
    ) {
        let domain: &mut DisplayInfo =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.description = description;
    }

    // === Symbol ===

    struct Symbol has store {
        symbol: String,
    }

    /// Gets symbol of `Symbol`
    public fun symbol(domain: &Symbol): &String {
        &domain.symbol
    }

    /// Creates new `Symbol` with a symbol
    public fun new_symbol_domain(symbol: String): Symbol {
        Symbol { symbol }
    }

    /// Sets name of `DisplayInfo`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_symbol<T>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        symbol: String,
    ) {
        let domain: &mut Symbol =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.symbol = symbol;
    }
}
