/// Module of `ComposableSvg`
///
/// `ComposableSvg` does not itself compose NFTs but serves as a display
/// standard provider for NFTs which register `SvgDomain` and are composed
/// within `NftBag`.
module nft_protocol::composable_svg {
    use std::ascii::{Self, String};
    use std::vector;

    use sui::object::{Self, UID, ID};
    use sui::vec_map::{Self, VecMap};
    use sui::dynamic_field as df;
    use sui::vec_set::{Self, VecSet};

    use nft_protocol::svg;
    use nft_protocol::nft_bag;
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

    /// Tried to call `finish_render_svg` when the `HotPotato` was still
    /// not empty. In other words, hot_potato.children still has elements
    /// in it. Consider calling `render_child` to remove those elements.
    const ERenderIncomplete: u64 = 3;

    /// Domain for providing composed SVG data
    struct ComposableSvg has store {
        /// NFTs which are being composed
        nfts: vector<ID>,
        /// Attributes of root `svg` tag
        attributes: VecMap<String, String>,
        /// Composed SVG data
        svg: vector<u8>,
    }

    /// Hot potato struct to ensure the client re-renders the ComposableSVG
    /// completely upon calling `start_render_svg`
    struct RenderGuard {
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

    /// Registers NFT whose SVG data should be composed within `ComposableSvg`
    ///
    /// `ComposableSvg` will not be automatically updated so
    /// `composable_svg::start_render` must be called.
    ///
    /// #### Panics
    ///
    /// - `ComposableSvg` doesn't exist
    /// - `NftBag` doesn't exist
    /// - NFT was of a different collection type
    /// - NFT wasn't composed
    public fun register<C, Parent: key + store, Child: key + store>(
        _witness: DelegatedWitness<C>,
        parent_nft: &mut UID,
        child_nft: &mut UID,
    ) {
        let nft_bag = nft_bag::borrow_domain_mut(parent_nft);
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
    /// `composable_svg::start_render` must be called.
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
        let child_id = object::uid_to_inner(child_nft);

        let composable_svg = borrow_domain_mut(parent_nft);

        let (has_entry, idx) =
            vector::index_of(&composable_svg.nfts, &child_id);
        assert!(has_entry, EUndefinedNft);

        vector::remove(&mut composable_svg.nfts, idx);
    }

    /// Initialises the render of the composed SVG data
    ///
    /// Returns `RenderGuard` object, which forces the client to subsequently
    /// call `composable_svg::render_child` for each child NFT.
    ///
    /// NFTs which are not present in `NftBag` or whose `SvgDomain` was
    /// unregistered will be skipped.
    ///
    /// #### Panics
    ///
    /// - `ComposableSvg` is not registered
    /// - `NftBagDomain` is not registered
    public fun start_render<Parent: key + store>(
        parent_nft: &mut UID,
    ): RenderGuard {
        let composable_svg = borrow_domain_mut(parent_nft);
        let attributes = borrow_attributes(composable_svg);

        let svg = vector::empty();

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

        let children = utils::vec_set_from_vec(&composable_svg.nfts);

        RenderGuard { children, svg }
    }

    /// Renders SVG data from child NFT to `ComposableSvg`, progressively
    /// emptying the `RenderGuard`
    ///
    /// #### Panics
    ///
    /// * `ComposableSvg` is not registered
    /// * `NftBag` is not registered
    public fun render_child(hp: &mut RenderGuard, child: &mut UID) {
        let nft_svg = svg::get_svg(svg::borrow_domain(child));

        // TODO: Somehow consider serializing id attribute
        vector::append(&mut hp.svg, b"<g>");
        vector::append(&mut hp.svg, *nft_svg);
        vector::append(&mut hp.svg, b"</g>");

        vec_set::remove(&mut hp.children, object::uid_as_inner(child));
    }


    /// Finishes the compositions of the SVG data in the Parent's ComposableSvg
    /// domain. It consumes the hot potato, `RenderGuard`, signaling the end of
    /// the programmable batch of transactions.
    ///
    /// #### Panics
    ///
    /// * `ComposableSvg` is not registered
    /// * `NftBag` is not registered
    /// * `RenderGuard` is not empty
    public fun finish_render(hp: RenderGuard, parent_nft: &mut UID) {
        let RenderGuard { children, svg } = hp;
        assert!(vec_set::size(&children) == 0, ERenderIncomplete);

        vector::append(&mut svg, b"</svg>");

        let composable_svg: &mut ComposableSvg = borrow_domain_mut(parent_nft);
        composable_svg.svg = svg;
    }

    // === Interoperability ===

    /// Returns whether `ComposableSvg` is registered on NFT
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<ComposableSvg>, ComposableSvg>(
            nft, utils::marker(),
        )
    }

    /// Borrows `ComposableSvg` from NFT
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableSvg` is not registered on the NFT
    public fun borrow_domain(nft: &UID): &ComposableSvg {
        assert_composable_svg(nft);
        df::borrow(nft, utils::marker<ComposableSvg>())
    }

    /// Mutably borrows `ComposableSvg` from NFT
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableSvg` is not registered on the NFT
    public fun borrow_domain_mut(nft: &mut UID): &mut ComposableSvg {
        assert_composable_svg(nft);
        df::borrow_mut(nft, utils::marker<ComposableSvg>())
    }

    /// Adds `ComposableSvg` to NFT
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

    /// Remove `ComposableSvg` from NFT
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableSvg` domain doesnt exist
    public fun remove_domain(nft: &mut UID): ComposableSvg {
        assert_composable_svg(nft);
        df::remove(nft, utils::marker<ComposableSvg>())
    }

    // === Assertions ===

    /// Asserts that `ComposableSvg` is registered on NFT
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableSvg` is not registered
    public fun assert_composable_svg(nft: &UID) {
        assert!(has_domain(nft), EUndefinedComposableSvg);
    }

    /// Asserts that `ComposableSvg` is not registered on NFT
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableSvg` is registered
    public fun assert_no_composable_svg(nft: &UID) {
        assert!(!has_domain(nft), EExistingComposableSvg);
    }
}
