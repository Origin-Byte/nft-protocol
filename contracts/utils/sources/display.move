module ob_utils::display {
    use std::string::{Self, String};
    use std::vector;

    use sui::object::{Self, ID};
    use sui::vec_map::{Self, VecMap};

    public fun from_vec(vec: vector<String>): String {
        let output = string::utf8(b"[");

        vector::reverse(&mut vec);
        let len = vector::length(&vec);

        while (len > 0) {

            let elem = vector::pop_back(&mut vec);

            string::append_utf8(&mut output, b"\"");
            string::append(&mut output, elem);
            string::append_utf8(&mut output, b"\"");

            len = len - 1;
            if (len != 0) {
                // We add a comma as long as it's not the last entry
                string::append_utf8(&mut output, b",");
            };
        };

        string::append_utf8(&mut output, b"]");

        output
    }

    public fun from_vec_utf8(vec: vector<vector<u8>>): String {
        let output = string::utf8(b"[");

        vector::reverse(&mut vec);
        let len = vector::length(&vec);

        while (len > 0) {
            let elem = vector::pop_back(&mut vec);
            string::append_utf8(&mut output, b"\"");
            string::append_utf8(&mut output, elem);
            string::append_utf8(&mut output, b"\"");

            len = len - 1;

            if (len != 0) {
                // We add a comma as long as it's not the last entry
                string::append_utf8(&mut output, b",");
            };
        };

        string::append_utf8(&mut output, b"]");

        output
    }

    public fun from_vec_map(vec: VecMap<String, String>): String {
        let output = string::utf8(b"{");

        let keys = vec_map::keys(&vec);
        vector::reverse(&mut keys);

        let len = vector::length(&keys);

        while (len > 0) {
            let key = vector::pop_back(&mut keys);
            let (key, elem) = vec_map::remove(&mut vec, &key);

            // Push key to json-like string
            string::append_utf8(&mut output, b"\"");
            string::append(&mut output, key);
            string::append_utf8(&mut output, b"\": ");

            string::append_utf8(&mut output, b"\"");
            string::append(&mut output, elem);
            string::append_utf8(&mut output, b"\"");

            len = len - 1;

            if (len != 0) {
                // We add a comma as long as it's not the last entry
                string::append_utf8(&mut output, b",");
            };
        };

        string::append_utf8(&mut output, b"}");

        output
    }

    public fun from_vec_map_ref(vec: &VecMap<String, String>, is_string: bool): String {
        let output = string::utf8(b"{");

        let keys = vec_map::keys(vec);
        vector::reverse(&mut keys);

        let len = vector::length(&keys);

        while (len > 0) {
            let key = vector::pop_back(&mut keys);
            let elem = vec_map::get(vec, &key);

            // Push key to json-like string
            string::append_utf8(&mut output, b"\"");
            string::append(&mut output, copy key);
            string::append_utf8(&mut output, b"\": ");

            if (is_string) { string::append_utf8(&mut output, b"\"") };
            string::append(&mut output, *elem);
            if (is_string) { string::append_utf8(&mut output, b"\"") };

            len = len - 1;

            if (len != 0) {
                // We add a comma as long as it's not the last entry
                string::append_utf8(&mut output, b",");
            };
        };

        string::append_utf8(&mut output, b"}");

        output
    }

    const HEX_ALPHABET: vector<u8> = vector[48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102];

    // Converts bytes to hex-encoded string
    public fun bytes_to_string(bytes: &vector<u8>): String {
        let encoded = string::utf8(b"");

        let i = 0;
        let len = vector::length(bytes);
        while (i < len) {
            let byte = vector::borrow(bytes, i);

            let high = (*byte >> 4) & 0xf;
            let low = *byte & 0xf;

            string::append_utf8(
                &mut encoded,
                vector[
                    *vector::borrow(&HEX_ALPHABET, (high as u64)),
                    *vector::borrow(&HEX_ALPHABET, (low as u64)),
                ],
            );

            i = i + 1;
        };

        encoded
    }

    /// Converts `address` to `String`
    public fun address_to_string(address: &address): String {
        let string = string::utf8(b"0x");
        string::append(&mut string, bytes_to_string(&std::bcs::to_bytes(address)));

        string
    }

    /// Converts `ID` to `String`
    public fun id_to_string(id: &ID): String {
        let string = string::utf8(b"0x");
        string::append(&mut string, bytes_to_string(&object::id_to_bytes(id)));

        string
    }

    #[test]
    fun test_bytes_to_string() {
        let bytes = vector[0, 1, 127, 128, 129, 255];
        let string = bytes_to_string(&bytes);

        assert!(string == string::utf8(b"00017f8081ff"), 0)
    }

    #[test]
    fun test_address_to_string() {
        let address =
            @0x54f1c10a66a20cd9c5c63ee6926ed8b2940a4a803dfc528b6c3c6cc806c910d6;
        let string = address_to_string(&address);

        assert!(
            string == string::utf8(
                b"0x54f1c10a66a20cd9c5c63ee6926ed8b2940a4a803dfc528b6c3c6cc806c910d6"
            ),
            0,
        )
    }
}
