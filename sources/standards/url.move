/// Module of the `UrlDomain`
///
/// Used to associate a URL with `Collection` or `Nft`.add
///
/// Interoperability functions are delegated to the `display_ext` module.
module nft_protocol::url {
    use sui::url::Url;
    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::utils::{Self, Marker};

    /// `UrlDomain` was not defined
    ///
    /// Call `url::add_domain` to add `UrlDomain`.
    const EUndefinedUrl: u64 = 1;

    /// `UrlDomain` already defined
    ///
    /// Call `url::borrow_domain` to borrow domain.
    const EExistingUrl: u64 = 2;

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

    /// Borrow URL of `UrlDomain`
    public fun borrow_url(domain: &UrlDomain): &Url {
        &domain.url
    }

    /// Mutably borrow URL of `UrlDomain`
    public fun borrow_url_mut(domain: &mut UrlDomain): &mut Url {
        &mut domain.url
    }

    /// Sets URL of `UrlDomain`
    ///
    /// Need to ensure that `UrlDomain` is updated with attributes if they
    /// exist therefore function cannot be public.
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` does not exist on `Nft`
    public fun set_url(
        domain: &mut UrlDomain,
        url: Url,
    ) {
        domain.url = url;
    }

    // === Interoperability ===

    /// Returns whether `UrlDomain` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<UrlDomain>, UrlDomain>(
            nft, utils::marker(),
        )
    }

    /// Borrows `UrlDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &UrlDomain {
        assert_url(nft);
        df::borrow(nft, utils::marker<UrlDomain>())
    }

    /// Mutably borrows `UrlDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut UrlDomain {
        assert_url(nft);
        df::borrow_mut(nft, utils::marker<UrlDomain>())
    }

    /// Adds `UrlDomain` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: UrlDomain,
    ) {
        assert_no_url(nft);
        df::add(nft, utils::marker<UrlDomain>(), domain);
    }

    /// Remove `UrlDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` domain doesnt exist
    public fun remove_domain(nft: &mut UID): UrlDomain {
        assert_url(nft);
        df::remove(nft, utils::marker<UrlDomain>())
    }

    // === Assertions ===

    /// Asserts that `UrlDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered
    public fun assert_url(nft: &UID) {
        assert!(has_domain(nft), EUndefinedUrl);
    }

    /// Asserts that `UrlDomain` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is registered
    public fun assert_no_url(nft: &UID) {
        assert!(!has_domain(nft), EExistingUrl);
    }
}
