/// Module of Nft Flyweight domain.
///
/// The flyweight domain is responsible for the implementation of the
/// loose NFT pattern. Where NFT data live in the `Archetype` object and
/// `Nft`s have a `Pointer` to it.
///
/// The loose NFT pattern is based on the flyweight pattern, which is a design
/// pattern that achieves storage and memory efficiency by sharing common parts
/// of state between multiple objects instead of keeping all of the data
/// in each object.
///
/// For more on the design pattern:
/// https://refactoring.guru/design-patterns/flyweight
///
/// Embedded NFTs, contrary to loose NFTs, hold their own data, and therefore
/// the minting of data and the NFT itself can happen in one single step. With
/// Loose NFTs however, the data Archetype is first minted and only then the
/// NFT(s) associated to that object is(are) minted.
///
/// Embedded NFTs are nevertheless only useful to represent 1-to-1 relationships
/// between the NFT object and the data. In contrast, loose NFTs can
/// represent 1-to-many relationships. Essentially this allows us to build
/// NFTs which effectively have a supply.
module nft_protocol::flyweight {
    use sui::transfer;
    use sui::dynamic_field as df;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::object_table::{Self, ObjectTable};

    use nft_protocol::utils;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::collection::{Self, Collection, MintCap};

    /// `RegistryDomain` not registered on `Collection`
    ///
    /// Call `flyweight::init_registry` on the `Collection`.
    const EUNDEFINED_ARCHETYPE_REGISTRY: u64 = 1;

    /// `Archetype` with the given is was not registered on `RegistryDomain`
    ///
    /// Call `flyweight::add_archetype` to add an `Archetype` to
    /// `RegistryDomain`.
    const EUNDEFINED_ARCHETYPE: u64 = 2;

    /// `Archetype` supply is unregulated
    ///
    /// Create an `Archetype` using `flyweight::new_regulated` to create a
    /// regulated `Archetype`.
    const EUNREGULATED_ARCHETYPE: u64 = 3;

    /// `Archetype` supply is regulated
    ///
    /// Create an `Archetype` using `flyweight::new_unregulated` to create an
    /// unregulated `Archetype`.
    const EREGULATED_ARCHETYPE: u64 = 3;

    // === Pointer ===

    struct Pointer has key, store {
        id: UID,
        archetype_id: ID,
    }

    /// Creates a new `Pointer` to the given `Archetype`
    public fun pointer<C>(archetype: &Archetype<C>, ctx: &mut TxContext): Pointer {
        Pointer {
            id: object::new(ctx),
            archetype_id: object::id(archetype),
        }
    }

    /// Return `ID` of `Archetype` associated with this pointer
    public fun archetype_id(pointer: &Pointer): ID {
        pointer.archetype_id
    }

    // === Archetype ===

    /// `Archetype` object
    struct Archetype<phantom C> has key, store {
        id: UID,
        archetype: Nft<C>,
    }

    /// Create `Archetype` with unregulated supply
    ///
    /// Does not require that collection itself is unregulated as `Archetype`
    /// supply is independently regulated.
    public fun new_unregulated<C>(
        archetype: Nft<C>,
        ctx: &mut TxContext,
    ): Archetype<C> {
        Archetype<C> {
            id: object::new(ctx),
            archetype,
        }
    }

    /// Create `Archetype` with unregulated supply and transfer to transaction
    /// sender
    ///
    /// Does not require that collection itself is unregulated as `Archetype`
    /// supply is independently regulated.
    public entry fun create_unregulated<C>(
        archetype: Nft<C>,
        ctx: &mut TxContext
    ) {
        let archetype = new_unregulated(archetype, ctx);
        transfer::transfer(archetype, tx_context::sender(ctx));
    }

    /// Create `Archetype` with unregulated supply
    ///
    /// Does not require that collection itself is regulated as `Archetype`
    /// supply is independently regulated.
    public fun new_regulated<C>(
        archetype: Nft<C>,
        supply: u64,
        ctx: &mut TxContext,
    ): Archetype<C> {
        let archetype = new_unregulated(archetype, ctx);

        let supply = supply::new(supply, false);
        df::add(
            &mut archetype.id,
            utils::marker<Supply>(),
            supply,
        );

        archetype
    }

    /// Create `Archetype` with regulated supply and transfer to transaction
    /// sender
    ///
    /// Does not require that collection itself is regulated as `Archetype`
    /// supply is independently regulated.
    public entry fun create_regulated<C>(
        archetype: Nft<C>,
        supply: u64,
        ctx: &mut TxContext,
    ) {
        let archetype = new_regulated(archetype, supply, ctx);
        transfer::transfer(archetype, tx_context::sender(ctx));
    }

    /// Returns whether `Archetype` has a regulated supply
    public fun is_regulated<C>(archetype: &Archetype<C>): bool {
        df::exists_with_type<utils::Marker<Supply>, Supply>(
            &archetype.id, utils::marker<Supply>()
        )
    }

    /// Returns the `Archetype` supply
    ///
    /// #### Panics
    ///
    /// Panics if `Archetype` supply is unregulated
    public fun borrow_supply<C>(archetype: &Archetype<C>): &Supply {
        assert_regulated(archetype);
        df::borrow(
            &archetype.id,
            utils::marker<Supply>(),
        )
    }

    /// Returns the `Archetype` supply
    ///
    /// #### Panics
    ///
    /// Panics if `Archetype` supply is unregulated
    fun borrow_supply_mut<C>(archetype: &mut Archetype<C>): &mut Supply {
        assert_regulated(archetype);
        df::borrow_mut(
            &mut archetype.id,
            utils::marker<Supply>(),
        )
    }

    /// Freeze `Archetype` supply
    public entry fun freeze_supply<C>(archetype: &mut Archetype<C>) {
        let supply = borrow_supply_mut(archetype);
        supply::freeze_supply(supply);
    }

    /// Freeze `Archetype` supply in `Collection`
    public entry fun freeze_archetype_supply<C>(
        collection: &mut Collection<C>,
        archetype_id: ID,
    ) {
        let registry = borrow_registry_mut(collection);
        let archetype = borrow_archetype_mut(registry, archetype_id);
        freeze_supply(archetype);
    }

    /// Mint `Pointer` to `Archetype`
    ///
    /// #### Panics
    ///
    /// Panics if `Archetype` supply is exceeded.
    public fun mint_pointer<C>(
        archetype: &mut Archetype<C>,
        ctx: &mut TxContext,
    ): Pointer {
        if (is_regulated(archetype)) {
            let supply = borrow_supply_mut(archetype);
            supply::increment(supply, 1);
        };

        pointer(archetype, ctx)
    }

    /// Mint `Pointer` to `Archetype`
    ///
    /// If mutable reference to `Archetype` can be obtained, prefer to use
    /// [mint_pointer](#mint_pointer), as it will work for both regulated and
    /// unregulated archetypes.
    ///
    /// #### Panics
    ///
    /// Panics if `Archetype` supply is regulated.
    public fun mint_pointer_unregulated<C>(
        archetype: &Archetype<C>,
        ctx: &mut TxContext,
    ): Pointer {
        assert_unregulated(archetype);
        pointer(archetype, ctx)
    }

    /// Create a `Pointer` object and adds it to `Nft<C>`
    ///
    /// #### Panics
    ///
    /// Panics if a `Pointer` was already registered on `Nft` or if supply is
    /// exceeded.
    public fun set_archetype<C>(
        nft: &mut Nft<C>,
        archetype: &mut Archetype<C>,
        ctx: &mut TxContext,
    ) {
        let pointer = mint_pointer(archetype, ctx);
        nft::add_domain(nft, pointer, ctx);
    }

    /// Create a `Pointer` object and adds it to `Nft<C>`
    ///
    /// If mutable reference to `Archetype` can be obtained, prefer to use
    /// [set_archetype](#set_archetype), as it will work for both regulated and
    /// unregulated archetypes.
    ///
    /// #### Panics
    ///
    /// Panics if a `Pointer` was already registered on `Nft` or if supply is
    /// regulated.
    public fun set_archetype_unregulated<C>(
        nft: &mut Nft<C>,
        archetype: &Archetype<C>,
        ctx: &mut TxContext,
    ) {
        let pointer = mint_pointer_unregulated(archetype, ctx);
        nft::add_domain(nft, pointer, ctx);
    }

    // === RegistryDomain ===

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
        collection: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        ctx: &mut TxContext,
    ) {
        let registry = new_registry<C>(ctx);
        collection::add_domain(collection, mint_cap, registry);
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
        registry: &mut RegistryDomain<C>,
        _mint_cap: &MintCap<C>,
        archetype: Archetype<C>,
    ) {
        object_table::add<ID, Archetype<C>>(
            &mut registry.table,
            object::id(&archetype),
            archetype,
        );
    }

    // === Interoperability ===

    /// Return whether `Collection` has defined an archetype `RegistryDomain`
    public fun is_archetypal<C>(collection: &Collection<C>): bool {
        collection::has_domain<C, RegistryDomain<C>>(collection)
    }

    /// Add `RegistryDomain` to `Collection`
    public fun add_registry<C>(
        collection: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        registry: RegistryDomain<C>,
    ) {
        collection::add_domain(collection, mint_cap, registry);
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
        collection: &mut Collection<C>,
        _mint_cap: &MintCap<C>,
        archetype: Archetype<C>,
    ) {
        let registry = borrow_registry_mut(collection);
        object_table::add(
            &mut registry.table,
            object::id(&archetype),
            archetype,
        );
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

    /// Asserts that `Archetype` has a regulated supply
    public fun assert_regulated<C>(archetype: &Archetype<C>) {
        assert!(is_regulated(archetype), EUNREGULATED_ARCHETYPE);
    }

    /// Asserts that `Archetype` has a regulated supply
    public fun assert_unregulated<C>(archetype: &Archetype<C>) {
        assert!(!is_regulated(archetype), EREGULATED_ARCHETYPE);
    }
}
