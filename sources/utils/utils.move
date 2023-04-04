/// Utility functions
module nft_protocol::utils {
    use nft_protocol::err;
    use std::ascii;
    use std::string::{Self, String, sub_string};
    use std::type_name;
    use std::vector;

    use sui::vec_set::{Self, VecSet};
    use sui::package::{Self, Publisher};
    use sui::table_vec::{Self, TableVec};
    use sui::vec_map::{Self, VecMap};
    use sui::tx_context::TxContext;
    use sui::object::{Self, ID, UID};


    /// Mismatched length of key and value vectors used in `from_vec_to_map`
    const EMismatchedKeyValueLength: u64 = 1;

    const EPackagePublisherMismatch: u64 = 2;

    /// Used to mark type fields in dynamic fields
    struct Marker<phantom T> has copy, drop, store {}

    struct UidType<phantom T> has drop {
        id: ID,
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

    public fun marker<T>(): Marker<T> {
        Marker<T> {}
    }

    public fun bps(): u16 {
        10_000
    }

    public fun assert_with_witness<W: drop, T: key>(
        nft_uid: &UID,
        nft_type: UidType<T>
    ) {
        assert_uid_type(nft_uid, &nft_type);
        assert_same_module<T, W>();
    }

    public fun assert_with_consumable_witness<T: key>(
        nft_uid: &UID,
        nft_type: UidType<T>
    ) {
        assert_uid_type(nft_uid, &nft_type);
    }

    public fun uid_type_to_inner<T: key>(uid: &UidType<T>): ID {
        uid.id
    }

    public fun proof_of_type<T: key>(uid: &UID, object: &T): UidType<T> {
        let uid_id = object::uid_to_inner(uid);
        let object_id = object::id(object);

        assert!(uid_id == object_id, 0);

        UidType<T> { id: uid_id }
    }

    public fun assert_uid_type<T: key>(uid: &UID, uid_type: &UidType<T>) {
        assert!(*object::uid_as_inner(uid) == uid_type.id, 0);
    }

    public fun assert_uid_type_<T: key>(uid: &UID, object: &T) {
        let uid_id = object::uid_to_inner(uid);
        let object_id = object::id(object);

        assert!(uid_id == object_id, 0);
    }

    public fun assert_same_module<T, Witness: drop>() {
        let (package_a, module_a, _) = get_package_module_type<T>();
        let (package_b, module_b, _) = get_package_module_type<Witness>();

        assert!(package_a == package_b, err::witness_source_mismatch());
        assert!(module_a == module_b, err::witness_source_mismatch());
    }

    public fun assert_same_module_<A, B, C>() {
        let (package_a, module_a, _) = get_package_module_type<A>();
        let (package_b, module_b, _) = get_package_module_type<B>();
        let (package_c, module_c, _) = get_package_module_type<C>();

        assert!(package_a == package_b && package_b == package_c, err::witness_source_mismatch());
        assert!(module_a == module_b && module_b == module_c, err::witness_source_mismatch());
    }

    // TODO: deprecate in favor of assert_same_module as it is more generic?
    // TODO: Rearrange the order of witnesses from <T, W> to <W, T>

    public fun assert_package_publisher<C>(pub: &Publisher) {
        assert!(package::from_package<C>(pub), EPackagePublisherMismatch);
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
