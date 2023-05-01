#[test_only]
module ob_tests::utils_insert_vec_in_table {
    use std::vector;
    use ob_utils::utils::{Self};
    use sui::table_vec::{Self};
    use sui::test_scenario as ts;

    const TEST_UTILS: address = @0x123;

    #[test]
    public fun test_insert_vec_in_table_empty_vector() {
        let scenario = ts::begin(TEST_UTILS);    
        let table_vec = table_vec::empty<u64>(ts::ctx(&mut scenario));
        let v: vector<u64> = vector::empty();

        utils::insert_vec_in_table(&mut table_vec, v);

        assert!(table_vec::length(&table_vec) == 0, 0);
        table_vec::destroy_empty(table_vec);
        ts::end(scenario);
    }

    #[test]
    public fun test_insert_vec_in_table_single_entry() {
        let scenario = ts::begin(TEST_UTILS);    
        let table_vec = table_vec::empty<u64>(ts::ctx(&mut scenario));
        let v: vector<u64> = vector[5];

        utils::insert_vec_in_table(&mut table_vec, v);

        assert!(table_vec::length(&table_vec) == 1, 0);
        let value = table_vec::borrow(&table_vec, 0);
        assert!(*value == 5, 1);

        table_vec::pop_back(&mut table_vec);
        table_vec::destroy_empty(table_vec);
        ts::end(scenario);
    }

    #[test]
    public fun test_insert_vec_in_table_multiple_entries() {
        let scenario = ts::begin(TEST_UTILS);    
        let table_vec = table_vec::empty<u64>(ts::ctx(&mut scenario));
        let v: vector<u64> = vector[1, 2, 3];

        utils::insert_vec_in_table(&mut table_vec, v);

        assert!(table_vec::length(&table_vec) == 3, 0);
        let value1 = table_vec::borrow(&table_vec, 0);
        assert!(*value1 == 3, 1);

        let value2 = table_vec::borrow(&table_vec, 1);
        assert!(*value2 == 2, 2);

        let value3 = table_vec::borrow(&table_vec, 2);        
        assert!(*value3 == 1, 3);

        table_vec::pop_back(&mut table_vec);
        table_vec::pop_back(&mut table_vec);
        table_vec::pop_back(&mut table_vec);
        table_vec::destroy_empty(table_vec);
        ts::end(scenario);
    }
}