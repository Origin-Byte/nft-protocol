module nft_protocol::karibu {
    //! Showcase of a whitelist organization which requires that a collection
    //! is approved by the organization before it can be added to the list.
    //! Prevents spam.

    use nft_protocol::collection::Collection;
    use nft_protocol::transfer_whitelist::{Self, Whitelist};
    use sui::object::{Self, UID, ID};
    use sui::transfer::{transfer, share_object};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set::{Self, VecSet};
    use std::type_name::{Self, TypeName};

    struct Witness has drop {}

    struct Karibu has key {
        id: UID,
        whitelist: ID,
        candidates: VecSet<TypeName>,
    }

    struct OwnerCap has key {
        id: UID,
        list_id: ID,
    }

    public entry fun create(ctx: &mut TxContext) {
        let list = transfer_whitelist::create(Witness {}, ctx);
        let governance = Karibu {
            id: object::new(ctx),
            whitelist: object::id(&list),
            candidates: vec_set::empty(),
        };
        let list_id = object::id(&list);

        share_object(list);
        share_object(governance);
        transfer(
            OwnerCap { id: object::new(ctx), list_id, },
            tx_context::sender(ctx),
        );
    }

    public entry fun add_candidate<T>(
        owner_cap: &OwnerCap,
        governance: &mut Karibu,
        _ctx: &mut TxContext,
    ) {
        assert!(object::id(governance) == owner_cap.list_id, 0);

        vec_set::insert(&mut governance.candidates, type_name::get<T>());
    }

    public entry fun insert_collection<T, M: store>(
        collection: &Collection<T, M>,
        governance: &mut Karibu,
        whitelist: &mut Whitelist<Witness>,
        ctx: &mut TxContext,
    ) {
        // aborts if collection not in the set
        vec_set::remove(&mut governance.candidates, &type_name::get<T>());

        transfer_whitelist::insert_collection(
            Witness {},
            collection,
            whitelist,
            ctx,
        );
    }

    /// Only the owner of the whitelist can manage it
    public entry fun insert_authority<Auth>(
        owner: &OwnerCap,
        list: &mut Whitelist<Witness>,
        _ctx: &mut TxContext,
    ) {
        assert!(object::id(list) == owner.list_id, 0);

        transfer_whitelist::insert_authority<Witness, Auth>(
            Witness {},
            list,
        );
    }

    /// Only the owner of the whitelist can manage it
    public entry fun remove_authority<Auth>(
        owner: &OwnerCap,
        list: &mut Whitelist<Witness>,
        _ctx: &mut TxContext,
    ) {
        assert!(object::id(list) == owner.list_id, 0);

        transfer_whitelist::remove_authority<Witness, Auth>(
            Witness {},
            list,
        );
    }
}
