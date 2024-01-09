/// # Critbit u64
/// 
/// Critbit implementation using `u64` keys.
module critbit::critbit_u64 {
    use sui::tx_context::TxContext;
    use sui::table::{Self, Table};

    // === Errors ===

    const EExceedCapacity: u64 = 1;
    const ETreeNotEmpty: u64 = 2;
    const EKeyAlreadyExist: u64 = 3;
    const ELeafNotExist: u64 = 4;
    const EIndexOutOfRange: u64 = 5;
    const ENullParent: u64 = 6;

    // === Constants ===

    const PARTITION_INDEX: u64 = 0x8000000000000000; // 9223372036854775808
    const MAX_U64: u64 = 0xFFFFFFFFFFFFFFFF; // 18446744073709551615
    const MAX_CAPACITY: u64 = 0x7fffffffffffffff;

    // === Structs ===

    /// Internal leaf type
    struct Leaf<V> has store, drop {
        key: u64,
        value: V,
        parent: u64,
    }

    /// Internal node type
    struct InternalNode has store, drop {
        mask: u64,
        left_child: u64,
        right_child: u64,
        // We keep track of the parent node to make it easier to traverse the tree to retrieve the previous or the next leaf.
        parent: u64,
    }

    /// Critbit tree
    struct CritbitTree<V: store> has store {
        root: u64,
        internal_nodes: Table<u64, InternalNode>,
        // A leaf contains orders at that price level.
        leaves: Table<u64, Leaf<V>>,
        min_leaf: u64,
        max_leaf: u64,
        next_internal_node_index: u64,
        next_leaf_index: u64
    }

    /// Create a new critbit tree
    public fun new<V: store>(ctx: &mut TxContext): CritbitTree<V> {
        CritbitTree<V>{
            root: PARTITION_INDEX,
            internal_nodes: table::new(ctx),
            leaves: table::new(ctx),
            min_leaf: PARTITION_INDEX,
            max_leaf: PARTITION_INDEX,
            next_internal_node_index: 0,
            next_leaf_index: 0
        }
    }

    /// Return size of tree
    public fun size<V: store>(tree: &CritbitTree<V>): u64 {
        table::length(&tree.leaves)
    }

    /// Return whether tree is empty
    public fun is_empty<V: store>(tree: &CritbitTree<V>): bool {
        table::is_empty(&tree.leaves)
    }

    /// Return whether leaf exists
    public fun has_leaf<V: store>(tree: &CritbitTree<V>, key: u64): bool {
        let (has_leaf, _) = find_leaf(tree, key);
        has_leaf
    }

    /// Return (key, index) of the leaf with minimum value
    public fun min_leaf<V: store>(tree: &CritbitTree<V>): (u64, u64) {
        assert!(!is_empty(tree), ELeafNotExist);
        let min_leaf = table::borrow(&tree.leaves, tree.min_leaf);
        return (min_leaf.key, tree.min_leaf)
    }

    /// Return (key, index) of the leaf with maximum value
    public fun max_leaf<V: store>(tree: &CritbitTree<V>): (u64, u64) {
        assert!(!is_empty(tree), ELeafNotExist);
        let max_leaf = table::borrow(&tree.leaves, tree.max_leaf);
        return (max_leaf.key, tree.max_leaf)
    }

    /// Return the previous leaf (key, index) from the input leaf
    public fun previous_leaf<V: store>(tree: &CritbitTree<V>, _key: u64): (u64, u64) {
        let (_, index) = find_leaf(tree, _key);
        assert!(index != PARTITION_INDEX, ELeafNotExist);
        let ptr = MAX_U64 - index;
        let parent = table::borrow(&tree.leaves, index).parent;
        while (parent != PARTITION_INDEX && is_left_child(tree, parent, ptr)){
            ptr = parent;
            parent = table::borrow(&tree.internal_nodes, ptr).parent;
        };
        if(parent == PARTITION_INDEX) {
            return (0, PARTITION_INDEX)
        };
        index = MAX_U64 - right_most_leaf(tree, table::borrow(&tree.internal_nodes, parent).left_child);
        let key = table::borrow(&tree.leaves, index).key;
        return (key, index)
    }

    /// Return the next leaf (key, index) of the input leaf
    public fun next_leaf<V: store>(tree: &CritbitTree<V>, _key: u64): (u64, u64) {
        let (_, index) = find_leaf(tree, _key);
        assert!(index != PARTITION_INDEX, ELeafNotExist);
        let ptr = MAX_U64 - index;
        let parent = table::borrow(&tree.leaves, index).parent;
        while (parent != PARTITION_INDEX && !is_left_child(tree, parent, ptr)){
            ptr = parent;
            parent = table::borrow(&tree.internal_nodes, ptr).parent;
        };
        if(parent == PARTITION_INDEX) {
            return (0, PARTITION_INDEX)
        };
        index = MAX_U64 - left_most_leaf(tree, table::borrow(&tree.internal_nodes, parent).right_child);
        let key = table::borrow(&tree.leaves, index).key;
        return (key, index)
    }

    /// Insert new leaf to the tree, returning the index of the new leaf
    public fun insert_leaf<V: store>(tree: &mut CritbitTree<V>, _key: u64, _value: V): u64 {
        let new_leaf = Leaf<V>{
            key: _key,
            value: _value,
            parent: PARTITION_INDEX,
        };
        let new_leaf_index = tree.next_leaf_index;
        tree.next_leaf_index = tree.next_leaf_index + 1;
        assert!(new_leaf_index < MAX_CAPACITY - 1, EExceedCapacity);
        table::add(&mut tree.leaves, new_leaf_index, new_leaf);

        let closest_leaf_index = get_closest_leaf_index_by_key(tree, _key);

        // handle the first insertion
        if(closest_leaf_index == PARTITION_INDEX){
            assert!(new_leaf_index == 0, ETreeNotEmpty);
            tree.root = MAX_U64 - new_leaf_index;
            tree.min_leaf = new_leaf_index;
            tree.max_leaf = new_leaf_index;
            return 0
        };

        let closest_key = table::borrow(&tree.leaves, closest_leaf_index).key;
        assert!(closest_key != _key, EKeyAlreadyExist);

        // note that we reserve count_leading_zeros of form u128 for future usage
        let critbit = 64 - (count_leading_zeros(((closest_key ^ _key) as u128) ) -64);
        let new_mask = 1u64 << (critbit - 1);

        let new_internal_node = InternalNode{
            mask: new_mask,
            left_child: PARTITION_INDEX,
            right_child: PARTITION_INDEX,
            parent: PARTITION_INDEX,
        };
        let new_internal_node_index = tree.next_internal_node_index;
        tree.next_internal_node_index = tree.next_internal_node_index + 1;
        table::add(&mut tree.internal_nodes, new_internal_node_index, new_internal_node);

        let ptr = tree.root;
        let new_internal_node_parent_index = PARTITION_INDEX;
        // search position of the new internal node
        while (ptr < PARTITION_INDEX) {
            let internal_node = table::borrow(&tree.internal_nodes, ptr);
            if (new_mask > internal_node.mask) {
                break
            };
            new_internal_node_parent_index = ptr;
            if (_key & internal_node.mask == 0){
                ptr = internal_node.left_child;
            }else {
                ptr = internal_node.right_child;
            };
        };

        // we update the child info of new internal node's parent
        if (new_internal_node_parent_index == PARTITION_INDEX){
            // if the new internal node is root
            tree.root = new_internal_node_index;
        } else{
            // In another case, we update the child field of the new internal node's parent
            // and the parent field of the new internal node
            let is_left_child = is_left_child(tree, new_internal_node_parent_index, ptr);
            update_child(tree, new_internal_node_parent_index, new_internal_node_index, is_left_child);
        };

        // finally, we update the child filed of the new internal node
        let is_left_child = new_mask & _key == 0;
        update_child(tree, new_internal_node_index, MAX_U64 - new_leaf_index, is_left_child);
        update_child(tree, new_internal_node_index, ptr, !is_left_child);

        if (table::borrow(&tree.leaves, tree.min_leaf).key > _key) {
            tree.min_leaf = new_leaf_index;
        };
        if (table::borrow(&tree.leaves, tree.max_leaf).key < _key) {
            tree.max_leaf = new_leaf_index;
        };
        new_leaf_index
    }

    /// Find the leaf in the tree, returning true and the index if the leaf
    /// exists
    public fun find_leaf<V: store>(tree: & CritbitTree<V>, _key: u64): (bool, u64) {
        if (is_empty(tree)) {
            return (false, PARTITION_INDEX)
        };
        let closest_leaf_index = get_closest_leaf_index_by_key(tree, _key);
        let closeset_leaf = table::borrow(&tree.leaves, closest_leaf_index);
        if (closeset_leaf.key != _key){
            return (false, PARTITION_INDEX)
        } else{
            return (true, closest_leaf_index)
        }
    }

    /// Find the closest leaf of the tree, returning true and the index if the
    /// leaf exists
    public fun find_closest_key<V: store>(tree: & CritbitTree<V>, _key: u64): u64 {
        if (is_empty(tree)) {
            return 0
        };
        let closest_leaf_index = get_closest_leaf_index_by_key(tree, _key);
        let closeset_leaf = table::borrow(&tree.leaves, closest_leaf_index);
        closeset_leaf.key
    }

    /// Remove leaf from the tree by index
    /// 
    /// #### Panics
    /// 
    /// Panics if the index does not exist in the tree
    public fun remove_leaf_by_index<V: store>(tree: &mut CritbitTree<V>, _index: u64): V {
        let key = table::borrow(& tree.leaves, _index).key;
        if(tree.min_leaf == _index) {
            let (_, index) = next_leaf(tree, key);
            tree.min_leaf = index;
        };
        if(tree.max_leaf == _index) {
            let (_, index) = previous_leaf(tree, key);
            tree.max_leaf = index;
        };

        let is_left_child_;
        let Leaf<V> {key: _, value, parent: removed_leaf_parent_index} = table::remove(&mut tree.leaves, _index);
        if (size(tree) == 0) {
            tree.root = PARTITION_INDEX;
            tree.min_leaf = PARTITION_INDEX;
            tree.max_leaf = PARTITION_INDEX;
            tree.next_internal_node_index = 0;
            tree.next_leaf_index = 0;
        } else{
            assert!(removed_leaf_parent_index != PARTITION_INDEX, EIndexOutOfRange);
            let removed_leaf_parent = table::borrow(&tree.internal_nodes, removed_leaf_parent_index);
            let removed_leaf_grand_parent_index = removed_leaf_parent.parent;

            // note that sibling of the removed leaf can be a leaf or a internal node
            is_left_child_ = is_left_child(tree, removed_leaf_parent_index, MAX_U64 - _index);
            let sibling_index = if (is_left_child_) { removed_leaf_parent.right_child }
            else { removed_leaf_parent.left_child };

            if (removed_leaf_grand_parent_index == PARTITION_INDEX) {
                // parent of the removed leaf is the tree root
                // update the parent of the sibling node and and set sibling as the tree root
                if (sibling_index < PARTITION_INDEX) {
                    // sibling is a internal node
                    table::borrow_mut(&mut tree.internal_nodes, sibling_index).parent = PARTITION_INDEX;
                } else{
                    // sibling is a leaf
                    table::borrow_mut(&mut tree.leaves, MAX_U64 - sibling_index).parent = PARTITION_INDEX;
                };
                tree.root = sibling_index;
            } else {
                // grand parent of the removed leaf is a internal node
                // set sibling as the child of the grand parent of the removed leaf
                is_left_child_ = is_left_child(tree, removed_leaf_grand_parent_index, removed_leaf_parent_index);
                update_child(tree, removed_leaf_grand_parent_index, sibling_index, is_left_child_);
            };
            table::remove(&mut tree.internal_nodes, removed_leaf_parent_index);
        };
        value
    }

    /// Remove leaf from the tree by key
    /// 
    /// #### Panics
    /// 
    /// Panics if the key does not exist in the tree
    public fun remove_leaf_by_key<V: store>(tree: &mut CritbitTree<V>, key: u64): V {
        let (is_exist, index) = find_leaf(tree, key);
        assert!(is_exist, ELeafNotExist);
        remove_leaf_by_index(tree, index)
    }    

    /// Mutably borrow leaf from the tree by index
    /// 
    /// #### Panics
    /// 
    /// Panics if the index does not exist in the tree
    public fun borrow_mut_leaf_by_index<V: store>(tree: &mut CritbitTree<V>, index: u64): &mut V {
        let entry = table::borrow_mut(&mut tree.leaves, index);
        &mut entry.value
    }

    /// Mutably borrow leaf from the tree by key
    /// 
    /// #### Panics
    /// 
    /// Panics if the key does not exist in the tree
    public fun borrow_mut_leaf_by_key<V: store>(tree: &mut CritbitTree<V>, key: u64): &mut V {
        let (is_exist, index) = find_leaf(tree, key);
        assert!(is_exist, ELeafNotExist);
        borrow_mut_leaf_by_index(tree, index)
    }

    /// Borrow leaf from the tree by index
    /// 
    /// #### Panics
    /// 
    /// Panics if the index does not exist in the tree
    public fun borrow_leaf_by_index<V: store>(tree: & CritbitTree<V>, index: u64): &V {
        let entry = table::borrow(&tree.leaves, index);
        &entry.value
    }

    /// Borrow leaf from the tree by key
    /// 
    /// #### Panics
    /// 
    /// Panics if the key does not exist in the tree
    public fun borrow_leaf_by_key<V: store>(tree: & CritbitTree<V>, key: u64): &V {
        let (is_exist, index) = find_leaf(tree, key);
        assert!(is_exist, ELeafNotExist);
        borrow_leaf_by_index(tree, index)
    }

    /// Destroy tree dropping all the entries within
    public fun drop<V: store + drop>(tree: CritbitTree<V>) {
        let CritbitTree<V> {
            root: _,
            internal_nodes,
            leaves,
            min_leaf: _,
            max_leaf: _,
            next_internal_node_index: _,
            next_leaf_index: _,

        } = tree;
        table::drop(internal_nodes);
        table::drop(leaves);
    }

    /// Destroy empty tree
    /// 
    /// #### Panics
    /// 
    /// Panics if tree is not empty
    public fun destroy_empty<V: store>(tree: CritbitTree<V>) {
        assert!(table::length(&tree.leaves) == 0, 0);

        let CritbitTree<V> {
            root: _,
            leaves,
            internal_nodes,
            min_leaf: _,
            max_leaf: _,
            next_internal_node_index: _,
            next_leaf_index: _
        } = tree;

        table::destroy_empty(leaves);
        table::destroy_empty(internal_nodes);
    }

    // === Internal functions ===

    fun left_most_leaf<V: store>(tree: &CritbitTree<V>, root: u64): u64 {
        let ptr = root;
        while (ptr < PARTITION_INDEX){
            ptr = table::borrow(& tree.internal_nodes, ptr).left_child;
        };
        ptr
    }

    fun right_most_leaf<V: store>(tree: &CritbitTree<V>, root: u64): u64 {
        let ptr = root;
        while (ptr < PARTITION_INDEX){
            ptr = table::borrow(& tree.internal_nodes, ptr).right_child;
        };
        ptr
    }

    fun get_closest_leaf_index_by_key<V: store>(tree: &CritbitTree<V>, _key: u64): u64 {
        let ptr = tree.root;
        // if tree is empty, return the patrition index
        if(ptr == PARTITION_INDEX) return PARTITION_INDEX;
        while (ptr < PARTITION_INDEX){
            let node = table::borrow(&tree.internal_nodes, ptr);
            if (_key & node.mask == 0){
                ptr = node.left_child;
            } else {
                ptr = node.right_child;
            }
        };
        return (MAX_U64 - ptr)
    }

    fun update_child<V: store>(tree: &mut CritbitTree<V>, parent_index: u64, new_child: u64, is_left_child: bool) {
        assert!(parent_index != PARTITION_INDEX, ENullParent);
        if (is_left_child) {
            table::borrow_mut(&mut tree.internal_nodes, parent_index).left_child = new_child;
        } else{
            table::borrow_mut(&mut tree.internal_nodes, parent_index).right_child = new_child;
        };
        if (new_child != PARTITION_INDEX) {
            if (new_child > PARTITION_INDEX){
                table::borrow_mut(&mut tree.leaves, MAX_U64 - new_child).parent = parent_index;
            }else{
                table::borrow_mut(&mut tree.internal_nodes, new_child).parent = parent_index;
            }
        };
    }

    fun is_left_child<V: store>(tree: &CritbitTree<V>, parent_index: u64, index: u64): bool {
        table::borrow(&tree.internal_nodes, parent_index).left_child == index
    }

    fun count_leading_zeros(x: u128): u8 {
        if (x == 0) {
            128
        } else {
            let n: u8 = 0;
            if (x & 0xFFFFFFFFFFFFFFFF0000000000000000 == 0) {
                // x's higher 64 is all zero, shift the lower part over
                x = x << 64;
                n = n + 64;
            };
            if (x & 0xFFFFFFFF000000000000000000000000 == 0) {
                // x's higher 32 is all zero, shift the lower part over
                x = x << 32;
                n = n + 32;
            };
            if (x & 0xFFFF0000000000000000000000000000 == 0) {
                // x's higher 16 is all zero, shift the lower part over
                x = x << 16;
                n = n + 16;
            };
            if (x & 0xFF000000000000000000000000000000 == 0) {
                // x's higher 8 is all zero, shift the lower part over
                x = x << 8;
                n = n + 8;
            };
            if (x & 0xF0000000000000000000000000000000 == 0) {
                // x's higher 4 is all zero, shift the lower part over
                x = x << 4;
                n = n + 4;
            };
            if (x & 0xC0000000000000000000000000000000 == 0) {
                // x's higher 2 is all zero, shift the lower part over
                x = x << 2;
                n = n + 2;
            };
            if (x & 0x80000000000000000000000000000000 == 0) {
                n = n + 1;
            };

            n
        }
    }

    // === Helpers ===

    #[test_only]
    use std::vector;

    #[test_only]
    public fun new_leaf_for_test<V>(key: u64, value: V, parent: u64): Leaf<V> {
        Leaf<V> {
            key,
            value,
            parent,
        }
    }

    #[test_only]
    public fun new_internal_node_for_test(mask: u64, parent: u64, left_child: u64, right_child: u64): InternalNode {
        InternalNode {
            mask,
            left_child,
            right_child,
            parent,
        }
    }

    #[test_only]
    public fun check_tree_struct<V: store>(
        tree: &CritbitTree<V>,
        internal_node_keys: &vector<u64>,
        internal_node: &vector<InternalNode>,
        leaves_keys: &vector<u64>,
        leaves: &vector<Leaf<V>>,
        root: u64,
        min_leaf: u64,
        max_leaf: u64
    ): bool {
        assert!(vector::length(internal_node_keys) == vector::length(internal_node), 0);
        assert!(vector::length(leaves_keys) == vector::length(leaves), 0);
        if(tree.root != root || tree.min_leaf != min_leaf || tree.max_leaf != max_leaf){
            return false
        };
        let internal_node_from_tree = &tree.internal_nodes;
        let leaves_from_tree = &tree.leaves;
        let i = 0;
        let is_equal = true;
        while (i < vector::length(internal_node_keys)){
            let key = *vector::borrow(internal_node_keys, i);
            if(table::borrow(internal_node_from_tree, key) != vector::borrow(internal_node, i)){
                is_equal = false;
                break
            };
            i = i + 1;
        };
        i = 0;
        while (i < vector::length(leaves_keys)){
            let key = *vector::borrow(leaves_keys, i);
            if(table::borrow(leaves_from_tree, key) != vector::borrow(leaves, i)){
                is_equal = false;
                break
            };
            i = i + 1;
        };
        is_equal
    }

    #[test_only]
    public fun check_empty_tree<V: store>(tree: &CritbitTree<V>, ) {
        assert!(table::is_empty(&tree.leaves), 0);
        assert!(table::is_empty(&tree.internal_nodes), 0);
        assert!(tree.root == PARTITION_INDEX, 0);
        assert!(tree.min_leaf == PARTITION_INDEX, 0);
        assert!(tree.max_leaf == PARTITION_INDEX, 0);
    }
}