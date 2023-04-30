module ob_permissions::frozen_publisher {
    use std::ascii;
    use std::string::utf8;

    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::display::{Self, Display};
    use sui::package::{Self, Publisher};

    use ob_utils::utils::{Self, assert_same_module};
    use ob_permissions::witness::Witness as DelegatedWitness;

    struct FROZEN_PUBLISHER has drop {}

    struct FrozenPublisher has key {
        id: UID,
        inner: Publisher,
    }

    fun init(otw: FROZEN_PUBLISHER, ctx: &mut TxContext) {
        let publisher = package::claim(otw, ctx);
        let display = display::new<FrozenPublisher>(&publisher, ctx);

        display::add(&mut display, utf8(b"name"), utf8(b"FrozenPublisher"));
        display::add(&mut display, utf8(b"url"), utils::originbyte_docs_url());
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
    public fun new_display<PW: drop, Parent: key>(
        _parent_wit: PW,
        self: &FrozenPublisher,
        ctx: &mut TxContext,
    ): Display<Parent> {
        assert_same_module<PW, Parent>();

        display::new(&self.inner, ctx)
    }

    // === Test-Only Functions ===

    #[test_only]
    public fun get_frozen_publisher_for_test<OTW: drop>(otw: OTW, ctx: &mut TxContext): FrozenPublisher {
        let publisher = package::claim(otw, ctx);
        new(publisher, ctx)
    }
}
