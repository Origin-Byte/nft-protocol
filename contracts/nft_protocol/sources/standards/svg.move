/// Module of the `Svg`
///
/// Used to associate SVG data with `Collection` or `Nft`.
///
/// Composable NFTs with children registering `Svg` can declare them with
/// `ComposableSvg` to compose all SVG data into one definition.
module nft_protocol::svg {
    use std::vector;

    use sui::object::UID;
    use sui::dynamic_field as df;

    use ob_witness::marker::{Self, Marker};

    /// `Svg` was not defined
    ///
    /// Call `svg::add_domain` to add `Svg`.
    const EUndefinedSvg: u64 = 1;

    /// `Svg` already defined
    ///
    /// Call `svg::borrow_domain` to borrow domain.
    const EExistingSvg: u64 = 2;

    /// Domain for storing an associated SVG data
    struct Svg has store, drop {
        svg: vector<u8>,
    }

    /// Creates new `Svg`
    public fun new(svg: vector<u8>): Svg {
        Svg { svg }
    }

    /// Creates new `Svg`
    public fun new_empty(): Svg {
        Svg { svg: vector::empty() }
    }

    /// Borrow SVG from `Svg`
    public fun get_svg(domain: &Svg): &vector<u8> {
        &domain.svg
    }

    /// Set Svg` field
    public fun set_svg<C>(
        domain: &mut Svg,
        svg: vector<u8>,
    ) {
        domain.svg = svg;
    }

    // === Interoperability ===

    /// Returns whether `Svg` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<Svg>, Svg>(
            nft, marker::marker(),
        )
    }

    /// Borrows `Svg` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &Svg {
        assert_svg(nft);
        df::borrow(nft, marker::marker<Svg>())
    }

    /// Mutably borrows `Svg` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut Svg {
        assert_svg(nft);
        df::borrow_mut(nft, marker::marker<Svg>())
    }

    /// Adds `Svg` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: Svg,
    ) {
        assert_no_svg(nft);
        df::add(nft, marker::marker<Svg>(), domain);
    }

    /// Adds `Svg` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` domain already exists
    public fun add_new(nft: &mut UID, svg: vector<u8>) {
        add_domain(nft, new(svg))
    }

    /// Adds empty `Svg` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` domain already exists
    public fun add_empty(nft: &mut UID) {
        add_domain(nft, new_empty())
    }

    /// Remove `Svg` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` domain doesnt exist
    public fun remove_domain(nft: &mut UID): Svg {
        assert_svg(nft);
        df::remove(nft, marker::marker<Svg>())
    }

    // === Assertions ===

    /// Borrows Mutably the `Svg` field.
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` is not registered
    public fun assert_svg(nft: &UID) {
        assert!(has_domain(nft), EUndefinedSvg);
    }

    /// Asserts that `Svg` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Svg` is registered
    public fun assert_no_svg(nft: &UID) {
        assert!(!has_domain(nft), EExistingSvg);
    }
}
