/// Module of collection `SupplyDomain`
///
/// A `Collection` with a defined `SupplyDomain` has a regulated supply.
/// Collections can have a ceiling on the maximum supply and keep track
/// of the current supply, whilst unregulated policies have no supply
/// constraints nor they keep track of the number of minted objects.
///
/// Regulated policies are enforced by
module nft_protocol::supply_domain {
    use nft_protocol::err;
    use nft_protocol::collection::{Self, Collection, MintCap};
    use nft_protocol::supply::{Self, Supply};

    friend nft_protocol::inventory;

    struct SupplyDomain<phantom C> has store {
        supply: DelegatedSupply<C>,
    }

    /// Creates a `SupplyDomain`
    fun new<C>(max: u64, frozen: bool): SupplyDomain<C> {
        SupplyDomain {
            supply: DelegatedSupply { supply: supply::new(max, frozen) }
        }
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Borrows `Supply` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `SupplyDomain` is not registered on `Collection`.
    public fun supply<C>(collection: &Collection<C>): &Supply {
        assert_regulated(collection);
        let domain: &SupplyDomain<C> = collection::borrow_domain(collection);
        &domain.supply.supply
    }

    /// Mutably borrows `Supply` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `SupplyDomain` is not registered on `Collection`.
    fun supply_mut<C>(collection: &mut Collection<C>): &mut Supply {
        assert_regulated(collection);
        let domain: &mut SupplyDomain<C> =
            collection::borrow_domain_mut(Witness {}, collection);
        &mut domain.supply.supply
    }

    /// Returns whether `Collection` supply is regulated
    public fun is_regulated<C>(collection: &Collection<C>): bool {
        collection::has_domain<C, SupplyDomain<C>>(collection)
    }

    /// Regulate the supply of `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if collection is already regulated.
    public entry fun regulate<C>(
        collection: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        max: u64,
        frozen: bool,
    ) {
        collection::add_domain(collection, mint_cap, new<C>(max, frozen));
    }

    /// Deregulate the supply of `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated or supply is non-zero or frozen.
    public entry fun deregulate<C>(
        collection: &mut Collection<C>,
        _mint_cap: &MintCap<C>,
    ) {
        supply::assert_not_frozen(supply(collection));
        let SupplyDomain<C> { supply } =
            collection::remove_domain(Witness {}, collection);
        let DelegatedSupply<C> { supply } = supply;
        supply::assert_zero(&supply);
    }

    /// Freeze the supply of `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated or supply was already frozen.
    public entry fun freeze_supply<C>(
        collection: &mut Collection<C>,
        _mint_cap: &MintCap<C>,
    ) {
        supply::freeze_supply(supply_mut(collection))
    }

    /// Delegate partial `DelegatedSupply<C>` for use in composing an
    /// `Inventory<C>`.
    ///
    /// Requires that collection supply is frozen.
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated, supply is not frozen, or if there
    /// is no excess supply to delegate a supply of `value`.
    public fun delegate<C>(
        collection: &mut Collection<C>,
        _mint_cap: &MintCap<C>,
        value: u64,
    ): DelegatedSupply<C> {
        let supply = supply_mut(collection);
        DelegatedSupply {
            supply: supply::extend(supply, value)
        }
    }

    /// Merge delegated supply
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated.
    public fun merge_delegated<C>(
        collection: &mut Collection<C>,
        delegated: DelegatedSupply<C>,
    ) {
        let supply = supply_mut(collection);
        let DelegatedSupply<C> { supply: delegated } = delegated;
        supply::merge(supply, delegated);
    }

    /// Increases maximum supply
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated or supply is frozen.
    public entry fun increase_max_supply<C>(
        collection: &mut Collection<C>,
        _mint_cap: &MintCap<C>,
        value: u64,
    ) {
        supply::increase_maximum(supply_mut(collection), value)
    }

    /// Decreases maximum supply
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated, supply is frozen, or if new
    /// maximum supply is smaller than current supply.
    public entry fun decrease_max_supply<C>(
        collection: &mut Collection<C>,
        _mint_cap: &MintCap<C>,
        value: u64
    ) {
        supply::decrease_maximum(supply_mut(collection), value)
    }

    /// Increments current supply
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated or supply exceeds maximum.
    public fun increment_supply<C>(
        collection: &mut Collection<C>,
        _mint_cap: &MintCap<C>,
        value: u64
    ) {
        supply::increment(supply_mut(collection), value)
    }

    /// Increments current supply
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated.
    public fun decrement_supply<C>(
        collection: &mut Collection<C>,
        _mint_cap: &MintCap<C>,
        value: u64
    ) {
        supply::decrement(supply_mut(collection), value)
    }

    // === Assertions ===

    /// Assert that the `Collection` supply is regulated
    public fun assert_regulated<C>(collection: &Collection<C>) {
        assert!(is_regulated(collection), err::supply_not_regulated());
    }

    /// Assert that the `Collection` supply is not regulated
    public fun assert_unregulated<C>(collection: &Collection<C>) {
        assert!(!is_regulated(collection), err::supply_regulated());
    }

    // === DelegatedSupply ===

    /// Type protected object which allows `Collection` locked supply to be
    /// delegated to `Inventory` objects.
    struct DelegatedSupply<phantom C> has store {
        supply: Supply,
    }

    public fun delegated_supply<C>(delegated: &DelegatedSupply<C>): &Supply {
        &delegated.supply
    }

    public(friend) fun delegated_supply_mut<C>(
        delegated: &mut DelegatedSupply<C>
    ): &mut Supply {
        &mut delegated.supply
    }
}
