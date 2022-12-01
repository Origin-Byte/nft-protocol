module nft_protocol::box {
    use nft_protocol::err;
    use nft_protocol::domain::{domain_key, DomainKey};
    use nft_protocol::utils;

    use sui::bag::{Self, Bag};
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};

    struct Box has store {
        id: UID,
        object: Bag,
    }

    public fun empty(ctx: &mut TxContext): Box {
        Box {
            id: object::new(ctx),
            object: bag::new(ctx),
        }
    }

    public fun new<V: store>(
        object: V,
        ctx: &mut TxContext,
    ): Box {

        let ob = bag::new(ctx);

        bag::add(&mut ob, domain_key<V>(), object);

        Box {
            id: object::new(ctx),
            object: ob,
        }
    }

    // === Domain Functions ===

    public fun has_object<D: store>(generic: &Box): bool {
        bag::contains_with_type<DomainKey, D>(&generic.object, domain_key<D>())
    }

    public fun borrow_object<D: store>(generic: &Box): &D {
        bag::borrow<DomainKey, D>(&generic.object, domain_key<D>())
    }

    public fun borrow_object_mut<D: store, W: drop>(
        generic: &mut Box,
    ): &mut D {
        bag::borrow_mut<DomainKey, D>(&mut generic.object, domain_key<D>())

    }

    public fun add_object<V: store>(
        generic: &mut Box,
        v: V,
    ) {
        assert!(bag::length(&generic.object) == 0, err::generic_bag_full());

        bag::add(&mut generic.object, domain_key<V>(), v);
    }

    public fun remove_object<W: drop, V: store>(
        _witness: W,
        generic: &mut Box,
    ): V {
        utils::assert_same_module_as_witness<W, V>();
        bag::remove(&mut generic.object, domain_key<V>())
    }
}
