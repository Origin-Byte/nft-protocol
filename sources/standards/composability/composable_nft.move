module nft_protocol::composable_nft {
    // TODO: Ideally we would allow for multiple NFTs to be composed together in a single
    // transaction
    // TODO: some endpoint for reorder_children
    use std::type_name::{Self, TypeName};

    use sui::transfer::public_transfer;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::nft_bag;

    /// Parent and child types are not composable
    ///
    /// Call `composable_nft::add_relationship` to add parent child
    /// relationship to the composability blueprint.
    const ETYPES_NOT_COMPOSABLE: u64 = 1;

    /// Relationship between provided parent and child types is already defined
    const ERELATIONSHIP_ALREADY_DEFINED: u64 = 2;

    /// Exceeded composed type limit when calling `composable_nft::compose`
    ///
    /// Set a higher type limit in the composability blueprint.
    const EEXCEEDED_TYPE_LIMIT: u64 = 3;

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Internal struct for indexing NFTs in `NftBagDomain`
    struct Key<phantom T> has drop, store {}

    // === Node ===

    /// Defines the properties of a child NFT in the context of type-limited
    /// composability
    struct Node has store {
        // Amount of times the child NFT can be attached
        limit: u64,
        // TODO: Node generic about parametrization types
        // Rendering order of the child NFT
        order: u64,
    }

    /// Create a new `Node`
    fun new_child_node(limit: u64, order: u64): Node {
        Node { limit, order }
    }

    // === Blueprint ===

    /// Domain held in the Collection object, blueprinting all the composability
    /// between types.
    ///
    /// Multiple blueprints can exist in each collection, therefore they are
    /// generic on `S`, a schema marker.
    struct Blueprint<phantom Schema> has store {
        id: UID,
        nodes: VecMap<TypeName, Node>,
    }

    public fun new_blueprint<Schema>(ctx: &mut TxContext): Blueprint<Schema> {
        Blueprint {
            id: object::new(ctx),
            nodes: vec_map::empty(),
        }
    }

    /// Adds parent child relationship to `Blueprint`
    ///
    /// #### Panics
    ///
    /// Panics if parent child relationship already exists
    public fun add_relationship<Schema, Child>(
        blueprint: &mut Blueprint<Schema>,
        limit: u64,
        order: u64,
    ) {
        let child_type = type_name::get<Child>();

        assert!(
            !has_child(blueprint, &child_type),
            ERELATIONSHIP_ALREADY_DEFINED,
        );

        let child = new_child_node(limit, order);
        vec_map::insert(&mut blueprint.nodes, child_type, child);
    }

    /// Returns whether a parent child relationship exists in the blueprint
    public fun has_child<Schema>(
        blueprint: &Blueprint<Schema>,
        child_type: &TypeName,
    ): bool {
        vec_map::contains(&blueprint.nodes, child_type)
    }

    /// Borrow child node from composability blueprint
    ///
    /// #### Panics
    ///
    /// Panics if parent child relationship was not defined on composability
    /// blueprint.
    public fun borrow_child<Schema>(
        blueprint: &Blueprint<Schema>,
        child_type: &TypeName,
    ): &Node {
        assert_composable(blueprint, child_type);
        vec_map::get(&blueprint.nodes, child_type)
    }

    /// Mutbaly borrow child node from composability blueprint
    ///
    /// #### Panics
    ///
    /// Panics if parent child relationship was not defined on composability
    /// blueprint.
    fun borrow_child_mut<Schema>(
        blueprint: &mut Blueprint<Schema>,
        child_type: &TypeName,
    ): &mut Node {
        assert_composable(blueprint, child_type);
        vec_map::get_mut(&mut blueprint.nodes, child_type)
    }

    /// Registers `Blueprint` on the given `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Blueprint` is already registered on the `Collection`.
    public fun add_blueprint_domain<T, Schema, W: drop>(
        witness: W,
        collection: &mut Collection<T>,
        domain: Blueprint<Schema>,
    ) {
        collection::add_domain(witness, collection, domain);
    }

    /// Compose child NFT into parent NFT
    ///
    /// #### Panics
    ///
    /// * `Blueprint<Parent>` is not registered as a domain on the parent NFT
    /// * Parent child relationship is not defined on the composability
    /// blueprint
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
        let blueprint: &Blueprint<Schema> =
            collection::borrow_domain(collection);

        // Asserts that parent and child are composable
        let child_type = type_name::get<Child>();
        let node = borrow_child(blueprint, &child_type);

        let nfts = nft_bag::borrow_domain_mut<Child>(parent_nft);

        assert!(
            nft_bag::count<Child, Key<Child>>(nfts) < node.limit,
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
        blueprint: &Blueprint<S>,
        child_type: &TypeName,
    ) {
        assert!(
            has_child(blueprint, child_type),
            ETYPES_NOT_COMPOSABLE,
        );
    }
}
