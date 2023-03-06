/// Module of `ComposableSvgDomain`
///
/// `ComposableSvgDomain` does not itself compose NFTs but serves as a display
/// standard provider for NFTs which register `SvgDomain` and are composed
/// within `ContainerDomain`.
module nft_protocol::composable_svg {
    use std::ascii::{Self, String};
    use std::vector;

    use sui::object::ID;
    use sui::vec_map::{Self, VecMap};

    use nft_protocol::svg;
    use nft_protocol::container;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::witness::Witness as DelegatedWitness;

    /// `ComposableSvgDomain` was not defined
    ///
    /// Call `composable_svg::add` or to add `ComposableSvgDomain`.
    const EUNDEFINED_SVG_DOMAIN: u64 = 1;

    /// `ComposableSvgDomain` already defined
    ///
    /// Call `composable_svg::borrow` to borrow domain.
    const EEXISTING_SVG_DOMAIN: u64 = 2;

    /// `ComposableSvgDomain` did not compose NFT with given ID
    ///
    /// Call `container::deregister` with an NFT ID that exists.
    const EUNDEFINED_NFT: u64 = 3;

    /// Domain for providing composed SVG data
    struct ComposableSvgDomain has store {
        /// NFTs which are being composed
        nfts: vector<ID>,
        /// Attributes of root `svg` tag
        attributes: VecMap<String, String>,
        /// Composed SVG data
        svg: vector<u8>,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates new `ComposableSvgDomain` with no predefined NFTs
    public fun new(): ComposableSvgDomain {
        let attributes = vec_map::empty();
        vec_map::insert(
            &mut attributes,
            ascii::string(b"xmlns"),
            ascii::string(b"http://www.w3.org/2000/svg"),
        );

        ComposableSvgDomain {
            nfts: vector::empty(),
            attributes,
            svg: vector::empty(),
        }
    }

    /// Borrows root tag attributes from `ComposableSvgDomain`
    public fun borrow_attributes(
        domain: &ComposableSvgDomain,
    ): &VecMap<String, String> {
        &domain.attributes
    }

    /// Borrows registered NFTs from `ComposableSvgDomain`
    public fun borrow_nfts(domain: &ComposableSvgDomain): &vector<ID> {
        &domain.nfts
    }

    /// Registers NFT whose SVG data should be composed within the final
    /// composed SVG
    ///
    /// `ComposableSvgDomain` will not be automatically updated so
    /// `composable_svg::regenerate` must be called.
    ///
    /// #### Panics
    ///
    /// - `ComposableSvgDomain` doesn't exist
    /// - `ContainerDomain` doesn't exist
    /// - NFT was of a different collection type
    /// - NFT wasn't composed
    public entry fun register<C>(parent_nft: &mut Nft<C>, child_nft_id: ID) {
        let container_domain = container::borrow_domain_mut(parent_nft);

        // Assert that child NFT exists and it has `SvgDomain`
        let child_nft = container::borrow<C>(container_domain, child_nft_id);
        svg::assert_svg(child_nft);

        let domain = borrow_domain_mut(parent_nft);
        vector::push_back(&mut domain.nfts, child_nft_id);
    }

    /// Deregisters NFT whose SVG data is being composed within
    /// `ComposableSvgDomain`
    ///
    /// `ComposableSvgDomain` will not be automatically updated so
    /// `composable_svg::regenerate` must be called.
    ///
    /// #### Panics
    ///
    /// - `ComposableSvgDomain` doesn't exist
    /// - NFT wasn't composed
    public entry fun deregister<C>(parent_nft: &mut Nft<C>, child_nft_id: ID) {
        let domain = borrow_domain_mut(parent_nft);

        let (has_entry, idx) = vector::index_of(&domain.nfts, &child_nft_id);
        assert!(has_entry, EUNDEFINED_NFT);

        vector::remove(&mut domain.nfts, idx);
    }

    /// Regenerates composed SVG data
    ///
    /// NFTs which were removed from `ContainerDomain` or whose `SvgDomain`
    /// was unregistered will be skipped.
    ///
    /// #### Panics
    ///
    /// - `ComposableSvgDomain` is not registered
    /// - `ContainerDomain` is not registered
    public entry fun regenerate<C>(nft: &mut Nft<C>) {
        let composable_svg_domain = borrow_domain(nft);

        let svg = vector::empty();

        // Serialize `svg` tag
        let attributes = borrow_attributes(composable_svg_domain);
        vector::append(&mut svg, b"<svg");

        let idx = 0;
        let size = vec_map::size(attributes);
        while (idx < size) {
            let (key, value) = vec_map::get_entry_by_idx(attributes, idx);

            vector::append(&mut svg, b" ");
            vector::append(&mut svg, ascii::into_bytes(*key));
            vector::append(&mut svg, b"=\"");
            vector::append(&mut svg, ascii::into_bytes(*value));
            vector::append(&mut svg, b"\"");

            idx = idx + 1;
        };

        vector::append(&mut svg, b">");

        // Serialize NFT tags
        let nfts = borrow_nfts(composable_svg_domain);
        let container = container::borrow_domain(nft);

        let idx = 0;
        let size = vector::length(nfts);
        while (idx < size) {
            let nft_id = vector::borrow(nfts, idx);

            if (container::has(container, *nft_id)) {
                let nft = container::borrow<C>(container, *nft_id);
                if (svg::has_domain(nft)) {
                    let nft_svg = svg::borrow_svg(nft);

                    // TODO: Somehow consider serializing id attribute
                    vector::append(&mut svg, b"<g>");
                    vector::append(&mut svg, *nft_svg);
                    vector::append(&mut svg, b"</g>");
                }
            };

            idx = idx + 1;
        };

        vector::append(&mut svg, b"</svg>");
        let composable_svg_domain = borrow_domain_mut(nft);
        composable_svg_domain.svg = svg;
    }

    // === Interoperability ===

    /// Returns whether `SvgDomain` is registered on `Nft`
    public fun has_domain<C>(nft: &Nft<C>): bool {
        nft::has_domain<C, ComposableSvgDomain>(nft)
    }

    /// Borrows SVG data from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` is not registered on the `Nft`
    public fun borrow_domain<C>(nft: &Nft<C>): &ComposableSvgDomain {
        assert_composable_svg(nft);
        nft::borrow_domain(nft)
    }

    /// Mutably borrows SVG data from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` is not registered on the `Nft`
    fun borrow_domain_mut<C>(nft: &mut Nft<C>): &mut ComposableSvgDomain {
        assert_composable_svg(nft);
        nft::borrow_domain_mut(Witness {}, nft)
    }

    /// Adds `SvgDomain` to `Nft`
    ///
    /// `ComposableSvgDomain` will not be automatically updated so
    /// `composable_svg::register` and `composable_svg::regenerate` must be
    /// called.
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` domain already exists
    public fun add_domain<C>(
        _witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
    ) {
        assert!(!has_domain(nft), EEXISTING_SVG_DOMAIN);
        nft::add_domain(&Witness {}, nft, new());
    }

    // === Assertions ===

    /// Asserts that `ComposableSvgDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableSvgDomain` is not registered
    public fun assert_composable_svg<C>(nft: &Nft<C>) {
        assert!(has_domain(nft), EUNDEFINED_SVG_DOMAIN);
    }
}
