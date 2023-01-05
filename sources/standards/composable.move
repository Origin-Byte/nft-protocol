module nft_protocol::composable {
    // TODO: Limit configurations (i.e. how many weapon NFTs can be attached to Avatar NFT)
    // TODO: Grouping of types into taxonomies can make the structuring of the
    // type system easier as it would more closely resemble the business logic.
    // However we should do this without introducing any convulution to this module,
    // and therefore this should be a higher-level abstraction exposed in a separate module
    use std::ascii;
    use std::hash;
    use std::vector;
    use std::string::{Self, String};
    use std::type_name::{Self, TypeName};

    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use nft_protocol::nft::{Self, Nft};
    use sui::object_bag::{Self, ObjectBag};
    use sui::object_table::{Self, ObjectTable};
    use nft_protocol::object_vec::{Self, ObjectVec};
    use nft_protocol::collection::{Self, Collection};

    struct Witness has drop {}

    struct Nfts<phantom T> has key, store {
        // A 2-rank tensor represented by a 2-nested object vector, where
        // the outer vector is indexed by object TypeName, and the inner vector
        // is index.
        // A nested structure is preferred over a simple ObjectTable as it
        // reduces the amount of average iterations required in read/write
        // operations
        table: ObjectTable<TypeName, ObjectVec<Nft<T>>>
    }

    struct Link<Parent: store, Child: store> has key, store {
        id: UID,
        parent: Parent,
        child: Child,
        // limit: Option<u64>, // Objective of Option is to make storage efficient
    }

    struct Blueprint has key, store {
        id: UID,
        links: ObjectBag,
    }

    public fun new_link<Parent: store, Child: store>(
        parent: Parent,
        child: Child,
        ctx: &mut TxContext
    ): Link<Parent, Child> {
        Link {
            id: object::new(ctx),
            parent: parent,
            child: child,
            // limit: option::none(),
        }
    }

    public fun new_blueprint(ctx: &mut TxContext): Blueprint {
        Blueprint {
            id: object::new(ctx),
            links: object_bag::new(ctx),
        }
    }

    public fun link_types<Parent: store, Child: store>(
        parent: Parent,
        child: Child,
        blueprint: &mut Blueprint,
        ctx: &mut TxContext,
    ) {
        let link = new_link(parent, child, ctx);

        let hash = get_hash<Parent, Child>();

        object_bag::add(&mut blueprint.links, hash, link);
    }

    public fun compose<T, Parent: store, Child: store>(
        parent_nft: &mut Nft<T>,
        child_nft: Nft<T>,
        collection: &Collection<T>,
        ctx: &mut TxContext,
    ) {
        let blueprint = collection::borrow_domain<T, Blueprint>(collection);

        let parent = nft::borrow_domain<T, Parent>(parent_nft);
        let child = nft::borrow_domain<T, Child>(&child_nft);

        assert!(has_link(parent, child, blueprint), 0);

        let nfts = nft::borrow_domain_mut<T, Nfts<T>, Witness>(
            Witness {}, parent_nft
        );

        let has_type = object_table::contains(
            &nfts.table, type_name::get<Child>()
        );

        if (!has_type) {
            object_table::add(
                &mut nfts.table,
                type_name::get<Child>(),
                object_vec::new<Nft<T>>(ctx)
            );
        };

        let table = object_table::borrow_mut(
            &mut nfts.table,
            type_name::get<Child>()
        );

        object_vec::add(table, child_nft);
    }

    public fun get_hash<Parent: store, Child: store>(
    ): String {
        let type = ascii::into_bytes(
            type_name::into_string(type_name::get<Parent>())
        );

        vector::append(
            &mut type,
            ascii::into_bytes(type_name::into_string(type_name::get<Child>())),
        );

        string::utf8(hash::sha2_256(type))
    }

    public fun has_link<Parent: store, Child: store>(
        parent: &Parent,
        child: &Child,
        blueprint: &Blueprint,
    ): bool {
        let hash = get_hash<Parent, Child>();

        object_bag::contains(&blueprint.links, hash)
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
