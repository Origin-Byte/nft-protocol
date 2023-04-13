module nft_protocol::composable_nft {
    use std::type_name::{Self, TypeName};

    use sui::dynamic_field as df;
    use sui::transfer::public_transfer;
    use sui::object::{ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::nft_bag::{Self, NftBag};

    /// `Composition` was not defined
    ///
    /// Call `composable_nft::add_domain` to add `Composition`.
    const EUndefinedComposition: u64 = 1;

    /// `Composition` already defined
    ///
    /// Call `composable_nft::borrow_domain` to borrow domain.
    const EExistingComposition: u64 = 2;

    /// Parent and child types are not composable
    ///
    /// Call `composable_nft::add_relationship` to add parent child
    /// relationship to the `Composition`.
    const EChildNotComposable: u64 = 3;

    /// Relationship between provided parent and child types is already defined
    const EExistingRelationship: u64 = 4;

    /// Exceeded composed type limit when calling `composable_nft::compose`
    ///
    /// Set a higher type limit in the `Composition`.
    const EExceededLimit: u64 = 5;

    /// Internal struct for indexing NFTs in `NftBag`
    struct Key<phantom T> has drop, store {}

    /// Object that defines type-limiting composabiilty rules for NFTs stored
    /// in `NftBag`.
    ///
    /// Multiple compositions can exist in each collection, therefore they are
    /// generic on `S`, a schema marker.
    struct Composition<phantom Schema> has store {
        limits: VecMap<TypeName, u64>,
    }

    /// Create new `Composition`
    public fun new_composition<Schema>(): Composition<Schema> {
        Composition {
            limits: vec_map::empty(),
        }
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
        vec_map::get_mut(&mut composition.limits, child_type)
    }

    /// Borrow child limit from composability composition
    public fun borrow_limits<Schema>(
        composition: &Composition<Schema>,
    ): &VecMap<TypeName, u64> {
        &composition.limits
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
        // TODO: Needs assertion for type Child -- check same package
        let child_type = type_name::get<Child>();

        assert!(
            !has_child(composition, &child_type),
            EExistingRelationship,
        );

        vec_map::insert(&mut composition.limits, child_type, limit);
    }

    /// Compose child NFT into parent NFT
    ///
    /// #### Panics
    ///
    /// * Parent or child NFT do not have corresponding `Type<Parent>` and
    /// `Type<Child>` domains registered
    /// * Limit of children is exceeded
    public fun compose<Schema, Child: key + store>(
        composition: &Composition<Schema>,
        nfts: &mut NftBag,
        child_nft: Child,
    ) {
        // Asserts that parent and child are composable
        let child_type = type_name::get<Child>();
        let limit = get_limit(composition, &child_type);

        assert!(
            nft_bag::count<Key<Child>>(nfts) < limit,
            EExceededLimit,
        );

        nft_bag::compose(Key<Child> {}, nfts, child_nft);
    }

    /// Composes child NFT into parent NFT
    ///
    /// #### Panics
    ///
    /// * `NftBag` is not registered on the parent `Nft`
    /// * Parent or child NFT do not have corresponding `Type<Parent>` and
    /// `Type<Child>` domains registered
    /// * Limit of children is exceeded
    public fun compose_into_nft<Schema, Child: key + store>(
        composition: &Composition<Schema>,
        parent_nft: &mut UID,
        child_nft: Child,
    ) {
        let nfts = nft_bag::borrow_domain_mut(parent_nft);
        compose(composition, nfts, child_nft);
    }

    /// Decomposes NFT with given ID from parent NFT
    ///
    /// #### Panics
    ///
    /// Panics if there is no NFT with given ID composed
    public fun decompose<T: key + store>(
        nfts: &mut NftBag,
        child_nft_id: ID,
    ): T {
        // TODO: Should check whether this NFT is allowed to be decomposed
        // somehow
        nft_bag::decompose(Key<T> {}, nfts, child_nft_id)
    }

    /// Decomposes NFT with given ID from parent NFT and transfers to
    /// transaction sender
    ///
    /// #### Panics
    ///
    /// Panics if there is no NFT with given ID composed
    public fun decompose_and_transfer<T: key + store>(
        nfts: &mut NftBag,
        child_nft_id: ID,
        ctx: &mut TxContext,
    ) {
        let nft = decompose<T>(nfts, child_nft_id);
        public_transfer(nft, tx_context::sender(ctx));
    }

    /// Decomposes child NFT from parent NFT
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` is not registered on the parent `Nft`
    public fun decompose_from_nft<T: key + store>(
        parent_nft: &mut UID,
        child_nft_id: ID,
    ): T {
        let nfts = nft_bag::borrow_domain_mut(parent_nft);
        decompose(nfts, child_nft_id)
    }

    /// Decomposes child NFT from parent NFT
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` is not registered on the parent `Nft`
    public fun decompose_from_nft_and_transfer<T: key + store>(
        parent_nft: &mut UID,
        child_nft_id: ID,
        ctx: &mut TxContext,
    ) {
        let nft = decompose_from_nft<T>(parent_nft, child_nft_id);
        public_transfer(nft, tx_context::sender(ctx));
    }

    // === Interoperability ===

    /// Returns whether `Composition` is registered on collection
    public fun has_domain<Schema>(collection: &UID): bool {
        df::exists_with_type<Marker<Composition<Schema>>, Composition<Schema>>(
            collection, utils::marker(),
        )
    }

    /// Borrows `Composition` from collection
    ///
    /// #### Panics
    ///
    /// Panics if `Composition` is not registered on the collection
    public fun borrow_domain<Schema>(collection: &UID): &Composition<Schema> {
        assert_attributes<Schema>(collection);
        df::borrow(collection, utils::marker<Composition<Schema>>())
    }

    /// Mutably borrows `Composition` from collection
    ///
    /// #### Panics
    ///
    /// Panics if `Composition` is not registered on the collection
    public fun borrow_domain_mut<Schema>(
        collection: &mut UID,
    ): &mut Composition<Schema> {
        assert_attributes<Schema>(collection);
        df::borrow_mut(collection, utils::marker<Composition<Schema>>())
    }

    /// Adds `Composition` to collection
    ///
    /// #### Panics
    ///
    /// Panics if `Composition` domain already exists
    public fun add_domain<Schema>(
        collection: &mut UID,
        domain: Composition<Schema>,
    ) {
        assert_no_attributes<Schema>(collection);
        df::add(collection, utils::marker<Composition<Schema>>(), domain);
    }

    /// Create a new `Composition` and register it on a collection
    public fun add_new_composition<Schema>(collection: &mut UID) {
        add_domain(collection, new_composition<Schema>())
    }

    /// Remove `Composition` from collection
    ///
    /// #### Panics
    ///
    /// Panics if `Composition` domain doesnt exist
    public fun remove_domain<Schema>(
        collection: &mut UID,
    ): Composition<Schema> {
        assert_attributes<Schema>(collection);
        df::remove(collection, utils::marker<Composition<Schema>>())
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
            EChildNotComposable,
        );
    }

    /// Asserts that `Composition` is registered on collection
    ///
    /// #### Panics
    ///
    /// Panics if `Composition` is not registered
    public fun assert_attributes<Schema>(collection: &UID) {
        assert!(has_domain<Schema>(collection), EUndefinedComposition);
    }

    /// Asserts that `Composition` is not registered on collection
    ///
    /// #### Panics
    ///
    /// Panics if `Composition` is registered
    public fun assert_no_attributes<Schema>(collection: &UID) {
        assert!(!has_domain<Schema>(collection), EExistingComposition);
    }
}
