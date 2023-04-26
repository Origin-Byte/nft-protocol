module nft_protocol::composable_nft {
    use std::type_name::{Self, TypeName};

    use sui::dynamic_field as df;
    use sui::object::{ID, UID};
    use sui::vec_map::{Self, VecMap};

    use witness::marker::{Self, Marker};

    use nft_protocol::collection::{Self, Collection};
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

    /// Internal struct for indexing NFTs in `Composition`
    struct Key<phantom T> has drop, store {}

    /// Object that defines type-limiting composabiilty rules for NFTs stored
    /// in `NftBag`
    ///
    /// `&Composition<Schema>` acts as an authority allowing an NFT to be
    /// composed into an `NftBag`, but more importantly, whether it is allowed
    /// to be decomposed. `&Composition<Schema>` must be kept private as
    /// it serves as ownership proof.
    ///
    /// The creator must verify that it is not possible to pass arbitrary
    /// compositions into their `compose` and `decompose` endpoints since it is
    /// always possible to spoof a composition for any types. The best practice
    /// is to extract it from a trusted object such as an NFT you control or
    /// `Collection<OTW>`.
    ///
    /// Since we only check `&Composition<Schema>`, a `Composition` can be
    /// registered on both NFTs and collections, for maximally flexible
    /// composition schemas.
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
    /// Verifies that composition operation does not violate the provided
    /// composition schema.
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
            EExistingRelationship,
        );

        vec_map::insert(&mut composition.limits, child_type, limit);
    }

    /// Drops parent child relationship from `Composition`
    ///
    /// #### Panics
    ///
    /// Panics if parent child relationship does not exist
    public fun drop_relationship<Schema, Child>(
        composition: &mut Composition<Schema>,
    ) {
        let child_type = type_name::get<Child>();
        assert_composable(composition, &child_type);

        vec_map::remove(&mut composition.limits, &child_type);
    }

    /// Compose child NFT into parent NFT
    ///
    /// Verifies that composition operation does not violate the provided
    /// composition schema.
    ///
    /// #### Panics
    ///
    /// Panics if child is not composable under the schema or child limit is
    /// exceeded.
    public fun compose<Schema, Child: key + store>(
        composition: &Composition<Schema>,
        nfts: &mut NftBag,
        child_nft: Child,
    ) {
        let count = compose_(nfts, child_nft);
        assert_insertable<Schema, Child>(composition, count);
    }

    /// Unprotected compose child NFT into `NftBag` and return new count
    ///
    /// Method exists to perform all operations on `NftBag` without holding a
    /// simultaneous reference to `Composition`.
    fun compose_<Child: key + store>(
        nfts: &mut NftBag,
        child_nft: Child,
    ): u64 {
        nft_bag::compose(Key<Child> {}, nfts, child_nft);
        nft_bag::count<Key<Child>>(nfts)
    }

    /// Composes child NFT into parent NFT
    ///
    /// Verifies that composition operation does not violate the provided
    /// composition schema.
    ///
    /// #### Panics
    ///
    /// * Child is not composable under the schema
    /// * `NftBag` is not registered on the parent NFT
    /// * Limit of children is exceeded
    public fun compose_into_nft<Schema, Child: key + store>(
        composition: &Composition<Schema>,
        parent_nft: &mut UID,
        child_nft: Child,
    ) {
        let nfts = nft_bag::borrow_domain_mut(parent_nft);
        compose(composition, nfts, child_nft);
    }

    /// Composes child NFT into parent NFT using `Compostion<Schema>` defined
    /// on parent NFT
    ///
    /// #### Panics
    ///
    /// * Child is not composable under the schema
    /// * `NftBag` is not registered on the parent NFT
    /// * `Compostion<Schema>` is not registered on the parent NFT
    /// * Limit of children is exceeded
    public fun compose_with_nft_schema<Schema, Child: key + store>(
        parent_nft: &mut UID,
        child_nft: Child,
    ) {
        // Switch up the order a bit to avoid holding reference to
        // `Composition` and `NftBag` at the same time
        let nfts = nft_bag::borrow_domain_mut(parent_nft);
        let count = compose_(nfts, child_nft);

        let composition = borrow_domain<Schema>(parent_nft);
        assert_insertable<Schema, Child>(composition, count);
    }

    /// Composes child NFT into parent NFT using `Compostion<Schema>` defined
    /// on parent NFT
    ///
    /// The creator must ensure that the `Collection<C>` object is of a trusted
    /// type or originates from a trusted source.
    ///
    /// #### Panics
    ///
    /// * Child is not composable under the schema
    /// * `NftBag` is not registered on the parent NFT
    /// * `Compostion<Schema>` is not registered on the collection
    /// * Limit of children is exceeded
    public fun compose_with_collection_schema<C, Schema, Child: key + store>(
        collection: &Collection<C>,
        parent_nft: &mut UID,
        child_nft: Child,
    ) {
        let composition: &Composition<Schema> =
            collection::borrow_domain(collection);

        let nfts = nft_bag::borrow_domain_mut(parent_nft);
        compose(composition, nfts, child_nft);
    }

    /// Decomposes NFT with given ID from parent NFT
    ///
    /// Verifies that composition operation does not violate the provided
    /// composition schema.
    ///
    /// #### Panics
    ///
    /// Panics child is not composable under the schema or was not previously
    /// composed.
    public fun decompose<Schema, Child: key + store>(
        composition: &Composition<Schema>,
        nfts: &mut NftBag,
        child_nft_id: ID,
    ): Child {
        assert_composable(composition, &type_name::get<Child>());
        decompose_(nfts, child_nft_id)
    }

    /// Unprotected compose child NFT into `NftBag` and return new count
    ///
    /// Method exists to perform all operations on `NftBag` without holding a
    /// simultaneous reference to `Composition`.
    fun decompose_<Child: key + store>(
        nfts: &mut NftBag,
        child_nft_id: ID,
    ): Child {
        nft_bag::decompose(Key<Child> {}, nfts, child_nft_id)
    }

    /// Decomposes child NFT from parent NFT
    ///
    /// Verifies that composition operation does not violate the provided
    /// composition schema.
    ///
    /// #### Panics
    ///
    /// * Child is not composable under the schema
    /// * `NftBag` is not registered on the parent NFT
    /// * Child was not previously composed
    public fun decompose_from_nft<Schema, Child: key + store>(
        composition: &Composition<Schema>,
        parent_nft: &mut UID,
        child_nft_id: ID,
    ): Child {
        let nfts = nft_bag::borrow_domain_mut(parent_nft);
        decompose(composition, nfts, child_nft_id)
    }

    /// Decomposes child NFT from parent NFT
    ///
    /// Verifies that composition operation does not violate the provided
    /// composition schema.
    ///
    /// #### Panics
    ///
    /// * Child is not composable under the schema
    /// * `NftBag` is not registered on the parent NFT
    /// * `Compostion<Schema>` is not registered on the parent NFT
    /// * Child was not previously composed
    public fun decompose_with_nft_schema<Schema, Child: key + store>(
        parent_nft: &mut UID,
        child_nft_id: ID,
    ): Child {
        // Switch up the order a bit to avoid holding reference to
        // `Composition` and `NftBag` at the same time
        let composition = borrow_domain<Schema>(parent_nft);
        assert_composable(composition, &type_name::get<Child>());

        let nfts = nft_bag::borrow_domain_mut(parent_nft);
        decompose_(nfts, child_nft_id)
    }

    /// Decomposes child NFT from parent NFT
    ///
    /// Verifies that composition operation does not violate the provided
    /// composition schema.
    ///
    /// #### Panics
    ///
    /// * Child is not composable under the schema
    /// * `NftBag` is not registered on the parent NFT
    /// * `Compostion<Schema>` is not registered on the collection
    /// * Child was not previously composed
    public fun decompose_with_collection_schema<C, Schema, Child: key + store>(
        collection: &Collection<C>,
        parent_nft: &mut UID,
        child_nft_id: ID,
    ): Child {
        let composition: &Composition<Schema> =
            collection::borrow_domain(collection);

        let nfts = nft_bag::borrow_domain_mut(parent_nft);
        decompose(composition, nfts, child_nft_id)
    }

    // === Interoperability ===

    /// Returns whether `Composition` is registered on object
    public fun has_domain<Schema>(object: &UID): bool {
        df::exists_with_type<Marker<Composition<Schema>>, Composition<Schema>>(
            object, marker::marker(),
        )
    }

    /// Borrows `Composition` from object
    ///
    /// #### Panics
    ///
    /// Panics if `Composition` is not registered on the object
    public fun borrow_domain<Schema>(object: &UID): &Composition<Schema> {
        assert_composition<Schema>(object);
        df::borrow(object, marker::marker<Composition<Schema>>())
    }

    /// Mutably borrows `Composition` from object
    ///
    /// #### Panics
    ///
    /// Panics if `Composition` is not registered on the object
    public fun borrow_domain_mut<Schema>(
        object: &mut UID,
    ): &mut Composition<Schema> {
        assert_composition<Schema>(object);
        df::borrow_mut(object, marker::marker<Composition<Schema>>())
    }

    /// Adds `Composition` to object
    ///
    /// #### Panics
    ///
    /// Panics if `Composition` domain already exists
    public fun add_domain<Schema>(
        object: &mut UID,
        domain: Composition<Schema>,
    ) {
        assert_no_composition<Schema>(object);
        df::add(object, marker::marker<Composition<Schema>>(), domain);
    }

    /// Create a new `Composition` and register it on a collection
    public fun add_new_composition<Schema>(collection: &mut UID) {
        add_domain(collection, new_composition<Schema>())
    }

    /// Remove `Composition` from object
    ///
    /// #### Panics
    ///
    /// Panics if `Composition` domain doesnt exist
    public fun remove_domain<Schema>(
        object: &mut UID,
    ): Composition<Schema> {
        assert_composition<Schema>(object);
        df::remove(object, marker::marker<Composition<Schema>>())
    }

    /// Deconstruct `Composition`
    ///
    /// Note that this makes any NFTs left in `NftBag` unwithdrawable unless
    /// the `Composition` is re-registered.
    ///
    /// #### Panics
    ///
    /// Panics if `Composition` has NFTs deposited within.
    public fun delete<Schema>(composition: Composition<Schema>) {
        let Composition { limits: _ } = composition;
    }

    // === Assertions ===

    /// Assert that count doesnt exceed the limit for the given child type
    ///
    /// #### Panics
    ///
    /// Panics if count is greater than or equal to the limit for the child.
    fun assert_insertable<Schema, Child: key + store>(
        composition: &Composition<Schema>,
        count: u64,
    ) {
        let child_type = type_name::get<Child>();
        let limit = get_limit(composition, &child_type);
        assert!(count <= limit, EExceededLimit);
    }

    /// Assert that parent and child types are composable
    ///
    /// #### Panics
    ///
    /// Panics if parent and child types are not composable.
    public fun assert_composable<Schema>(
        composition: &Composition<Schema>,
        child_type: &TypeName,
    ) {
        assert!(
            has_child(composition, child_type),
            EChildNotComposable,
        );
    }

    /// Asserts that `Composition` is registered on object
    ///
    /// #### Panics
    ///
    /// Panics if `Composition` is not registered
    public fun assert_composition<Schema>(object: &UID) {
        assert!(has_domain<Schema>(object), EUndefinedComposition);
    }

    /// Asserts that `Composition` is not registered on object
    ///
    /// #### Panics
    ///
    /// Panics if `Composition` is registered
    public fun assert_no_composition<Schema>(object: &UID) {
        assert!(!has_domain<Schema>(object), EExistingComposition);
    }
}
