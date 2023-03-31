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
    use sui::tx_context::TxContext;

    use nft_protocol::err;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::witness::Witness as DelegatedWitness;

    /// `SupplyDomain` was frozen
    const ESupplyFrozen: u64 = 1;

    /// `SupplyDomain` provides the source of truth of the total supply and
    /// delegated mint rights.
    struct SupplyDomain<phantom T> has store {
        mint_cap: MintCap<T>,
        supply: Supply,
        frozen: bool,
    }

    /// Creates a `SupplyDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `MintCap` is regulated as we expect the root `MintCap`
    /// created at `Collection` initialization to be provided. This will
    /// be the only `MintCap` with unregulated supply.
    fun new<T>(
        mint_cap: MintCap<T>,
        supply: u64,
        frozen: bool,
    ): SupplyDomain<T> {
        mint_cap::assert_unregulated(&mint_cap);
        SupplyDomain { mint_cap, supply: supply::new(supply), frozen }
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Borrows `Supply` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `SupplyDomain` is not registered on `Collection`.
    public fun domain<T>(collection: &Collection<T>): &SupplyDomain<T> {
        assert_regulated(collection);
        collection::borrow_domain(collection)
    }

    /// Mutably borrows `Supply` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `SupplyDomain` is not registered on `Collection`.
    fun domain_mut<T>(collection: &mut Collection<T>): &mut SupplyDomain<T> {
        assert_regulated(collection);
        collection::borrow_domain_mut(Witness {}, collection)
    }

    /// Returns whether `Collection` supply is regulated
    public fun is_regulated<T>(collection: &Collection<T>): bool {
        collection::has_domain<T, SupplyDomain<T>>(collection)
    }

    /// Regulate the supply of `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if collection is already regulated.
    public fun regulate<T, W: drop>(
        witness: W,
        mint_cap: MintCap<T>,
        collection: &mut Collection<T>,
        supply: u64,
        frozen: bool,
    ) {
        assert_unregulated(collection);
        collection::add_domain(
            witness, collection, new<T>(mint_cap, supply, frozen)
        );
    }

    /// Deregulate the supply of `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated or supply is non-zero or frozen.
    public fun deregulate<T>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
    ): MintCap<T> {
        assert_regulated(collection);
        let domain: SupplyDomain<T> =
            collection::remove_domain(Witness {}, collection);

        assert_not_frozen(&domain);
        let SupplyDomain<T> { mint_cap, supply: _, frozen: _ } = domain;

        mint_cap
    }

    /// Freeze the supply of `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated or supply was already frozen.
    public fun freeze_supply<T>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
    ) {
        let domain = domain_mut(collection);
        domain.frozen = true;
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
    public fun delegate<T>(
        collection: &mut Collection<T>,
        quantity: u64,
        ctx: &mut TxContext,
    ): MintCap<T> {
        let domain = domain_mut(collection);

        supply::increment(&mut domain.supply, quantity);
        mint_cap::delegate(&mut domain.mint_cap, quantity, ctx)
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
    public entry fun delegate_and_transfer<T>(
        collection: &mut Collection<T>,
        quantity: u64,
        receiver: address,
        ctx: &mut TxContext,
    ) {
        let delegated = delegate(collection, quantity, ctx);
        transfer::public_transfer(delegated, receiver);
    }

    /// Merge delegated `RegulatedMintCap`
    ///
    /// Any excess supply on the merged `RegulatedMintCap` will be decremented
    /// from the original `Supply`.
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated.
    public entry fun merge_delegated<T>(
        collection: &mut Collection<T>,
        delegated: MintCap<T>,
    ) {
        let domain = domain_mut(collection);

        supply::decrement(&mut domain.supply, mint_cap::supply(&delegated));
        mint_cap::merge(&mut domain.mint_cap, delegated);
    }

    /// Increases maximum supply
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated or supply is frozen.
    public entry fun increase_max_supply<T>(
        collection: &mut Collection<T>,
        _mint_cap: &MintCap<T>,
        value: u64,
    ) {
        let domain = domain_mut(collection);
        assert_not_frozen(domain);

        supply::increase_maximum(&mut domain.supply, value)
    }

    /// Decreases maximum supply
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated, supply is frozen, or if new
    /// maximum supply is smaller than current supply.
    public entry fun decrease_max_supply<T>(
        collection: &mut Collection<T>,
        _mint_cap: &MintCap<T>,
        value: u64
    ) {
        let domain = domain_mut(collection);
        assert_not_frozen(domain);

        supply::decrease_maximum(&mut domain.supply, value)
    }

    // === Assertions ===

    /// Assert that the `Collection` supply is regulated
    public fun assert_regulated<T>(collection: &Collection<T>) {
        assert!(is_regulated(collection), err::supply_not_regulated());
    }

    /// Assert that the `Collection` supply is not regulated
    public fun assert_unregulated<T>(collection: &Collection<T>) {
        assert!(!is_regulated(collection), err::supply_regulated());
    }

    /// Assert that `SupplyDomain` is frozen
    public fun assert_not_frozen<T>(domain: &SupplyDomain<T>) {
        assert!(!domain.frozen, ESupplyFrozen)
    }
}
