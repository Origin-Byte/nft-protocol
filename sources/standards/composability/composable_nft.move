module nft_protocol::composable_nft {
    // TODO: Limit configurations (i.e. how many weapon NFTs can be attached to Avatar NFT)
    // TODO: Grouping of types into taxonomies can make the structuring of the
    // type system easier as it would more closely resemble the business logic.
    // However we should do this without introducing any convulution to this module,
    // and therefore this should be a higher-level abstraction exposed in a separate module
    // TODO: Ideally we would allow for multiple NFTs to be composed together in a single
    // transaction
    // TODO: some endpoint for reorder_children
    use std::type_name::{Self, TypeName};

    use sui::transfer;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::object_table::{Self, ObjectTable};
    use sui::bag::{Self, Bag};

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::witness::Witness as DelegatedWitness;

    struct Witness has drop {}

    /// ====== ChildNode ===

    /// Defines the properties of a child NFT in the context of type-limited
    /// composability
    struct ChildNode has store {
        // Amount of times the child NFT can be attached
        limit: u64,
        // TODO: ChildNode generic about parametrization types
        // Rendering order of the child NFT
        order: u64,
    }

    /// Create a new `ChildNode`
    fun new_child_node(limit: u64, order: u64): ChildNode {
        ChildNode { limit, order }
    }

    /// ====== ParentNode ===

    /// Defines which child NFTs can be attached to the root NFT
    struct ParentNode has store {
        children: Bag,
    }

    /// Create a new parent node which defines which child NFT nodes can be
    /// attached to it
    public fun new_parent_node(
        ctx: &mut TxContext
    ): ParentNode {
        ParentNode { children: bag::new(ctx) }
    }

    /// Define a new child node
    public fun add_child<Child>(
        parent_node: &mut ParentNode,
        limit: u64,
        order: u64,
    ) {
        let child = new_child_node(limit, order);
        bag::add(&mut parent_node.children, utils::marker<Child>(), child);
    }

    /// Borrows `ChildNode` from `ParentNode`
    ///
    /// #### Panics
    ///
    /// Panics if `ChildNode` was not registered.
    public fun borrow_child<Child>(parent_node: &ParentNode): &ChildNode {
        bag::borrow(&parent_node.children, utils::marker<Child>())
    }

    /// ====== Type ===

    struct Type<phantom T> has key, store {
        id: UID,
    }

    public fun new_type<T: drop + store>(
        ctx: &mut TxContext,
    ): Type<T> {
        Type {
            id: object::new(ctx),
        }
    }

    public fun add_type_domain<C, T: drop + store>(
        witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
        ctx: &mut TxContext
    ) {
        nft::add_domain(witness, nft, new_type<T>(ctx));
    }

    /// ====== Blueprint ===

    /// Domain held in the Collection object, blueprinting all the composability
    /// between types. It contains a ObjectTable with all the nodes of the
    /// composability flattened.
    struct Blueprint has key, store {
        id: UID,
        // ObjectTable with index TypeName as the type of the Parent,
        // and the value as ParentNode which contains all the children info
        nodes: Bag,
    }

    public fun new_blueprint(
        ctx: &mut TxContext
    ): Blueprint {
        Blueprint {
            id: object::new(ctx),
            nodes: bag::new(ctx),
        }
    }

    /// Adds parent child relationship to `Blueprint`
    ///
    /// #### Panics
    ///
    /// Panics if parent child relationship already exists
    public entry fun add_relationship<Parent, Child>(
        blueprint: &mut Blueprint,
        limit: u64,
        order: u64,
        ctx: &mut TxContext,
    ) {
        let parent_key = utils::marker<Parent>();

        if (!has_parent<Parent>(blueprint)) {
            bag::add(
                &mut blueprint.nodes,
                parent_key,
                new_parent_node(ctx),
            );
        };

        assert!(!has_child<Parent, Child>(blueprint), 0);

        let parent_node = bag::borrow_mut(
            &mut blueprint.nodes, parent_key
        );

        add_child<Child>(parent_node, limit, order);
    }

    /// Registers `Blueprint` on the given `Collection`
    public fun add_blueprint_domain<C>(
        witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        domain: Blueprint,
    ) {
        collection::add_domain(witness, collection, domain);
    }

    /// Borrows `ParentNode` from `Blueprint`
    ///
    /// #### Panics
    ///
    /// Panics if `ParentNode` was not registered.
    public fun borrow_parent<Parent>(blueprint: &Blueprint): &ParentNode {
        bag::borrow(&blueprint.nodes, utils::marker<Parent>())
    }

    /// ====== Nfts Domain ===

    /// Domain to be owned by the parent Nft.
    /// Allows the parent Nft to hold Child Nfts
    struct Nfts<phantom T> has key, store {
        id: UID,
        // A 2-rank tensor represented by a 2-nested object vector, where
        // the outer vector is indexed by object TypeName, and the inner vector
        // is index.
        // A nested structure is preferred over a simple ObjectTable as it
        // reduces the amount of average iterations required in read/write
        // operations
        table: ObjectTable<TypeName, ObjectTable<ID, Nft<T>>>
    }

    public entry fun compose<T, Parent: store, Child: store>(
        parent_nft: &mut Nft<T>,
        child_nft: Nft<T>,
        collection: &Collection<T>,
        ctx: &mut TxContext,
    ) {
        let child_type = type_name::get<Child>();

        let blueprint = collection::borrow_domain<T, Blueprint>(collection);

        // Assert that types match NFTs
        nft::assert_domain<T, Type<Parent>>(parent_nft);
        nft::assert_domain<T, Type<Child>>(&child_nft);

        // Assert if Parent and Child have link
        assert!(has_child_with_type<Parent, Child>(blueprint), 0);

        // Assert that it can compose within the limit
        let parent_node = borrow_parent<Parent>(blueprint);
        let child_node = borrow_child<Child>(parent_node);

        let nfts = nft::borrow_domain_mut<T, Nfts<T>, Witness>(
            Witness {}, parent_nft
        );

        // Add ObjectVec<Nft<T>> to Nfts<T> if not there
        let has_type = object_table::contains(
            &nfts.table, type_name::get<Child>()
        );

        // If there is no ObjectTable for this type, then it needs
        // to create one.
        if (!has_type) {
            object_table::add(
                &mut nfts.table,
                type_name::get<Child>(),
                object_table::new<ID, Nft<T>>(ctx)
            );
        };

        let nft_vec = object_table::borrow_mut(&mut nfts.table, child_type);

        // Assert that composition is within the limits
        assert!(
            object_table::length(nft_vec) <= child_node.limit,
            0
        );

        object_table::add(nft_vec, object::id(&child_nft), child_nft);
    }

    public entry fun decompose<T, Child: store>(
        parent_nft: &mut Nft<T>,
        child_nft: &Nft<T>,
        ctx: &mut TxContext,
    ) {
        // Confirm that child NFT is of type `Child`
        nft::assert_domain<T, Type<Child>>(child_nft);
        let child_nft_id = object::id(child_nft);

        let child_type = type_name::get<Child>();
        let nfts = nft::borrow_domain_mut<T, Nfts<T>, Witness>(Witness {}, parent_nft);

        let nfts_of_child_type = object_table::borrow_mut<TypeName, ObjectTable<ID, Nft<T>>>(
            &mut nfts.table,
            child_type
        );

        // TODO: Remove object table if empty
        let child_nft = object_table::remove<ID, Nft<T>>(nfts_of_child_type, child_nft_id);

        transfer::transfer(child_nft, tx_context::sender(ctx));
    }

    public fun has_parent<Parent>(blueprint: &Blueprint): bool {
        bag::contains(&blueprint.nodes, utils::marker<Parent>())
    }

    public fun has_child<Parent, Child>(blueprint: &Blueprint): bool {
        let parent_node = borrow_parent<Parent>(blueprint);
        bag::contains(&parent_node.children, utils::marker<Child>())
    }

    public fun has_child_with_type<Parent, Child>(
        blueprint: &Blueprint,
    ): bool {
        let parent_node = borrow_parent<Parent>(blueprint);
        bag::contains_with_type<Marker<Child>, ChildNode>(
            &parent_node.children, utils::marker<Child>(),
        )
    }

    /// Creates a new `Nfts` with name and description
    public fun new_nfts_domain<C>(
        ctx: &mut TxContext,
    ): Nfts<C> {
        Nfts<C> {
            id: object::new(ctx),
            table: object_table::new(ctx),
        }
    }

    public fun nfts_domain<C>(
        nft: &Nft<C>,
    ): &Nfts<C> {
        nft::borrow_domain(nft)
    }

    fun add_nfts_domain<C>(
        witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(witness, nft, new_nfts_domain<C>(ctx));
    }
}
