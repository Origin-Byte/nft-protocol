/// Module of the `Symbol`
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

    // === Symbol ===

    struct Symbol has store, drop {
        symbol: String,
    }

    /// Gets symbol of `Symbol`
    public fun symbol(domain: &Symbol): &String {
        &domain.symbol
    }

    /// Creates new `Symbol` with a symbol
    public fun new(symbol: String): Symbol {
        Symbol { symbol }
    }

    /// Sets name of `DisplayDomain`
    public fun set_symbol<T>(
        domain: &mut Symbol,
        symbol: String,
    ) {
        domain.symbol = symbol;
    }

    // === Interoperability ===

    /// Returns whether `Symbol` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<Symbol>, Symbol>(
            nft, utils::marker(),
        )
    }

    /// Borrows `Symbol` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Symbol` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &Symbol {
        assert_symbol(nft);
        df::borrow(nft, utils::marker<Symbol>())
    }

    /// Mutably borrows `Symbol` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Symbol` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut Symbol {
        assert_symbol(nft);
        df::borrow_mut(nft, utils::marker<Symbol>())
    }

    /// Adds `Symbol` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Symbol` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: Symbol,
    ) {
        assert_no_symbol(nft);
        df::add(nft, utils::marker<Symbol>(), domain);
    }

    /// Remove `Symbol` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Symbol` domain doesnt exist
    public fun remove_domain(nft: &mut UID): Symbol {
        assert_symbol(nft);
        df::remove(nft, utils::marker<Symbol>())
    }

    // === Assertions ===

    /// Asserts that `Symbol` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Symbol` is not registered
    public fun assert_symbol(nft: &UID) {
        assert!(has_domain(nft), EUndefinedSymbol);
    }

    /// Asserts that `Symbol` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Symbol` is registered
    public fun assert_no_symbol(nft: &UID) {
        assert!(!has_domain(nft), EExistingSymbol);
    }
}
