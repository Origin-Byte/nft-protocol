module nft_protocol::object_box {
    use std::type_name::{Self, TypeName};

    use nft_protocol::err;

    use sui::dynamic_object_field as dof;
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};

    struct ObjectBox has key, store {
        id: UID,
        len: u64,
    }

    public fun empty(ctx: &mut TxContext): ObjectBox {
        ObjectBox {
            id: object::new(ctx),
            len: 0,
        }
    }

    public fun new<V: store + key>(
        object: V,
        ctx: &mut TxContext,
    ): ObjectBox {

        let ob = ObjectBox {
            id: object::new(ctx),
            len: 0,
        };

        dof::add<TypeName, V>(
            &mut ob.id,
            type_name::get<V>(),
            object,
        );

        ob.len = 1;
        ob
    }

    // === Domain Functions ===

    public fun has_object<V: store + key>(ob: &ObjectBox): bool {
        dof::exists_<TypeName>(&ob.id, type_name::get<V>())
    }

    public fun borrow<V: store + key>(ob: &ObjectBox): &V {
        dof::borrow<TypeName, V>(&ob.id, type_name::get<V>())
    }

    public fun borrow_mut<V: store + key>(ob: &mut ObjectBox): &mut V {
        dof::borrow_mut<TypeName, V>(&mut ob.id, type_name::get<V>())
    }

    public fun add<V: store + key>(
        ob: &mut ObjectBox,
        v: V,
    ) {
        assert!(ob.len == 0, err::generic_bag_full());

        dof::add<TypeName, V>(
            &mut ob.id,
            type_name::get<V>(),
            v,
        );
    }

    public fun remove<V: store + key>(
        ob: &mut ObjectBox,
    ): V {
        dof::remove<TypeName, V>(&mut ob.id, type_name::get<V>())
    }

    public fun is_empty(ob: &ObjectBox): bool {
        ob.len == 0
    }
}
