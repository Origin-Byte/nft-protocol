/// Module of the `Symbol`
module nft_protocol::symbol {
    use std::ascii::String;

    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::utils::{
        assert_with_witness, assert_with_consumable_witness, UidType
    };
    use nft_protocol::consumable_witness::{Self as cw, ConsumableWitness};

    /// No field object `Symbol` defined as a dynamic field.
    const EUNDEFINED_SYMBOL_FIELD: u64 = 1;

    /// Field object `Symbol` already defined as dynamic field.
    const ESYMBOL_FIELD_ALREADY_EXISTS: u64 = 2;

    struct Symbol has store {
        symbol: String,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Key struct used to store Symbol in dynamic fields
    struct SymbolKey has store, copy, drop {}


    // === Insert with ConsumableWitness ===


    /// Adds `Symbol` as a dynamic field with key `SymbolKey`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Symbol`.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun add_symbol<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        symbol: String,
    ) {
        assert_has_not_symbol(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let symbol = new(symbol);

        cw::consume<T, Symbol>(consumable, &mut symbol);
        df::add(nft_uid, SymbolKey {}, symbol);
    }


    // === Insert with module specific Witness ===


    /// Adds `Symbol` as a dynamic field with key `SymbolKey`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun add_symbol_<W: drop, T: key>(
        _witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        symbol: String,
    ) {
        assert_has_not_symbol(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let symbol = new(symbol);
        df::add(nft_uid, SymbolKey {}, symbol);
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
    /// Panics if dynamic field with `SymbolKey` does not exist.
    public fun borrow_symbol(
        nft_uid: &UID,
    ): &Symbol {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_symbol(nft_uid);
        df::borrow(nft_uid, SymbolKey {})
    }

    /// Borrows Mutably the `Symbol` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Symbol`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `SymbolKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun borrow_symbol_mut<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>
    ): &mut Symbol {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_symbol(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let symbol = df::borrow_mut<SymbolKey, Symbol>(
            nft_uid,
            SymbolKey {}
        );
        cw::consume<T, Symbol>(consumable, symbol);

        symbol
    }

    /// Borrows Mutably the `Symbol` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `SymbolKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun borrow_symbol_mut_<W: drop, T: key>(
        _witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>
    ): &mut Symbol {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_symbol(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        df::borrow_mut(nft_uid, SymbolKey {})
    }


    // === Writer Functions ===


    /// Changes symbol string in the object field `Symbol` of the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Symbol`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `SymbolKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun change_symbol<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        new_symbol: String,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_symbol(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let symbol = borrow_mut_internal(nft_uid);

        cw::consume<T, Symbol>(consumable, symbol);
        symbol.symbol = new_symbol;
    }

    /// Changes symbol string in the object field `Symbol` of the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `SymbolKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun change_symbol_<W: drop, T: key>(
        witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        new_symbol: String,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_symbol(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let symbol = borrow_mut_internal(nft_uid);
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
        nft_uid: &mut UID,
    ): &mut Symbol {
        df::borrow_mut<SymbolKey, Symbol>(
            nft_uid,
            SymbolKey {}
        )
    }

    // === Assertions & Helpers ===


    /// Checks that a given NFT has a dynamic field with `SymbolKey`
    public fun has_symbol(
        nft_uid: &UID,
    ): bool {
        df::exists_(nft_uid, SymbolKey {})
    }

    public fun assert_has_symbol(nft_uid: &UID) {
        assert!(has_symbol(nft_uid), EUNDEFINED_SYMBOL_FIELD);
    }

    public fun assert_has_not_symbol(nft_uid: &UID) {
        assert!(!has_symbol(nft_uid), ESYMBOL_FIELD_ALREADY_EXISTS);
    }
}
