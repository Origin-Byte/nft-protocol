module nft_protocol::composable_nft {
    // TODO: Ideally we would allow for multiple NFTs to be composed together in a single
    // transaction
    // TODO: some endpoint for reorder_children
    use std::type_name::{Self, TypeName};

    use sui::transfer::public_transfer;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};

    use nft_protocol::nft::{Self, Nft};
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

    // === Type ===

    /// NFT type domain
    ///
    /// Used to mark the NFT as a certain type
    struct Type<phantom T> has store {}

    /// Creates a new `Type`
    public fun new_type<T>(): Type<T> {
        Type {}
    }

    /// Registers `Type` as a domain on the `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if NFT is already marked as the type
    public fun add_type_domain<C, W, Type>(
        witness: &W,
        nft: &mut Nft<C>,
    ) {
        nft::add_domain(witness, nft, new_type<Type>());
    }

    // === Blueprint ===

    /// Domain held in the Collection object, blueprinting all the composability
    /// between types. It contains a ObjectTable with all the nodes of the
    /// composability flattened.
    struct Blueprint<phantom T> has store {
        id: UID,
        nodes: VecMap<TypeName, Node>,
    }

    public fun new_blueprint<Parent>(ctx: &mut TxContext): Blueprint<Parent> {
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
    public fun add_relationship<Parent, Child>(
        blueprint: &mut Blueprint<Parent>,
        limit: u64,
        order: u64,
    ) {
        let child_type = type_name::get<Child>();

        assert!(
            !has_child<Parent>(blueprint, &child_type),
            ERELATIONSHIP_ALREADY_DEFINED,
        );

        let child = new_child_node(limit, order);
        vec_map::insert(&mut blueprint.nodes, child_type, child);
    }

    /// Returns whether a parent child relationship exists in the blueprint
    public fun has_child<Parent>(
        blueprint: &Blueprint<Parent>,
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
    public fun borrow_child<Parent>(
        blueprint: &Blueprint<Parent>,
        child_type: &TypeName,
    ): &Node {
        assert_composable<Parent>(blueprint, child_type);
        vec_map::get(&blueprint.nodes, child_type)
    }

    /// Mutbaly borrow child node from composability blueprint
    ///
    /// #### Panics
    ///
    /// Panics if parent child relationship was not defined on composability
    /// blueprint.
    fun borrow_child_mut<Parent>(
        blueprint: &mut Blueprint<Parent>,
        child_type: &TypeName,
    ): &mut Node {
        assert_composable<Parent>(blueprint, child_type);
        vec_map::get_mut(&mut blueprint.nodes, child_type)
    }

    /// Registers `Blueprint` on the given `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Blueprint` is already registered on the `Collection`.
    public fun add_blueprint_domain<C, W, Parent>(
        witness: &W,
        collection: &mut Collection<C>,
        domain: Blueprint<Parent>,
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
    public entry fun compose<C, Parent: store, Child: store>(
        parent_nft: &mut Nft<C>,
        child_nft: Nft<C>,
        collection: &Collection<C>,
    ) {
        let blueprint: &Blueprint<Parent> =
            collection::borrow_domain(collection);

        // Assert that types match NFTs
        nft::assert_domain<C, Type<Parent>>(parent_nft);
        nft::assert_domain<C, Type<Child>>(&child_nft);

        // Asserts that parent and child are composable
        let child_type = type_name::get<Child>();
        let node = borrow_child<Parent>(blueprint, &child_type);

        let nfts = nft_bag::borrow_domain_mut(parent_nft);

        assert!(
            nft_bag::count<Key<Child>>(nfts) < node.limit,
            EEXCEEDED_TYPE_LIMIT,
        );

        nft_bag::compose(Key<Child> {}, nfts, child_nft);
    }

    /// Decomposes NFT with given ID from parent NFT
    ///
    /// #### Panics
    ///
    /// Panics if there is no NFT with given ID composed
    public fun decompose<C, Parent, Child>(
        parent_nft: &mut Nft<C>,
        child_nft_id: ID,
    ): Nft<C> {
        let nfts = nft_bag::borrow_domain_mut(parent_nft);
        nft_bag::decompose(Key<Child> {}, nfts, child_nft_id)
    }

    /// Decomposes NFT with given ID from parent NFT and transfers to
    /// transaction sender
    ///
    /// #### Panics
    ///
    /// Panics if there is no NFT with given ID composed
    public fun decompose_and_transfer<C, Parent, Child>(
        parent_nft: &mut Nft<C>,
        child_nft_id: ID,
        ctx: &mut TxContext,
    ) {
        let nft = decompose<C, Parent, Child>(parent_nft, child_nft_id);
        public_transfer(nft, tx_context::sender(ctx));
    }

    // === Assertions ===

    /// Assert that parent and child types are composable
    ///
    /// #### Panics
    ///
    /// Panics if parent and child types are not composable.
    public fun assert_composable<Parent>(
        blueprint: &Blueprint<Parent>,
        child_type: &TypeName,
    ) {
        assert!(
            has_child<Parent>(blueprint, child_type),
            ETYPES_NOT_COMPOSABLE,
        );
    }
}
