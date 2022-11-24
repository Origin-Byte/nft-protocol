//! @title utils
//! @notice Utility functions in Move.
module nft_protocol::utils {
    use nft_protocol::err;
    use std::ascii;
    use std::string::{Self, String, sub_string};
    use std::type_name;
    use std::vector;

    /// This key does not exist in the map
    const ValueDoesNotExist: u64 = 1;

    public fun to_string_vector(
        vec: &mut vector<vector<u8>>
    ): vector<String> {
        let new_vec: vector<String> = vector::empty();

        let len = vector::length(vec);

        if (len == 0) {
            return new_vec
        };

        let i = 0;
        while (i < len) {
            let e = string::utf8(vector::pop_back(vec));
            vector::push_back(&mut new_vec, e);
            i = i + 1;
        };

        vector::reverse(&mut new_vec);
        new_vec
    }

    /// One time witness is a type exported by a contract which follows the
    /// module name.
    ///
    /// Witness is a type always in form "struct Witness has drop {}"
    ///
    /// They must be from the same module for this assertion to be ok.
    public fun assert_same_module_as_witness<OneTimeWitness, Witness>() {
        let (package_a, module_a, _) = get_package_module_type<OneTimeWitness>();
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
}
