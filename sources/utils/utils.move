/// Utility functions
module nft_protocol::utils {
    use std::ascii;
    use std::string::{Self, String, sub_string};
    use std::type_name;
    use std::vector;

    use sui::vec_map::{Self, VecMap};

    use nft_protocol::err;

    /// Used to mark type fields in dynamic fields
    struct Marker<phantom T> has copy, drop, store {}

    public fun marker<T>(): Marker<T> {
        Marker<T> {}
    }

    public fun bps(): u16 {
        10_000
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

        assert!(package_a == package_b, err::witness_source_mismatch());
        assert!(module_a == module_b, err::witness_source_mismatch());
        assert!(witness_type == string::utf8(b"Witness"), err::must_be_witness());
    }

    public fun get_package_module_type<T>(): (String, String, String) {
        let delimiter = string::utf8(b"::");

        let t = string::utf8(ascii::into_bytes(
            type_name::into_string(type_name::get<T>())
        ));

        // TBD: this can probably be hard-coded as all hex addrs are 32 bytes
        let package_delimiter_index = string::index_of(&t, &delimiter);
        let package_addr = sub_string(&t, 0, string::index_of(&t, &delimiter));

        let tail = sub_string(&t, package_delimiter_index + 2, string::length(&t));

        let module_delimiter_index = string::index_of(&tail, &delimiter);
        let module_name = sub_string(&tail, 0, module_delimiter_index);

        let type_name = sub_string(&tail, module_delimiter_index + 2, string::length(&tail));

        (package_addr, module_name, type_name)
    }

    public fun from_vec_to_map<K: copy + drop, V: drop>(
        keys: vector<K>,
        values: vector<V>,
    ): VecMap<K, V> {
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

    /// T mustn't be exported by nft-protocol to avoid unexpected bugs
    public fun assert_not_nft_protocol_type<T>() {
        let (t_pkg, _, _) = get_package_module_type<T>();
        assert!(t_pkg != nft_protocol_package_id(), err::generic_nft_must_not_be_protocol_type());
    }

    /// Returns true if T is of type `nft_protocol::nft::Nft`
    public fun is_nft_protocol_nft_type<T>(): bool {
        let (t_pkg, t_module, t) = get_package_module_type<T>();
        t_pkg == nft_protocol_package_id() &&
            t_module == string::utf8(b"nft") &&
            string::sub_string(&t, 0, 3) == string::utf8(b"Nft")
    }

    public fun nft_protocol_package_id(): String {
        let (nft_pkg, _, _) = get_package_module_type<Marker<sui::object::ID>>();
        nft_pkg
    }
}
