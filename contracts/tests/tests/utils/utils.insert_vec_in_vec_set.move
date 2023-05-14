#[test_only]
module ob_tests::utils_insert_vec_in_vec_set {
    use std::vector;
    use ob_utils::utils::{Self};
    use sui::vec_set::{Self, VecSet};

    #[test]
    public fun test_insert_vec_in_vec_set_empty_vector() {
        let s: VecSet<u64> = vec_set::empty();
        let v: vector<u64> = vector::empty();
        utils::insert_vec_in_vec_set(&mut s, v);
        assert!(vec_set::is_empty(&s), 0);
    }

    #[test]
    public fun test_insert_vec_in_vec_set_single_entry() {
        let s: VecSet<u64> = vec_set::empty();
        let v: vector<u64> = vector[5];
        utils::insert_vec_in_vec_set(&mut s, v);
        assert!(vec_set::size(&s) == 1, 0);
        assert!(vec_set::contains(&s, &5), 1);
    }

    #[test]
    public fun test_insert_vec_in_vec_set_multiple_entries() {
        let s: VecSet<u64> = vec_set::empty();
        let v: vector<u64> = vector[1,2,3];
        utils::insert_vec_in_vec_set(&mut s, v);
        assert!(vec_set::size(&s) == 3, 0);
        assert!(vec_set::contains(&s, &1), 1);
        assert!(vec_set::contains(&s, &2), 2);
        assert!(vec_set::contains(&s, &3), 3);
        assert!(vec_set::contains(&s, &3), 3);
    }

    #[test]
    #[expected_failure(abort_code = vec_set::EKeyAlreadyExists)]
    public fun test_insert_vec_in_vec_set_with_duplicates() {
        let s: VecSet<u64> = vec_set::empty();
        let v: vector<u64> = vector[1,1,2,2,3,3];
        utils::insert_vec_in_vec_set(&mut s, v);
    }
}