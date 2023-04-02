/// Module of the `Symbol`
module nft_protocol::symbol {
    use std::ascii::String;

    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::utils::{
        assert_with_witness, UidType, marker, Marker
    };

    /// No field object `Symbol` defined as a dynamic field.
    const EUNDEFINED_SYMBOL_FIELD: u64 = 1;

    /// Field object `Symbol` already defined as dynamic field.
    const ESYMBOL_FIELD_ALREADY_EXISTS: u64 = 2;

    struct Symbol has store {
        symbol: String,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}


    // === Insert with module specific Witness ===


    /// Adds `Symbol` as a dynamic field with key `Marker<Symbol>`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun add_symbol<W:drop, T: key>(
        _witness: W,
        object_uid: &mut UID,
        object_type: UidType<T>,
        symbol: String,
    ) {
        assert_has_not_symbol(object_uid);
        assert_with_witness<W, T>(object_uid, object_type);

        let symbol = new(symbol);

        df::add(object_uid, marker<Symbol>(), symbol);
    }


    // === Get for call from external Module ===


    /// Creates new `Symbol`
    public fun new(symbol: String): Symbol {
        Symbol { symbol }
    }

    // === Field Borrow Functions ===


    /// Borrows immutably the `Symbol` field.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `Marker<Symbol>` does not exist.
    public fun borrow_symbol(
        object_uid: &UID,
    ): &Symbol {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_symbol(object_uid);
        df::borrow(object_uid, marker<Symbol>())
    }

    /// Borrows Mutably the `Symbol` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `Marker<Symbol>` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun borrow_symbol_mut<W: drop, T: key>(
        _witness: W,
        object_uid: &mut UID,
        object_type: UidType<T>
    ): &mut Symbol {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_symbol(object_uid);
        assert_with_witness<W, T>(object_uid, object_type);

        let symbol = df::borrow_mut<Marker<Symbol>, Symbol>(
            object_uid,
            marker<Symbol>()
        );

        symbol
    }


    // === Writer Functions ===


    /// Changes symbol string in the object field `Symbol` of the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `Marker<Symbol>` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun change_symbol<W: drop, T: key>(
        _witness: W,
        object_uid: &mut UID,
        object_type: UidType<T>,
        new_symbol: String,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_symbol(object_uid);
        assert_with_witness<W, T>(object_uid, object_type);

        let symbol = borrow_mut_internal(object_uid);

        symbol.symbol = new_symbol;
    }


    // === Getter Functions & Static Mutability Accessors ===


    /// Borrows underlying `Symbol` string.
    public fun get_symbol(
        symbol: &Symbol,
    ): &String {
        &symbol.symbol
    }

    /// Mutably borrows underlying `Symbol` string.
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `Symbol`.
    public fun get_symbol_mut(
        symbol: &mut Symbol,
    ): &String {
        &mut symbol.symbol
    }


    // === Private Functions ===


    /// Borrows Mutably the `Symbol` field.
    ///
    /// For internal use only.
    fun borrow_mut_internal(
        object_uid: &mut UID,
    ): &mut Symbol {
        df::borrow_mut<Marker<Symbol>, Symbol>(
            object_uid,
            marker<Symbol>()
        )
    }

    // === Assertions & Helpers ===


    /// Checks that a given NFT has a dynamic field with `Marker<Symbol>`
    public fun has_symbol(
        object_uid: &UID,
    ): bool {
        df::exists_(object_uid, marker<Symbol>())
    }

    public fun assert_has_symbol(object_uid: &UID) {
        assert!(has_symbol(object_uid), EUNDEFINED_SYMBOL_FIELD);
    }

    public fun assert_has_not_symbol(object_uid: &UID) {
        assert!(!has_symbol(object_uid), ESYMBOL_FIELD_ALREADY_EXISTS);
    }
}
