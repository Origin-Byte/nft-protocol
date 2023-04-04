/// Module of `ComposableSvg`
///
/// `ComposableSvg` does not itself compose NFTs but serves as a display
/// standard provider for NFTs which register `SvgDomain` and are composed
/// within `NftBagDomain`.
module nft_protocol::composable_svg {
    use std::ascii::{Self, String};
    use std::vector;

    use sui::object::{Self, UID, ID};
    use sui::vec_map::{Self, VecMap};
    use sui::dynamic_field as df;
    use sui::vec_set::{Self, VecSet};

    use nft_protocol::svg;
    use nft_protocol::nft_bag;
    // use nft_protocol::nft::{Self, Nft};
    use nft_protocol::witness::Witness as DelegatedWitness;
    use nft_protocol::utils::{Self, Marker};

    /// `ComposableSvg` was not defined
    ///
    /// Call `composable_svg::add` or to add `ComposableSvg`.
    const EUndefinedComposableSvg: u64 = 1;

    /// `ComposableSvg` already defined
    ///
    /// Call `composable_svg::borrow` to borrow domain.
    const EExistingComposableSvg: u64 = 2;

    /// `ComposableSvg` did not compose NFT with given ID
    ///
    /// Call `composable_svg::deregister` with an NFT ID that exists.
    const EUndefinedNft: u64 = 3;

    /// Domain for providing composed SVG data
    struct ComposableSvg has store {
        /// NFTs which are being composed
        nfts: vector<ID>,
        /// Attributes of root `svg` tag
        attributes: VecMap<String, String>,
        /// Composed SVG data
        svg: vector<u8>,
    }

    struct HotPotato {
        children: VecSet<ID>,
        svg: vector<u8>,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates new `ComposableSvg` with no predefined NFTs
    public fun new(): ComposableSvg {
        let attributes = vec_map::empty();
        vec_map::insert(
            &mut attributes,
            ascii::string(b"xmlns"),
            ascii::string(b"http://www.w3.org/2000/svg"),
        );

        ComposableSvg {
            nfts: vector::empty(),
            attributes,
            svg: vector::empty(),
        }
    }

    /// Borrows root tag attributes from `ComposableSvg`
    public fun borrow_attributes(
        domain: &ComposableSvg,
    ): &VecMap<String, String> {
        &domain.attributes
    }

    /// Borrows registered NFTs from `ComposableSvg`
    public fun borrow_nfts(domain: &ComposableSvg): &vector<ID> {
        &domain.nfts
    }

    /// Registers NFT whose SVG data should be composed within the final
    /// composed SVG
    ///
    /// `ComposableSvg` will not be automatically updated so
    /// `composable_svg::regenerate` must be called.
    ///
    /// #### Panics
    ///
    /// - `ComposableSvg` doesn't exist
    /// - `NftBagDomain` doesn't exist
    /// - NFT was of a different collection type
    /// - NFT wasn't composed
    public fun register<C, Parent: key + store, Child: key + store>(
        _witness: DelegatedWitness<C>,
        parent_nft: &mut UID,
        child_nft: &mut UID,
    ) {
        let nft_bag = nft_bag::borrow_domain_mut<Parent>(parent_nft);
        let child_id = object::uid_to_inner(child_nft);

        nft_bag::assert_composed(nft_bag, child_id);

        // Assert that child NFT exists and it has `SvgDomain`
        svg::assert_svg(child_nft);

        let composable_svg = borrow_domain_mut(parent_nft);
        vector::push_back(&mut composable_svg.nfts, child_id);
    }

    /// Deregisters NFT whose SVG data is being composed within
    /// `ComposableSvg`
    ///
    /// `ComposableSvg` will not be automatically updated so
    /// `composable_svg::regenerate` must be called.
    ///
    /// #### Panics
    ///
    /// - `ComposableSvg` doesn't exist
    /// - NFT wasn't composed
    public fun deregister<C, Parent: key + store, Child: key + store>(
        _witness: DelegatedWitness<C>,
        parent_nft: &mut UID,
        child_nft: &mut UID,
    ) {
        let nft_bag = nft_bag::borrow_domain_mut<Parent>(parent_nft);
        let child_id = object::uid_to_inner(child_nft);

        let composable_svg = borrow_domain_mut(parent_nft);

        let (has_entry, idx) = vector::index_of(&composable_svg.nfts, &child_id);
        assert!(has_entry, EUndefinedNft);

        vector::remove(&mut composable_svg.nfts, idx);
    }

    public fun start_render_svg(parent_nft: &mut UID): HotPotato {
        HotPotato { children: get_children_ids(parent), svg: b"<svg " }
    }

    /// Regenerates composed SVG data
    ///
    /// NFTs which were removed from `NftBagDomain` or whose `SvgDomain`
    /// was unregistered will be skipped.
    ///
    /// #### Panics
    ///
    /// - `ComposableSvg` is not registered
    /// - `NftBagDomain` is not registered
    /// - Composed type was not `Nft<C>`
    public fun regenerate<C>(nft: &mut UID) {
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
        let nft_bag = nft_bag::borrow_domain<Nft<C>>(nft);

        let idx = 0;
        let size = vector::length(nfts);
        while (idx < size) {
            let nft_id = vector::borrow(nfts, idx);

            if (nft_bag::has(nft_bag, *nft_id)) {
                // TODO: Sui needs to allow obtaining `&UID`
                let nft = nft::borrow_uid(nft_bag::borrow(nft_bag, *nft_id));
                if (svg::has_domain(nft)) {
                    let nft_svg = svg::get_svg(svg::borrow_domain(nft));

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

    /// Returns whether `ComposableSvg` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<ComposableSvg>, ComposableSvg>(
            nft, utils::marker(),
        )
    }

    /// Borrows `ComposableSvg` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableSvg` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &ComposableSvg {
        assert_composable_svg(nft);
        df::borrow(nft, utils::marker<ComposableSvg>())
    }

    /// Mutably borrows `ComposableSvg` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableSvg` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut ComposableSvg {
        assert_composable_svg(nft);
        df::borrow_mut(nft, utils::marker<ComposableSvg>())
    }

    /// Adds `ComposableSvg` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableSvg` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: ComposableSvg,
    ) {
        assert_no_composable_svg(nft);
        df::add(nft, utils::marker<ComposableSvg>(), domain);
    }

    /// Remove `ComposableSvg` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableSvg` domain doesnt exist
    public fun remove_domain(nft: &mut UID): ComposableSvg {
        assert_composable_svg(nft);
        df::remove(nft, utils::marker<ComposableSvg>())
    }

    // === Assertions ===

    /// Asserts that `ComposableSvg` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableSvg` is not registered
    public fun assert_composable_svg(nft: &UID) {
        assert!(has_domain(nft), EUndefinedComposableSvg);
    }

    /// Asserts that `ComposableSvg` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableSvg` is registered
    public fun assert_no_composable_svg(nft: &UID) {
        assert!(!has_domain(nft), EExistingComposableSvg);
    }
}
