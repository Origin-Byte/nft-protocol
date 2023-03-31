/// Module of the `AttributesDomain`
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

    /// `AttributesDomain` was not defined
    ///
    /// Call `attributes::add_domain` to add `AttributesDomain`.
    const EUndefinedAttributes: u64 = 1;

    /// `AttributesDomain` already defined
    ///
    /// Call `attributes::borrow_domain` to borrow domain.
    const EExistingAttributes: u64 = 2;

    /// Domain for storing NFT string attributes
    ///
    /// Changes are replicated to `ComposableUrl` domain as URL parameters.
    struct AttributesDomain has store, drop {
        /// Map of attributes
        map: VecMap<String, String>,
    }

    /// Creates new `AttributesDomain`
    ///
    /// Need to ensure that `UrlDomain` is updated with attributes if they
    /// exist therefore function cannot be public.
    public fun new(map: VecMap<String, String>): AttributesDomain {
        AttributesDomain { map }
    }

    /// Creates empty `AttributesDomain`
    ///
    /// Need to ensure that `UrlDomain` is updated with attributes if they
    /// exist therefore function cannot be public.
    public fun empty(): AttributesDomain {
        AttributesDomain { map: vec_map::empty() }
    }

    /// Creates new `AttributesDomain` from vectors of keys and values
    ///
    /// Need to ensure that `UrlDomain` is updated with attributes if they
    /// exist therefore function cannot be public.
    ///
    /// #### Panics
    ///
    /// Panics if keys and values vectors have different lengths
    public fun from_vec(
        keys: vector<String>,
        values: vector<String>,
    ): AttributesDomain {
        let map = utils::from_vec_to_map<String, String>(keys, values);
        new(map)
    }

    /// Borrows underlying attribute map of `AttributesDomain`
    public fun borrow_attributes(
        domain: &AttributesDomain,
    ): &VecMap<String, String> {
        &domain.map
    }

    /// Mutably borrows underlying attribute map of `AttributesDomain`
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `AttributesDomain`.
    public fun borrow_attributes_mut(
        domain: &mut AttributesDomain,
    ): &mut VecMap<String, String> {
        &mut domain.map
    }

    /// Serializes attributes as URL parameters
    public fun as_url_parameters(domain: &AttributesDomain): vector<u8> {
        let parameters = vector::empty<u8>();

        let attributes = borrow_attributes(domain);
        let size = vec_map::size(attributes);

        // Check if we even expect URL parameters
        if (size > 0) {
            vector::append(&mut parameters, b"?");
        };

        let idx = 0;
        while (idx < size) {
            let (key, value) = vec_map::get_entry_by_idx(attributes, idx);

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

    /// Returns whether `AttributesDomain` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<AttributesDomain>, AttributesDomain>(
            nft, utils::marker(),
        )
    }

    /// Borrows `UrlDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &AttributesDomain {
        assert_attributes(nft);
        df::borrow(nft, utils::marker<AttributesDomain>())
    }

    /// Mutably borrows `UrlDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut AttributesDomain {
        assert_attributes(nft);
        df::borrow_mut(nft, utils::marker<AttributesDomain>())
    }

    /// Adds `AttributesDomain` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `AttributesDomain` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: AttributesDomain,
    ) {
        assert_no_attributes(nft);
        df::add(nft, utils::marker<AttributesDomain>(), domain);
    }

    /// Remove `AttributesDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `AttributesDomain` domain doesnt exist
    public fun remove_domain(nft: &mut UID): AttributesDomain {
        assert_attributes(nft);
        df::remove(nft, utils::marker<AttributesDomain>())
    }

    // === Assertions ===

    /// Asserts that `AttributesDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `AttributesDomain` is not registered
    public fun assert_attributes(nft: &UID) {
        assert!(has_domain(nft), EUndefinedAttributes);
    }

    /// Asserts that `AttributesDomain` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `AttributesDomain` is registered
    public fun assert_no_attributes(nft: &UID) {
        assert!(!has_domain(nft), EExistingAttributes);
    }
}
