/// Module of the `DisplayInfo`
module nft_protocol::display_info {
    use std::ascii::String;

    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::utils::{
        assert_with_witness, assert_with_consumable_witness, UidType
    };
    use nft_protocol::consumable_witness::{Self as cw, ConsumableWitness};

    /// No field object `DisplayInfo` defined as a dynamic field.
    const EUNDEFINED_DISPLAY_INFO_FIELD: u64 = 1;

    /// Field object `DisplayInfo` already defined as dynamic field.
    const EDISPLAY_INFO_FIELD_ALREADY_EXISTS: u64 = 2;

    struct DisplayInfo has store {
        name: String,
        description: String,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Key struct used to store DisplayInfo in dynamic fields
    struct DisplayInfoKey has store, copy, drop {}


    // === Insert with ConsumableWitness ===


    /// Adds `DisplayInfo` as a dynamic field with key `DisplayInfoKey`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `DisplayInfo`.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun add_display_info<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        name: String,
        description: String,
    ) {
        assert_has_not_display_info(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let display_info = new(name, description);

        cw::consume<T, DisplayInfo>(consumable, &mut display_info);
        df::add(nft_uid, DisplayInfoKey {}, display_info);
    }


    // === Insert with module specific Witness ===


    /// Adds `DisplayInfo` as a dynamic field with key `DisplayInfoKey`.
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
    public fun add_display_info_<W: drop, T: key>(
        _witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        name: String,
        description: String,
    ) {
        assert_has_not_display_info(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let display_info = new(name, description);
        df::add(nft_uid, DisplayInfoKey {}, display_info);
    }

    // === Get for call from external Module ===


    /// Creates new `DisplayInfo`
    public fun new(name: String, description: String): DisplayInfo {
        DisplayInfo { name, description }
    }

    // === Field Borrow Functions ===


    /// Borrows immutably the `DisplayInfo` field.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `DisplayInfoKey` does not exist.
    public fun borrow_display_info(
        nft_uid: &UID,
    ): &DisplayInfo {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_display_info(nft_uid);
        df::borrow(nft_uid, DisplayInfoKey {})
    }

    /// Borrows Mutably the `DisplayInfo` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `DisplayInfo`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `DisplayInfoKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun borrow_display_info_mut<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>
    ): &mut DisplayInfo {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_display_info(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let display_info = df::borrow_mut<DisplayInfoKey, DisplayInfo>(
            nft_uid,
            DisplayInfoKey {}
        );
        cw::consume<T, DisplayInfo>(consumable, display_info);

        display_info
    }

    /// Borrows Mutably the `DisplayInfo` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `DisplayInfoKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun borrow_display_info_mut_<W: drop, T: key>(
        _witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>
    ): &mut DisplayInfo {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_display_info(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        df::borrow_mut(nft_uid, DisplayInfoKey {})
    }


    // === Writer Functions ===


    /// Changes name string in the object field `DisplayInfo` of the object type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `DisplayInfo`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `DisplayInfoKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun change_name<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        new_name: String,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_display_info(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let display_info = borrow_mut_internal(nft_uid);

        cw::consume<T, DisplayInfo>(consumable, display_info);
        display_info.name = new_name;
    }

    /// Changes name string in the object field `DisplayInfo` of the object type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `DisplayInfoKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun change_name_<W: drop, T: key>(
        witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        new_name: String,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_display_info(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let display_info = borrow_mut_internal(nft_uid);

        display_info.name = new_name;
    }

    /// Changes description string in the object field `DisplayInfo` of the object type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `DisplayInfo`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `DisplayInfoKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun change_description<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        new_description: String,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_display_info(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let display_info = borrow_mut_internal(nft_uid);

        cw::consume<T, DisplayInfo>(consumable, display_info);
        display_info.description = new_description;
    }

    /// Changes description string in the object field `DisplayInfo` of the object type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `DisplayInfoKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun change_description_<W: drop, T: key>(
        witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        new_description: String,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_display_info(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let display_info = borrow_mut_internal(nft_uid);
        display_info.description = new_description;
    }

    // === Getter Functions & Static Mutability Accessors ===


    /// Borrows underlying `DisplayInfo` name string.
    public fun get_name(
        display_info: &DisplayInfo,
    ): &String {
        &display_info.name
    }

    /// Borrows underlying `DisplayInfo` description string.
    public fun get_description(
        display_info: &DisplayInfo,
    ): &String {
        &display_info.description
    }

    /// Mutably borrows underlying `DisplayInfo` name string.
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `DisplayInfo`.
    public fun get_name_mut(
        display_info: &mut DisplayInfo,
    ): &String {
        &mut display_info.name
    }

    /// Mutably borrows underlying `DisplayInfo` description string.
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `DisplayInfo`.
    public fun get_description_mut(
        display_info: &mut DisplayInfo,
    ): &String {
        &mut display_info.description
    }


    // === Private Functions ===


    /// Borrows Mutably the `DisplayInfo` field.
    ///
    /// For internal use only.
    fun borrow_mut_internal(
        nft_uid: &mut UID,
    ): &mut DisplayInfo {
        df::borrow_mut<DisplayInfoKey, DisplayInfo>(
            nft_uid,
            DisplayInfoKey {}
        )
    }

    // === Assertions & Helpers ===


    /// Checks that a given NFT has a dynamic field with `DisplayInfoKey`
    public fun has_display_info(
        nft_uid: &UID,
    ): bool {
        df::exists_(nft_uid, DisplayInfoKey {})
    }

    public fun assert_has_display_info(nft_uid: &UID) {
        assert!(has_display_info(nft_uid), EUNDEFINED_DISPLAY_INFO_FIELD);
    }

    public fun assert_has_not_display_info(nft_uid: &UID) {
        assert!(!has_display_info(nft_uid), EDISPLAY_INFO_FIELD_ALREADY_EXISTS);
    }
}
