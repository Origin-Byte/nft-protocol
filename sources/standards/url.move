/// Module of the `AttributesDomain`
///
/// Used to associate a URL with `Collection` or `Nft`
module nft_protocol::url {
    use sui::url::Url;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::witness::Witness as DelegatedWitness;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::composable_url;

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
    struct UrlDomain has key, store {
        id: UID,
        url: Url,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates new `UrlDomain` with a URL
    public fun new(url: Url, ctx: &mut TxContext): UrlDomain {
        UrlDomain { id: object::new(ctx), url }
    }

    /// Sets URL of `UrlDomain`
    ///
    /// Changes are replicated to `ComposableUrl` domain as URL base for NFTs.
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` does not exist on `Nft`
    public fun set_url<C>(
        _witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
        url: Url,
    ) {
        let domain_url = borrow_mut(nft);
        *domain_url = url;

        if (composable_url::has(nft)) {
            composable_url::update_url(nft, &url);
        }
    }

    /// Sets URL of `UrlDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` does not exist on `Collection`
    public fun set_collection_url<C>(
        _witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        url: Url,
    ) {
        let domain_url = borrow_collection_mut(collection);
        *domain_url = url;
    }

    // === Interoperability ===

    /// Returns whether `UrlDomain` is registered on `Nft`
    public fun has<C>(nft: &Nft<C>): bool {
        nft::has_domain<C, UrlDomain>(nft)
    }

    /// Returns whether `UrlDomain` is registered on `Collection`
    public fun has_collection<C>(collection: &Collection<C>): bool {
        collection::has_domain<C, UrlDomain>(collection)
    }

    /// Borrows `UrlDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered on the `Nft`
    public fun borrow<C>(nft: &Nft<C>): &Url {
        assert_url(nft);
        let domain: &UrlDomain = nft::borrow_domain(nft);
        &domain.url
    }

    /// Mutably borrows `UrlDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered on the `Nft`
    fun borrow_mut<C>(nft: &mut Nft<C>): &mut Url {
        assert_url(nft);
        let domain: &mut UrlDomain = nft::borrow_domain_mut(Witness {}, nft);
        &mut domain.url
    }

    /// Borrows `UrlDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered on the `Collection`
    public fun borrow_collection<C>(collection: &Collection<C>): &Url {
        assert_collection_url(collection);
        let domain: &UrlDomain = collection::borrow_domain(collection);
        &domain.url
    }

    /// Mutably borrows `UrlDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered on the `Collection`
    fun borrow_collection_mut<C>(
        collection: &mut Collection<C>,
    ): &mut Url {
        assert_collection_url(collection);
        let domain: &mut UrlDomain =
            collection::borrow_domain_mut(Witness {}, collection);
        &mut domain.url
    }

    /// Adds `UrlDomain` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` domain already exists
    public fun add<C>(
        witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
        url: Url,
        ctx: &mut TxContext,
    ) {
        assert!(!has(nft), EEXISTING_DOMAIN);
        nft::add_domain(witness, nft, new(url, ctx));
    }

    /// Adds `UrlDomain` to `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` domain already exists
    public fun add_collection<C>(
        witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        url: Url,
        ctx: &mut TxContext,
    ) {
        assert!(!has_collection(collection), EEXISTING_DOMAIN);
        collection::add_domain(witness, collection, new(url, ctx));
    }

    // === Assertions ===

    /// Asserts that `UrlDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered
    public fun assert_url<C>(nft: &Nft<C>) {
        assert!(has(nft), EUNDEFINED_URL_DOMAIN);
    }

    /// Asserts that `UrlDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered
    public fun assert_collection_url<C>(collection: &Collection<C>) {
        assert!(has_collection(collection), EUNDEFINED_URL_DOMAIN);
    }
}