/// Module of `ComposableUrlDomain`
///
/// `ComposableUrlDomain` does not itself compose NFTs but serves as a display
/// standard provider for and NFT which composes `UrlDomain` with
/// `AttributesDomain`.
module nft_protocol::composable_url {
    use std::ascii;
    use std::vector;

    use sui::url::Url;

    use nft_protocol::url;
    use nft_protocol::witness;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::attributes;
    use nft_protocol::witness::Witness as DelegatedWitness;

    /// `ComposableUrlDomain` was not defined
    ///
    /// Call `composable_url::add_domain` or to add `ComposableUrlDomain`.
    const EUNDEFINED_URL_DOMAIN: u64 = 1;

    /// `ComposableUrlDomain` already defined
    ///
    /// Call `composable_url::borrow_domain` to borrow domain.
    const EEXISTING_URL_DOMAIN: u64 = 2;

    /// Domain for providing composed URL data
    struct ComposableUrlDomain has store {
        /// Composed URL
        url: Url,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates new `ComposableUrlDomain` with no predefined NFTs
    public fun new(): ComposableUrlDomain {
        ComposableUrlDomain {
            url: sui::url::new_unsafe_from_bytes(b""),
        }
    }

    /// Sets URL of `ComposableUrlDomain`
    ///
    /// Also sets static `url` field on `Nft`.
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrlDomain` does not exist on `Nft`
    public fun set_url<C>(
        witness: DelegatedWitness<Nft<C>>,
        nft: &mut Nft<C>,
        url: Url,
    ) {
        let domain_url = borrow_composable_url_mut(nft);
        *domain_url = url;

        url::set_url(witness, nft, url);
    }

    /// Regenerates composed URL data
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrlDomain` or `UrlDomain` is not registered
    public fun regenerate<C>(
        // TODO: Remove delegated witness by removing static fields from `Nft`
        witness: DelegatedWitness<Nft<C>>,
        nft: &mut Nft<C>,
    ) {
        let url = ascii::into_bytes(sui::url::inner_url(url::borrow_url(nft)));

        if (attributes::has_domain(nft)) {
            let attributes_domain = attributes::borrow_domain(nft);
            let parameters = attributes::as_url_parameters(attributes_domain);

            vector::append(&mut url, parameters);
        };

        // Set `Nft.url` to composed URL
        set_url(witness, nft, sui::url::new_unsafe_from_bytes(url));
    }

    // === Interoperability ===

    /// Returns whether `ComposableUrlDomain` is registered on `Nft`
    public fun has_composable_url<C>(nft: &Nft<C>): bool {
        nft::has_domain<C, ComposableUrlDomain>(nft)
    }

    /// Borrows composed URL data from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrlDomain` is not registered on the `Nft`
    public fun borrow_composable_url<C>(nft: &Nft<C>): &Url {
        assert_composable_url(nft);
        let domain: &ComposableUrlDomain = nft::borrow_domain(nft);
        &domain.url
    }

    /// Mutably borrows URL data from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered on the `Nft`
    fun borrow_composable_url_mut<C>(nft: &mut Nft<C>): &mut Url {
        assert_composable_url(nft);
        let domain: &mut ComposableUrlDomain =
            nft::borrow_domain_mut(Witness {}, nft);
        &mut domain.url
    }

    /// Adds `UrlDomain` to `Nft`
    ///
    /// `ComposableUrlDomain` will not be automatically updated so
    /// `composable_url::register` and `composable_url::regenerate` must be
    /// called.
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` domain already exists
    public fun add_composable_url<C, W>(
        witness: &W,
        nft: &mut Nft<C>,
    ) {
        add_composable_url_delegated(witness::from_witness(witness), nft);
    }

    /// Adds `UrlDomain` to `Nft`
    ///
    /// `ComposableUrlDomain` will not be automatically updated so
    /// `composable_url::register` and `composable_url::regenerate` must be
    /// called.
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` domain already exists
    public fun add_composable_url_delegated<C>(
        _witness: DelegatedWitness<Nft<C>>,
        nft: &mut Nft<C>,
    ) {
        assert!(!has_composable_url(nft), EEXISTING_URL_DOMAIN);
        nft::add_domain(&Witness {}, nft, new());
    }

    // === Assertions ===

    /// Asserts that `ComposableUrlDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrlDomain` is not registered
    public fun assert_composable_url<C>(nft: &Nft<C>) {
        assert!(has_composable_url(nft), EUNDEFINED_URL_DOMAIN);
    }
}
