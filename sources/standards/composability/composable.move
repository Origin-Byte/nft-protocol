module nft_protocol::composable {
    // TODO: Limit configurations (i.e. how many weapon NFTs can be attached to Avatar NFT)
    // TODO: Grouping of types into taxonomies can make the structuring of the
    // type system easier as it would more closely resemble the business logic.
    // However we should do this without introducing any convulution to this module,
    // and therefore this should be a higher-level abstraction exposed in a separate module
    // TODO: Ideally we would allow for multiple NFTs to be composed together in a single
    // transaction
    use std::ascii;
    use std::hash;
    use std::vector;
    use std::option::{Self, Option};
    use std::string::{Self, String};
    use std::type_name::{Self, TypeName};

    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use nft_protocol::nft::{Self, Nft};
    use sui::object_bag::{Self, ObjectBag};
    use sui::bag::{Self, Bag};
    use sui::object_table::{Self, ObjectTable};
    use nft_protocol::object_vec::{Self, ObjectVec};
    use nft_protocol::collection::{Self, Collection};

    struct Witness has drop {}

    /// Domain to be owned by the parent Nft.
    /// Allows the parent Nft to hold Child Nfts
    struct Nfts<phantom T> has key, store {
        // A 2-rank tensor represented by a 2-nested object vector, where
        // the outer vector is indexed by object TypeName, and the inner vector
        // is index.
        // A nested structure is preferred over a simple ObjectTable as it
        // reduces the amount of average iterations required in read/write
        // operations
        table: ObjectTable<TypeName, ObjectVec<Nft<T>>>
    }

    /// Defines which NFTs can be composed with each other
    /// The type-exporting collection module will export a type system
    /// for its NFTs, and links can be made between types via parent-child
    /// relationship.
    struct Link<Parent: store> has key, store {
        id: UID,
        parent: Parent,
        // Children types ordered by rendering order
        children: Bag,
        // Maximum limit ordered by rendering order
        limit: vector<u64>,
    }

    /// Domain held in the Collection object, grouping all Links in a collection
    struct Blueprint has key, store {
        id: UID,
        // ObjectBag with Links. It is an ObjectBag instead of ObjectTable,
        // in order to avoid the Parent generic in Link
        links: ObjectBag,
    }

    public fun new_link<Parent: store, Child: store>(
        parent: Parent,
        ctx: &mut TxContext
    ): Link<Parent> {
        Link {
            id: object::new(ctx),
            parent: parent,
            children: bag::new(ctx),
            limit: vector::empty(),
        }
    }

    public fun add_to_link<Parent: store, Child: store>(
        link: &mut Link<Parent>,
        new_child: Child,
        limit: u64,
        ctx: &mut TxContext
    ) {
        let index = bag::length(&link.children);

        bag::add(&mut link.children, index + 1, new_child);

        vector::push_back(&mut link.limit, limit);
    }

    // TODO
    public fun reorder_children() {}

    public fun new_blueprint(ctx: &mut TxContext): Blueprint {
        Blueprint {
            id: object::new(ctx),
            links: object_bag::new(ctx),
        }
    }

    public fun add_link_to_blueprint<Parent: store, Child: store>(
        link: Link<Parent>,
        blueprint: &mut Blueprint,
        ctx: &mut TxContext,
    ) {
        let type = type_name::get<Child>();

        object_bag::add(&mut blueprint.links, type, link);
    }

    public fun compose<T, Parent: store, Child: store>(
        parent_nft: &mut Nft<T>,
        child_nft: Nft<T>,
        collection: &Collection<T>,
        ctx: &mut TxContext,
    ) {
        let blueprint = collection::borrow_domain<T, Blueprint>(collection);

        // Fetching types
        let parent = nft::borrow_domain<T, Parent>(parent_nft);
        let child = nft::borrow_domain<T, Child>(&child_nft);

        // Assert if Parent and Child have link
        assert!(has_link(parent, child, blueprint), 0);

        let nfts = nft::borrow_domain_mut<T, Nfts<T>, Witness>(
            Witness {}, parent_nft
        );

        let has_type = object_table::contains(
            &nfts.table, type_name::get<Child>()
        );

        // If it doesn't have an ObjectVec yet for this type, then it needs
        // to create one.
        if (!has_type) {
            object_table::add(
                &mut nfts.table,
                type_name::get<Child>(),
                object_vec::new<Nft<T>>(ctx)
            );
        };

        let vec = object_table::borrow_mut(
            &mut nfts.table,
            type_name::get<Child>()
        );

        // Get link
        let type = type_name::get<Parent>();

        let link = object_bag::borrow_mut(
            &mut blueprint.links, type
        );

        // TODO: problem here is that there is no way to fetch without iterating
        let limit = link.limits

        assert!(
            object_vec::length(&vec) < link.
        )

        object_vec::add(vec, child_nft);
    }

    // public fun get_hash<Parent: store, Child: store>(
    // ): String {
    //     let type = ascii::into_bytes(
    //         type_name::into_string(type_name::get<Parent>())
    //     );

    //     vector::append(
    //         &mut type,
    //         ascii::into_bytes(type_name::into_string(type_name::get<Child>())),
    //     );

    //     string::utf8(hash::sha2_256(type))
    // }

    public fun has_link<Parent: store, Child: store>(
        parent: &Parent,
        child: &Child,
        blueprint: &Blueprint,
    ): bool {
        let parent_type = type_name::get<Parent>();

        let link = object_bag::borrow<TypeName, Link<Parent>>(&blueprint.links, parent_type);

        let child_type = type_name::get<Child>();

        bag::contains(&link.children, child_type)
    }

    public fun nfts_domain<C>(
        collection: &Collection<C>,
    ): &Nfts<C> {
        collection::borrow_domain(collection)
    }

    fun add_nfts_domain<C>(
        nft: &mut Nft<C>,
        domain: Nfts<C>,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(nft, domain, ctx);
    }
}
