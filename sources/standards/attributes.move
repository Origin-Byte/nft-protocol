/// Module of the `Attributes`
///
/// Used to register string attributes on NFTs.
///
/// Interoperability functions are delegated to the `display_ext` module.
module nft_protocol::attributes {
    use std::vector;
    use std::ascii::{Self, String};

    use sui::vec_map::{Self, VecMap};
    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::utils::{
        Self, assert_with_witness, assert_with_consumable_witness, UidType
    };
    use nft_protocol::consumable_witness::{Self as cw, ConsumableWitness};

    /// No field object `Attributes` defined as a dynamic field.
    const EUNDEFINED_ATTRIBUTES_FIELD: u64 = 1;

    /// Field object `Attributes` already defined as dynamic field.
    const EATTRIBUTES_FIELD_ALREADY_EXISTS: u64 = 2;

    /// Field for storing NFT string attributes
    ///
    /// Changes are replicated to `ComposableUrl` domain as URL parameters.
    struct Attributes has store {
        /// Map of attributes
        map: VecMap<String, String>,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Key struct used to store Attributes in dynamic fields
    struct AttributesKey has store, copy, drop {}


    // === Insert with ConsumableWitness ===


    /// Adds `Attributes` as a dynamic field with key `AttributesKey`.
    /// It adds attributes from a `VecMap<String, String>`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun add_attributes<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        map: VecMap<String, String>,
    ) {
        assert_has_not_attributes(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let attributes = new(map);

        cw::consume<T, Attributes>(consumable, &mut attributes);
        df::add(nft_uid, AttributesKey {}, attributes);
    }

    /// Adds `Attributes` as a dynamic field with key `AttributesKey`.
    /// It adds attributes from vectors of keys and values.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if keys and values vectors have different lengths.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun add_attributes_from_vec<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        keys: vector<String>,
        values: vector<String>,
    ) {
        assert_has_not_attributes(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let map = utils::from_vec_to_map<String, String>(keys, values);
        let attributes = new(map);

        cw::consume<T, Attributes>(consumable, &mut attributes);
        df::add(nft_uid, AttributesKey {}, attributes);
    }

    /// Adds empty `Attributes` as a dynamic field with key `AttributesKey`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun add_empty<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
    ) {
        assert_has_not_attributes(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let attributes = empty();

        cw::consume<T, Attributes>(consumable, &mut attributes);
        df::add(nft_uid, AttributesKey {}, attributes);
    }


    // === Insert with module specific Witness ===


    /// Adds `Attributes` as a dynamic field with key `AttributesKey`.
    /// It adds attributes from a `VecMap<String, String>`.
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
    public fun add_attributes_<W: drop, T: key>(
        _witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        map: VecMap<String, String>,
    ) {
        assert_has_not_attributes(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let attributes = new(map);
        df::add(nft_uid, AttributesKey {}, attributes);
    }

    /// Adds `Attributes` as a dynamic field with key `AttributesKey`.
    /// It adds attributes from vectors of keys and values.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if keys and values vectors have different lengths.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun add_attributes_from_vec_<W: drop, T: key>(
        _witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        keys: vector<String>,
        values: vector<String>,
    ) {
        assert_has_not_attributes(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let map = utils::from_vec_to_map<String, String>(keys, values);
        let attributes = new(map);
        df::add(nft_uid, AttributesKey {}, attributes);
    }

    /// Adds empty `Attributes` as a dynamic field with key `AttributesKey`.
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
    public fun add_empty_<W: drop, T: key>(
        _witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
    ) {
        assert_has_not_attributes(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let attributes = empty();
        df::add(nft_uid, AttributesKey {}, attributes);
    }

    // === Get for call from external Module ===


    /// Creates new `Attributes`
    public fun new(map: VecMap<String, String>): Attributes {
        Attributes { map }
    }

    /// Creates new `Attributes` from vectors of keys and values
    ///
    /// #### Panics
    ///
    /// Panics if keys and values vectors have different lengths
    public fun from_vec(
        keys: vector<String>,
        values: vector<String>,
    ): Attributes {
        let map = utils::from_vec_to_map<String, String>(keys, values);
        new(map)
    }

    /// Creates empty `Attributes`
    public fun empty(): Attributes {
        Attributes { map: vec_map::empty() }
    }


    // === Field Borrow Functions ===


    /// Borrows immutably the `Attributes` field.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    public fun borrow_attributes(
        nft_uid: &UID,
    ): &Attributes {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_attributes(nft_uid);
        df::borrow(nft_uid, AttributesKey {})
    }

    /// Borrows Mutably the `Attributes` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun borrow_attributes_mut<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>
    ): &mut Attributes {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_attributes(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let attributes = df::borrow_mut<AttributesKey, Attributes>(
            nft_uid,
            AttributesKey {}
        );
        cw::consume<T, Attributes>(consumable, attributes);

        attributes
    }

    /// Borrows Mutably the `Attributes` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun borrow_attributes_mut_<W: drop, T: key>(
        _witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>
    ): &mut Attributes {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_attributes(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        df::borrow_mut(nft_uid, AttributesKey {})
    }


    // === Writer Functions ===


    /// Inserts attribute to `Attributes` field in the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun insert_attribute<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        attribute_key: String,
        attribute_value: String,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_attributes(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let attributes = borrow_mut_internal(nft_uid);

        vec_map::insert(
            &mut attributes.map,
            attribute_key,
            attribute_value,
        );

        cw::consume<T, Attributes>(consumable, attributes);
    }

    /// Removes attribute to `Attributes` field in the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun remove_attribute<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        attribute_key: &String,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_attributes(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let attributes = borrow_mut_internal(nft_uid);

        vec_map::remove(
            &mut attributes.map,
            attribute_key,
        );

        cw::consume<T, Attributes>(consumable, attributes);
    }

    /// Inserts attribute to `Attributes` field in the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun insert_attribute_<W: drop, T: key>(
        witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        attribute_key: String,
        attribute_value: String,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_attributes(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let attributes = borrow_mut_internal(nft_uid);

        vec_map::insert(
            &mut attributes.map,
            attribute_key,
            attribute_value,
        );
    }

    /// Removes attribute to `Attributes` field in the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun remove_attribute_<W: drop, T: key>(
        witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        attribute_key: &String,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_attributes(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let attributes = borrow_mut_internal(nft_uid);

        vec_map::remove(
            &mut attributes.map,
            attribute_key,
        );
    }


    // === Getter Functions & Static Mutability Accessors ===


    /// Immutably borrows underlying attribute map of `Attributes`
    public fun get_attributes_map(
        attributes: &Attributes,
    ): &VecMap<String, String> {
        &attributes.map
    }

    /// Mutably borrows underlying attribute map of `Attributes`
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `Attributes`.
    public fun get_attributes_map_mut(
        attributes: &mut Attributes,
    ): &mut VecMap<String, String> {
        &mut attributes.map
    }

    /// Serializes attributes as URL parameters
    public fun as_url_parameters(attributes: &Attributes): vector<u8> {
        let parameters = vector::empty<u8>();

        let attributes_map = get_attributes_map(attributes);
        let size = vec_map::size(attributes_map);

        // Check if we even expect URL parameters
        if (size > 0) {
            vector::append(&mut parameters, b"?");
        };

        let idx = 0;
        while (idx < size) {
            let (key, value) = vec_map::get_entry_by_idx(attributes_map, idx);

            vector::append(&mut parameters, ascii::into_bytes(*key));
            vector::append(&mut parameters, b"=");
            vector::append(&mut parameters, ascii::into_bytes(*value));

            idx = idx + 1;

            // Check if its not the last element
            if (idx != size) {
                vector::append(&mut parameters, b"&");
            }
        };

        parameters
    }

    // === Private Functions ===


    /// Borrows Mutably the `Attributes` field.
    ///
    /// For internal use only.
    fun borrow_mut_internal(
        nft_uid: &mut UID,
    ): &mut Attributes {
        df::borrow_mut<AttributesKey, Attributes>(
            nft_uid,
            AttributesKey {}
        )
    }


    // === Assertions & Helpers ===


    /// Checks that a given NFT has a dynamic field with `AttributesKey`
    public fun has_attributes(
        nft_uid: &UID,
    ): bool {
        df::exists_(nft_uid, AttributesKey {})
    }

    public fun assert_has_attributes(nft_uid: &UID) {
        assert!(has_attributes(nft_uid), EUNDEFINED_ATTRIBUTES_FIELD);
    }

    public fun assert_has_not_attributes(nft_uid: &UID) {
        assert!(!has_attributes(nft_uid), EATTRIBUTES_FIELD_ALREADY_EXISTS);
    }
}
