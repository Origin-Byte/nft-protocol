module nft_protocol::templates {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::TxContext;
    use sui::object_table::{Self, ObjectTable};

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::mint_cap::{
        MintCap, RegulatedMintCap, UnregulatedMintCap,
    };
    use nft_protocol::witness::Witness as DelegatedWitness;

    use nft_protocol::template::{Self, Template};
    use nft_protocol::loose_mint_cap::LooseMintCap;

    /// `TemplatesDomain` not registered on `Collection`
    ///
    /// Call `templates::init_templates` on the `Collection`.
    const EUNDEFINED_ARCHETYPE_REGISTRY: u64 = 1;

    /// `Template` with the given is was not registered on `TemplatesDomain`
    ///
    /// Call `templates::add_template` to add an `Template` to
    /// `TemplatesDomain`.
    const EUNDEFINED_ARCHETYPE: u64 = 2;

    struct Witness has drop {}

    /// `TemplatesDomain` object
    struct TemplatesDomain<phantom C> has key, store {
        id: UID,
        table: ObjectTable<ID, Template<C>>,
    }

    /// Create a `TemplatesDomain` object
    public fun new_templates<C>(ctx: &mut TxContext): TemplatesDomain<C> {
        TemplatesDomain<C> {
            id: object::new(ctx),
            table: object_table::new<ID, Template<C>>(ctx),
        }
    }

    /// Create a `TemplatesDomain` object and register on `Collection`
    public fun init_templates<C>(
        witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ) {
        let registry = new_templates<C>(ctx);
        collection::add_domain(witness, collection, registry);
    }

    /// Returns whether `Template` with `ID` is registered on `TemplatesDomain`
    public fun contains_template<C>(
        registry: &TemplatesDomain<C>,
        template_id: ID,
    ): bool {
        object_table::contains(&registry.table, template_id)
    }

    /// Borrows `Template` from `TemplatesDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `Template` does not exist on `TemplatesDomain`.
    public fun borrow_template<C>(
        registry: &TemplatesDomain<C>,
        template_id: ID,
    ): &Template<C> {
        assert_template(registry, template_id);
        object_table::borrow(&registry.table, template_id)
    }

    /// Mutably borrows `Template` from `TemplatesDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `Template` does not exist on `TemplatesDomain`.
    fun borrow_template_mut<C>(
        registry: &mut TemplatesDomain<C>,
        template_id: ID,
    ): &mut Template<C> {
        assert_template(registry, template_id);
        object_table::borrow_mut(&mut registry.table, template_id)
    }

    /// Add `Template` to `TemplatesDomain`
    public entry fun add_template<C>(
        _mint_cap: &MintCap<C>,
        registry: &mut TemplatesDomain<C>,
        template: Template<C>,
    ) {
        object_table::add<ID, Template<C>>(
            &mut registry.table,
            object::id(&template),
            template,
        );
    }

    /// Freeze `Template` supply in `Collection`
    public entry fun freeze_template_supply<C>(
        collection: &mut Collection<C>,
        template_id: ID,
    ) {
        let registry = borrow_registry_mut(collection);
        let template = borrow_template_mut(registry, template_id);
        template::freeze_supply(template);
    }

    // === Interoperability ===

    /// Return whether `Collection` has defined an template `TemplatesDomain`
    public fun is_archetypal<C>(collection: &Collection<C>): bool {
        collection::has_domain<C, TemplatesDomain<C>>(collection)
    }

    /// Add `TemplatesDomain` to `Collection`
    public fun add_registry<C>(
        witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        registry: TemplatesDomain<C>,
    ) {
        collection::add_domain(witness, collection, registry);
    }

    /// Borrows `TemplatesDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Collection` does not have a `TemplatesDomain`.
    public fun borrow_registry<C>(collection: &Collection<C>): &TemplatesDomain<C> {
        assert_archetypal(collection);
        collection::borrow_domain(collection)
    }

    /// Mutably borrows `TemplatesDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Collection` does not have a `TemplatesDomain`.
    fun borrow_registry_mut<C>(collection: &mut Collection<C>): &mut TemplatesDomain<C> {
        assert_archetypal(collection);
        collection::borrow_domain_mut(Witness {}, collection)
    }

    /// Add `Template` to `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Collection` does not have a `TemplatesDomain`.
    public entry fun add_collection_template<C>(
        _mint_cap: &MintCap<C>,
        collection: &mut Collection<C>,
        template: Template<C>,
    ) {
        let registry = borrow_registry_mut(collection);
        object_table::add(
            &mut registry.table,
            object::id(&template),
            template,
        );
    }

    /// Delegates template minting rights while maintaining `Collection` and
    /// `Template` level supply invariants.
    ///
    /// The argument of `RegulatedMintCap` implies that supply is at least
    /// controlled at the `Collection` level.
    ///
    /// #### Panics
    ///
    /// Panics if template `TemplatesDomain` is not registered on `Collection`
    /// or `Template` does not exist.
    public fun delegate_regulated<C>(
        mint_cap: RegulatedMintCap<C>,
        collection: &mut Collection<C>,
        template_id: ID,
        ctx: &mut TxContext,
    ): LooseMintCap<C> {
        let registry = borrow_registry_mut(collection);
        let template = borrow_template_mut(registry, template_id);
        template::delegate_regulated(mint_cap, template, ctx)
    }

    /// Delegates template minting rights while maintaining `Collection` and
    /// `Template` level supply invariants.
    ///
    /// The argument of `RegulatedMintCap` implies that supply is at least
    /// controlled at the `Collection` level.
    ///
    /// #### Panics
    ///
    /// Panics if template `TemplatesDomain` is not registered on `Collection`
    /// or `Template` does not exist.
    public fun delegate_unregulated<C>(
        mint_cap: UnregulatedMintCap<C>,
        collection: &mut Collection<C>,
        template_id: ID,
        ctx: &mut TxContext,
    ): LooseMintCap<C> {
        let registry = borrow_registry_mut(collection);
        let template = borrow_template_mut(registry, template_id);
        template::delegate_unregulated(mint_cap, template, ctx)
    }

    // === Assertions ===

    /// Asserts that `Collection` has a defined `TemplatesDomain`
    public fun assert_archetypal<C>(collection: &Collection<C>) {
        assert!(is_archetypal(collection), EUNDEFINED_ARCHETYPE_REGISTRY);
    }

    /// Asserts that `Template` with `ID` is registered on `TemplatesDomain`
    public fun assert_template<C>(
        registry: &TemplatesDomain<C>,
        template_id: ID,
    ) {
        assert!(
            contains_template<C>(registry, template_id),
            EUNDEFINED_ARCHETYPE
        );
    }
}
