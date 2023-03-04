module nft_protocol::metadata_bag {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::TxContext;
    use sui::object_table::{Self, ObjectTable};

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::mint_cap::{
        MintCap, RegulatedMintCap, UnregulatedMintCap,
    };

    use nft_protocol::metadata::{Self, Metadata};
    use nft_protocol::loose_mint_cap::LooseMintCap;

    /// `MetadataBagDomain` not registered on `Collection`
    ///
    /// Call `templates::init_templates` on the `Collection`.
    const EUNDEFINED_ARCHETYPE_REGISTRY: u64 = 1;

    /// `Metadata` with the given is was not registered on `MetadataBagDomain`
    ///
    /// Call `templates::add_template` to add an `Metadata` to
    /// `MetadataBagDomain`.
    const EUNDEFINED_ARCHETYPE: u64 = 2;

    struct Witness has drop {}

    /// `MetadataBagDomain` object
    struct MetadataBagDomain<phantom C> has key, store {
        id: UID,
        table: ObjectTable<ID, Metadata<C>>,
    }

    /// Create a `MetadataBagDomain` object
    public fun new_templates<C>(ctx: &mut TxContext): MetadataBagDomain<C> {
        MetadataBagDomain<C> {
            id: object::new(ctx),
            table: object_table::new<ID, Metadata<C>>(ctx),
        }
    }

    /// Create a `MetadataBagDomain` object and register on `Collection`
    public fun init_templates<C, W>(
        witness: &W,
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ) {
        let registry = new_templates<C>(ctx);
        collection::add_domain(witness, collection, registry);
    }

    /// Returns whether `Metadata` with `ID` is registered on `MetadataBagDomain`
    public fun contains_template<C>(
        registry: &MetadataBagDomain<C>,
        template_id: ID,
    ): bool {
        object_table::contains(&registry.table, template_id)
    }

    /// Borrows `Metadata` from `MetadataBagDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `Metadata` does not exist on `MetadataBagDomain`.
    public fun borrow_template<C>(
        registry: &MetadataBagDomain<C>,
        template_id: ID,
    ): &Metadata<C> {
        assert_template(registry, template_id);
        object_table::borrow(&registry.table, template_id)
    }

    /// Mutably borrows `Metadata` from `MetadataBagDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `Metadata` does not exist on `MetadataBagDomain`.
    fun borrow_template_mut<C>(
        registry: &mut MetadataBagDomain<C>,
        template_id: ID,
    ): &mut Metadata<C> {
        assert_template(registry, template_id);
        object_table::borrow_mut(&mut registry.table, template_id)
    }

    /// Add `Metadata` to `MetadataBagDomain`
    public entry fun add_template<C>(
        _mint_cap: &MintCap<C>,
        registry: &mut MetadataBagDomain<C>,
        metadata: Metadata<C>,
    ) {
        object_table::add<ID, Metadata<C>>(
            &mut registry.table,
            object::id(&metadata),
            metadata,
        );
    }

    /// Freeze `Metadata` supply in `Collection`
    public entry fun freeze_template_supply<C>(
        collection: &mut Collection<C>,
        template_id: ID,
    ) {
        let registry = borrow_registry_mut(collection);
        let metadata = borrow_template_mut(registry, template_id);
        metadata::freeze_supply(metadata);
    }

    // === Interoperability ===

    /// Return whether `Collection` has defined an metadata `MetadataBagDomain`
    public fun is_archetypal<C>(collection: &Collection<C>): bool {
        collection::has_domain<C, MetadataBagDomain<C>>(collection)
    }

    /// Add `MetadataBagDomain` to `Collection`
    public fun add_registry<C, W>(
        witness: &W,
        collection: &mut Collection<C>,
        registry: MetadataBagDomain<C>,
    ) {
        collection::add_domain(witness, collection, registry);
    }

    /// Borrows `MetadataBagDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Collection` does not have a `MetadataBagDomain`.
    public fun borrow_registry<C>(collection: &Collection<C>): &MetadataBagDomain<C> {
        assert_archetypal(collection);
        collection::borrow_domain(collection)
    }

    /// Mutably borrows `MetadataBagDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Collection` does not have a `MetadataBagDomain`.
    fun borrow_registry_mut<C>(collection: &mut Collection<C>): &mut MetadataBagDomain<C> {
        assert_archetypal(collection);
        collection::borrow_domain_mut(Witness {}, collection)
    }

    /// Add `Metadata` to `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Collection` does not have a `MetadataBagDomain`.
    public entry fun add_collection_template<C>(
        _mint_cap: &MintCap<C>,
        collection: &mut Collection<C>,
        metadata: Metadata<C>,
    ) {
        let registry = borrow_registry_mut(collection);
        object_table::add(
            &mut registry.table,
            object::id(&metadata),
            metadata,
        );
    }

    /// Delegates metadata minting rights while maintaining `Collection` and
    /// `Metadata` level supply invariants.
    ///
    /// The argument of `RegulatedMintCap` implies that supply is at least
    /// controlled at the `Collection` level.
    ///
    /// #### Panics
    ///
    /// Panics if metadata `MetadataBagDomain` is not registered on `Collection`
    /// or `Metadata` does not exist.
    public fun delegate_regulated<C>(
        mint_cap: RegulatedMintCap<C>,
        collection: &mut Collection<C>,
        template_id: ID,
        ctx: &mut TxContext,
    ): LooseMintCap<C> {
        let registry = borrow_registry_mut(collection);
        let metadata = borrow_template_mut(registry, template_id);
        metadata::delegate_regulated(mint_cap, metadata, ctx)
    }

    /// Delegates metadata minting rights while maintaining `Collection` and
    /// `Metadata` level supply invariants.
    ///
    /// The argument of `RegulatedMintCap` implies that supply is at least
    /// controlled at the `Collection` level.
    ///
    /// #### Panics
    ///
    /// Panics if metadata `MetadataBagDomain` is not registered on `Collection`
    /// or `Metadata` does not exist.
    public fun delegate_unregulated<C>(
        mint_cap: UnregulatedMintCap<C>,
        collection: &mut Collection<C>,
        template_id: ID,
        ctx: &mut TxContext,
    ): LooseMintCap<C> {
        let registry = borrow_registry_mut(collection);
        let metadata = borrow_template_mut(registry, template_id);
        metadata::delegate_unregulated(mint_cap, metadata, ctx)
    }

    // === Assertions ===

    /// Asserts that `Collection` has a defined `MetadataBagDomain`
    public fun assert_archetypal<C>(collection: &Collection<C>) {
        assert!(is_archetypal(collection), EUNDEFINED_ARCHETYPE_REGISTRY);
    }

    /// Asserts that `Metadata` with `ID` is registered on `MetadataBagDomain`
    public fun assert_template<C>(
        registry: &MetadataBagDomain<C>,
        template_id: ID,
    ) {
        assert!(
            contains_template<C>(registry, template_id),
            EUNDEFINED_ARCHETYPE
        );
    }
}
