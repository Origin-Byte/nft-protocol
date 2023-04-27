/// Utility functions
module nft_protocol::utils {
    use std::vector;

    use sui::vec_set::{Self, VecSet};
    use sui::package::{Self, Publisher};
    use sui::table_vec::{Self, TableVec};
    use sui::vec_map::{Self, VecMap};
    use sui::tx_context::TxContext;

    /// Mismatched length of key and value vectors used in `from_vec_to_map`
    const EMismatchedKeyValueLength: u64 = 1;

    const EInvalidPublisher: u64 = 2;

    public fun table_vec_from_vec<T: store>(
        vec: vector<T>,
        ctx: &mut TxContext
    ): TableVec<T> {
        let table = table_vec::empty<T>(ctx);

        let len = vector::length(&vec);

        while (len > 0) {
            let elem = vector::pop_back(&mut vec);
            table_vec::push_back(&mut table, elem);

            len = len - 1;
        };

        vector::destroy_empty(vec);

        table
    }

    public fun vec_set_from_vec<T: store + copy + drop>(
        vec: &vector<T>,
    ): VecSet<T> {
        let set = vec_set::empty<T>();
        let len = vector::length(vec);

        while (len > 0) {
            let elem = vector::borrow(vec, len);
            vec_set::insert(&mut set, *elem);

            len = len - 1;
        };
        set
    }

    public fun insert_vec_in_vec_set<T: store + copy + drop>(
        set: &mut VecSet<T>,
        vec: vector<T>,
    ) {
        let len = vector::length(&vec);

        while (len > 0) {
            let elem = vector::pop_back(&mut vec);
            vec_set::insert(set, elem);

            len = len - 1;
        };

        vector::destroy_empty(vec);
    }

    public fun insert_vec_in_table<T: store>(
        table: &mut TableVec<T>,
        vec: vector<T>,
    ) {
        let len = vector::length(&vec);

        while (len > 0) {
            let elem = vector::pop_back(&mut vec);
            table_vec::push_back(table, elem);

            len = len - 1;
        };

        vector::destroy_empty(vec);
    }

    public fun bps(): u16 {
        10_000
    }

    public fun assert_package_publisher<T>(pub: &Publisher) {
        assert!(package::from_package<T>(pub), EInvalidPublisher);
    }

    public fun from_vec_to_map<K: copy + drop, V: drop>(
        keys: vector<K>,
        values: vector<V>,
    ): VecMap<K, V> {
        assert!(
            vector::length(&keys) == vector::length(&values),
            EMismatchedKeyValueLength,
        );

        let i = 0;
        let n = vector::length(&keys);
        let map = vec_map::empty<K, V>();

        while (i < n) {
            let key = vector::pop_back(&mut keys);
            let value = vector::pop_back(&mut values);

            vec_map::insert(
                &mut map,
                key,
                value,
            );

            i = i + 1;
        };

        map
    }
}
