/// Module of `ComposableUrlDomain`
///
/// `ComposableUrlDomain` does not itself compose NFTs but serves as a display
/// standard provider for NFTs which register `UrlDomain` and
/// `AttribtuesDomain` and are composed within `NftBagDomain`.
module nft_protocol::composable_url {
    use std::ascii;
    use std::vector;

    use sui::object::ID;
    use sui::url::Url;

    use nft_protocol::url;
    use nft_protocol::svg;
    use nft_protocol::nft_bag;
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

    /// `ComposableUrlDomain` did not compose NFT with given ID
    ///
    /// Call `composable_url::deregister` with an NFT ID that exists.
    const EUNDEFINED_NFT: u64 = 3;

    /// Domain for providing composed URL data
    struct ComposableUrlDomain has store {
        /// NFTs which are being composed
        nfts: vector<ID>,
        /// Composed URL
        url: Url,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates new `ComposableUrlDomain` with no predefined NFTs
    public fun new(): ComposableUrlDomain {
        ComposableUrlDomain {
            nfts: vector::empty(),
            url: sui::url::new_unsafe_from_bytes(b""),
        }
    }

    /// Borrows root tag attributes from `ComposableUrlDomain`
    public fun borrow_url(domain: &ComposableUrlDomain): &Url {
        &domain.url
    }

    /// Borrows registered NFTs from `ComposableUrlDomain`
    public fun borrow_nfts(domain: &ComposableUrlDomain): &vector<ID> {
        &domain.nfts
    }

    /// Sets URL of `ComposableUrlDomain`
    ///
    /// Also sets static `url` field on `Nft`.
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrlDomain` does not exist on `Nft`
    public fun set_url<C>(
        witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
        url: Url,
    ) {
        let domain = borrow_domain_mut(nft);
        domain.url = url;

        url::set_url(witness, nft, url);
    }

    /// Registers NFT whose SVG data should be composed within the final
    /// composed SVG
    ///
    /// `ComposableUrlDomain` will not be automatically updated so
    /// `composable_url::regenerate` must be called.
    ///
    /// #### Panics
    ///
    /// - `ComposableUrlDomain` doesn't exist
    /// - `NftBagDomain` doesn't exist
    /// - NFT was of a different collection type
    /// - NFT wasn't composed
    public fun register<C>(
        _witness: DelegatedWitness<C>,
        parent_nft: &mut Nft<C>,
        child_nft_id: ID,
    ) {
        let nft_bag_domain = nft_bag::borrow_domain_mut(parent_nft);

        // Assert that child NFT exists and it has `SvgDomain`
        let child_nft = nft_bag::borrow<C>(nft_bag_domain, child_nft_id);
        svg::assert_svg(child_nft);

        let domain = borrow_domain_mut(parent_nft);
        vector::push_back(&mut domain.nfts, child_nft_id);
    }

    /// Deregisters NFT whose SVG data is being composed within
    /// `ComposableUrlDomain`
    ///
    /// `ComposableUrlDomain` will not be automatically updated so
    /// `composable_url::regenerate` must be called.
    ///
    /// #### Panics
    ///
    /// - `ComposableUrlDomain` doesn't exist
    /// - NFT wasn't composed
    public fun deregister<C>(
        _witness: DelegatedWitness<C>,
        parent_nft: &mut Nft<C>,
        child_nft_id: ID,
    ) {
        let domain = borrow_domain_mut(parent_nft);

        let (has_entry, idx) = vector::index_of(&domain.nfts, &child_nft_id);
        assert!(has_entry, EUNDEFINED_NFT);

        vector::remove(&mut domain.nfts, idx);
    }

    /// Regenerates composed SVG data
    ///
    /// NFTs which were removed from `NftBagDomain` or whose `SvgDomain`
    /// was unregistered will be skipped.
    ///
    /// #### Panics
    ///
    /// - `ComposableUrlDomain` is not registered
    /// - `NftBagDomain` is not registered
    public fun regenerate<C>(
        // TODO: Remove delegated witness by removing static fields from `Nft`
        witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
    ) {
        if (url::has_url(nft)) {
            let url = ascii::into_bytes(sui::url::inner_url(url::borrow_url(nft)));

            if (attributes::has_domain(nft)) {
                let attributes_domain = attributes::borrow_domain(nft);
                let parameters = attributes::as_url_parameters(attributes_domain);

                vector::append(&mut url, parameters);
            };

            // Set `Nft.url` to composed URL
            set_url(witness, nft, sui::url::new_unsafe_from_bytes(url));
        };
    }

    // === Interoperability ===

    /// Returns whether `ComposableUrlDomain` is registered on `Nft`
    public fun has_domain<C>(nft: &Nft<C>): bool {
        nft::has_domain<C, ComposableUrlDomain>(nft)
    }

    /// Borrows composed URL data from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrlDomain` is not registered on the `Nft`
    public fun borrow_domain<C>(nft: &Nft<C>): &ComposableUrlDomain {
        assert_composable_url(nft);
        nft::borrow_domain(nft)
    }

    /// Mutably borrows SVG data from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` is not registered on the `Nft`
    fun borrow_domain_mut<C>(nft: &mut Nft<C>): &mut ComposableUrlDomain {
        assert_composable_url(nft);
        nft::borrow_domain_mut(Witness {}, nft)
    }

    /// Adds `SvgDomain` to `Nft`
    ///
    /// `ComposableUrlDomain` will not be automatically updated so
    /// `composable_url::register` and `composable_url::regenerate` must be
    /// called.
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` domain already exists
    public fun add_domain<C>(
        _witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
    ) {
        assert!(!has_domain(nft), EEXISTING_URL_DOMAIN);
        nft::add_domain(&Witness {}, nft, new());
    }

    // === Assertions ===

    /// Asserts that `ComposableUrlDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableUrlDomain` is not registered
    public fun assert_composable_url<C>(nft: &Nft<C>) {
        assert!(has_domain(nft), EUNDEFINED_URL_DOMAIN);
    }
}
