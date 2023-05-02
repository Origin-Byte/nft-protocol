#[test_only]
module ob_tests::utils_vec_set_from_vec {

    use std::vector;
    use ob_utils::utils::{Self};
    use sui::vec_set::{Self, VecSet};

    #[test]
    public fun test_vec_set_from_vec_empty_vector() {
        let v: vector<u64> = vector::empty();
        let s: VecSet<u64> = utils::vec_set_from_vec(&v);
        assert!(vec_set::is_empty(&s), 0);
    }

    #[test]
    public fun test_vec_set_from_vec_single_entry() {
        let v: vector<u64> = vector[1];
        let s = utils::vec_set_from_vec(&v);
        assert!(vec_set::size(&s) == 1, 0);
        assert!(vec_set::contains(&s, &1), 1);
    }

    #[test]
    public fun test_vec_set_from_vec_multiple_entries() {
        let v: vector<u64> = vector[1, 2, 3];
        let s = utils::vec_set_from_vec(&v);
        assert!(vec_set::size(&s) == 3, 0);
        assert!(vec_set::contains(&s, &1), 1);
        assert!(vec_set::contains(&s, &2), 2);
        assert!(vec_set::contains(&s, &3), 3);
    }

    #[test]
    #[expected_failure(abort_code = vec_set::EKeyAlreadyExists)]
    public fun test_vec_set_from_vec_with_duplicates() {
        let v: vector<u64> = vector[1,1,2,2,3];
        utils::vec_set_from_vec(&v);
    }
}