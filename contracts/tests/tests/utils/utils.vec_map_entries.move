#[test_only]
module ob_tests::vec_map_entries {
    use std::ascii;
    use std::vector;
    use sui::vec_map::{Self, VecMap};
    use ob_utils::utils::{Self};

    #[test]
    public fun test_vec_map_entries_empty_map() {
        let m: VecMap<u64, u64> = vec_map::empty();
        let entries = utils::vec_map_entries(&m);
        assert!(vector::is_empty(&entries), 0);
    }

    #[test]
    public fun test_vec_map_entries_single_entry() {
        let m = vec_map::empty();
        vec_map::insert(&mut m, 1, 5);
        let entries = utils::vec_map_entries(&m);
        assert!(entries == vector[5], 0);
    }

    #[test]
    public fun test_vec_map_entries_multiple_entries() {
        let m = vec_map::empty();
        vec_map::insert(&mut m, 0, ascii::string(b"zero"));
        vec_map::insert(&mut m, 1, ascii::string(b"one"));
        vec_map::insert(&mut m, 2, ascii::string(b"two"));
        let entries = utils::vec_map_entries(&m);
        assert!(entries == vector[ascii::string(b"zero"), ascii::string(b"one"), ascii::string(b"two")], 0);
    }

    #[test]
    public fun test_vec_map_entries_non_contiguous_keys() {
        let m = vec_map::empty();
        vec_map::insert(&mut m, 1, ascii::string(b"one"));
        vec_map::insert(&mut m, 3, ascii::string(b"three"));
        vec_map::insert(&mut m, 5, ascii::string(b"five"));
        let entries = utils::vec_map_entries(&m);
        assert!(entries == vector[ascii::string(b"one"), ascii::string(b"three"), ascii::string(b"five")], 0);
    }

    #[test]
    public fun test_vec_map_entries_large_map() {
        let m: VecMap<u64, u64> = vec_map::empty();
        let num_entries = 1000;
        let i = 0;
        let expected: vector<u64> = vector::empty();
        while (i < num_entries) {
            vec_map::insert(&mut m, i, i);
            vector::push_back(&mut expected, i);
            i = i + 1;
        };
        let entries = utils::vec_map_entries(&m);
        assert!(entries == expected, 0);
    }
}