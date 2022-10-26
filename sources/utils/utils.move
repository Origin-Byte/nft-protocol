//! @title utils
//! @notice Utility functions in Move.
module nft_protocol::utils {
    use std::string::{Self ,String};
    use std::vector;
    // use sui::vec_map::{Self, VecMap};

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
}
