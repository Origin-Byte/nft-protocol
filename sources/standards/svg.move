/// Module of the `Svg`
///
/// Used to associate SVG data with `Collection` or `Nft`.
///
/// Composable NFTs with children registering `Svg` can declare them with
/// `ComposableSvg` to compose all SVG data into one definition.
module nft_protocol::svg {
    use sui::dynamic_field as df;
    use sui::object::UID;

    use nft_protocol::witness::Witness as DelegatedWitness;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::utils::{Self, UidType};

    /// `Svg` was not defined
    ///
    /// Call `svg::add` or `svg::add_collection` to add `Svg`.
    const EUNDEFINED_SVG_DOMAIN: u64 = 1;

    /// `Svg` already defined
    ///
    /// Call `svg::borrow` or svg::borrow_collection` to borrow domain.
    const EEXISTING_SVG_DOMAIN: u64 = 2;

    /// Domain for storing an associated SVG data
    struct Svg has store {
        svg: vector<u8>,
    }

    struct SvgKey has store, copy, drop {}

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates new `Svg`
    public fun new(svg: vector<u8>): Svg {
        Svg { svg }
    }

    /// Sets SVG data of `Svg`
    ///
    /// `ComposableSvg` will not be automatically updated and
    /// `composable_svg::regenerate` must be called
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` does not exist on `Nft`
    public fun set_svg<C, T: key + store>(
        _witness: DelegatedWitness<C>,
        nft_uid: &mut UID,
        uid_type: &UidType<T>,
        svg: vector<u8>,
    ) {
        utils::assert_same_module<T, C>();
        utils::assert_uid_type<T>(nft_uid, uid_type);

        // TODO: The permissioning system must be rearranged,
        // because owners should not be allowed to change this field
        let svg_data = borrow_svg_mut(nft_uid);
        *svg_data = svg;
    }

    /// Sets SVG data of `Svg`
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` does not exist on `Collection`
    public fun set_collection_svg<T>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        svg: vector<u8>,
    ) {
        let svg_data = borrow_collection_svg_mut(collection);
        *svg_data = svg;
    }

    /// Borrows SVG data from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` is not registered on the `Nft`
    public fun borrow_svg(nft_uid: &UID): &vector<u8> {
        assert_svg(nft_uid);
        let svg = df::borrow(nft_uid, SvgKey {});
        svg
    }

    /// Mutably borrows SVG data from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` is not registered on the `Nft`
    fun borrow_svg_mut(nft_uid: &mut UID): &mut vector<u8> {
        assert_svg(nft_uid);
        let svg = df::borrow_mut(nft_uid, SvgKey {});
        svg
    }

    /// Returns whether `SvgDomain` is registered on `Collection`
    public fun has_domain_collection<C>(collection: &Collection<C>): bool {
        collection::has_domain<C, Svg>(collection)
    }

    /// Borrows SVG data from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` is not registered on the `Collection`
    public fun borrow_collection_svg<T>(collection: &Collection<T>): &vector<u8> {
        assert_collection_svg(collection);
        let domain: &Svg = collection::borrow_domain(collection);
        &domain.svg
    }

    // TODO: This is not safe, this endpoint should be protected, otherwise anyone
    // can come in and mutate the collection as the collection is a shared object.
    /// Mutably borrows SVG data from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` is not registered on the `Collection`
    fun borrow_collection_svg_mut<T>(
        collection: &mut Collection<T>,
    ): &mut vector<u8> {
        assert_collection_svg(collection);
        let domain: &mut Svg =
            collection::borrow_domain_mut(Witness {}, collection);
        &mut domain.svg
    }

    /// Adds `Svg` to `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` domain already exists
    public fun add_domain_collection<T>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        svg: vector<u8>,
    ) {
        assert!(!has_domain_collection(collection), EEXISTING_SVG_DOMAIN);
        collection::add_domain(&Witness {}, collection, new(svg));
    }

    // === Assertions ===

    public fun has_svg(nft_uid: &UID): bool {
        df::exists_(nft_uid, SvgKey {})
    }

    /// Asserts that `Svg` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` is not registered
    public fun assert_svg(nft_uid: &UID) {
        assert!(df::exists_(nft_uid, SvgKey {}), EUNDEFINED_SVG_DOMAIN)
    }

    /// Asserts that `Svg` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` is not registered
    public fun assert_collection_svg<T>(collection: &Collection<T>) {
        assert!(has_domain_collection(collection), EUNDEFINED_SVG_DOMAIN);
    }
}
