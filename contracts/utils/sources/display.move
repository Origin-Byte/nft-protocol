module ob_utils::display {
    use std::string::{Self, String};
    use std::vector;

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
}
