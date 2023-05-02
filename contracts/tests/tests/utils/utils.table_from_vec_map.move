#[test_only]
module ob_tests::test_table_from_vec_map {
    use std::ascii;
    use ob_utils::utils::{Self};
    use sui::table::{Self};
    use sui::test_scenario as ts;
    use sui::vec_map::{Self, VecMap};

    const TEST_UTILS: address = @0x123;

    #[test]
    public fun test_table_from_vec_map_empty_vector() {
        let scenario = ts::begin(TEST_UTILS);
        let m: VecMap<u64, u64> = vec_map::empty();

        let table = utils::table_from_vec_map(m, ts::ctx(&mut scenario));

        assert!(table::length(&table) == 0, 0);
        table::destroy_empty(table);
        ts::end(scenario);
    }

    #[test]
    public fun test_table_from_vec_map_single_entry() {
        let scenario = ts::begin(TEST_UTILS);
        let m = vec_map::empty();
        vec_map::insert(&mut m, 88, ascii::string(b"zero"));

        let table = utils::table_from_vec_map(m,  ts::ctx(&mut scenario));

        assert!(table::length(&table) == 1, 0);

        assert!(table::contains(&table, 88), 1);
        // check the values
        assert!(*table::borrow(&table, 88) == ascii::string(b"zero"), 2);
        assert!(table::remove(&mut table, 88) == ascii::string(b"zero"), 0);
        // verify that they are not there
        assert!(!table::contains(&table, 88), 0);

        table::destroy_empty(table);
        ts::end(scenario);
    }

   #[test]
    public fun test_table_from_vec_map_multiple_entries() {
        let scenario = ts::begin(TEST_UTILS);
        let m = vec_map::empty();
        vec_map::insert(&mut m, ascii::string(b"hundred"), 100);
        vec_map::insert(&mut m, ascii::string(b"thousand"), 1000);

        let table = utils::table_from_vec_map(m,  ts::ctx(&mut scenario));

        assert!(table::length(&table) == 2, 0);

        assert!(table::contains(&table, ascii::string(b"hundred")), 1);
        assert!(table::contains(&table, ascii::string(b"thousand")), 1);
        
        assert!(*table::borrow(&table, ascii::string(b"hundred")) == 100, 2);
        assert!(*table::borrow(&table, ascii::string(b"thousand")) == 1000, 2);

        assert!(table::remove(&mut table, ascii::string(b"hundred")) == 100, 3);
        assert!(table::remove(&mut table, ascii::string(b"thousand")) == 1000, 3);
       
        assert!(!table::contains(&table, ascii::string(b"hundred")), 4);
        assert!(!table::contains(&table, ascii::string(b"thousand")), 4);

        table::destroy_empty(table);
        ts::end(scenario);
    }
}