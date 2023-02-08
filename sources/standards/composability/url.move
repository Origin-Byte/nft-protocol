/// Module of `ComposableUrlDomain` domain
///
/// `ComposableUrlDomain` composes the base `UrlDomain` and `AttributesDomain` by
/// composing attributes as GET parameters.
///
/// `composable_url_ext` defines interoperability functions to avoid dependency cycles
module nft_protocol::composable_url {
    use std::vector;
    use std::ascii::{Self, String};

    use sui::url::{Self, Url};
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use nft_protocol::nft::{Self, Nft};

    friend nft_protocol::composable_url_ext;
    friend nft_protocol::url;
    friend nft_protocol::attributes;

    /// `UrlDomain` was not defined
    ///
    /// Call `url::add_url` or `url::add_collection_url` to add `UrlDomain`.
    const EUNDEFINED_COMPOSABLE_URL_DOMAIN: u64 = 1;

    /// Domain for storing an associated URL
    ///
    /// Changes are replicated to `ComposableUrlDomain` when `UrlDomain` or
    /// `AttributesDomain` are updated.
    ///
    /// `ComposableUrlDomain` must be instantiated by `url` module.
    struct ComposableUrlDomain has key, store {
        id: UID,
        url: Url,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates new `UrlDomain` with a URL
    public(friend) fun new(url: Url, ctx: &mut TxContext): ComposableUrlDomain {
        ComposableUrlDomain { id: object::new(ctx), url }
    }

    /// Get URL from `ComposableUrlDomain`
    public fun borrow_url(domain: &ComposableUrlDomain): &Url {
        &domain.url
    }

    /// Checks whether last element is query string marker `?` (63)
    ///
    /// #### Panics
    ///
    /// Panics if vector is empty
    fun has_last_parameter_separator(url: &vector<u8>): bool {
        let size = vector::length(url);
        *vector::borrow(url, size - 1) == 63
    }

    /// Sets base URL of `ComposableUrlDomain`
    ///
    /// This will retain all parameters after the last occurence of `?`.
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` does not exist on `Nft`
    public(friend) fun update_url<C>(
        nft: &mut Nft<C>,
        url: &Url,
    ) {
        let composable_url = ascii::into_bytes(url::inner_url(borrow(nft)));

        // Retain parameters
        let parameters = vector::empty();
        while (
            !vector::is_empty(&composable_url) &&
                !has_last_parameter_separator(&composable_url)
        ) {
            vector::push_back(&mut parameters, vector::pop_back(&mut composable_url))
        };
        vector::reverse(&mut parameters);

        // Build new URL
        let url = ascii::into_bytes(url::inner_url(url));
        vector::append(&mut url, b"?");
        vector::append(&mut url, parameters);

        *borrow_mut(nft) = url::new_unsafe_from_bytes(url);
    }

    /// Sets URL parameters of `ComposableUrlDomain`
    ///
    /// This will retain the base URL before the last occurence of `?`.
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` does not exist on `Nft`
    public(friend) fun update_parameters<C>(
        nft: &mut Nft<C>,
        parameters: String,
    ) {
        let composable_url = ascii::into_bytes(url::inner_url(borrow(nft)));

        // Retain base URL
        while (
            !vector::is_empty(&composable_url) &&
                !has_last_parameter_separator(&composable_url)
        ) {
            vector::pop_back(&mut composable_url);
        };

        // Remove remaining `?` if one exists
        if (!vector::is_empty(&composable_url)) {
            vector::pop_back(&mut composable_url);
        };

        // Build new URL
        vector::append(&mut composable_url, ascii::into_bytes(parameters));

        *borrow_mut(nft) = url::new_unsafe_from_bytes(composable_url);
    }

    /// Composes URL `ComposableUrlDomain` by combining a base URL and
    /// parameters
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` does not exist on `Nft`
    public(friend) fun set_url<C>(
        nft: &mut Nft<C>,
        base: &Url,
        parameters: String,
    ) {
        let base = ascii::into_bytes(url::inner_url(base));

        let parameters = ascii::into_bytes(parameters);
        vector::append(&mut base, parameters);

        *borrow_mut(nft) = url::new_unsafe_from_bytes(base);
    }

    // === Interoperability ===

    /// Returns whether `ComposableUrlDomain` is registered on `Nft`
    public fun has<C>(nft: &Nft<C>): bool {
        nft::has_domain<C, ComposableUrlDomain>(nft)
    }

    /// Borrows `ComposableUrlDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrlDomain` is not registered on the `Nft`
    public fun borrow<C>(nft: &Nft<C>): &Url {
        assert_url(nft);
        let domain: &ComposableUrlDomain = nft::borrow_domain(nft);
        &domain.url
    }

    /// Mutably borrows `ComposableUrlDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrlDomain` is not registered on the `Nft`
    fun borrow_mut<C>(nft: &mut Nft<C>): &mut Url {
        assert_url(nft);
        let domain: &mut ComposableUrlDomain =
            nft::borrow_domain_mut(Witness {}, nft);
        &mut domain.url
    }

    // === Assertions

    /// Asserts that `UrlDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered
    public fun assert_url<C>(nft: &Nft<C>) {
        assert!(has(nft), EUNDEFINED_COMPOSABLE_URL_DOMAIN);
    }
}