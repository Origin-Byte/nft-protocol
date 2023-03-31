/// Module of `ComposableUrlDomain`
///
/// `ComposableUrlDomain` does not itself compose NFTs but serves as a display
/// standard provider for and NFT which composes `UrlDomain` with
/// `AttributesDomain`.
module nft_protocol::composable_url {
    use std::ascii;
    use std::vector;

    use sui::url::Url;
    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::url;
    use nft_protocol::attributes;
    use nft_protocol::utils::{Self, Marker};

    /// `ComposableUrlDomain` was not defined
    ///
    /// Call `composable_url::add_domain` or to add `ComposableUrlDomain`.
    const EUndefinedComposableUrl: u64 = 1;

    /// `ComposableUrlDomain` already defined
    ///
    /// Call `composable_url::borrow_domain` to borrow domain.
    const EExistingComposableUrl: u64 = 2;

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
        domain: &mut ComposableUrlDomain,
        url: Url,
    ) {
        domain.url = url;
    }

    /// Regenerates composed URL data
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrlDomain` or `UrlDomain` is not registered
    public fun regenerate(
        nft: &mut UID,
    ) {
        let url_domain = url::borrow_url(url::borrow_domain(nft));
        let url = ascii::into_bytes(sui::url::inner_url(url_domain));

        if (attributes::has_domain(nft)) {
            let attributes_domain = attributes::borrow_domain(nft);
            let parameters = attributes::as_url_parameters(attributes_domain);

            vector::append(&mut url, parameters);
        };
    }

    // === Interoperability ===

    /// Returns whether `ComposableUrlDomain` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<ComposableUrlDomain>, ComposableUrlDomain>(
            nft, utils::marker(),
        )
    }

    /// Borrows `ComposableUrlDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrlDomain` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &ComposableUrlDomain {
        assert_composable_url(nft);
        df::borrow(nft, utils::marker<ComposableUrlDomain>())
    }

    /// Mutably borrows `ComposableUrlDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrlDomain` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut ComposableUrlDomain {
        assert_composable_url(nft);
        df::borrow_mut(nft, utils::marker<ComposableUrlDomain>())
    }

    /// Adds `ComposableUrlDomain` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrlDomain` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: ComposableUrlDomain,
    ) {
        assert_no_composable_url(nft);
        df::add(nft, utils::marker<ComposableUrlDomain>(), domain);
    }

    /// Remove `ComposableUrlDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrlDomain` domain doesnt exist
    public fun remove_domain(nft: &mut UID): ComposableUrlDomain {
        assert_composable_url(nft);
        df::remove(nft, utils::marker<ComposableUrlDomain>())
    }

    // === Assertions ===

    /// Asserts that `ComposableUrlDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrlDomain` is not registered
    public fun assert_composable_url(nft: &UID) {
        assert!(has_domain(nft), EUndefinedComposableUrl);
    }

    /// Asserts that `ComposableUrlDomain` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrlDomain` is registered
    public fun assert_no_composable_url(nft: &UID) {
        assert!(!has_domain(nft), EExistingComposableUrl);
    }
}
