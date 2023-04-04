module nft_protocol::composable_nft {
    // TODO: Ideally we would allow for multiple NFTs to be composed together in a single
    // transaction
    // TODO: some endpoint for reorder_children
    use std::type_name::{Self, TypeName};

    use sui::transfer::public_transfer;
    use sui::object::{ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};

    use nft_protocol::witness::Witness as DelegatedWitness;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::nft_bag;

    /// Parent and child types are not composable
    ///
    /// Call `composable_nft::add_relationship` to add parent child
    /// relationship to the composition.
    const ETYPES_NOT_COMPOSABLE: u64 = 1;

    /// Relationship between provided parent and child types is already defined
    const ERELATIONSHIP_ALREADY_DEFINED: u64 = 2;

    /// Exceeded composed type limit when calling `composable_nft::compose`
    ///
    /// Set a higher type limit in the composability composition.
    const EEXCEEDED_TYPE_LIMIT: u64 = 3;

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Internal struct for indexing NFTs in `NftBagDomain`
    struct Key<phantom T> has drop, store {}

    /// Domain held in the Collection object, blueprinting all the composability
    /// between types.
    ///
    /// Multiple compositions can exist in each collection, therefore they are
    /// generic on `S`, a schema marker.
    struct Composition<phantom Schema> has store {
        limits: VecMap<TypeName, u64>,
    }

    public fun new_composition<Schema>(): Composition<Schema> {
        Composition {
            limits: vec_map::empty(),
        }
    }

    /// Adds parent child relationship to `Composition`
    ///
    /// #### Panics
    ///
    /// Panics if parent child relationship already exists
    public fun add_relationship<Schema, Child>(
        composition: &mut Composition<Schema>,
        limit: u64,
    ) {
        let child_type = type_name::get<Child>();

        assert!(
            !has_child(composition, &child_type),
            ERELATIONSHIP_ALREADY_DEFINED,
        );

        vec_map::insert(&mut composition.limits, child_type, limit);
    }

    /// Returns whether a parent child relationship exists in the composition
    public fun has_child<Schema>(
        composition: &Composition<Schema>,
        child_type: &TypeName,
    ): bool {
        vec_map::contains(&composition.limits, child_type)
    }

    /// Get limit for given type
    ///
    /// #### Panics
    ///
    /// Panics if parent child relationship was not defined on composability
    /// composition.
    public fun get_limit<Schema>(
        composition: &Composition<Schema>,
        child_type: &TypeName,
    ): u64 {
        assert_composable(composition, child_type);
        *vec_map::get(borrow_limits(composition), child_type)
    }

    /// Borrow mutable limit for given type
    ///
    /// #### Panics
    ///
    /// Panics if parent child relationship was not defined on composability
    /// composition.
    public fun borrow_limit_mut<Schema>(
        composition: &mut Composition<Schema>,
        child_type: &TypeName,
    ): &mut u64 {
        assert_composable(composition, child_type);
        vec_map::get_mut(borrow_limits_mut(composition), child_type)
    }

    /// Borrow child limit from composability composition
    public fun borrow_limits<Schema>(
        composition: &Composition<Schema>,
    ): &VecMap<TypeName, u64> {
        &composition.limits
    }

    /// Mutbaly borrow child limit from composability composition
    fun borrow_limits_mut<Schema>(
        composition: &mut Composition<Schema>,
    ): &mut VecMap<TypeName, u64> {
        &mut composition.limits
    }

    /// Registers `Composition` on the given `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Composition` is already registered on the `Collection`.
    public fun add_composition_domain<T, Schema, W: drop>(
        witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        domain: Composition<Schema>,
    ) {
        collection::add_domain(witness, collection, domain);
    }

    /// Compose child NFT into parent NFT
    ///
    /// #### Panics
    ///
    /// * `Composition<Schema>` is not registered as a domain on the parent NFT
    /// * Parent child relationship is not defined on the composability
    /// composition
    /// * Parent or child NFT do not have corresponding `Type<Parent>` and
    /// `Type<Child>` domains registered
    /// * Limit of children is exceeded
    public fun compose<
        T: key + store,
        Schema,
        Child: key + store
    >(
        parent_nft: &mut UID,
        child_nft: Child,
        collection: &Collection<T>,
    ) {
        let composition: &Composition<Schema> =
            collection::borrow_domain(collection);

        // Asserts that parent and child are composable
        let child_type = type_name::get<Child>();
        let limit = get_limit(composition, &child_type);

        let nfts = nft_bag::borrow_domain_mut<Child>(parent_nft);

        assert!(
            nft_bag::count<Child, Key<Child>>(nfts) < limit,
            EEXCEEDED_TYPE_LIMIT,
        );

        nft_bag::compose(Key<Child> {}, nfts, child_nft);
    }

    /// Decomposes NFT with given ID from parent NFT
    ///
    /// #### Panics
    ///
    /// Panics if there is no NFT with given ID composed
    public fun decompose<T: key + store>(
        parent_nft: &mut UID,
        child_nft_id: ID,
    ): T {
        // TODO: Should check whether this NFT is allowed to be decomposed
        // somehow
        let nfts = nft_bag::borrow_domain_mut(parent_nft);
        nft_bag::decompose(Key<T> {}, nfts, child_nft_id)
    }

    /// Decomposes NFT with given ID from parent NFT and transfers to
    /// transaction sender
    ///
    /// #### Panics
    ///
    /// Panics if there is no NFT with given ID composed
    public fun decompose_and_transfer<T: key + store>(
        parent_nft: &mut UID,
        child_nft_id: ID,
        ctx: &mut TxContext,
    ) {
        let nft = decompose<T>(parent_nft, child_nft_id);
        public_transfer(nft, tx_context::sender(ctx));
    }

    // === Assertions ===

    /// Assert that parent and child types are composable
    ///
    /// #### Panics
    ///
    /// Panics if parent and child types are not composable.
    public fun assert_composable<S>(
        composition: &Composition<S>,
        child_type: &TypeName,
    ) {
        assert!(
            has_child(composition, child_type),
            ETYPES_NOT_COMPOSABLE,
        );
    }
}
