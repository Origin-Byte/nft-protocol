/// Module of `DisplayDomain` used to provide a `Display` implementation
module nft_protocol::display {
    use std::string::String;

    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::utils::{Self, Marker};

    /// `DisplayDomain` was not defined
    ///
    /// Call `display::add_domain` to add `DisplayDomain`.
    const EUndefinedDisplay: u64 = 1;

    /// `DisplayDomain` already defined
    ///
    /// Call `display::borrow_domain` to borrow domain.
    const EExistingDisplay: u64 = 2;

    struct DisplayDomain has drop, store {
        name: String,
        description: String,
    }

    /// Gets name of `DisplayDomain`
    public fun name(domain: &DisplayDomain): &String {
        &domain.name
    }

    /// Gets description of `DisplayDomain`
    public fun description(domain: &DisplayDomain): &String {
        &domain.description
    }

    /// Creates a new `DisplayDomain` with name and description
    public fun new(
        name: String,
        description: String,
    ): DisplayDomain {
        DisplayDomain { name, description }
    }

    /// Sets name of `DisplayDomain`
    public fun set_name<T>(
        domain: &mut DisplayDomain,
        name: String,
    ) {
        domain.name = name;
    }

    /// Sets description of `DisplayDomain`
    public fun set_description<T>(
        domain: &mut DisplayDomain,
        description: String,
    ) {
        domain.description = description;
    }

    // === Interoperability ===

    /// Returns whether `DisplayDomain` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<DisplayDomain>, DisplayDomain>(
            nft, utils::marker(),
        )
    }

    /// Borrows `DisplayDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `DisplayDomain` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &DisplayDomain {
        assert_display(nft);
        df::borrow(nft, utils::marker<DisplayDomain>())
    }

    /// Mutably borrows `DisplayDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `DisplayDomain` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut DisplayDomain {
        assert_display(nft);
        df::borrow_mut(nft, utils::marker<DisplayDomain>())
    }

    /// Adds `DisplayDomain` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `DisplayDomain` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: DisplayDomain,
    ) {
        assert_no_display(nft);
        df::add(nft, utils::marker<DisplayDomain>(), domain);
    }

    /// Remove `DisplayDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `DisplayDomain` domain doesnt exist
    public fun remove_domain(nft: &mut UID): DisplayDomain {
        assert_display(nft);
        df::remove(nft, utils::marker<DisplayDomain>())
    }

    // === Assertions ===

    /// Asserts that `AttributesDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `AttributesDomain` is not registered
    public fun assert_display(nft: &UID) {
        assert!(has_domain(nft), EUndefinedDisplay);
    }

    /// Asserts that `AttributesDomain` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `AttributesDomain` is registered
    public fun assert_no_display(nft: &UID) {
        assert!(!has_domain(nft), EExistingDisplay);
    }
}
