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

    use nft_protocol::utils;

    /// `Attributes` was not defined
    ///
    /// Call `attributes::add` to add `Attributes`.
    const EUNDEFINED_ATTRIBUTES_DOMAIN: u64 = 1;

    /// `Attributes` already defined
    ///
    /// Call `attributes::borrow` to borrow domain.
    const EEXISTING_DOMAIN: u64 = 2;

    /// Domain for storing NFT string attributes
    ///
    /// Changes are replicated to `ComposableUrl` domain as URL parameters.
    struct Attributes has store {
        /// Map of attributes
        map: VecMap<String, String>,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    struct AttributesKey has store, copy, drop {}

    /// Creates new `Attributes`
    ///
    /// Need to ensure that `UrlDomain` is updated with attributes if they
    /// exist therefore function cannot be public.
    fun new(map: VecMap<String, String>): Attributes {
        Attributes { map }
    }

    /// Creates empty `Attributes`
    ///
    /// Need to ensure that `UrlDomain` is updated with attributes if they
    /// exist therefore function cannot be public.
    fun empty(): Attributes {
        Attributes { map: vec_map::empty() }
    }

    /// Creates new `Attributes` from vectors of keys and values
    ///
    /// Need to ensure that `UrlDomain` is updated with attributes if they
    /// exist therefore function cannot be public.
    ///
    /// #### Panics
    ///
    /// Panics if keys and values vectors have different lengths
    fun from_vec(
        keys: vector<String>,
        values: vector<String>,
    ): Attributes {
        let map = utils::from_vec_to_map<String, String>(keys, values);
        new(map)
    }

    /// Borrows underlying attribute map of `Attributes`
    public fun borrow_attributes(
        domain: &Attributes,
    ): &VecMap<String, String> {
        &domain.map
    }

    /// Mutably borrows underlying attribute map of `Attributes`
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `Attributes`.
    public fun borrow_attributes_mut(
        domain: &mut Attributes,
    ): &mut VecMap<String, String> {
        &mut domain.map
    }

    public fun has_attributes_df(
        nft_uid: &UID,
    ): bool {
        df::exists_(nft_uid, AttributesKey {})
    }

    /// Borrows underlying attribute map of `Attributes`
    public fun borrow_attributes_df(
        nft_uid: &UID,
    ): &Attributes {
        df::borrow(nft_uid, AttributesKey {})
    }

    /// Mutably borrows underlying attribute map of `Attributes`
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `Attributes`.
    public fun borrow_attributes_df_mut<W: drop>(
        _witness: W,
        nft_uid: &mut UID,
    ): &mut Attributes {
        df::borrow_mut(nft_uid, AttributesKey {})
    }

    /// Serializes attributes as URL parameters
    public fun as_url_parameters(domain: &Attributes): vector<u8> {
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
}
