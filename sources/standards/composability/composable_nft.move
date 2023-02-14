module nft_protocol::composable_nft {
    // TODO: Limit configurations (i.e. how many weapon NFTs can be attached to Avatar NFT)
    // TODO: Grouping of types into taxonomies can make the structuring of the
    // type system easier as it would more closely resemble the business logic.
    // However we should do this without introducing any convulution to this module,
    // and therefore this should be a higher-level abstraction exposed in a separate module
    // TODO: Ideally we would allow for multiple NFTs to be composed together in a single
    // transaction
    // TODO: some endpoint for reorder_children
    use std::option;
    use std::type_name::{Self, TypeName};

    use sui::transfer;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::object_table::{Self, ObjectTable};
    use sui::vec_map::{Self, VecMap};

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::witness::Witness as DelegatedWitness;

    struct Witness has drop {}

    /// === ChildNode ===

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

    /// === Type ===

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

    /// === Blueprint ===

    /// Domain held in the Collection object, blueprinting all the composability
    /// between types. It contains a ObjectTable with all the nodes of the
    /// composability flattened.
    struct Blueprint<phantom T> has store {
        id: UID,
        nodes: VecMap<TypeName, ChildNode>,
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
    public entry fun add_relationship<Parent, Child>(
        blueprint: &mut Blueprint<Parent>,
        limit: u64,
        order: u64,
    ) {
        assert!(!has_child<Parent, Child>(blueprint), 0);

        let child = new_child_node(limit, order);
        let child_type = type_name::get<Child>();
        vec_map::insert(&mut blueprint.nodes, child_type, child);
    }

    public fun borrow_child<Parent>(
        blueprint: &Blueprint<Parent>,
        child_type: &TypeName,
    ): &ChildNode {
        vec_map::get(&blueprint.nodes, child_type)
    }

    fun borrow_child_mut<Parent>(
        blueprint: &mut Blueprint<Parent>,
        child_type: &TypeName,
    ): &mut ChildNode {
        vec_map::get_mut(&mut blueprint.nodes, child_type)
    }

    /// Registers `Blueprint` on the given `Collection`
    public fun add_blueprint_domain<C, Parent>(
        witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        domain: Blueprint<Parent>,
    ) {
        collection::add_domain(witness, collection, domain);
    }

    /// === Nfts Domain ===

    /// Domain to be owned by the parent Nft.
    /// Allows the parent Nft to hold Child Nfts
    struct Nfts<phantom C> has key, store {
        id: UID,
        // A 2-rank tensor represented by a 2-nested object vector, where
        // the outer vector is indexed by object TypeName, and the inner vector
        // is index.
        // A nested structure is preferred over a simple ObjectTable as it
        // reduces the amount of average iterations required in read/write
        // operations
        table: VecMap<TypeName, ObjectTable<ID, Nft<C>>>
    }

    /// Mutably borrow entry of children
    ///
    /// Creates a new entry if one does not already exist.
    ///
    /// Endpoint is unprotected and relies on safe access to `Nfts`.
    public fun borrow_composed_mut<C>(
        nfts: &mut Nfts<C>,
        parent_type: &TypeName,
        ctx: &mut TxContext,
    ): &mut ObjectTable<ID, Nft<C>> {
        let idx_opt = vec_map::get_idx_opt(&nfts.table, parent_type);

        let idx = if (option::is_some(&idx_opt)) {
            option::destroy_some(idx_opt)
        } else {
            let idx = vec_map::size(&nfts.table);
            vec_map::insert(
                &mut nfts.table,
                *parent_type,
                object_table::new<ID, Nft<C>>(ctx),
            );
            idx
        };

        let (_, entry) =
            vec_map::get_entry_by_idx_mut(&mut nfts.table, idx);
        entry
    }

    /// Mutably borrow entry of children
    ///
    /// Endpoint is unprotected and relies on safe access to `Nfts`.
    ///
    /// #### Panics
    ///
    /// Panics if entry does not exist
    public fun try_borrow_composed_mut<C>(
        nfts: &mut Nfts<C>,
        parent_type: &TypeName,
    ): &mut ObjectTable<ID, Nft<C>> {
        vec_map::get_mut(&mut nfts.table, parent_type)
    }

    public entry fun compose<C, Parent: store, Child: store>(
        parent_nft: &mut Nft<C>,
        child_nft: Nft<C>,
        collection: &Collection<C>,
        ctx: &mut TxContext,
    ) {
        let blueprint: &Blueprint<Parent> =
            collection::borrow_domain(collection);

        // Assert that types match NFTs
        nft::assert_domain<C, Type<Parent>>(parent_nft);
        nft::assert_domain<C, Type<Child>>(&child_nft);

        // Assert if Parent and Child are composable
        assert!(has_child<Parent, Child>(blueprint), 0);

        let nfts = nft::borrow_domain_mut<C, Nfts<C>, Witness>(
            Witness {}, parent_nft
        );

        let parent_type = type_name::get<Parent>();
        let nft_vec = borrow_composed_mut(nfts, &parent_type, ctx);

        // Asserts that type is composable
        let child_type = type_name::get<Child>();
        let child_node = borrow_child<Parent>(blueprint, &child_type);

        assert!(object_table::length(nft_vec) <= child_node.limit, 0);

        object_table::add(nft_vec, object::id(&child_nft), child_nft);
    }

    /// Decomposes NFT with given ID from parent NFT
    ///
    /// #### Panics
    ///
    /// Panics if there is no NFT with given ID composed
    public entry fun decompose<C, Parent, Child>(
        parent_nft: &mut Nft<C>,
        child_nft_id: ID,
        ctx: &mut TxContext,
    ) {
        let nfts: &mut Nfts<C> =
            nft::borrow_domain_mut(Witness {}, parent_nft);

        let parent_type = type_name::get<Parent>();
        let nft_vec = try_borrow_composed_mut(nfts, &parent_type);

        // TODO: Remove object table if empty
        let child_nft = object_table::remove(nft_vec, child_nft_id);

        transfer::transfer(child_nft, tx_context::sender(ctx));
    }

    public fun has_child<Parent, Child>(blueprint: &Blueprint<Parent>): bool {
        let child_type = type_name::get<Child>();
        vec_map::contains(&blueprint.nodes, &child_type)
    }

    /// Creates new `Nfts` domain
    public fun new_nfts_domain<C>(ctx: &mut TxContext): Nfts<C> {
        Nfts {
            id: object::new(ctx),
            table: vec_map::empty(),
        }
    }

    public fun nfts_domain<C>(nft: &Nft<C>): &Nfts<C> {
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
