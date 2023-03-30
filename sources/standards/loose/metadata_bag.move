module nft_protocol::metadata_bag {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::TxContext;
    use sui::object_table::{Self, ObjectTable};

    use nft_protocol::nft::Nft;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::mint_cap::MintCap;
    use nft_protocol::metadata::{Self, Metadata};
    use nft_protocol::loose_mint_cap::LooseMintCap;

    /// `MetadataBagDomain` not registered on `Collection`
    ///
    /// Call `metadata_bag::init_metadata_bag` on the `Collection`.
    const EUNDEFINED_METADATA_IN_BAG: u64 = 1;

    /// `Metadata` with the given is was not registered on `MetadataBagDomain`
    ///
    /// Call `metadata_bag::add_metadata` to add an `Metadata` to
    /// `MetadataBagDomain`.
    const EUNDEFINED_ARCHETYPE: u64 = 2;

    struct Witness has drop {}

    /// `MetadataBagDomain` object
    struct MetadataBagDomain<T: key + store> has key, store {
        id: UID,
        table: ObjectTable<ID, Metadata<T>>,
    }

    /// Create a `MetadataBagDomain` object
    public fun new_metadata_bag<C>(
        ctx: &mut TxContext,
    ): MetadataBagDomain<C> {
        MetadataBagDomain {
            id: object::new(ctx),
            table: object_table::new(ctx),
        }
    }

    /// Create a `MetadataBagDomain` object and register on `Collection`
    public fun init_metadata_bag<T: key + store, W>(
        witness: &W,
        collection: &mut Collection<Nft<C>>,
        ctx: &mut TxContext,
    ) {
        let metadata_bag = new_metadata_bag<T>(ctx);
        collection::add_domain(witness, collection, metadata_bag);
    }

    /// Returns whether `Metadata` with `ID` is registered on `MetadataBagDomain`
    public fun contains_metadata<T: key + store>(
        metadata_bag: &MetadataBagDomain<T>,
        metadata_id: ID,
    ): bool {
        object_table::contains(&metadata_bag.table, metadata_id)
    }

    /// Borrows `Metadata` from `MetadataBagDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `Metadata` does not exist on `MetadataBagDomain`.
    public fun borrow_metadata<T: key + store>(
        metadata_bag: &MetadataBagDomain<T>,
        metadata_id: ID,
    ): &Metadata<T> {
        assert_metadata(metadata_bag, metadata_id);
        object_table::borrow(&metadata_bag.table, metadata_id)
    }

    /// Mutably borrows `Metadata` from `MetadataBagDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `Metadata` does not exist on `MetadataBagDomain`.
    fun borrow_metadata_mut<T: key + store>(
        metadata_bag: &mut MetadataBagDomain<T>,
        metadata_id: ID,
    ): &mut Metadata<T> {
        assert_metadata(metadata_bag, metadata_id);
        object_table::borrow_mut(&mut metadata_bag.table, metadata_id)
    }

    /// Add `Metadata` to `MetadataBagDomain`
    public entry fun add_metadata<C>(
        _mint_cap: &MintCap<Nft<C>>,
        metadata_bag: &mut MetadataBagDomain<C>,
        metadata: Metadata<C>,
    ) {
        object_table::add(
            &mut metadata_bag.table,
            object::id(&metadata),
            metadata,
        );
    }

    // === Interoperability ===

    /// Return whether `Collection` has defined an metadata `MetadataBagDomain`
    public fun is_archetypal<C>(
        collection: &Collection<Nft<C>>,
    ): bool {
        collection::has_domain<Nft<C>, MetadataBagDomain<C>>(collection)
    }

    /// Add `MetadataBagDomain` to `Collection`
    public fun add_metadata_bag<T: key + store, W>(
        witness: &W,
        collection: &mut Collection<Nft<C>>,
        metadata_bag: MetadataBagDomain<C>,
    ) {
        collection::add_domain(witness, collection, metadata_bag);
    }

    /// Borrows `MetadataBagDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Collection` does not have a `MetadataBagDomain`.
    public fun borrow_metagada_bag<C>(
        collection: &Collection<Nft<C>>,
    ): &MetadataBagDomain<C> {
        assert_archetypal(collection);
        collection::borrow_domain(collection)
    }

    /// Mutably borrows `MetadataBagDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Collection` does not have a `MetadataBagDomain`.
    fun borrow_metadata_bag_mut<C>(
        collection: &mut Collection<Nft<C>>,
    ): &mut MetadataBagDomain<C> {
        assert_archetypal(collection);
        collection::borrow_domain_mut(Witness {}, collection)
    }

    /// Add `Metadata` to `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Collection` does not have a `MetadataBagDomain`.
    public entry fun add_metadata_to_collection<C>(
        _mint_cap: &MintCap<Nft<C>>,
        collection: &mut Collection<Nft<C>>,
        metadata: Metadata<C>,
    ) {
        let metadata_bag = borrow_metadata_bag_mut(collection);
        object_table::add(
            &mut metadata_bag.table,
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
    /// * `MetadataBagDomain` is not registered on `Collection`
    /// * `Metadata` does not exist
    /// * Supply is exceeded
    public fun delegate<C>(
        mint_cap: &mut MintCap<Nft<C>>,
        collection: &mut Collection<Nft<C>>,
        metadata_id: ID,
        quantity: u64,
        ctx: &mut TxContext,
    ): LooseMintCap<Nft<C>> {
        let metadata_bag = borrow_metadata_bag_mut(collection);
        let metadata = borrow_metadata_mut(metadata_bag, metadata_id);
        metadata::delegate(mint_cap, metadata, quantity, ctx)
    }

    // === Assertions ===

    /// Asserts that `Collection` has a defined `MetadataBagDomain`
    public fun assert_archetypal<C>(
        collection: &Collection<Nft<C>>,
    ) {
        assert!(is_archetypal(collection), EUNDEFINED_METADATA_IN_BAG);
    }

    /// Asserts that `Metadata` with `ID` is registered on `MetadataBagDomain`
    public fun assert_metadata<T: key + store>(
        metadata_bag: &MetadataBagDomain<T>,
        metadata_id: ID,
    ) {
        assert!(
            contains_metadata<T>(metadata_bag, metadata_id),
            EUNDEFINED_ARCHETYPE
        );
    }
}
