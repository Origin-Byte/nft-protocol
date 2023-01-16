module nft_protocol::c_nft {
    // TODO: Limit configurations (i.e. how many weapon NFTs can be attached to Avatar NFT)
    // TODO: Grouping of types into taxonomies can make the structuring of the
    // type system easier as it would more closely resemble the business logic.
    // However we should do this without introducing any convulution to this module,
    // and therefore this should be a higher-level abstraction exposed in a separate module
    // TODO: Ideally we would allow for multiple NFTs to be composed together in a single
    // transaction
    // TODO: some endpoint for reorder_children
    use std::type_name::{Self, TypeName};

    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::vec_set::{Self, VecSet};
    use sui::object_table::{Self, ObjectTable};

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::object_vec::{Self, ObjectVec};
    use nft_protocol::collection::{Self, Collection, MintCap};

    struct Witness has drop {}

    /// ====== ChildNode ===

    /// Defines a Child type in the context of a composability node.
    /// To be used by ParentNode
    struct ChildNode has key, store {
        id: UID,
        // Childr type
        type: TypeName,
        // Amount of times child NFT of a the type given
        // can be attached to a given Parent NFT
        limit: u64,
        // Represents the layer in which the child NFT is stacked,
        // for rendering purposes.
        order: u64,
    }

    public fun new_child_node<Child>(
        limit: u64,
        order: u64,
        ctx: &mut TxContext,
    ): ChildNode {
        ChildNode {
            id: object::new(ctx),
            type: type_name::get<Child>(),
            limit: limit,
            order: order,
        }
    }

    /// ====== ParentNode ===

    /// Defines which child NFTs can be attached to the Parent NFT.
    struct ParentNode has key, store {
        id: UID,
        children: ObjectTable<TypeName, ChildNode>,
        // Orders are redundantly represented here for
        // the purpose of ownership test
        orders: VecSet<u64>,
    }

    public fun new_parent_node(
        ctx: &mut TxContext
    ): ParentNode {
        ParentNode {
            id: object::new(ctx),
            children: object_table::new(ctx),
            orders: vec_set::empty(),
        }
    }

    public fun add_child(
        parent_node: &mut ParentNode,
        child: ChildNode,
    ) {
        object_table::add(&mut parent_node.children, child.type, child);
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
        nft: &mut Nft<C>,
        ctx: &mut TxContext
    ) {
        nft::add_domain(nft, new_type<T>(ctx), ctx);
    }

    /// ====== Blueprint ===

    /// Domain held in the Collection object, blueprinting all the composability
    /// between types. It contains a ObjectTable with all the nodes of the
    /// composability flattened.
    struct Blueprint has key, store {
        id: UID,
        // ObjectTable with index TypeName as the type of the Parent,
        // and the value as ParentNode which contains all the children info
        nodes: ObjectTable<TypeName, ParentNode>,
    }

    public fun new_blueprint(
        ctx: &mut TxContext
    ): Blueprint {
        Blueprint {
            id: object::new(ctx),
            nodes: object_table::new<TypeName, ParentNode>(ctx),
        }
    }

    public entry fun add_parent_child_relationship<Parent: store>(
        blueprint: &mut Blueprint,
        child_node: ChildNode,
        ctx: &mut TxContext,
    ) {
        let parent_type = type_name::get<Parent>();

        let has_parent = object_table::contains(
            &blueprint.nodes, parent_type
        );

        // If it doesn't have an ObjectVec yet for this type,
        // then it needs to create one.
        if (!has_parent) {
            object_table::add(
                &mut blueprint.nodes,
                parent_type,
                new_parent_node(ctx),
            );
        };

        assert!(!has_child_<Parent>(&child_node, blueprint), 0);
        assert!(!has_order<Parent>(child_node.order, blueprint), 0);

        let parent_node = object_table::borrow_mut(
            &mut blueprint.nodes, parent_type
        );

        add_child(parent_node, child_node);
    }

    /// Registers `Blueprint` on the given `Collection`
    public fun add_blueprint_domain<C>(
        collection: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        domain: Blueprint,
    ) {
        collection::add_domain(collection, mint_cap, domain);
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
        table: ObjectTable<TypeName, ObjectVec<Nft<T>>>
    }

    public entry fun compose<T, Parent: store, Child: store>(
        parent_nft: &mut Nft<T>,
        child_nft: Nft<T>,
        collection: &Collection<T>,
        ctx: &mut TxContext,
    ) {
        let parent_type = type_name::get<Parent>();
        let child_type = type_name::get<Child>();

        let blueprint = collection::borrow_domain<T, Blueprint>(collection);

        // Assert that types match NFTs
        nft::assert_domain<T, Parent>(parent_nft);
        nft::assert_domain<T, Child>(&child_nft);

        // Assert if Parent and Child have link
        assert!(has_child_with_type<Parent, Child>(blueprint), 0);

        // Assert that it can compose within the limit
        let parent_node = object_table::borrow(
            &blueprint.nodes,
            parent_type,
        );

        let child_node = object_table::borrow(
            &parent_node.children,
            child_type,
        );



        let nfts = nft::borrow_domain_mut<T, Nfts<T>, Witness>(
            Witness {}, parent_nft
        );

        // Add ObjectVec<Nft<T>> to Nfts<T> if not there
        let has_type = object_table::contains(
            &nfts.table, type_name::get<Child>()
        );

        // If there is no ObjectVec for this type, then it needs
        // to create one.
        if (!has_type) {
            object_table::add(
                &mut nfts.table,
                type_name::get<Child>(),
                object_vec::new<Nft<T>>(ctx)
            );
        };

        let nft_vec = object_table::borrow_mut(&mut nfts.table, child_type);

        // Assert that composition is within the limits
        assert!(
            object_vec::length(nft_vec) <= child_node.limit,
            0
        );

        object_vec::add(nft_vec, child_nft);
    }

    // TODO
    public entry fun decompose() {}

    public fun has_child_<Parent: store>(
        child: &ChildNode,
        blueprint: &Blueprint,
    ): bool {
        let parent_type = type_name::get<Parent>();

        let parent_node = object_table::borrow(
            &blueprint.nodes, parent_type
        );

        object_table::contains(&parent_node.children, child.type)
    }

    public fun has_child_with_type<Parent: store, Child: store>(
        blueprint: &Blueprint,
    ): bool {
        let parent_type = type_name::get<Parent>();
        let child_type = type_name::get<Parent>();

        let parent_node = object_table::borrow(
            &blueprint.nodes, parent_type
        );

        object_table::contains(&parent_node.children, child_type)
    }

    public fun has_order<Parent: store>(
        order: u64,
        blueprint: &Blueprint,
    ): bool {
        let parent_type = type_name::get<Parent>();

        let parent_node = object_table::borrow(
            &blueprint.nodes, parent_type
        );

        vec_set::contains(&parent_node.orders, &order)
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
        nft: &mut Nft<C>,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(nft, new_nfts_domain<C>(ctx), ctx);
    }
}
