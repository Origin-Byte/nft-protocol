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

    public fun assert_exported_by_same_package<A, B>() {
        let package_a = get_package_as_string<A>();
        let package_b = get_package_as_string<B>();

        assert!(package_a == package_b, err::package_mismatch());
    }

    fun get_package_as_string<T>(): String {
        let delimiter = string::utf8(b"::");

        let t = string::utf8(ascii::into_bytes(
            type_name::into_string(type_name::get<T>())
        ));

        sub_string(&t, 0, string::index_of(&t, &delimiter))
    }
}
