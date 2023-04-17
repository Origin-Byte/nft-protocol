/// Module containing `Supply` type
///
/// `Supply` tracks the supply of a given object type or an accumualtion of
/// actions. It tracks the current supply and guarantees that it cannot surpass
/// the maximum supply defined. Among others, this is used to keep track of
/// NFT supply for collections.
///
/// A `Collection` with a defined `Supply` has a regulated supply.
/// Collections can have a ceiling on the maximum supply and keep track
/// of the current supply, whilst unregulated policies have no supply
/// constraints nor they keep track of the number of minted objects.
module nft_protocol::supply {
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::utils_supply;
    use nft_protocol::witness::Witness as DelegatedWitness;

    use sui::object::UID;
    use sui::dynamic_field as df;

    /// `Supply` was not defined
    ///
    /// Call `supply::add_domain` or to add `Supply`.
    const EUndefinedSupply: u64 = 1;

    /// `Supply` already defined
    ///
    /// Call `supply::borrow_domain` to borrow domain.
    const EExistingSupply: u64 = 2;

    /// `Supply` is frozen
    const ESupplyFrozen: u64 = 3;

    /// `Supply` tracks supply parameters for type `T`
    ///
    /// `Supply` can be frozen, therefore making it impossible to change the
    /// maximum supply.
    struct Supply<phantom T> has store, drop {
        frozen: bool,
        inner: utils_supply::Supply,
    }

    /// Creates a new `Supply`
    public fun new<T>(
        _witness: DelegatedWitness<T>,
        max: u64,
        frozen: bool
    ): Supply<T> {
        Supply { frozen, inner: utils_supply::new(max) }
    }

    /// Borrows the underlying supply object
    public fun borrow_inner<T>(supply: &Supply<T>): &utils_supply::Supply {
        &supply.inner
    }

    // === Writer Functions ===

    /// Increases maximum for `Supply<T>`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if `Supply<T>` is frozen.
    public fun increase_supply_ceil<T>(
        _witness: DelegatedWitness<T>,
        supply: &mut Supply<T>,
        value: u64,
    ) {
        assert_not_frozen(supply);
        utils_supply::increase_maximum(&mut supply.inner, value)
    }

    /// Increases maximum for `Supply<T>`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if `Supply<T>` is not defined on object or is frozen.
    public fun increase_supply_ceil_nft<T>(
        witness: DelegatedWitness<T>,
        object: &mut UID,
        value: u64,
    ) {
        let supply = borrow_domain_mut(object);
        increase_supply_ceil(witness, supply, value);
    }

    /// Decreases maximum for `Supply<T>`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if `Supply<T>` is frozen or maximum supply would become lower
    /// than current supply.
    public fun decrease_supply_ceil<T>(
        _witness: DelegatedWitness<T>,
        supply: &mut Supply<T>,
        value: u64,
    ) {
        assert_not_frozen(supply);
        utils_supply::decrease_maximum(&mut supply.inner, value)
    }

    /// Decreases maximum for `Supply<T>`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// - `Supply<T>` is not defined
    /// - Supply is frozen
    /// - Maximum supply would become lower than current supply
    public fun decrease_supply_ceil_nft<T>(
        witness: DelegatedWitness<T>,
        object: &mut UID,
        value: u64,
    ) {
        let supply = borrow_domain_mut(object);
        decrease_supply_ceil(witness, supply, value)
    }

    /// Freezes supply in `Supply` field in the object of type `T`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if `Supply<T>` is already frozen.
    public fun freeze_supply<T>(
        _witness: DelegatedWitness<T>,
        supply: &mut Supply<T>,
    ) {
        assert_not_frozen(supply);
        supply.frozen = true;
    }

    /// Freezes supply in `Supply` field in the object of type `T`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if `Supply<T>` is not defined or is already frozen.
    public fun freeze_supply_nft<T>(
        witness: DelegatedWitness<T>,
        object: &mut UID,
    ) {
        let supply = borrow_domain_mut(object);
        freeze_supply(witness, supply)
    }

    /// Increments current supply.
    ///
    /// This function should be called when an NFT is minted, if it's type has
    /// a supply.
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `Supply<T>`.
    ///
    /// #### Panics
    ///
    /// Panics if new maximum supply exceeds maximum.
    public fun increment<T>(
        _witness: DelegatedWitness<T>,
        supply: &mut Supply<T>,
        value: u64
    ) {
        utils_supply::increment(&mut supply.inner, value)
    }

    /// Decrements current supply.
    ///
    /// This function should be called when an NFT is minted, if it's type has
    /// a supply.
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `Supply<T>`.
    ///
    /// #### Panics
    ///
    /// Panics if new maximum supply exceeds maximum.
    public fun decrement<T>(
        _witness: DelegatedWitness<T>,
        supply: &mut Supply<T>,
        value: u64
    ) {
        utils_supply::decrement(&mut supply.inner, value)
    }

    /// Merge two `Supply` to one
    ///
    /// Ideally, the merged `Supply` will have been extended from the original
    /// `Supply`, as otherwise it may not be possible to merge the two
    /// supplies.
    ///
    /// Any excess supply on the merged `Supply` will be decremented from the
    /// original supply.
    ///
    /// #### Panics
    ///
    /// Panics if total supply will cause maximum or zero supply to be
    /// exceeded.
    public fun merge<T>(supply: &mut Supply<T>, other: Supply<T>) {
        let other = delete(other);
        utils_supply::merge(&mut supply.inner, other);
    }

    /// Split one `Supply` into two.
    ///
    /// #### Panics
    ///
    /// Panics if `split_max` is larger remaining supply
    public fun split<T>(
        supply: &mut Supply<T>,
        split_max: u64,
    ): Supply<T> {
        let inner = utils_supply::split(&mut supply.inner, split_max);
        Supply { frozen: true, inner }
    }

    /// Returns `true` if frozen
    public fun is_frozen<T>(supply: &Supply<T>): bool {
        supply.frozen
    }

    /// Returns maximum supply
    public fun get_max<T>(supply: &Supply<T>): u64 {
        utils_supply::get_max(&supply.inner)
    }

    /// Returns current supply
    public fun get_current<T>(supply: &Supply<T>): u64 {
        utils_supply::get_current(&supply.inner)
    }

    /// Returns remaining supply
    public fun get_remaining<T>(supply: &Supply<T>): u64 {
        utils_supply::get_remaining(&supply.inner)
    }

    // === Interoperability ===

    /// Returns whether `Supply` is registered on object
    public fun has_domain<T>(nft: &UID): bool {
        df::exists_with_type<Marker<Supply<T>>, Supply<T>>(
            nft, utils::marker(),
        )
    }

    /// Borrows `Supply` from object
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` is not registered on the object
    public fun borrow_domain<T>(nft: &UID): &Supply<T> {
        assert_supply<T>(nft);
        df::borrow(nft, utils::marker<Supply<T>>())
    }

    /// Mutably borrows `Supply` from object
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` is not registered on the object
    public fun borrow_domain_mut<T>(nft: &mut UID): &mut Supply<T> {
        assert_supply<T>(nft);
        df::borrow_mut(nft, utils::marker<Supply<T>>())
    }

    /// Adds `Supply` to object
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` domain already exists
    public fun add_domain<T>(
        nft: &mut UID,
        domain: Supply<T>,
    ) {
        assert_no_supply<T>(nft);
        df::add(nft, utils::marker<Supply<T>>(), domain);
    }

    /// Adds new `Supply` to object
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` domain already exists
    public fun add_new<T>(
        witness: DelegatedWitness<T>,
        object: &mut UID,
        max: u64,
        frozen: bool,
    ) {
        add_domain(object, new<T>(witness, max, frozen))
    }

    /// Remove `Supply` from object
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` domain doesnt exist
    public fun remove_domain<T>(object: &mut UID): Supply<T> {
        assert_supply<T>(object);
        df::remove(object, utils::marker<Supply<T>>())
    }

    /// Delete `Supply`
    public fun delete<T>(supply: Supply<T>): utils_supply::Supply {
        let Supply { frozen: _, inner } = supply;
        inner
    }

    // === Assertions ===

    /// Asserts that current supply is zero
    ///
    /// #### Panics
    ///
    /// Panics if supply is non-zero.
    public fun assert_zero<T>(supply: &Supply<T>) {
        utils_supply::assert_zero(&supply.inner)
    }

    /// Asserts that supply is not frozen
    ///
    /// #### Panics
    ///
    /// Panics if supply is not frozen.
    public fun assert_not_frozen<T>(supply: &Supply<T>) {
        assert!(!supply.frozen, ESupplyFrozen)
    }

    /// Asserts that `Supply` is registered on object
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` is not registered
    public fun assert_supply<T>(nft: &UID) {
        assert!(has_domain<T>(nft), EUndefinedSupply);
    }

    /// Asserts that `Supply` is not registered on object
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` is registered
    public fun assert_no_supply<T>(nft: &UID) {
        assert!(!has_domain<T>(nft), EExistingSupply);
    }
}
