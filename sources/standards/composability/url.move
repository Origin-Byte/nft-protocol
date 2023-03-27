/// Module of `ComposableUrl`
///
/// `ComposableUrl` does not itself compose NFTs but serves as a display
/// standard provider for and NFT which composes `UrlDomain` with
/// `AttributesDomain`.
module nft_protocol::composable_url {
    use std::ascii;
    use std::vector;

    use sui::url::{Self, Url};
    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::utils::{Self, UidType};
    use nft_protocol::witness;
    use nft_protocol::attributes;
    use nft_protocol::witness::Witness as DelegatedWitness;

    /// `ComposableUrl` was not defined
    ///
    /// Call `composable_url::add_domain` or to add `ComposableUrl`.
    const EUNDEFINED_URL_DOMAIN: u64 = 1;

    /// `ComposableUrl` already defined
    ///
    /// Call `composable_url::borrow_domain` to borrow domain.
    const EEXISTING_URL_DOMAIN: u64 = 2;

    /// Domain for providing composed URL data
    struct ComposableUrl has store {
        /// Composed URL
        url: Url,
    }

    struct ComposableUrlKey has store, copy, drop {}

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates new `ComposableUrl` with no predefined NFTs
    public fun new(): ComposableUrl {
        ComposableUrl {
            url: sui::url::new_unsafe_from_bytes(b""),
        }
    }

    /// Sets URL of `ComposableUrl`
    ///
    /// Also sets static `url` field on `Nft`.
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrl` does not exist on `Nft`
    public fun set_url<C, T: key + store>(
        witness: DelegatedWitness<C>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        url: Url,
    ) {
        utils::assert_same_module<C, T>();
        utils::assert_uid_type(nft_uid, &nft_type);

        let composable_url = df::borrow_mut<ComposableUrlKey, ComposableUrl>(
            nft_uid,
            ComposableUrlKey {}
        );

        composable_url.url = url;
    }

    /// Regenerates composed URL data
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrl` or `UrlDomain` is not registered
    public fun regenerate<C, T: key + store>(
        // TODO: Remove delegated witness by removing static fields from `Nft`
        witness: DelegatedWitness<C>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
    ) {
        let composable_url = df::borrow_mut<ComposableUrlKey, ComposableUrl>(nft_uid, ComposableUrlKey {});
        let url = ascii::into_bytes(url::inner_url(&composable_url.url));

        if (attributes::has_attributes_df(nft_uid)) {
            let attributes = attributes::borrow_attributes_df(nft_uid);
            let parameters = attributes::as_url_parameters(attributes);

            vector::append(&mut url, parameters);
        };

        // Set `Nft.url` to composed URL
        composable_url.url = sui::url::new_unsafe_from_bytes(url);
    }

    // === Interoperability ===

    /// Returns whether `ComposableUrl` is registered on `Nft`
    public fun has_composable_url(nft_uid: &UID): bool {
        df::exists_(nft_uid, ComposableUrlKey {})
    }

    /// Borrows composed URL data from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrl` is not registered on the `Nft`
    public fun borrow_composable_url(nft_uid: &UID): &Url {
        assert_composable_url(nft_uid);

        let comp_url = df::borrow<ComposableUrlKey, ComposableUrl>(nft_uid, ComposableUrlKey {});
        &comp_url.url
    }

    /// Mutably borrows URL data from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` is not registered on the `Nft`
    fun borrow_composable_url_mut<C>(nft_uid: &mut UID): &mut Url {
        assert_composable_url(nft_uid);

        let comp_url = df::borrow_mut<ComposableUrlKey, ComposableUrl>(nft_uid, ComposableUrlKey {});
        &mut comp_url.url
    }

    /// Adds `UrlDomain` to `Nft`
    ///
    /// `ComposableUrl` will not be automatically updated so
    /// `composable_url::register` and `composable_url::regenerate` must be
    /// called.
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` domain already exists
    public fun add_composable_url<W, T: key + store>(
        // TODO: Do we use W witness of C? We need to use W, because C you can't
        // produce an instance
        witness: &W,
        nft_uid: &mut UID,
        nft_type: &mut UidType<T>,
    ) {
        add_composable_url_delegated<W, T>(witness::from_witness(witness), nft_uid, nft_type);
    }

    /// Adds `UrlDomain` to `Nft`
    ///
    /// `ComposableUrl` will not be automatically updated so
    /// `composable_url::register` and `composable_url::regenerate` must be
    /// called.
    ///
    /// #### Panics
    ///
    /// Panics if `UrlDomain` domain already exists
    public fun add_composable_url_delegated<W, T: key + store>(
        _witness: DelegatedWitness<W>,
        nft_uid: &mut UID,
        nft_type: &mut UidType<T>,
    ) {
        utils::assert_same_module<W, T>();
        utils::assert_uid_type<T>(nft_uid, nft_type);

        assert!(!has_composable_url(nft_uid), EEXISTING_URL_DOMAIN);
        df::add(nft_uid, ComposableUrlKey {}, new());
    }

    // === Assertions ===

    /// Asserts that `ComposableUrl` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrl` is not registered
    public fun assert_composable_url(nft_uid: &UID) {
        assert!(has_composable_url(nft_uid), EUNDEFINED_URL_DOMAIN);
    }
}
