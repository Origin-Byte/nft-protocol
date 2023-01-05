module nft_protocol::box {
    use std::type_name::{Self, TypeName};

    use nft_protocol::err;

    use sui::dynamic_field as df;
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};

    struct Box has key, store {
        id: UID,
        len: u64,
    }

    public fun empty(ctx: &mut TxContext): Box {
        Box {
            id: object::new(ctx),
            len: 0,
        }
    }

    public fun new<V: store + key>(
        object: V,
        ctx: &mut TxContext
    ): Box {

        let ob = Box {
            id: object::new(ctx),
            len: 0,
        };

        df::add(
            &mut ob.id,
            type_name::get<V>(),
            object,
        );

        ob.len = 1;
        ob
    }

    // === Domain Functions ===

    public fun has_object<V: store>(ob: &Box): bool {
        df::exists_<TypeName>(&ob.id, type_name::get<V>())
    }

    public fun borrow<V: store>(ob: &Box): &V {
        df::borrow<TypeName, V>(&ob.id, type_name::get<V>())
    }

    public fun borrow_mut<V: store>(ob: &mut Box): &mut V {
        df::borrow_mut<TypeName, V>(&mut ob.id, type_name::get<V>())
    }

    public fun add<V: store>(
        ob: &mut Box,
        v: V,
    ) {
        assert!(ob.len == 0, err::generic_bag_full());

        df::add<TypeName, V>(
            &mut ob.id,
            type_name::get<V>(),
            v,
        );
    }

    public fun remove<V: store>(
        ob: &mut Box,
    ): V {
        df::remove<TypeName, V>(&mut ob.id, type_name::get<V>())
    }

    public fun is_empty(ob: &Box): bool {
        ob.len == 0
    }
}
