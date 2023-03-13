/// Module of the `AttributesDomain`
///
/// Used to register string attributes on NFTs.
///
/// Interoperability functions are delegated to the `display_ext` module.
module nft_protocol::attributes {
    use std::vector;
    use std::ascii::{Self, String};

    use sui::vec_map::{Self, VecMap};

    use nft_protocol::utils;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::witness::{Self, Witness as DelegatedWitness};

    /// `AttributesDomain` was not defined
    ///
    /// Call `attributes::add` to add `AttributesDomain`.
    const EUNDEFINED_ATTRIBUTES_DOMAIN: u64 = 1;

    /// `AttributesDomain` already defined
    ///
    /// Call `attributes::borrow` to borrow domain.
    const EEXISTING_DOMAIN: u64 = 2;

    /// Domain for storing NFT string attributes
    ///
    /// Changes are replicated to `ComposableUrl` domain as URL parameters.
    struct AttributesDomain has store {
        /// Map of attributes
        map: VecMap<String, String>,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates new `AttributesDomain`
    ///
    /// Need to ensure that `UrlDomain` is updated with attributes if they
    /// exist therefore function cannot be public.
    fun new(map: VecMap<String, String>): AttributesDomain {
        AttributesDomain { map }
    }

    /// Creates empty `AttributesDomain`
    ///
    /// Need to ensure that `UrlDomain` is updated with attributes if they
    /// exist therefore function cannot be public.
    fun empty(): AttributesDomain {
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
    fun from_vec(
        keys: vector<String>,
        values: vector<String>,
    ): AttributesDomain {
        let map = utils::from_vec_to_map<String, String>(keys, values);
        new(map)
    }

    /// Returns value map of attributes
    public fun attributes(domain: &AttributesDomain): &VecMap<String, String> {
        &domain.map
    }

    /// Gets keys of attributes
    public fun keys(domain: &AttributesDomain): vector<String> {
        let (keys, _) = vec_map::into_keys_values(domain.map);
        keys
    }

    /// Gets values of attributes
    public fun values(domain: &AttributesDomain): vector<String> {
        let (_, values) = vec_map::into_keys_values(domain.map);
        values
    }

    /// Serializes attributes as URL parameters
    public fun as_url_parameters(domain: &AttributesDomain): vector<u8> {
        let parameters = vector::empty<u8>();

        let attributes = attributes(domain);
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
    public fun has_domain<C>(nft: &Nft<C>): bool {
        nft::has_domain<C, AttributesDomain>(nft)
    }

    /// Borrows `UrlDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered on the `Nft`
    public fun borrow_domain<C>(nft: &Nft<C>): &AttributesDomain {
        assert_attributes(nft);
        nft::borrow_domain<C, AttributesDomain>(nft)
    }

    /// Mutably borrows `UrlDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered on the `Nft`
    fun borrow_domain_mut<C>(nft: &mut Nft<C>): &mut AttributesDomain {
        assert_attributes(nft);
        nft::borrow_domain_mut(Witness {}, nft)
    }

    /// Adds `AttributesDomain` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `AttributesDomain` domain already exists
    public fun add_domain<C, W>(
        witness: &W,
        nft: &mut Nft<C>,
        map: VecMap<String, String>,
    ) {
        add_domain_delegated(witness::from_witness(witness), nft, map)
    }

    /// Adds `AttributesDomain` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `AttributesDomain` domain already exists
    public fun add_domain_delegated<C>(
        witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
        map: VecMap<String, String>,
    ) {
        assert!(!has_domain(nft), EEXISTING_DOMAIN);
        nft::add_domain_delegated(witness, nft, new(map));
    }

    /// Adds `AttributesDomain` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `AttributesDomain` domain already exists
    public fun add_empty_domain<C, W>(
        witness: &W,
        nft: &mut Nft<C>,
    ) {
        add_empty_domain_delegated(witness::from_witness(witness), nft)
    }

    /// Adds `AttributesDomain` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `AttributesDomain` domain already exists
    public fun add_empty_domain_delegated<C>(
        witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
    ) {
        assert!(!has_domain(nft), EEXISTING_DOMAIN);
        nft::add_domain_delegated(witness, nft, empty());
    }

    /// Adds `AttributesDomain` to `Nft` from vector of keys and values
    ///
    /// #### Panics
    ///
    /// Panics if `AttributesDomain` domain already exists or keys and values
    /// vectors have different lengths
    public fun add_domain_from_vec<C, W>(
        witness: &W,
        nft: &mut Nft<C>,
        keys: vector<String>,
        values: vector<String>,
    ) {
        add_domain_from_vec_delegated(
            witness::from_witness(witness), nft, keys, values,
        )
    }

    /// Adds `AttributesDomain` to `Nft` from vector of keys and values
    ///
    /// #### Panics
    ///
    /// Panics if `AttributesDomain` domain already exists or keys and values
    /// vectors have different lengths
    public fun add_domain_from_vec_delegated<C>(
        witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
        keys: vector<String>,
        values: vector<String>,
    ) {
        assert!(!has_domain(nft), EEXISTING_DOMAIN);
        nft::add_domain_delegated(witness, nft, from_vec(keys, values));
    }

    // === Assertions ===

    /// Asserts that `AttributesDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `AttributesDomain` is not registered
    public fun assert_attributes<C>(nft: &Nft<C>) {
        assert!(has_domain(nft), EUNDEFINED_ATTRIBUTES_DOMAIN);
    }
}
