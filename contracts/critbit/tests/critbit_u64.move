// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[test_only]
module critbit::test_critbit_u64 {
    use sui::test_scenario::{Self, ctx};
    
    use critbit::critbit_u64::{
        Self as critbit,
        InternalNode,
        Leaf,
        check_tree_struct,
    };

    const PARTITION_INDEX: u64 = 1 << 63; // 9223372036854775808
    const MAX_U64: u64 = 0xFFFFFFFFFFFFFFFF; // 18446744073709551615

    const CREATOR: address = @0x1337;

    #[test]
    fun insert_0() {
        let scenario = test_scenario::begin(CREATOR);

        let t1 = critbit::new<u64>(ctx(&mut scenario));
        critbit::insert_leaf(&mut t1, 48, 48);
        critbit::insert_leaf(&mut t1, 16, 16);
        critbit::insert_leaf(&mut t1, 1, 1);
        critbit::insert_leaf(&mut t1, 3, 3);

        let internal_nodes_keys = vector<u64>[0, 1 , 2];
        let internal_nodes = vector<InternalNode> [
                critbit::new_internal_node_for_test(32, PARTITION_INDEX, 1, MAX_U64 - 0),
                critbit::new_internal_node_for_test(16, 0, 2, MAX_U64 - 1),
                critbit::new_internal_node_for_test(2, 1, MAX_U64 - 2, MAX_U64 - 3),
        ];
        let leaves_keys = vector<u64>[0, 1, 2, 3];
        let leaves = vector<Leaf<u64>>[
                critbit::new_leaf_for_test(48, 48, 0),
                critbit::new_leaf_for_test(16, 16, 1),
                critbit::new_leaf_for_test(1, 1, 2),
                critbit::new_leaf_for_test(3, 3, 2)
        ];
        let is_equal = check_tree_struct(
            &t1,
            &internal_nodes_keys,
            &internal_nodes,
            &leaves_keys,
            &leaves,
            0,
            2,
            0
        );
        assert!(is_equal, 0);

        let (res, index) = critbit::find_leaf(&t1 , 48);
        assert!(res == true, 0);
        assert!(index == 0, 0);

        let (min_leaf_key, min_leaf_index) = critbit::min_leaf(&t1);
        assert!(min_leaf_key == 1, 0);
        assert!(min_leaf_index == 2, 0);

        let (max_leaf_key, max_leaf_index) = critbit::max_leaf(&t1);
        assert!(max_leaf_key == 48, 0);
        assert!(max_leaf_index == 0, 1);

        let (key, index) = critbit::next_leaf(&t1, 1);
        assert!(key == 3, 0);
        assert!(index == 3, 0);
        (key, index) = critbit::next_leaf(&t1, 3);
        assert!(key == 16, 0);
        assert!(index == 1, 0);
        (key, index) = critbit::next_leaf(&t1, 16);
        assert!(key == 48, 0);
        assert!(index == 0, 0);
        (key, index) = critbit::next_leaf(&t1, 48);
        assert!(key == 0, 0);
        assert!(index == PARTITION_INDEX, 0);

        (key, index) = critbit::previous_leaf(&t1, 1);
        assert!(key == 0, 0);
        assert!(index == PARTITION_INDEX, 0);
        (key, index) = critbit::previous_leaf(&t1, 3);
        assert!(key == 1, 0);
        assert!(index == 2, 0);
        (key, index) = critbit::previous_leaf(&t1, 16);
        assert!(key == 3, 0);
        assert!(index == 3, 0);
        (key, index) = critbit::previous_leaf(&t1, 48);
        assert!(key == 16, 0);
        assert!(index == 1, 0);
        critbit::drop(t1);

        test_scenario::end(scenario);
    }

    #[test]
    fun insert_1() {
        let scenario = test_scenario::begin(CREATOR);

        let t1 = critbit::new<u64>(ctx(&mut scenario));
        critbit::insert_leaf(&mut t1, 1, 1);
        critbit::insert_leaf(&mut t1, 3, 3);
        critbit::insert_leaf(&mut t1, 16, 16);
        critbit::insert_leaf(&mut t1, 48, 48);

        let internal_nodes_keys = vector<u64>[0, 1 , 2];
        let internal_nodes = vector<InternalNode> [
            critbit::new_internal_node_for_test(2, 1, MAX_U64, MAX_U64 - 1),
            critbit::new_internal_node_for_test(16, 2, 0, MAX_U64 - 2),
            critbit::new_internal_node_for_test(32, PARTITION_INDEX,  1, MAX_U64 - 3),
        ];
        let leaves_keys = vector<u64>[0, 1, 2, 3];
        let leaves = vector<Leaf<u64>>[
            critbit::new_leaf_for_test(1, 1, 0),
            critbit::new_leaf_for_test(3, 3, 0),
            critbit::new_leaf_for_test(16, 16, 1),
            critbit::new_leaf_for_test(48, 48, 2)
        ];
        let is_equal = check_tree_struct(
            &t1,
            &internal_nodes_keys,
            &internal_nodes,
            &leaves_keys,
            &leaves,
            2,
            0,
            3,
        );
        assert!(is_equal, 0);
        let (res, index) = critbit::find_leaf(&t1 , 48);
        assert!(res == true, 0);
        assert!(index == 3, 0);

        let (min_leaf_key, min_leaf_index) = critbit::min_leaf(&t1);
        assert!(min_leaf_key == 1, 0);
        assert!(min_leaf_index == 0, 0);

        let (max_leaf_key, max_leaf_index) = critbit::max_leaf(&t1);
        assert!(max_leaf_key == 48, 0);
        assert!(max_leaf_index == 3, 1);

        let (key, index) = critbit::next_leaf(&t1, 1);
        assert!(key == 3, 0);
        assert!(index == 1, 0);
        (key, index) = critbit::next_leaf(&t1, 3);
        assert!(key == 16, 0);
        assert!(index == 2, 0);
        (key, index) = critbit::next_leaf(&t1, 16);
        assert!(key == 48, 0);
        assert!(index == 3, 0);
        (key, index) = critbit::next_leaf(&t1, 48);
        assert!(key == 0, 0);
        assert!(index == PARTITION_INDEX, 0);

        (key, index) = critbit::previous_leaf(&t1, 1);
        assert!(key == 0, 0);
        assert!(index == PARTITION_INDEX, 0);
        (key, index) = critbit::previous_leaf(&t1, 3);
        assert!(key == 1, 0);
        assert!(index == 0, 0);
        (key, index) = critbit::previous_leaf(&t1, 16);
        assert!(key == 3, 0);
        assert!(index == 1, 0);
        (key, index) = critbit::previous_leaf(&t1, 48);
        assert!(key == 16, 0);
        assert!(index == 2, 0);
        critbit::drop(t1);

        test_scenario::end(scenario);
    }

    #[test]
    fun remove() {
        let scenario = test_scenario::begin(CREATOR);

        let t1 = critbit::new<u64>(ctx(&mut scenario));
        critbit::insert_leaf(&mut t1, 48, 48);
        critbit::remove_leaf_by_index(&mut t1, 0);
        critbit::check_empty_tree(&t1);

        critbit::insert_leaf(&mut t1, 48, 48);
        critbit::insert_leaf(&mut t1, 16, 16);
        critbit::remove_leaf_by_index(&mut t1, 0);

        let internal_nodes_keys = vector<u64>[];
        let internal_nodes = vector<InternalNode> [];
        let leaves_keys = vector<u64>[1];
        let leaves = vector<Leaf<u64>>[
            critbit::new_leaf_for_test(16, 16, PARTITION_INDEX),
        ];
        let is_equal = check_tree_struct(
            &t1,
            &internal_nodes_keys,
            &internal_nodes,
            &leaves_keys,
            &leaves,
            MAX_U64 - 1,
            1,
            1
        );
        assert!(is_equal, 0);
        critbit::remove_leaf_by_index(&mut t1, 1);
        critbit::check_empty_tree(&t1);
        critbit::drop(t1);

        test_scenario::end(scenario);
    }
}