/// Module of `SymbolDomain` used to assign a symbol to collection or NFT
module nft_protocol::symbol {
    use std::string::String;

    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::utils::{Self, Marker};

    /// `SymbolDomain` was not defined
    ///
    /// Call `symbol::add_domain` to add `SymbolDomain`.
    const EUndefinedSymbol: u64 = 1;

    /// `SymbolDomain` already defined
    ///
    /// Call `symbol::borrow_domain` to borrow domain.
    const EExistingSymbol: u64 = 2;

    // === SymbolDomain ===

    struct SymbolDomain has store {
        symbol: String,
    }

    /// Gets symbol of `SymbolDomain`
    public fun symbol(domain: &SymbolDomain): &String {
        &domain.symbol
    }

    /// Creates new `SymbolDomain` with a symbol
    public fun new(symbol: String): SymbolDomain {
        SymbolDomain { symbol }
    }

    /// Sets name of `DisplayDomain`
    public fun set_symbol<T>(
        domain: &mut SymbolDomain,
        symbol: String,
    ) {
        domain.symbol = symbol;
    }

    // === Interoperability ===

    /// Returns whether `SymbolDomain` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<SymbolDomain>, SymbolDomain>(
            nft, utils::marker(),
        )
    }

    /// Borrows `SymbolDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SymbolDomain` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &SymbolDomain {
        assert_symbol(nft);
        df::borrow(nft, utils::marker<SymbolDomain>())
    }

    /// Mutably borrows `SymbolDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SymbolDomain` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut SymbolDomain {
        assert_symbol(nft);
        df::borrow_mut(nft, utils::marker<SymbolDomain>())
    }

    /// Adds `SymbolDomain` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SymbolDomain` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: SymbolDomain,
    ) {
        assert_no_symbol(nft);
        df::add(nft, utils::marker<SymbolDomain>(), domain);
    }

    /// Remove `SymbolDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SymbolDomain` domain doesnt exist
    public fun remove_domain(nft: &mut UID): SymbolDomain {
        assert_symbol(nft);
        df::remove(nft, utils::marker<SymbolDomain>())
    }

    // === Assertions ===

    /// Asserts that `SymbolDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SymbolDomain` is not registered
    public fun assert_symbol(nft: &UID) {
        assert!(has_domain(nft), EUndefinedSymbol);
    }

    /// Asserts that `SymbolDomain` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SymbolDomain` is registered
    public fun assert_no_symbol(nft: &UID) {
        assert!(!has_domain(nft), EExistingSymbol);
    }
}
