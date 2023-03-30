/// Module of the `SvgDomain`
///
/// Used to associate SVG data with `Collection` or `Nft`.
///
/// Composable NFTs with children registering `SvgDomain` can declare them with
/// `ComposableSvgDomain` to compose all SVG data into one definition.
module nft_protocol::svg {
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::witness::Witness as DelegatedWitness;
    use nft_protocol::collection::{Self, Collection};

    /// `SvgDomain` was not defined
    ///
    /// Call `svg::add` or `svg::add_collection` to add `SvgDomain`.
    const EUNDEFINED_SVG_DOMAIN: u64 = 1;

    /// `SvgDomain` already defined
    ///
    /// Call `svg::borrow` or svg::borrow_collection` to borrow domain.
    const EEXISTING_SVG_DOMAIN: u64 = 2;

    /// Domain for storing an associated SVG data
    struct SvgDomain has store {
        svg: vector<u8>,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates new `SvgDomain`
    public fun new(svg: vector<u8>): SvgDomain {
        SvgDomain { svg }
    }

    /// Sets SVG data of `SvgDomain`
    ///
    /// `ComposableSvgDomain` will not be automatically updated and
    /// `composable_svg::regenerate` must be called
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` does not exist on `Nft`
    public fun set_svg<C>(
        _witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
        svg: vector<u8>,
    ) {
        let svg_data = borrow_svg_mut(nft);
        *svg_data = svg;
    }

    /// Sets SVG data of `SvgDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` does not exist on `Collection`
    public fun set_collection_svg<T>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        svg: vector<u8>,
    ) {
        let svg_data = borrow_collection_svg_mut(collection);
        *svg_data = svg;
    }

    // === Interoperability ===

    /// Returns whether `SvgDomain` is registered on `Nft`
    public fun has_domain<C>(nft: &Nft<C>): bool {
        nft::has_domain<C, SvgDomain>(nft)
    }

    /// Returns whether `SvgDomain` is registered on `Collection`
    public fun has_domain_collection<T>(collection: &Collection<T>): bool {
        collection::has_domain<T, SvgDomain>(collection)
    }

    /// Borrows SVG data from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` is not registered on the `Nft`
    public fun borrow_svg<C>(nft: &Nft<C>): &vector<u8> {
        assert_svg(nft);
        let domain: &SvgDomain = nft::borrow_domain(nft);
        &domain.svg
    }

    /// Mutably borrows SVG data from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` is not registered on the `Nft`
    fun borrow_svg_mut<C>(nft: &mut Nft<C>): &mut vector<u8> {
        assert_svg(nft);
        let domain: &mut SvgDomain = nft::borrow_domain_mut(Witness {}, nft);
        &mut domain.svg
    }

    /// Borrows SVG data from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` is not registered on the `Collection`
    public fun borrow_collection_svg<T>(collection: &Collection<T>): &vector<u8> {
        assert_collection_svg(collection);
        let domain: &SvgDomain = collection::borrow_domain(collection);
        &domain.svg
    }

    /// Mutably borrows SVG data from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` is not registered on the `Collection`
    fun borrow_collection_svg_mut<T>(
        collection: &mut Collection<T>,
    ): &mut vector<u8> {
        assert_collection_svg(collection);
        let domain: &mut SvgDomain =
            collection::borrow_domain_mut(Witness {}, collection);
        &mut domain.svg
    }

    /// Adds `SvgDomain` to `Nft`
    ///
    /// `ComposableSvgDomain` will not be automatically updated so
    /// `composable_svg::compose` and `composable_svg::regenerate` must be
    /// called.
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` domain already exists
    public fun add_domain<C>(
        _witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
        svg: vector<u8>,
    ) {
        assert!(!has_domain(nft), EEXISTING_SVG_DOMAIN);
        nft::add_domain(&Witness {}, nft, new(svg));
    }

    /// Adds `SvgDomain` to `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` domain already exists
    public fun add_domain_collection<T>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        svg: vector<u8>,
    ) {
        assert!(!has_domain_collection(collection), EEXISTING_SVG_DOMAIN);
        collection::add_domain(&Witness {}, collection, new(svg));
    }

    // === Assertions ===

    /// Asserts that `SvgDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` is not registered
    public fun assert_svg<C>(nft: &Nft<C>) {
        assert!(has_domain(nft), EUNDEFINED_SVG_DOMAIN);
    }

    /// Asserts that `SvgDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` is not registered
    public fun assert_collection_svg<T>(collection: &Collection<T>) {
        assert!(has_domain_collection(collection), EUNDEFINED_SVG_DOMAIN);
    }
}
