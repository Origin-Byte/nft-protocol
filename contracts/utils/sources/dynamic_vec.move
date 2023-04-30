module ob_utils::dyn_vec {
    use std::vector;
    use std::debug;
    use std::string::utf8;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::dynamic_field as df;

    /// `Warehouse` does not have NFTs left to withdraw
    ///
    /// Call `warehouse::deposit_nft` or `listing::add_nft` to add NFTs.
    const EEmpty: u64 = 1;

    /// `Warehouse` still has NFTs left to withdraw
    ///
    /// Call `warehouse::redeem_nft` or a `Listing` market to withdraw remaining
    /// NFTs.
    const ENotEmpty: u64 = 2;

    /// `Warehouse` does not have NFT at specified index
    ///
    /// Call `warehouse::redeem_nft_at_index` with an index that exists.
    const EIndexOutOfBounds: u64 = 3;

    /// `Warehouse` did not contain NFT object with given ID
    ///
    /// Call `warehouse::redeem_nft_with_id` with an ID that exists.
    const EInvalidNftId: u64 = 4;

    /// Attempted to construct a `RedeemCommitment` with a hash length
    /// different than 32 bytes
    const EInvalidCommitmentLength: u64 = 5;

    /// Commitment in `RedeemCommitment` did not match original value committed
    ///
    /// Call `warehouse::random_redeem_nft` with the correct commitment.
    const EInvalidCommitment: u64 = 6;

    struct DynVec<Element> has store {
        vec_0: vector<Element>,
        vecs: UID,
        len: u64,
        limit: u64,
    }

    /// The index into the vector is out of bounds
    const EINDEX_OUT_OF_BOUNDS: u64 = 1;

    const ECAPACITY_REACHED: u64 = 2;

    const ECAPACITY_DECREASE_EXCEEDS_LENGTH: u64 = 3;

    /// Create an empty dynamic vector.
    public fun empty<Element: store>(limit: u64, ctx: &mut TxContext): DynVec<Element> {
        DynVec {
            vec_0: vector::empty(),
            vecs: object::new(ctx),
            len: 0,
            limit,
        }
    }

    /// Return the current length of the dynamic vector.
    public fun length<Element: store>(v: &DynVec<Element>): u64 {
        v.len
    }

    public fun push_back<Element: store>(
        v: &mut DynVec<Element>,
        elem: Element,
    ) {
        // TODO: Test, why is it not - 1 here?
        let idx = v.len;
        let (chunk_idx, _) = chunk_index(v, idx);
        if (has_chunk(v, chunk_idx)) {
            debug::print(&utf8(b"Adding to chunk:"));
            debug::print(&elem);
            let chunk = borrow_chunk_mut(v, chunk_idx);
            vector::push_back(chunk, elem);
        } else {
            debug::print(&utf8(b"########################################"));
            debug::print(&utf8(b"Inserting new chunk at:"));
            debug::print(&elem);
            insert_chunk(v, chunk_idx, elem);
        };

        v.len = v.len + 1;
    }

    public fun pop_back<Element: store>(
        v: &mut DynVec<Element>,
    ): Element {
        // TODO: Test, why is it - 1 here?
        let idx = v.len - 1;
        let (chunk_idx, idx) = chunk_index(v, idx);

        let elem = if (idx > 0) {
            let chunk = borrow_chunk_mut(v, chunk_idx);
            // debug::print(chunk);
            vector::pop_back(chunk)
        } else {
            remove_chunk(v, chunk_idx)
        };

        v.len = v.len - 1;
        elem
    }


    public fun pop_at_index<Element: store>(
        v: &mut DynVec<Element>,
        index: u64,
    ): Element {
        assert!(v.len > 0, EEmpty);
        assert!(index < v.len, EIndexOutOfBounds);

        // TODO: Test, why is it - 1 here?
        let idx_ = v.len - 1;
        let (chunk_idx_remove, idx_remove) = chunk_index(v, index);
        let (chunk_idx_last, idx_last) = chunk_index(v, idx_);

        let chunk_last = borrow_chunk_mut(v, chunk_idx_last);

        let elem = if (chunk_idx_remove == chunk_idx_last) {
            // If the chunk to remove from is the last chunk
            // - Perform swap remove
            // - Cleanup last chunk if it is now empty
            if (idx_last > 0) {
                vector::swap_remove(chunk_last, idx_remove)
            } else {
                remove_chunk(v, chunk_idx_last)
            }
        } else {
            // If the chunk to remove from is not the last chunk
            // - Perform swap remove in remove chunk
            // - Pop ID from last chunk and push to remove chunk
            // - Cleanup last chunk if now empty
            let id_last = if (idx_last > 0) {
                vector::pop_back(chunk_last)
            } else {
                remove_chunk(v, chunk_idx_last)
            };

            let chunk_remove = borrow_chunk_mut(v, chunk_idx_remove);
            let id_remove = vector::swap_remove(chunk_remove, idx_remove);
            vector::push_back(chunk_remove, id_last);

            id_remove
        };

        v.len = v.len - 1;
        elem
    }


    // === Chunks ===

    fun chunk_index<Element: store>(v: &DynVec<Element>, idx: u64): (u64, u64) {
        let chunk_idx = idx / v.limit;
        let _idx = idx % v.limit;

        (chunk_idx, _idx)
    }

    /// Check whether chunk exists
    public fun has_chunk<Element: store>(
        v: &DynVec<Element>,
        chunk_idx: u64,
    ): bool {
        if (chunk_idx == 0) {
            true
        } else {
            df::exists_(&v.vecs, chunk_idx)
        }
    }

    /// Borrow chunk
    public fun borrow_chunk<Element: store>(
        v: &DynVec<Element>,
        chunk_idx: u64,
    ): &vector<Element> {
        if (chunk_idx == 0) {
            &v.vec_0
        } else {
            df::borrow(&v.vecs, chunk_idx)
        }
    }

    /// Borrow chunk mutably
    fun borrow_chunk_mut<Element: store>(
        v: &mut DynVec<Element>,
        chunk_idx: u64,
    ): &mut vector<Element> {
        if (chunk_idx == 0) {
            &mut v.vec_0
        } else {
            df::borrow_mut(&mut v.vecs, chunk_idx)
        }
    }

    /// Insert new chunk
    fun insert_chunk<Element: store>(
        v: &mut DynVec<Element>,
        chunk_idx: u64,
        element: Element,
    ) {
        let chunk = vector::singleton(element);
        df::add(&mut v.vecs, chunk_idx, chunk);
        v.len = v.len + 1;
    }

    /// Remove chunk
    ///
    /// #### Panics
    ///
    /// Panics if it had more than one element left
    fun remove_chunk<Element: store>(
        v: &mut DynVec<Element>,
        chunk_idx: u64,
    ): Element {
        let elem = if (chunk_idx == 0) {
            vector::pop_back(&mut v.vec_0)
        } else {
            let chunk = df::remove(&mut v.vecs, chunk_idx);
            // debug::print(&chunk);
            let elem = vector::pop_back(&mut chunk);
            vector::destroy_empty(chunk);
            elem
        };

        v.len = v.len - 1;
        elem
    }

    // === Tests ===

    #[test_only]
    use sui::test_scenario::{Self, ctx};

    #[test_only]
    fun destroy_test<Element: store + drop>(v: DynVec<Element>) {
        let DynVec<Element> { vec_0: _, vecs, len: _, limit: _ } = v;

        object::delete(vecs);
    }

    #[test]
    fun it_works() {
        let scenario = test_scenario::begin(@0x0);

        let vec = empty<u64>(10, ctx(&mut scenario));

        let i = 0;

        while (i <= 6_000) {
            push_back(&mut vec, i);
            i = i + 1;
        };

        // let k = 50_000;

        // while (k >= 0) {
        //     let j = pop_back(&mut vec);
        //     debug::print(&k);
        //     debug::print(&j);

        //     assert!(k == j, 0);

        //     k = k - 1;
        // };


        destroy_test(vec);
        test_scenario::end(scenario);
    }


}
