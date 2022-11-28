module nft_protocol::generic {
    use nft_protocol::err;
    use nft_protocol::domain::{domain_key, DomainKey};
    use nft_protocol::utils;

    use sui::object_bag::{Self, ObjectBag};
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};

    struct Generic has key, store {
        id: UID,
        object: ObjectBag,
    }

    public fun new<C>(ctx: &mut TxContext): Generic {
        Generic {
            id: object::new(ctx),
            object: object_bag::new(ctx),
        }
    }

    // === Domain Functions ===

    public fun has_object<D: store + key>(generic: &Generic): bool {
        object_bag::contains_with_type<DomainKey, D>(&generic.object, domain_key<D>())
    }

    public fun borrow_object<D: store + key>(generic: &Generic): &D {
        object_bag::borrow<DomainKey, D>(&generic.object, domain_key<D>())
    }

    public fun borrow_object_mut<D: store + key, W: drop>(
        _witness: W,
        generic: &mut Generic,
    ): &mut D {
        utils::assert_same_module_as_witness<W, D>();
        object_bag::borrow_mut<DomainKey, D>(&mut generic.object, domain_key<D>())

    }

    public fun add_object<V: store + key>(
        generic: &mut Generic,
        v: V,
    ) {
        assert!(object_bag::length(&generic.object) == 0, err::generic_bag_full());

        object_bag::add(&mut generic.object, domain_key<V>(), v);
    }

    public fun remove_object<W: drop, V: store + key>(
        _witness: W,
        generic: &mut Generic,
    ): V {
        utils::assert_same_module_as_witness<W, V>();
        object_bag::remove(&mut generic.object, domain_key<V>())
    }
}
