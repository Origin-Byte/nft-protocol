/// Module of collection `SupplyDomain`
///
/// A `Collection` with a defined `SupplyDomain` has a regulated supply.
/// Collections can have a ceiling on the maximum supply and keep track
/// of the current supply, whilst unregulated policies have no supply
/// constraints nor they keep track of the number of minted objects.
///
/// Regulated policies are enforced by
module nft_protocol::supply_domain {
    use sui::transfer;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use nft_protocol::collection::{Self, Collection, MintCap};
    use nft_protocol::supply::{Self, Supply};

    friend nft_protocol::warehouse;

    struct SupplyDomain<phantom C> has key, store {
        id: UID,
        supply: Supply,
    }

    /// Creates a `SupplyDomain`
    fun new<C>(max: u64, frozen: bool, ctx: &mut TxContext): SupplyDomain<C> {
        SupplyDomain {
            id: object::new(ctx),
            supply: supply::new(max, frozen),
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
        &domain.supply
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
        &mut domain.supply
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
        ctx: &mut TxContext,
    ) {
        collection::add_domain(collection, mint_cap, new<C>(max, frozen, ctx));
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
        let SupplyDomain<C> { id, supply } =
            collection::remove_domain(Witness {}, collection);
        supply::assert_zero(&supply);
        object::delete(id);
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
    /// `Inventory`.
    ///
    /// The extend value is used as the maximum supply for the new
    /// `RegulatedMintCap`, while the current supply of the existing supply is
    /// incremented by the value.
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
        ctx: &mut TxContext,
    ): RegulatedMintCap<C> {
        let collection_id = object::id(collection);
        let supply = supply_mut(collection);
        RegulatedMintCap {
            id: object::new(ctx),
            collection_id,
            supply: supply::extend(supply, value)
        }
    }

    /// Delegate partial `DelegatedSupply<C>` for use in composing an
    /// `Inventory` and transfer to transaction sender.
    ///
    /// The extend value is used as the maximum supply for the new
    /// `RegulatedMintCap`, while the current supply of the existing supply is
    /// incremented by the value.
    ///
    /// Requires that collection supply is frozen.
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated, supply is not frozen, or if there
    /// is no excess supply to delegate a supply of `value`.
    public entry fun delegate_and_transfer<C>(
        collection: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        value: u64,
        ctx: &mut TxContext,
    ) {
        let delegated = delegate(collection, mint_cap, value, ctx);
        transfer::transfer(delegated, tx_context::sender(ctx));
    }

    /// Merge delegated `RegulatedMintCap`
    ///
    /// Any excess supply on the merged `RegulatedMintCap` will be decremented
    /// from the original `Supply`.
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated.
    public entry fun merge_delegated<C>(
        collection: &mut Collection<C>,
        delegated: RegulatedMintCap<C>,
    ) {
        let supply = supply_mut(collection);
        let RegulatedMintCap<C> { id, collection_id: _, supply: delegated } = delegated;
        object::delete(id);
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

    // === RegulatedMintCap ===

    /// `RegulatedMintCap<C>` delegates the capability to it's owner to mint
    /// `Nft<C>` from collections with regulated supply.
    struct RegulatedMintCap<phantom C> has key, store {
        /// `RegulatedMintCap` ID
        id: UID,
        /// ID of the `Collection` that `RegulatedMintCap` controls
        ///
        /// Intended for discovery.
        collection_id: ID,
        /// Supply that `RegulatedMintCap` is entitled to mint
        supply: Supply,
    }

    public fun delegated_supply<C>(delegated: &RegulatedMintCap<C>): &Supply {
        &delegated.supply
    }

    /// Increments the delegated supply of `Inventory`
    ///
    /// This endpoint must be called before a new `Nft` object is created to
    /// ensure that global supply tracking remains consistent.
    ///
    /// #### Panics
    ///
    /// Panics if delegated supply is exceeded.
    public entry fun mint_supply<C>(
        delegated: &mut RegulatedMintCap<C>,
        value: u64,
    ) {
        supply::increment(&mut delegated.supply, value);
    }
}
