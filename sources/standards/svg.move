/// Module of the `Svg`
///
/// Used to associate SVG data with `Collection` or `Nft`.
///
/// Composable NFTs with children registering `Svg` can declare them with
/// `ComposableSvg` to compose all SVG data into one definition.
module nft_protocol::svg {
    use sui::dynamic_field as df;
    use sui::object::UID;

    use nft_protocol::utils::{
        assert_with_consumable_witness, UidType
    };
    use nft_protocol::consumable_witness::{Self as cw, ConsumableWitness};

    /// No field object `Svg` defined as a dynamic field.
    const EUNDEFINED_SVG_FIELD: u64 = 1;

    /// Field object `Svg` already defined as dynamic field.
    const ESVG_FIELD_ALREADY_EXISTS: u64 = 2;

    /// Domain for storing an associated SVG data
    struct Svg has store {
        svg: vector<u8>,
    }

    struct SvgKey has store, copy, drop {}

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}


    // === Insert with ConsumableWitness ===


    /// Adds `Svg` as a dynamic field with key `SvgKey`.
    /// It adds svg from a `vector<u8>`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Svg`.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun add_svg<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        svg_vec: vector<u8>,
    ) {
        assert_has_not_svg(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let svg = new(svg_vec);

        cw::consume<T, Svg>(consumable, &mut svg);
        df::add(nft_uid, SvgKey {}, svg);
    }


    // === Get for call from external Module ===


    /// Creates new `Svg`
    public fun new(svg: vector<u8>): Svg {
        Svg { svg }
    }


    // === Field Borrow Functions ===


    /// Borrows immutably the `Svg` field.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `SvgKey` does not exist.
    public fun borrow_svg(
        nft_uid: &UID,
    ): &Svg {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_svg(nft_uid);
        df::borrow(nft_uid, SvgKey {})
    }

    /// Borrows Mutably the `Svg` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Svg`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `SvgKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun borrow_svg_mut<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>
    ): &mut Svg {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_svg(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let svg = df::borrow_mut<SvgKey, Svg>(
            nft_uid,
            SvgKey {}
        );
        cw::consume<T, Svg>(consumable, svg);

        svg
    }


    // === Writer Functions ===


    /// Sets SVG data of `Svg` field in the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Svg`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `SvgKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun set_svg<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        svg_vec: vector<u8>,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_svg(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let svg = borrow_mut_internal(nft_uid);
        svg.svg = svg_vec;

        cw::consume<T, Svg>(consumable, svg);
    }


    /// Sets SVG data of `Svg` field in the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Svg`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `SvgKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun burn_svg<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>
    ): vector<u8> {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_svg(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let svg = df::remove<SvgKey, Svg>(nft_uid, SvgKey {});
        cw::consume<T, Svg>(consumable, &mut svg);

        burn_svg_(svg)
    }


    // === Getter Functions & Static Mutability Accessors ===

    /// Immutably borrows svg as a `vector<u8>`
    public fun get_svg(
        svg: &mut Svg,
    ): &vector<u8> {
        &svg.svg
    }

    // TODO: Duplicate name
    /// Sets SVG data of `Svg` field in the NFT of type `T`.
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `Svg`.
    public fun set_svg_(
        svg: &mut Svg,
        new_svg: vector<u8>,
    ) {
        svg.svg = new_svg;
    }

    /// Destructs `Svg` field returns svg data as `vector<u8>`.
    ///
    /// Endpoint is unprotected as it relies on safetly the object `Svg` itself.
    public fun burn_svg_(
        svg: Svg,
    ): vector<u8> {
        let Svg { svg: svg_vec } = svg;

        svg_vec
    }


    // === Private Functions ===


    /// Borrows Mutably the `Svg` field.
    ///
    /// For internal use only.
    fun borrow_mut_internal(
        nft_uid: &mut UID,
    ): &mut Svg {
        df::borrow_mut<SvgKey, Svg>(
            nft_uid,
            SvgKey {}
        )
    }


    // === Assertions & Helpers ===


    /// Checks that a given NFT has a dynamic field with `SvgKey`
    public fun has_svg(
        nft_uid: &UID,
    ): bool {
        df::exists_(nft_uid, SvgKey {})
    }

    public fun assert_has_svg(nft_uid: &UID) {
        assert!(has_svg(nft_uid), EUNDEFINED_SVG_FIELD);
    }

    public fun assert_has_not_svg(nft_uid: &UID) {
        assert!(!has_svg(nft_uid), ESVG_FIELD_ALREADY_EXISTS);
    }
}
