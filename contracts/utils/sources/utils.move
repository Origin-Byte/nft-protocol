/// Utility functions
module ob_utils::utils {
    use std::vector;
    use std::ascii;
    use std::type_name;
    use std::string::{Self, String, utf8, sub_string};

    use sui::vec_set::{Self, VecSet};
    use sui::table::{Self, Table};
    use sui::package::{Self, Publisher};
    use sui::table_vec::{Self, TableVec};
    use sui::vec_map::{Self, VecMap};
    use sui::tx_context::TxContext;

    use originmate::pseudorandom;

    /// Mismatched length of key and value vectors used in `from_vec_to_map`
    const EMismatchedKeyValueLength: u64 = 1;

    const EInvalidPublisher: u64 = 2;

    /// `Witness` was from a different package than `T`
    const EInvalidWitnessPackage: u64 = 3;

    /// `Witness` was from a different module than `T`
    const EInvalidWitnessModule: u64 = 4;

    /// Witness was not named `Witness`
    const EInvalidWitness: u64 = 5;

    /// Used to mark type fields in dynamic fields
    struct Marker<phantom T> has copy, drop, store {}

    struct IsShared has copy, store, drop {}

    public fun marker<T>(): Marker<T> {
        Marker<T> {}
    }

    public fun is_shared(): IsShared {
        IsShared {}
    }

    /// Outputs modulo of a random `u256` number and a bound
    ///
    /// Due to `random >> bound` we `select` does not exhibit significant
    /// modulo bias.
    public fun random_number(bound: u64, random: &vector<u8>): u64 {
        let random = pseudorandom::u256_from_bytes(random);
        let mod  = random % (bound as u256);
        (mod as u64)
    }

    public fun get_package_module_type<T>(): (String, String, String) {
        let t = string::utf8(ascii::into_bytes(
            type_name::into_string(type_name::get<T>())
        ));

        get_package_module_type_raw(t)
    }

    public fun get_package_module_type_raw(t: String): (String, String, String) {
        let delimiter = string::utf8(b"::");

        // TBD: this can probably be hard-coded as all hex addrs are 32 bytes
        let package_delimiter_index = string::index_of(&t, &delimiter);
        let package_addr = sub_string(&t, 0, string::index_of(&t, &delimiter));

        let tail = sub_string(&t, package_delimiter_index + 2, string::length(&t));

        let module_delimiter_index = string::index_of(&tail, &delimiter);
        let module_name = sub_string(&tail, 0, module_delimiter_index);

        let type_name = sub_string(&tail, module_delimiter_index + 2, string::length(&tail));

        (package_addr, module_name, type_name)
    }

    /// Assert that two types are exported by the same module.
    public fun assert_same_module<T1, T2>() {
        let (package_a, module_a, _) = get_package_module_type<T1>();
        let (package_b, module_b, _) = get_package_module_type<T2>();

        assert!(package_a == package_b, EInvalidWitnessPackage);
        assert!(module_a == module_b, EInvalidWitnessModule);
    }

    /// First generic `T` is any type, second generic is `Witness`.
    /// `Witness` is a type always in form "struct Witness has drop {}"
    ///
    /// In this method, we check that `T` is exported by the same _module_.
    /// That is both package ID, package name and module name must match.
    /// Additionally, with accordance to the convention above, the second
    /// generic `Witness` must be named `Witness` as a type.
    ///
    /// # Example
    /// It's useful to assert that a one-time-witness is exported by the same
    /// contract as `Witness`.
    /// That's because one-time-witness is often used as a convention for
    /// initiating e.g. a collection name.
    /// However, it cannot be instantiated outside of the `init` function.
    /// Therefore, the collection contract can export `Witness` which serves as
    /// an auth token at a later stage.
    public fun assert_same_module_as_witness<T, Witness>() {
        let (package_a, module_a, _) = get_package_module_type<T>();
        let (package_b, module_b, witness_type) = get_package_module_type<Witness>();

        assert!(package_a == package_b, EInvalidWitnessPackage);
        assert!(module_a == module_b, EInvalidWitnessModule);
        assert!(witness_type == std::string::utf8(b"Witness"), EInvalidWitness);
    }

    /// Asserts that `Publisher` is of type `T`
    ///
    /// #### Panics
    ///
    /// Panics if `Publisher` is mismatched
    public fun assert_publisher<T>(pub: &Publisher) {
        assert!(package::from_package<T>(pub), EInvalidPublisher);
    }

    public fun originbyte_docs_url(): String {
        utf8(b"https://docs.originbyte.io")
    }

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
            let elem = vector::borrow(vec, len - 1);
            vec_set::insert(&mut set, *elem);

            len = len - 1;
        };
        set
    }

    public fun vec_map_entries<K: copy + drop, V: copy>(map: &VecMap<K, V>): vector<V> {
        let keys = vec_map::keys(map);

        let i = 0;
        let n = vector::length(&keys);
        let values = vector::empty();
        while (i < n) {
            let key = vector::borrow(&keys, i);
            let value = vec_map::get(map, key);
            vector::push_back(&mut values, *value);
            i = i + 1;
        };
        values
    }

    public fun sum_vector(vec: vector<u64>): u64 {
        let len = vector::length(&vec);

        let result = 0;
        while (len > 0) {
            let val = vector::pop_back(&mut vec);
            result = result + val;

            len = len - 1;
        };

        result
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
