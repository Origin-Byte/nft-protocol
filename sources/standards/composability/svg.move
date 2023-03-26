/// Module of `ComposableSvg`
///
/// `ComposableSvg` does not itself compose NFTs but serves as a display
/// standard provider for NFTs which register `SvgDomain` and are composed
/// within `NftBagDomain`.
module nft_protocol::composable_svg {
    use std::ascii::{Self, String};
    use std::vector;

    use sui::object::{Self, ID, UID};
    use sui::vec_map::{Self, VecMap};
    use sui::dynamic_field as df;

    use nft_protocol::svg;
    use nft_protocol::items;
    use nft_protocol::witness::Witness as DelegatedWitness;
    use nft_protocol::utils::{Self, UidType};

    /// `ComposableSvg` was not defined
    ///
    /// Call `composable_svg::add` or to add `ComposableSvg`.
    const EUNDEFINED_SVG_DOMAIN: u64 = 1;

    /// `ComposableSvg` already defined
    ///
    /// Call `composable_svg::borrow` to borrow domain.
    const EEXISTING_SVG_DOMAIN: u64 = 2;

    /// `ComposableSvg` did not compose NFT with given ID
    ///
    /// Call `composable_svg::deregister` with an NFT ID that exists.
    const EUNDEFINED_NFT: u64 = 3;

    const EINCORRECT_CHILD_ID: u64 = 3;

    /// Domain for providing composed SVG data
    struct ComposableSvg has store {
        /// NFTs which are being composed
        nfts: vector<ID>,
        /// Attributes of root `svg` tag
        attributes: VecMap<String, String>,
        /// Composed SVG data
        svg: vector<u8>,
    }

    struct ComposableSvgKey has copy, store, drop {}

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
        parent_uid: &mut UID,
        parent_type: &UidType<Parent>,
        child_uid: &UID,
        child_type: &UidType<Child>,
        child_nft_id: ID,
    ) {
        utils::assert_same_module<Parent, C>();
        utils::assert_uid_type<Parent>(parent_uid, parent_type);
        utils::assert_same_module<Child, C>();
        utils::assert_uid_type<Child>(child_uid, child_type);

        let items = items::borrow_items(parent_uid);

        // Assert that child NFT exists and it has `SvgDomain`
        let child_nft = items::borrow_nft<Child>(items, child_nft_id);

        // Assert that child_nft matches child_uid
        // TODO: make function with assertion
        assert_child_id(child_nft, child_uid);
        svg::assert_svg(child_uid);

        // get composable SVG
        let composable_svg = borrow_composable_svg_mut(parent_uid);

        vector::push_back(&mut composable_svg.nfts, child_nft_id);
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
    public fun deregister<C, Parent: key + store>(
        _witness: DelegatedWitness<C>,
        parent_uid: &mut UID,
        parent_type: &UidType<Parent>,
        child_nft_id: ID,
    ) {
        utils::assert_same_module<Parent, C>();
        utils::assert_uid_type<Parent>(parent_uid, parent_type);

        let composable_svg = borrow_composable_svg_mut(parent_uid);

        let (has_entry, idx) = vector::index_of(&composable_svg.nfts, &child_nft_id);
        assert!(has_entry, EUNDEFINED_NFT);

        vector::remove(&mut composable_svg.nfts, idx);
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
    public entry fun regenerate<T: key + store>(nft_uid: &mut UID) {
        let composable_svg = borrow_composable_svg(nft_uid);
        let svg = vector::empty();

        // Serialize `svg` tag
        let attributes = borrow_attributes(composable_svg);
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
        let nfts = borrow_nfts(composable_svg);
        let items = items::borrow_items(nft_uid);

        let idx = 0;
        let size = vector::length(nfts);
        while (idx < size) {
            let nft_id = vector::borrow(nfts, idx);

            if (items::has(items, *nft_id)) {
                let nft = items::borrow_nft<T>(items, *nft_id);
                if (svg::has_svg(nft)) {
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

    /// Returns whether `SvgDomain` is registered on `Nft`
    public fun has_composable_svg(nft_uid: &UID): bool {
        df::exists_(nft_uid, ComposableSvgKey {})
    }

    /// Borrows SVG data from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` is not registered on the `Nft`
    public fun borrow_composable_svg(parent_uid: &UID): &ComposableSvg {
        df::borrow<ComposableSvgKey, ComposableSvg>(
            parent_uid,
            ComposableSvgKey {}
        )
    }

    /// Mutably borrows SVG data from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` is not registered on the `Nft`
    fun borrow_composable_svg_mut(parent_uid: &mut UID): &mut ComposableSvg {
        df::borrow_mut<ComposableSvgKey, ComposableSvg>(
            parent_uid,
            ComposableSvgKey {}
        )
    }

    // === Assertions ===

    /// Asserts that `ComposableSvg` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableSvg` is not registered
    public fun assert_composable_svg<C>(nft: &UID) {
        assert!(has_composable_svg(nft), EUNDEFINED_SVG_DOMAIN);
    }

    public fun assert_child_id<Child: key + store>(child_nft: &Child, child_uid: &UID) {
        assert!(object::id(child_nft) == object::uid_to_inner(child_uid), EINCORRECT_CHILD_ID);
    }
}
