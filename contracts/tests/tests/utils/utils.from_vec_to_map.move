#[test_only]
module ob_tests::utils_from_vec_to_map {
    use std::ascii;
    use std::ascii::String;
    use std::vector;
    use sui::vec_map::{Self};
    use ob_utils::utils::{Self};

    #[test]
    public fun test_from_vec_to_map_empty_vectors() {
        let keys: vector<u64> = vector::empty();
        let values: vector<u64> = vector::empty();
        let m = utils::from_vec_to_map(keys, values);
        assert!(vec_map::is_empty(&m), 0);
    }

    #[test]
    public fun test_from_vec_to_map_single_entry() {
        let keys: vector<u64> = vector[1];
        let values: vector<String> = vector[ascii::string(b"zero")];
        let m = utils::from_vec_to_map(keys, values);
        assert!(vec_map::size(&m) == 1, 0);
        assert!(*vec_map::get(&m, &1) == ascii::string(b"zero"), 1);
    }

    #[test]
    public fun test_from_vec_to_map_multiple_entries() {
        let keys: vector<u64> = vector[1, 2, 3];
        let values: vector<String> = vector[ascii::string(b"one"), ascii::string(b"two"), ascii::string(b"three")];
        let m = utils::from_vec_to_map(keys, values);
        assert!(vec_map::size(&m) == 3, 0);
        assert!(*vec_map::get(&m, &1) == ascii::string(b"one"), 1);
        assert!(*vec_map::get(&m, &2) == ascii::string(b"two"), 2);
        assert!(*vec_map::get(&m, &3) == ascii::string(b"three"), 3);
    }

    #[test]
    public fun test_from_vec_to_map_non_contiguous_keys() {
        let keys: vector<u64> = vector[1, 3, 5];
        let values: vector<String> = vector[ascii::string(b"one"), ascii::string(b"three"), ascii::string(b"five")];
        let m = utils::from_vec_to_map(keys, values);
        assert!(vec_map::size(&m) == 3, 0);
        assert!(*vec_map::get(&m, &1) == ascii::string(b"one"), 1);
        assert!(*vec_map::get(&m, &3) == ascii::string(b"three"), 2);
        assert!(*vec_map::get(&m, &5) == ascii::string(b"five"), 3);
    }

    #[test]
    #[expected_failure(abort_code = utils::EMismatchedKeyValueLength)]
    public fun test_from_vec_to_map_mismatched_key_value_len() {
        let keys: vector<u64> = vector[1, 2];
        let values: vector<String> = vector[ascii::string(b"one"), ascii::string(b"two"), ascii::string(b"three")];
        let _m = utils::from_vec_to_map(keys, values);
    }
}
