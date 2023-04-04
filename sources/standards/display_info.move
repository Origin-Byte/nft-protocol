/// Module of the `DisplayInfo`
module nft_protocol::display_info {
    use std::string::String;

    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::utils::{Self, Marker};

    /// `DisplayInfo` was not defined
    ///
    /// Call `display_info::add_domain` to add `DisplayInfo`.
    const EUndefinedDisplay: u64 = 1;

    /// `DisplayInfo` already defined
    ///
    /// Call `display_info::borrow_domain` to borrow domain.
    const EExistingDisplay: u64 = 2;

    struct DisplayInfo has store, drop {
        name: String,
        description: String,
    }

    /// Creates new `DisplayInfo`
    public fun new(name: String, description: String): DisplayInfo {
        DisplayInfo { name, description }
    }

    // === Writer Functions ===

    /// Changes name string in the object field `DisplayInfo` of the object type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `Marker<DisplayInfo>` does not exist.
    public fun change_name(
        display_info: &mut DisplayInfo,
        new_name: String,
    ) {
        display_info.name = new_name;
    }


    /// Changes description string in the object field `DisplayInfo` of the object type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `Marker<DisplayInfo>` does not exist.
    public fun change_description(
        display_info: &mut DisplayInfo,
        new_description: String,
    ) {
        display_info.description = new_description;
    }

    // === Getter Functions & Static Mutability Accessors ===

    /// Borrows underlying `DisplayInfo` name string.
    public fun get_name(
        display_info: &DisplayInfo,
    ): &String {
        &display_info.name
    }

    /// Borrows underlying `DisplayInfo` description string.
    public fun get_description(
        display_info: &DisplayInfo,
    ): &String {
        &display_info.description
    }

    /// Mutably borrows underlying `DisplayInfo` name string.
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `DisplayInfo`.
    public fun get_name_mut(
        display_info: &mut DisplayInfo,
    ): &String {
        &mut display_info.name
    }

    /// Mutably borrows underlying `DisplayInfo` description string.
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `DisplayInfo`.
    public fun get_description_mut(
        display_info: &mut DisplayInfo,
    ): &String {
        &mut display_info.description
    }


    // === Interoperability ===

    /// Returns whether `DisplayInfo` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<DisplayInfo>, DisplayInfo>(
            nft, utils::marker(),
        )
    }

    /// Borrows `DisplayInfo` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `DisplayInfo` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &DisplayInfo {
        assert_display(nft);
        df::borrow(nft, utils::marker<DisplayInfo>())
    }

    /// Mutably borrows `DisplayInfo` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `DisplayInfo` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut DisplayInfo {
        assert_display(nft);
        df::borrow_mut(nft, utils::marker<DisplayInfo>())
    }

    /// Adds `DisplayInfo` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `DisplayInfo` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: DisplayInfo,
    ) {
        assert_no_display(nft);
        df::add(nft, utils::marker<DisplayInfo>(), domain);
    }

    /// Remove `DisplayInfo` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `DisplayInfo` domain doesnt exist
    public fun remove_domain(nft: &mut UID): DisplayInfo {
        assert_display(nft);
        df::remove(nft, utils::marker<DisplayInfo>())
    }

    // === Assertions ===

    /// Asserts that `DisplayInfo` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `DisplayInfo` is not registered
    public fun assert_display(nft: &UID) {
        assert!(has_domain(nft), EUndefinedDisplay);
    }

    /// Asserts that `DisplayInfo` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `DisplayInfo` is registered
    public fun assert_no_display(nft: &UID) {
        assert!(!has_domain(nft), EExistingDisplay);
    }
}
