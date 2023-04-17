/// Module of `ComposableSvg`
///
/// `ComposableSvg` does not itself compose NFTs but serves as a display
/// standard provider for NFTs which register `SvgDomain`.
module nft_protocol::composable_svg {
    use std::ascii::{Self, String};
    use std::vector;

    use sui::object::{Self, UID, ID};
    use sui::vec_map::{Self, VecMap};
    use sui::dynamic_field as df;

    use nft_protocol::svg;
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

    /// Tried to call `render_child` on child not present in `RenderGuard`
    ///
    /// Call `composable_svg::render_child` only on children defined within
    /// the `RenderGuard`.
    const EInvalidChild: u64 = 4;

    /// Tried to call `finish_render_svg` when `RenderGuard` was not empty
    ///
    /// Call `composable_svg::render_child` to remove those elements.
    const ERenderIncomplete: u64 = 5;

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
        children: vector<ID>,
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

        from_attributes(attributes)
    }

    /// Creates new `ComposableSvg` from attributes
    public fun from_attributes(
        attributes: VecMap<String, String>,
    ): ComposableSvg {
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

    /// Borrows composed SVG data
    public fun borrow_svg(domain: &ComposableSvg): &vector<u8> {
        &domain.svg
    }

    /// Borrows composed SVG data
    ///
    /// #### Panics
    ///
    /// Panics if `ComposedSvg` was not registered on NFT.
    public fun borrow_svg_nft(nft: &UID): &vector<u8> {
        borrow_svg(borrow_domain(nft))
    }

    /// Registers NFT whose SVG data should be composed within `ComposableSvg`
    ///
    /// `ComposableSvg` will not be automatically updated so
    /// `composable_svg::start_render` must be called.
    public fun register(
        composable_svg: &mut ComposableSvg,
        child_id: ID,
    ) {
        vector::push_back(&mut composable_svg.nfts, child_id);
    }

    /// Registers NFT whose SVG data should be composed within `ComposableSvg`
    ///
    /// `ComposableSvg` will not be automatically updated so
    /// `composable_svg::start_render` must be called.
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableSvg` doesn't exist.
    public fun register_nft(
        parent_nft: &mut UID,
        child_id: ID,
    ) {
        let composable_svg = borrow_domain_mut(parent_nft);
        register(composable_svg, child_id)
    }

    /// Deregisters NFT whose SVG data is being composed within
    /// `ComposableSvg`
    ///
    /// `ComposableSvg` will not be automatically updated so
    /// `composable_svg::start_render` must be called.
    ///
    /// #### Panics
    ///
    /// Panics if NFT wasn't registered within `ComposableSvg`.
    public fun deregister(
        composable_svg: &mut ComposableSvg,
        child_id: ID,
    ) {
        let (has_entry, idx) =
            vector::index_of(borrow_nfts(composable_svg), &child_id);
        assert!(has_entry, EUndefinedNft);

        vector::remove(&mut composable_svg.nfts, idx);
    }

    /// Deregisters NFT whose SVG data is being composed within
    /// `ComposableSvg`
    ///
    /// `ComposableSvg` will not be automatically updated so
    /// `composable_svg::start_render` must be called.
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableSvg` doesn't exist.
    public fun deregister_nft(
        parent_nft: &mut UID,
        child_id: ID,
    ) {
        let composable_svg = borrow_domain_mut(parent_nft);
        deregister(composable_svg, child_id);
    }

    /// Initialises the render of the composed SVG data
    ///
    /// Returns `RenderGuard` object, which forces the client to subsequently
    /// call `composable_svg::render_child` for each child NFT.
    public fun start_render(
        composable_svg: &ComposableSvg,
    ): RenderGuard {
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

        RenderGuard { children: composable_svg.nfts, svg }
    }

    /// Initialises the render of the composed SVG data
    ///
    /// Returns `RenderGuard` object, which forces the client to subsequently
    /// call `composable_svg::render_child` for each child NFT.
    public fun start_render_nft(
        parent_nft: &UID,
    ): RenderGuard {
        let composable_svg = borrow_domain(parent_nft);
        start_render(composable_svg)
    }

    /// Renders SVG data from child NFT to `ComposableSvg`, progressively
    /// emptying the `RenderGuard`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` is not present on NFT.
    public fun render_child(hp: &mut RenderGuard, child: &UID) {
        let nft_svg = svg::get_svg(svg::borrow_domain(child));
        render_child_(hp, object::uid_as_inner(child), *nft_svg);
    }

    /// Renders custom SVG data from child NFT to `ComposableSvg`,
    /// progressively emptying the `RenderGuard`
    ///
    /// Requires proof that you own the mutability rights to the NFT as this
    /// would be equivalent to simply adding `SvgDomain` before rendering the
    /// child.
    public fun render_child_external(
        hp: &mut RenderGuard,
        child: &mut UID,
        nft_svg: vector<u8>,
    ) {
        render_child_(hp, object::uid_as_inner(child), nft_svg);
    }

    fun render_child_(
        hp: &mut RenderGuard,
        child_id: &ID,
        nft_svg: vector<u8>,
    ) {
        // TODO: Somehow consider serializing id attribute
        vector::append(&mut hp.svg, b"<g>");
        vector::append(&mut hp.svg, nft_svg);
        vector::append(&mut hp.svg, b"</g>");

        let (is_child, idx) = vector::index_of(&mut hp.children, child_id);
        assert!(is_child, EInvalidChild);

        vector::swap_remove(&mut hp.children, idx);
    }

    /// Finishes the compositions of the SVG data in the Parent's ComposableSvg
    /// domain. It consumes the hot potato, `RenderGuard`, signaling the end of
    /// the programmable batch of transactions.
    ///
    /// #### Panics
    ///
    /// * `RenderGuard` is not empty
    public fun finish_render(
        hp: RenderGuard,
        composable_svg: &mut ComposableSvg,
    ) {
        let RenderGuard { children, svg } = hp;
        assert!(vector::length(&children) == 0, ERenderIncomplete);

        vector::append(&mut svg, b"</svg>");

        composable_svg.svg = svg;
    }

    /// Finishes the compositions of the SVG data in the Parent's ComposableSvg
    /// domain. It consumes the hot potato, `RenderGuard`, signaling the end of
    /// the programmable batch of transactions.
    ///
    /// #### Panics
    ///
    /// * `ComposableSvg` is not registered
    /// * `RenderGuard` is not empty
    public fun finish_render_nft(
        hp: RenderGuard,
        parent_nft: &mut UID,
    ) {
        let composable_svg: &mut ComposableSvg = borrow_domain_mut(parent_nft);
        finish_render(hp, composable_svg)
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

    /// Adds new `ComposableSvg` to NFT
    public fun add_new(nft: &mut UID) {
        add_domain(nft, new())
    }

    /// Adds new `ComposableSvg` to NFT
    public fun add_from_attributes(
        nft: &mut UID,
        attributes: VecMap<String, String>,
    ) {
        add_domain(nft, from_attributes(attributes))
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

    /// Delete `ComposableSvg`
    public fun delete(domain: ComposableSvg) {
        let ComposableSvg { nfts: _, attributes: _, svg: _ } = domain;
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
