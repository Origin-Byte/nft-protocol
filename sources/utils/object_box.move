module nft_protocol::object_box {
    use nft_protocol::err;
    use nft_protocol::domain::{domain_key, DomainKey};
    use nft_protocol::utils;

    use sui::bag::{Self, Bag};
    use sui::object_bag::{Self, ObjectBag};
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};

    struct ObjectBox has key, store {
        id: UID,
        object: ObjectBag,
    }

    public fun empty(ctx: &mut TxContext): ObjectBox {
        ObjectBox {
            id: object::new(ctx),
            object: object_bag::new(ctx),
        }
    }

    public fun new<V: store + key>(
        object: V,
        ctx: &mut TxContext,
    ): ObjectBox {

        let ob = object_bag::new(ctx);

        object_bag::add(&mut ob, domain_key<V>(), object);

        ObjectBox {
            id: object::new(ctx),
            object: ob,
        }
    }

    // === Domain Functions ===

    public fun has_object<D: store + key>(generic: &ObjectBox): bool {
        object_bag::contains_with_type<DomainKey, D>(&generic.object, domain_key<D>())
    }

    public fun borrow<D: store + key>(generic: &ObjectBox): &D {
        object_bag::borrow<DomainKey, D>(&generic.object, domain_key<D>())
    }

    public fun borrow_mut<D: store + key>(
        generic: &mut ObjectBox,
    ): &mut D {
        object_bag::borrow_mut<DomainKey, D>(&mut generic.object, domain_key<D>())

    }

    public fun add_object<V: store + key>(
        generic: &mut ObjectBox,
        v: V,
    ) {
        assert!(object_bag::length(&generic.object) == 0, err::generic_bag_full());

        object_bag::add(&mut generic.object, domain_key<V>(), v);
    }

    public fun remove_object<W: drop, V: store + key>(
        _witness: W,
        generic: &mut ObjectBox,
    ): V {
        utils::assert_same_module_as_witness<W, V>();
        object_bag::remove(&mut generic.object, domain_key<V>())
    }

    public fun is_empty(generic: &ObjectBox): bool {
        object_bag::is_empty(&generic.object)
    }
}
