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

    use nft_protocol::utils::{Self, Marker};

    /// `Attributes` was not defined
    ///
    /// Call `attributes::add_domain` to add `Attributes`.
    const EUndefinedAttributes: u64 = 1;

    /// `Attributes` already defined
    ///
    /// Call `attributes::borrow_domain` to borrow domain.
    const EExistingAttributes: u64 = 2;

    /// Domain for storing NFT string attributes
    ///
    /// Changes are replicated to `ComposableUrl` domain as URL parameters.
    struct Attributes has store, drop {
        /// Map of attributes
        map: VecMap<String, String>,
    }

    // === Static Instantiators ===

    /// Creates new `Attributes`
    public fun new(map: VecMap<String, String>): Attributes {
        Attributes { map }
    }

    /// Creates empty `Attributes`
    public fun empty(): Attributes {
        Attributes { map: vec_map::empty() }
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

    // === Dynamic Instantiators ===

    /// Creates new `Attributes` and adds it to the object UID as a
    /// dynamic field with Key `Marker<Attributes>`. Note that `object_uid` can
    /// be the UID of an NFT or in general any object that has a UID.
    ///
    /// Caution: The Key `Marker<Attributes>` is not defined in this module
    /// and it is permissionless, which means that anyone can instantiate it.
    /// As a result NFT creators must be mindful when sharing &mut UID because
    /// anyone with untethered access to &mut UID can mutate this field.
    ///
    /// #### Panics
    ///
    /// If the object already has a dynamic field with this Key
    public fun add_new(
        object_uid: &mut UID,
        map: VecMap<String, String>
    ) {
        df::add(object_uid, utils::marker<Attributes>(), new(map));
    }

    /// Creates empty `Attributes` and adds it to the object UID as a
    /// dynamic field with Key `Marker<Attributes>`. Note that `object_uid`
    /// can be the UID of an NFT or in general any object that has a UID.
    ///
    /// Caution: The Key `Marker<Attributes>` is not defined in this module
    /// and it is permissionless, which means that anyone can instantiate it.
    /// As a result NFT creators must be mindful when sharing &mut UID because
    /// anyone with untethered access to &mut UID can mutate this field.
    ///
    /// #### Panics
    ///
    /// If the object already has a dynamic field with this Key
    public fun add_empty(nft_uid: &mut UID) {
        df::add(nft_uid, utils::marker<Attributes>(), empty());
    }

    /// Creates new `Attributes` from vectors of keys and values and adds it
    /// to the object UID as a dynamic field with Key `Marker<Attributes>`.
    /// Note that `object_uid` can be the UID of an NFT or in general
    /// any object that has a UID.
    ///
    /// Caution: The Key `Marker<Attributes>` is not defined in this module
    /// and it is permissionless, which means that anyone can instantiate it.
    /// As a result NFT creators must be mindful when sharing &mut UID because
    /// anyone with untethered access to &mut UID can mutate this field.
    ///
    /// #### Panics
    ///
    /// Panics if keys and values vectors have different lengths
    public fun add_from_vec(
        keys: vector<String>,
        values: vector<String>,
    ): Attributes {
        let map = utils::from_vec_to_map<String, String>(keys, values);
        new(map)
    }

    /// Immutably borrows underlying attribute map of `Attributes`
    public fun get_attributes(
        attributes: &Attributes,
    ): &VecMap<String, String> {
        &attributes.map
    }

    /// Mutably borrows underlying attribute map of `Attributes`
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `Attributes`.
    public fun get_attributes_mut(
        attributes: &mut Attributes,
    ): &mut VecMap<String, String> {
        &mut attributes.map
    }

    /// Inserts attribute to `Attributes` field in the NFT of type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if `Attributes` are not registered on NFT.
    public fun insert_attribute<W: drop, T: key>(
        attributes: &mut Attributes,
        attribute_key: String,
        attribute_value: String,
    ) {
        vec_map::insert(
            get_attributes_mut(attributes),
            attribute_key,
            attribute_value,
        );
    }

    /// Removes attribute from `Attributes`
    ///
    /// #### Panics
    ///
    /// Panics if `Attributes` dont exist.
    public fun remove_attribute<W: drop, T: key>(
        attributes: &mut Attributes,
        attribute_key: &String,
    ) {
        vec_map::remove(
            get_attributes_mut(attributes),
            attribute_key,
        );
    }

    /// Serializes attributes as URL parameters
    public fun as_url_parameters(attributes: &Attributes): vector<u8> {
        let parameters = vector::empty<u8>();

        let attributes_map = get_attributes(attributes);
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

    // === Interoperability ===

    /// Returns whether `Attributes` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<Attributes>, Attributes>(
            nft, utils::marker(),
        )
    }

    /// Borrows `Attributes` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Attributes` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &Attributes {
        assert_attributes(nft);
        df::borrow(nft, utils::marker<Attributes>())
    }

    /// Mutably borrows `Attributes` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Attributes` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut Attributes {
        assert_attributes(nft);
        df::borrow_mut(nft, utils::marker<Attributes>())
    }

    /// Adds `Attributes` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Attributes` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: Attributes,
    ) {
        assert_no_attributes(nft);
        df::add(nft, utils::marker<Attributes>(), domain);
    }

    /// Remove `Attributes` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Attributes` domain doesnt exist
    public fun remove_domain(nft: &mut UID): Attributes {
        assert_attributes(nft);
        df::remove(nft, utils::marker<Attributes>())
    }

    // === Assertions ===

    /// Asserts that `Attributes` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Attributes` is not registered
    public fun assert_attributes(nft: &UID) {
        assert!(has_domain(nft), EUndefinedAttributes);
    }

    /// Asserts that `Attributes` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Attributes` is registered
    public fun assert_no_attributes(nft: &UID) {
        assert!(!has_domain(nft), EExistingAttributes);
    }
}
