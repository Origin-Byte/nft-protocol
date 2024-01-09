// SPDX-License-Identifier: MIT

/// @title object_vec
/// @dev An implementation of ObjectBag that constrains bag to holding only
/// one object.
module originmate::object_box {
    // TODO: Would be good to rename to ObjectField and create a second 
    // Field which does not require key. Would allow users to mark dynamic
    // fields explicitly.
    // TODOS: Tests
    use std::type_name::{Self, TypeName};

    use sui::dynamic_object_field as dof;
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};

    /// @dev Attempting to add an object to an ObjectBox when it already has one.
    const GENERIC_BOX_FULL: u64 = 0x60700;

    struct ObjectBox has key, store {
        id: UID,
        // TODO: Change to bool
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
        assert!(ob.len == 0, GENERIC_BOX_FULL);

        dof::add<TypeName, V>(
            &mut ob.id,
            type_name::get<V>(),
            v,
        );
        ob.len = ob.len + 1;
    }

    public fun remove<V: store + key>(
        ob: &mut ObjectBox,
    ): V {
        ob.len = ob.len - 1;
        dof::remove<TypeName, V>(&mut ob.id, type_name::get<V>())
    }

    public fun is_empty(ob: &ObjectBox): bool {
        ob.len == 0
    }
}
