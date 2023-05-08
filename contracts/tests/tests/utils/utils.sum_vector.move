#[test_only]
module ob_tests::utils_sum_vector {
    use std::vector;
    use ob_utils::utils::{Self};
    const U64_MAX: u64 = 18446744073709551615;

    #[test]
    public fun test_sum_vector_empty_vector() {
        let v: vector<u64> = vector::empty();
        let s = utils::sum_vector(v);
        assert!(s == 0, 0);
    }

    #[test]
    public fun test_sum_vector_single_entry() {
        let v: vector<u64> =  vector[7];
        let s = utils::sum_vector(v);
        assert!(s == 7, 0);
    }

    #[test]
    public fun test_sum_vector_multiple_entries() {
        let v: vector<u64> =  vector[1, 2, 3, 4, 5];
        let s = utils::sum_vector(v);
        assert!(s == 15, 0);
    }

    #[test]
    #[expected_failure(arithmetic_error, location=ob_utils::utils)]
    public fun test_sum_vector_overflow() {
        let v: vector<u64> =  vector[U64_MAX, U64_MAX];
        let _s = utils::sum_vector(v);
    }
}