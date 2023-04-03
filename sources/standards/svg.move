/// Module of the `SvgDomain`
///
/// Used to associate SVG data with `Collection` or `Nft`.
///
/// Composable NFTs with children registering `SvgDomain` can declare them with
/// `ComposableSvgDomain` to compose all SVG data into one definition.
module nft_protocol::svg {
    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::utils::{Self, Marker};

    /// `SvgDomain` was not defined
    ///
    /// Call `svg::add_domain` to add `SvgDomain`.
    const EUndefinedSvg: u64 = 1;

    /// `SvgDomain` already defined
    ///
    /// Call `svg::borrow_domain` to borrow domain.
    const EExistingSvg: u64 = 2;

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

    /// Borrow SVG from `SvgDomain`
    public fun borrow_svg(domain: &SvgDomain): &vector<u8> {
        &domain.svg
    }

    /// Sets SVG data of `SvgDomain`
    ///
    /// `ComposableSvgDomain` will not be automatically updated and
    /// `composable_svg::regenerate` must be called
    public fun set_svg<C>(
        domain: &mut SvgDomain,
        svg: vector<u8>,
    ) {
        domain.svg = svg;
    }

    // === Interoperability ===

    /// Returns whether `SvgDomain` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<SvgDomain>, SvgDomain>(
            nft, utils::marker(),
        )
    }

    /// Borrows `SvgDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &SvgDomain {
        assert_svg(nft);
        df::borrow(nft, utils::marker<SvgDomain>())
    }

    /// Mutably borrows `SvgDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut SvgDomain {
        assert_svg(nft);
        df::borrow_mut(nft, utils::marker<SvgDomain>())
    }

    /// Adds `SvgDomain` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: SvgDomain,
    ) {
        assert_no_svg(nft);
        df::add(nft, utils::marker<SvgDomain>(), domain);
    }

    /// Remove `SvgDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` domain doesnt exist
    public fun remove_domain(nft: &mut UID): SvgDomain {
        assert_svg(nft);
        df::remove(nft, utils::marker<SvgDomain>())
    }

    // === Assertions ===

    /// Asserts that `SvgDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` is not registered
    public fun assert_svg(nft: &UID) {
        assert!(has_domain(nft), EUndefinedSvg);
    }

    /// Asserts that `SvgDomain` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `SvgDomain` is registered
    public fun assert_no_svg(nft: &UID) {
        assert!(!has_domain(nft), EExistingSvg);
    }
}
