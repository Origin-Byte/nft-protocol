module ob_launchpad_v2::lp_utils {
    use std::vector;

    use sui::table::{Self, Table};
    use sui::vec_map::{Self, VecMap};
    use sui::tx_context::TxContext;

    public fun table_from_vec_map<K: copy +  store + drop, T: store>(
        vec: VecMap<K, T>,
        ctx: &mut TxContext
    ): Table<K, T> {
        let table = table::new<K, T>(ctx);

        let (keys, vals) = vec_map::into_keys_values(vec);

        let len = vector::length(&vals);

        while (len > 0) {
            let elem = vector::pop_back(&mut vals);
            let key = vector::pop_back(&mut keys);
            table::add(&mut table, key, elem);

            len = len - 1;
        };

        vector::destroy_empty(vals);
        vector::destroy_empty(keys);

        table
    }
}
