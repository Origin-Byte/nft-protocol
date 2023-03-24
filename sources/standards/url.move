/// Module of the `UrlDomain`
///
/// Used to associate a URL with `Collection` or `Nft`.add
///
/// Interoperability functions are delegated to the `display_ext` module.
module nft_protocol::url {
    use sui::url::Url;

    use nft_protocol::witness::{Self, Witness as DelegatedWitness};
    use nft_protocol::collection::{Self, Collection};

    /// `UrlDomain` was not defined
    ///
    /// Call `url::add` or `url::add_collection` to add `UrlDomain`.
    const EUNDEFINED_URL_DOMAIN: u64 = 1;

    /// `UrlDomain` already defined
    ///
    /// Call `url::borrow` or url::borrow_collection` to borrow domain.
    const EEXISTING_DOMAIN: u64 = 2;

    /// Domain for storing an associated URL
    ///
    /// Changes are replicated to `ComposableUrl` domain as URL base for NFTs.
    struct UrlDomain has store {
        url: Url,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates new `UrlDomain` with a URL
    public fun new(url: Url): UrlDomain {
        UrlDomain { url }
    }

    /// Sets URL of `UrlDomain`
    ///
    /// Need to ensure that `UrlDomain` is updated with attributes if they
    /// exist therefore function cannot be public.
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` does not exist on `Nft`
    public fun set_url<C>(
        witness: DelegatedWitness<Nft<C>>,
        nft: &mut Nft<C>,
        url: Url,
    ) {
        let domain_url = borrow_url_mut(nft);
        *domain_url = url;

        nft::set_url(witness, nft, url);
    }

    /// Sets URL of `UrlDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` does not exist on `Collection`
    public fun set_collection_url<T>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        url: Url,
    ) {
        let domain_url = borrow_collection_url_mut(collection);
        *domain_url = url;
    }

    // === Interoperability ===

    /// Returns whether `UrlDomain` is registered on `Nft`
    public fun has_url<C>(nft: &Nft<C>): bool {
        nft::has_domain<C, UrlDomain>(nft)
    }

    /// Returns whether `UrlDomain` is registered on `Collection`
    public fun has_collection_url<T>(collection: &Collection<T>): bool {
        collection::has_domain<T, UrlDomain>(collection)
    }

    /// Borrows `UrlDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered on the `Nft`
    public fun borrow_url<C>(nft: &Nft<C>): &Url {
        assert_url(nft);
        let domain: &UrlDomain = nft::borrow_domain(nft);
        &domain.url
    }

    /// Mutably borrows `UrlDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered on the `Nft`
    fun borrow_url_mut<C>(nft: &mut Nft<C>): &mut Url {
        assert_url(nft);
        let domain: &mut UrlDomain = nft::borrow_domain_mut(Witness {}, nft);
        &mut domain.url
    }

    /// Borrows `UrlDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered on the `Collection`
    public fun borrow_collection_url<T>(collection: &Collection<T>): &Url {
        assert_collection_url(collection);
        let domain: &UrlDomain = collection::borrow_domain(collection);
        &domain.url
    }

    /// Mutably borrows `UrlDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered on the `Collection`
    fun borrow_collection_url_mut<T>(
        collection: &mut Collection<T>,
    ): &mut Url {
        assert_collection_url(collection);
        let domain: &mut UrlDomain =
            collection::borrow_domain_mut(Witness {}, collection);
        &mut domain.url
    }

    /// Adds `UrlDomain` to `Nft`
    ///
    /// Need to ensure that `UrlDomain` is updated with attributes if they
    /// exist therefore function cannot be public.
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` domain already exists
    public fun add_url_domain<C, W>(
        witness: &W,
        nft: &mut Nft<C>,
        url: Url,
    ) {
        add_url_domain_delegated(witness::from_witness(witness), nft, url)
    }

    /// Adds `UrlDomain` to `Nft`
    ///
    /// Need to ensure that `UrlDomain` is updated with attributes if they
    /// exist therefore function cannot be public.
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` domain already exists
    public fun add_url_domain_delegated<C>(
        witness: DelegatedWitness<Nft<C>>,
        nft: &mut Nft<C>,
        url: Url,
    ) {
        assert!(!has_url(nft), EEXISTING_DOMAIN);
        nft::add_domain_delegated(witness, nft, new(url));
    }

    /// Adds `UrlDomain` to `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` domain already exists
    public fun add_collection_url_domain<T, W>(
        witness: &W,
        collection: &mut Collection<T>,
        url: Url,
    ) {
        add_collection_url_domain_delegated(
            witness::from_witness(witness), collection, url,
        )
    }

    /// Adds `UrlDomain` to `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` domain already exists
    public fun add_collection_url_domain_delegated<T>(
        witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        url: Url,
    ) {
        assert!(!has_collection_url(collection), EEXISTING_DOMAIN);
        collection::add_domain_delegated(witness, collection, new(url));
    }

    // === Assertions ===

    /// Asserts that `UrlDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered
    public fun assert_url<C>(nft: &Nft<C>) {
        assert!(has_url(nft), EUNDEFINED_URL_DOMAIN);
    }

    /// Asserts that `UrlDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered
    public fun assert_collection_url<T>(collection: &Collection<T>) {
        assert!(has_collection_url(collection), EUNDEFINED_URL_DOMAIN);
    }
}
