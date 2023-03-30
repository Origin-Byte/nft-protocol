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
    use sui::tx_context::TxContext;
    use sui::bag::{Self, Bag};

    use nft_protocol::svg;
    use nft_protocol::items;
    use nft_protocol::witness::Witness as DelegatedWitness;
    use nft_protocol::utils::{
        assert_with_consumable_witness, UidType, assert_same_module, assert_uid_type
    };
    use nft_protocol::consumable_witness::{Self as cw, ConsumableWitness};


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

    /// No field object `ComposableSvg` defined as a dynamic field.
    const EUNDEFINED_COMPOSABLE_URL_FIELD: u64 = 4;

    /// Field object `ComposableSvg` already defined as dynamic field.
    const ECOMPOSABLE_URL_FIELD_ALREADY_EXISTS: u64 = 5;

    /// Domain for providing composed SVG data
    struct ComposableSvg has store {
        /// NFTs which are being composed
        nfts: vector<ID>,
        /// Attributes of root `svg` tag
        attributes: VecMap<String, String>,
        /// Composed SVG data
        svg: vector<u8>,
        child_svgs: Bag,
    }

    struct ComposableSvgKey has copy, store, drop {}

    struct ChildSvgKey has copy, store, drop {
        nft_id: ID,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}


    /// Adds `ComposableSvg` as a dynamic field with key `ComposableSvgKey`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `ComposableSvg`.
    ///
    /// #### Panics
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun add_composable_url<T: key>(
        consumable: ConsumableWitness<T>,
        object_uid: &mut UID,
        object_type: UidType<T>,
        ctx: &mut TxContext
    ) {
        assert_has_not_composable_url(object_uid);
        assert_with_consumable_witness(object_uid, object_type);

        let composable_url = new(ctx);

        cw::consume<T, ComposableSvg>(consumable, &mut composable_url);
        df::add(object_uid, ComposableSvgKey {}, composable_url);
    }


    // === Get for call from external Module ===


    /// Creates new `ComposableSvg` with no predefined NFTs
    public fun new(ctx: &mut TxContext): ComposableSvg {
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
            child_svgs: bag::new(ctx)
        }
    }


    // === Field Borrow Functions ===


    /// Borrows immutably the `ComposableSvg` field.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `ComposableSvgKey` does not exist.
    public fun borrow_composable_svg(
        object_uid: &UID,
    ): &ComposableSvg {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_composable_url(object_uid);
        df::borrow(object_uid, ComposableSvgKey {})
    }

    /// Borrows Mutably the `ComposableSvg` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `ComposableUrl`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `ComposableSvgKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun borrow_composable_url_mut<T: key>(
        consumable: ConsumableWitness<T>,
        object_uid: &mut UID,
        object_type: UidType<T>
    ): &mut ComposableSvg {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_composable_url(object_uid);
        assert_with_consumable_witness(object_uid, object_type);

        let composable_svg = df::borrow_mut<ComposableSvgKey, ComposableSvg>(
            object_uid,
            ComposableSvgKey {}
        );
        cw::consume<T, ComposableSvg>(consumable, composable_svg);

        composable_svg
    }


    // === Writer Functions ===

    /// Registers NFT whose SVG data should be composed within the final
    /// composed SVG
    ///
    /// `ComposableSvg` will not be automatically updated so
    /// `composable_svg::regenerate` must be called.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `ComposableSvg`.
    ///
    /// #### Panics
    ///
    /// - `ComposableSvg` doesn't exist
    /// - `NftBagDomain` doesn't exist
    /// - NFT was of a different collection type
    /// - NFT wasn't composed
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun register<Parent: key + store, Child: key + store>(
        parent_consumable: ConsumableWitness<Parent>,
        // TODO: Maybe we get away with this by copying the SVG from the child
        // instead of burning it
        child_consumable: ConsumableWitness<Child>,
        parent_uid: &mut UID,
        parent_type: UidType<Parent>,
        child_uid: &mut UID,
        child_type: UidType<Child>,
    ) {
        assert_same_module<Parent, Child>();
        assert_uid_type<Parent>(parent_uid, &parent_type);
        assert_uid_type<Child>(child_uid, &child_type);

        // Assert that child NFT exists and it has `SvgDomain`
        let child_id = object::uid_to_inner(child_uid);
        let child_nft = items::borrow_nft<Child>(parent_uid, child_id);

        // Assert that child_nft matches child_uid
        assert_child_id(child_nft, child_uid);
        svg::assert_has_svg(child_uid);

        // get composable SVG
        let composable_svg = borrow_composable_svg_mut(parent_uid);
        cw::consume<Parent, ComposableSvg>(parent_consumable, composable_svg);

        // Pop SVG from child and Push it to ComposableSvg
        let child_svg = svg::burn_svg(child_consumable, child_uid, child_type);
        insert_child_svg(composable_svg, child_svg, child_id);

        vector::push_back(&mut composable_svg.nfts, child_id);
    }


    /// Deregisters NFT whose SVG data is being composed within
    /// `ComposableSvg`
    ///
    /// `ComposableSvg` will not be automatically updated so
    /// `composable_svg::regenerate` must be called.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `ComposableSvg`.
    ///
    /// #### Panics
    ///
    /// - `ComposableSvg` doesn't exist
    /// - NFT wasn't composed
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun deregister<Parent: key + store, Child: key + store>(
        parent_consumable: ConsumableWitness<Parent>,
        // TODO: Maybe we get away with this by copying the SVG from the child
        // instead of burning it
        child_consumable: ConsumableWitness<Child>,
        parent_uid: &mut UID,
        parent_type: UidType<Parent>,
        child_uid: &mut UID,
        child_type: UidType<Child>,
    ) {
        assert_same_module<Parent, Child>();
        assert_uid_type<Parent>(parent_uid, &parent_type);
        assert_uid_type<Child>(child_uid, &child_type);

        let composable_svg = borrow_composable_svg_mut(parent_uid);
        cw::consume<Parent, ComposableSvg>(parent_consumable, composable_svg);
        let child_id = object::uid_to_inner(child_uid);

        let (has_entry, idx) = vector::index_of(&composable_svg.nfts, &child_id);
        assert!(has_entry, EUNDEFINED_NFT);

        // Pop SVG from ComposableSvg and Push it to Child
        let child_svg = pop_child_svg(composable_svg, child_id);
        svg::set_svg<Child>(child_consumable, child_uid, child_type, child_svg);

        vector::remove(&mut composable_svg.nfts, idx);
    }

    /// Regenerates composed SVG data
    ///
    /// NFTs which were removed from `NftBagDomain` or whose `SvgDomain`
    /// was unregistered will be skipped.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `ComposableSvg`.
    ///
    /// #### Panics
    ///
    /// - `ComposableSvg` is not registered
    /// - `NftBagDomain` is not registered
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public entry fun regenerate<T: key + store>(nft_uid: &mut UID) {
        let composable_svg = borrow_composable_svg(nft_uid);
        let svg = vector::empty();

        // Serialize `svg` tag
        let attributes = get_attributes(composable_svg);
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
        let nft_ids = get_nft_ids(composable_svg);
        let items = items::borrow_items(nft_uid);

        let idx = 0;
        let size = vector::length(nft_ids);

        while (idx < size) {
            let nft_id = vector::borrow(nft_ids, idx);

            if (items::has_nft_(items, *nft_id)) {

                let nft_svg = bag::borrow<ChildSvgKey, vector<u8>>(
                    &composable_svg.child_svgs,
                    ChildSvgKey { nft_id: *nft_id }
                );

                // TODO: Somehow consider serializing id attribute
                vector::append(&mut svg, b"<g>");
                vector::append(&mut svg, *nft_svg);
                vector::append(&mut svg, b"</g>");
            };

            idx = idx + 1;
        };

        vector::append(&mut svg, b"</svg>");
        let composable_svg = borrow_composable_svg_mut(nft_uid);
        composable_svg.svg = svg;
    }


    // === Getter Functions & Static Mutability Accessors ===

    /// Borrows root tag attributes from `ComposableSvg`
    public fun get_attributes(
        domain: &ComposableSvg,
    ): &VecMap<String, String> {
        &domain.attributes
    }


    /// Borrows registered NFTs from `ComposableSvg`
    public fun get_nft_ids(domain: &ComposableSvg): &vector<ID> {
        &domain.nfts
    }

    /// Borrows root composed svg from `ComposableSvg`
    public fun get_svg(
        svg: &ComposableSvg,
    ): &vector<u8> {
        &svg.svg
    }

    /// Borrows root child svgs from `ComposableSvg`
    public fun get_child_svgs(
        svg: &ComposableSvg,
    ): &Bag {
        &svg.child_svgs
    }

    /// Mutably borrows root tag attributes from `ComposableSvg`
    public fun get_attributes_mut(
        svg: &mut ComposableSvg,
    ): &mut VecMap<String, String> {
        &mut svg.attributes
    }

    /// Mutably borrows root composed svg from `ComposableSvg`
    public fun get_svg_mut(
        svg: &mut ComposableSvg,
    ): &mut vector<u8> {
        &mut svg.svg
    }

    /// Mutably borrows root child svgs from `ComposableSvg`
    public fun get_child_svgs_mut(
        svg: &mut ComposableSvg,
    ): &Bag {
        &mut svg.child_svgs
    }


    // === Private Functions ===


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

    fun insert_child_svg(
        composable_svg: &mut ComposableSvg,
        svg: vector<u8>,
        nft_id: ID
    ) {
        bag::add(&mut composable_svg.child_svgs, ChildSvgKey { nft_id }, svg);
    }

    fun pop_child_svg(
        composable_svg: &mut ComposableSvg,
        nft_id: ID
    ): vector<u8> {
        bag::remove(&mut composable_svg.child_svgs, ChildSvgKey { nft_id })
    }


    // === Assertions & Helpers ===


    /// Returns whether `SvgDomain` is registered on `Nft`
    public fun has_composable_svg(nft_uid: &UID): bool {
        df::exists_(nft_uid, ComposableSvgKey {})
    }

    /// Checks that a given NFT has a dynamic field with `ComposableSvgKey`
    public fun has_composable_url(
        object_uid: &UID,
    ): bool {
        df::exists_(object_uid, ComposableSvgKey {})
    }

    public fun assert_child_id<Child: key + store>(child_nft: &Child, child_uid: &UID) {
        assert!(object::id(child_nft) == object::uid_to_inner(child_uid), EINCORRECT_CHILD_ID);
    }

    /// Asserts that `ComposableSvg` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ComposableSvg` is not registered
    public fun assert_has_composable_url(object_uid: &UID) {
        assert!(has_composable_url(object_uid), EUNDEFINED_COMPOSABLE_URL_FIELD);
    }

    public fun assert_has_not_composable_url(object_uid: &UID) {
        assert!(!has_composable_url(object_uid), ECOMPOSABLE_URL_FIELD_ALREADY_EXISTS);
    }
}
