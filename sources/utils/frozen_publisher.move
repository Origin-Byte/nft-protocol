module nft_protocol::frozen_publisher {
    use nft_protocol::utils;
    use nft_protocol::witness::Witness as DelegatedWitness;
    use std::ascii;
    use std::string::{Self, utf8, sub_string};
    use sui::display::{Self, Display};
    use sui::object::{Self, UID};
    use sui::package::{Self, Publisher};
    use sui::transfer;
    use sui::tx_context::TxContext;

    struct FROZEN_PUBLISHER has drop {}

    struct FrozenPublisher has key {
        id: UID,
        inner: Publisher,
    }

    fun init(otw: FROZEN_PUBLISHER, ctx: &mut TxContext) {
        let publisher = package::claim(otw, ctx);
        let display = display::new<FrozenPublisher>(&publisher, ctx);

        display::add(&mut display, utf8(b"name"), utf8(b"FrozenPublisher"));
        display::add(&mut display, utf8(b"link"), utils::originbyte_docs_url());
        display::add(
            &mut display,
            utf8(b"description"),
            utf8(b"Enables access to Publisher via witness::Witness"),
        );

        transfer::public_freeze_object(display);
        package::burn_publisher(publisher);
    }

    public fun freeze_from_otw<OTW: drop>(otw: OTW, ctx: &mut TxContext) {
        public_freeze_object(new(package::claim(otw, ctx), ctx));
    }

    public fun new(inner: Publisher, ctx: &mut TxContext): FrozenPublisher {
        FrozenPublisher { id: object::new(ctx), inner }
    }

    public fun public_freeze_object(self: FrozenPublisher) {
        transfer::freeze_object(self);
    }

    public fun pkg(self: &FrozenPublisher): &ascii::String {
        package::published_package(&self.inner)
    }

    public fun mod(self: &FrozenPublisher): &ascii::String {
        package::published_module(&self.inner)
    }

    public fun borrow_publisher<T>(
        _witness: DelegatedWitness<T>, self: &FrozenPublisher,
    ): &Publisher {
        assert!(package::from_module<T>(&self.inner), 0);
        &self.inner
    }

    /// FrozenPublisher has Publisher from OTW of PARENT.
    ///
    /// PARENT: a::b::Foo<c::d::Bar<..>>
    /// INNER: c::d::Bar<..>
    ///
    /// Asserts that inner type of Foo equals to the Bar.
    public fun new_display_for_inner_generic<PARENT: key, INNER>(
        _witness: DelegatedWitness<INNER>, self: &FrozenPublisher, ctx: &mut TxContext,
    ): Display<PARENT> {
        let (_, _, parent) = utils::get_package_module_type<PARENT>(); // Foo<c::d::Bar<..>>
        let open_chicken = string::index_of(&parent, &utf8(b"<"));

        let inner = sub_string(&parent, open_chicken + 1, string::length(&parent) - 1); // c::d::Bar<..>

        let (pkg, mod, typ) = utils::get_package_module_type_raw(inner);
        let (expected_pkg, expected_mod, expected_typ) = utils::get_package_module_type<PARENT>();
        assert!(pkg == expected_pkg, 0);
        assert!(mod == expected_mod, 0);
        assert!(typ == expected_typ, 0);

        display::new(&self.inner, ctx)
    }
}
