module nft_protocol::flyweight_registry {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::TxContext;
    use sui::object_table::{Self, ObjectTable};

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::mint_cap::{
        MintCap, RegulatedMintCap, UnregulatedMintCap,
    };
    use nft_protocol::witness::Witness as DelegatedWitness;

    use nft_protocol::flyweight_archetype::{Self as archetype, Archetype};
    use nft_protocol::flyweight_mint_cap::ArchetypeMintCap;

    /// `RegistryDomain` not registered on `Collection`
    ///
    /// Call `flyweight::init_registry` on the `Collection`.
    const EUNDEFINED_ARCHETYPE_REGISTRY: u64 = 1;

    /// `Archetype` with the given is was not registered on `RegistryDomain`
    ///
    /// Call `flyweight::add_archetype` to add an `Archetype` to
    /// `RegistryDomain`.
    const EUNDEFINED_ARCHETYPE: u64 = 2;

    struct Witness has drop {}

    /// `RegistryDomain` object
    struct RegistryDomain<phantom C> has key, store {
        id: UID,
        table: ObjectTable<ID, Archetype<C>>,
    }

    /// Create a `RegistryDomain` object
    public fun new_registry<C>(ctx: &mut TxContext): RegistryDomain<C> {
        RegistryDomain<C> {
            id: object::new(ctx),
            table: object_table::new<ID, Archetype<C>>(ctx),
        }
    }

    /// Create a `RegistryDomain` object and register on `Collection`
    public entry fun init_registry<C>(
        witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ) {
        let registry = new_registry<C>(ctx);
        collection::add_domain(witness, collection, registry);
    }

    /// Returns whether `Archetype` with `ID` is registered on `RegistryDomain`
    public fun contains_archetype<C>(
        registry: &RegistryDomain<C>,
        archetype_id: ID,
    ): bool {
        object_table::contains(&registry.table, archetype_id)
    }

    /// Borrows `Archetype` from `RegistryDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `Archetype` does not exist on `RegistryDomain`.
    public fun borrow_archetype<C>(
        registry: &RegistryDomain<C>,
        archetype_id: ID,
    ): &Archetype<C> {
        assert_archetype(registry, archetype_id);
        object_table::borrow(&registry.table, archetype_id)
    }

    /// Mutably borrows `Archetype` from `RegistryDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `Archetype` does not exist on `RegistryDomain`.
    fun borrow_archetype_mut<C>(
        registry: &mut RegistryDomain<C>,
        archetype_id: ID,
    ): &mut Archetype<C> {
        assert_archetype(registry, archetype_id);
        object_table::borrow_mut(&mut registry.table, archetype_id)
    }

    /// Add `Archetype` to `RegistryDomain`
    public entry fun add_archetype<C>(
        _mint_cap: &MintCap<C>,
        registry: &mut RegistryDomain<C>,
        archetype: Archetype<C>,
    ) {
        object_table::add<ID, Archetype<C>>(
            &mut registry.table,
            object::id(&archetype),
            archetype,
        );
    }

    /// Freeze `Archetype` supply in `Collection`
    public entry fun freeze_archetype_supply<C>(
        collection: &mut Collection<C>,
        archetype_id: ID,
    ) {
        let registry = borrow_registry_mut(collection);
        let archetype = borrow_archetype_mut(registry, archetype_id);
        archetype::freeze_supply(archetype);
    }

    // === Interoperability ===

    /// Return whether `Collection` has defined an archetype `RegistryDomain`
    public fun is_archetypal<C>(collection: &Collection<C>): bool {
        collection::has_domain<C, RegistryDomain<C>>(collection)
    }

    /// Add `RegistryDomain` to `Collection`
    public fun add_registry<C>(
        witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        registry: RegistryDomain<C>,
    ) {
        collection::add_domain(witness, collection, registry);
    }

    /// Borrows `RegistryDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Collection` does not have a `RegistryDomain`.
    public fun borrow_registry<C>(collection: &Collection<C>): &RegistryDomain<C> {
        assert_archetypal(collection);
        collection::borrow_domain(collection)
    }

    /// Mutably borrows `RegistryDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Collection` does not have a `RegistryDomain`.
    fun borrow_registry_mut<C>(collection: &mut Collection<C>): &mut RegistryDomain<C> {
        assert_archetypal(collection);
        collection::borrow_domain_mut(Witness {}, collection)
    }

    /// Add `Archetype` to `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Collection` does not have a `RegistryDomain`.
    public entry fun add_collection_archetype<C>(
        _mint_cap: &MintCap<C>,
        collection: &mut Collection<C>,
        archetype: Archetype<C>,
    ) {
        let registry = borrow_registry_mut(collection);
        object_table::add(
            &mut registry.table,
            object::id(&archetype),
            archetype,
        );
    }

    /// Delegates archetype minting rights while maintaining `Collection` and
    /// `Archetype` level supply invariants.
    ///
    /// The argument of `RegulatedMintCap` implies that supply is at least
    /// controlled at the `Collection` level.
    ///
    /// #### Panics
    ///
    /// Panics if archetype `RegistryDomain` is not registered on `Collection`
    /// or `Archetype` does not exist.
    public fun delegate<C>(
        mint_cap: RegulatedMintCap<C>,
        collection: &mut Collection<C>,
        archetype_id: ID,
        ctx: &mut TxContext,
    ): ArchetypeMintCap<C> {
        let registry = borrow_registry_mut(collection);
        let archetype = borrow_archetype_mut(registry, archetype_id);
        archetype::delegate_regulated(mint_cap, archetype, ctx)
    }

    /// Delegates archetype minting rights while maintaining `Collection` and
    /// `Archetype` level supply invariants.
    ///
    /// The argument of `RegulatedMintCap` implies that supply is at least
    /// controlled at the `Collection` level.
    ///
    /// #### Panics
    ///
    /// Panics if archetype `RegistryDomain` is not registered on `Collection`
    /// or `Archetype` does not exist.
    public fun delegate_unregulated<C>(
        mint_cap: UnregulatedMintCap<C>,
        collection: &mut Collection<C>,
        archetype_id: ID,
        ctx: &mut TxContext,
    ): ArchetypeMintCap<C> {
        let registry = borrow_registry_mut(collection);
        let archetype = borrow_archetype_mut(registry, archetype_id);
        archetype::delegate_unregulated(mint_cap, archetype, ctx)
    }

    // === Assertions ===

    /// Asserts that `Collection` has a defined `RegistryDomain`
    public fun assert_archetypal<C>(collection: &Collection<C>) {
        assert!(is_archetypal(collection), EUNDEFINED_ARCHETYPE_REGISTRY);
    }

    /// Asserts that `Archetype` with `ID` is registered on `RegistryDomain`
    public fun assert_archetype<C>(
        registry: &RegistryDomain<C>,
        archetype_id: ID,
    ) {
        assert!(
            contains_archetype<C>(registry, archetype_id),
            EUNDEFINED_ARCHETYPE
        );
    }
}
