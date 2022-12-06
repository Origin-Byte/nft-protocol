module nft_protocol::box {
    use std::type_name::{Self, TypeName};

    use nft_protocol::err;
    use nft_protocol::domain::{domain_key, DomainKey};
    use nft_protocol::utils;

    use sui::dynamic_field as df;
    use sui::bag::{Self, Bag};
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};

    struct Box has store {
        id: UID,
        len: u64,
    }

    public fun empty(ctx: &mut TxContext): Box {
        Box {
            id: object::new(ctx),
            len: 0
        }
    }

    public fun new<V: store>(
        object: V,
        ctx: &mut TxContext,
    ): Box {

        let box = Box {
            id: object::new(ctx),
            len: 0,
        };

        df::add<TypeName, V>(
            &mut box.id,
            type_name::get<V>(),
            object,
        );

        box.len = 1;
        box
    }

    // === Domain Functions ===

    public fun has_object<V: store>(ob: &Box): bool {
        df::exists_with_type<TypeName, V>(&ob.id, type_name::get<V>())
    }

    public fun borrow<V: store + key>(box: &Box): &V {
        df::borrow<TypeName, V>(&box.id, type_name::get<V>())
    }

    public fun borrow_mut<V: store + key>(box: &mut Box): &mut V {
        df::borrow_mut<TypeName, V>(&mut box.id, type_name::get<V>())
    }

    public fun add<V: store + key>(
        box: &mut Box,
        v: V,
    ) {
        assert!(box.len == 0, err::generic_bag_full());

        df::add<TypeName, V>(
            &mut box.id,
            type_name::get<V>(),
            v,
        );
    }

    public fun remove<V: store + key>(
        box: &mut Box,
    ): V {
        df::remove<TypeName, V>(&mut box.id, type_name::get<V>())
    }

    public fun is_empty(box: &Box): bool {
        box.len == 0
    }
}
