/// Module of the `UrlDomain`
///
/// Used to associate a URL with `Collection` or `Nft`.add
///
/// Interoperability functions are delegated to the `display_ext` module.
module nft_protocol::url {
    use sui::url::Url;
    use sui::object::UID;
    use sui::dynamic_field as df;

    use witness::marker::{Self, Marker};

    /// `UrlDomain` was not defined
    ///
    /// Call `url::add_domain` to add `UrlDomain`.
    const EUndefinedUrl: u64 = 1;

    /// `UrlDomain` already defined
    ///
    /// Call `url::borrow_domain` to borrow domain.
    const EExistingUrl: u64 = 2;

    // === Interoperability ===

    /// Returns whether `Url` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<Url>, Url>(
            nft, marker::marker(),
        )
    }

    /// Borrows `Url` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Url` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &Url {
        assert_url(nft);
        df::borrow(nft, marker::marker<Url>())
    }

    /// Mutably borrows `Url` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Url` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut Url {
        assert_url(nft);
        df::borrow_mut(nft, marker::marker<Url>())
    }

    /// Adds `Url` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Url` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: Url,
    ) {
        assert_no_url(nft);
        df::add(nft, marker::marker<Url>(), domain);
    }

    /// Remove `Url` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Url` domain doesnt exist
    public fun remove_domain(nft: &mut UID): Url {
        assert_url(nft);
        df::remove(nft, marker::marker<Url>())
    }

    // === Assertions ===

    /// Asserts that `Url` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Url` is not registered
    public fun assert_url(nft: &UID) {
        assert!(has_domain(nft), EUndefinedUrl);
    }

    /// Asserts that `Url` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Url` is registered
    public fun assert_no_url(nft: &UID) {
        assert!(!has_domain(nft), EExistingUrl);
    }
}
