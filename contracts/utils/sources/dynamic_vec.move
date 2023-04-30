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
        current_chunk: u64,
        tip_length: u64,
        total_length: u64,
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
            current_chunk: 0,
            tip_length: 0,
            total_length: 0,
            limit,
        }
    }

    /// Return the current length of the dynamic vector.
    public fun total_length<Element: store>(v: &DynVec<Element>): u64 {
        v.total_length
    }

    public fun tip_length<Element: store>(v: &DynVec<Element>): u64 {
        v.tip_length
    }

    public fun current_chunk<Element: store>(v: &DynVec<Element>): u64 {
        v.current_chunk
    }

    public fun push_back<Element: store>(
        v: &mut DynVec<Element>,
        elem: Element,
    ) {
        let chunk_idx = v.current_chunk;

        // If the tip is maxed out, create a new vector and add it there
        if (v.tip_length == v.limit) {
            insert_chunk(v, chunk_idx + 1, elem);

            // Update current chunk
            v.current_chunk = v.current_chunk + 1;

            // Update the current tip length to one since it's a new tip
            v.tip_length = 1;


            // debug::print(&(v.current_chunk + 1));
        } else {
            // Then it means that there is still capacity for the tip to hold
            // another element
            let chunk = borrow_chunk_mut(v, chunk_idx);
            vector::push_back(chunk, elem);

            // Update the current tip length
            v.tip_length = v.tip_length + 1;
        };

        // Update the total length
        v.total_length = v.total_length + 1;
    }

    public fun pop_back<Element: store>(
        v: &mut DynVec<Element>,
    ): Element {
        // This only occurs when it has no elements
        assert!(v.tip_length != 0, 0);
        let chunk_idx = v.current_chunk;

        let elem = if (v.tip_length == 1) {
            let elem = remove_chunk(v, chunk_idx);

            // Reset the tip length


            // Update current chunk
            if (v.current_chunk > 0) {
                v.current_chunk = v.current_chunk - 1;
                // If there are more chunks, then reset the tip to the limit
                v.tip_length = v.limit;
            } else {
                // If there are no more chunks, then reset the tip to zero
                v.tip_length = 0;
            };

            elem
        } else {
            let chunk = borrow_chunk_mut(v, chunk_idx);
            let elem = vector::pop_back(chunk);

            // Update the tip length
            v.tip_length = v.tip_length - 1;

            elem
        };

        v.total_length = v.total_length - 1;

        elem
    }


    // public fun pop_at_index<Element: store>(
    //     v: &mut DynVec<Element>,
    //     index: u64,
    // ): Element {
    //     assert!(v.len > 0, EEmpty);
    //     assert!(index < v.len, EIndexOutOfBounds);

    //     // TODO: Test, why is it - 1 here?
    //     let idx_ = v.len - 1;
    //     let (chunk_idx_remove, idx_remove) = chunk_index(v, index);
    //     let (chunk_idx_last, idx_last) = chunk_index(v, idx_);

    //     let chunk_last = borrow_chunk_mut(v, chunk_idx_last);

    //     let elem = if (chunk_idx_remove == chunk_idx_last) {
    //         // If the chunk to remove from is the last chunk
    //         // - Perform swap remove
    //         // - Cleanup last chunk if it is now empty
    //         if (idx_last > 0) {
    //             vector::swap_remove(chunk_last, idx_remove)
    //         } else {
    //             remove_chunk(v, chunk_idx_last)
    //         }
    //     } else {
    //         // If the chunk to remove from is not the last chunk
    //         // - Perform swap remove in remove chunk
    //         // - Pop ID from last chunk and push to remove chunk
    //         // - Cleanup last chunk if now empty
    //         let id_last = if (idx_last > 0) {
    //             vector::pop_back(chunk_last)
    //         } else {
    //             remove_chunk(v, chunk_idx_last)
    //         };

    //         let chunk_remove = borrow_chunk_mut(v, chunk_idx_remove);
    //         let id_remove = vector::swap_remove(chunk_remove, idx_remove);
    //         vector::push_back(chunk_remove, id_last);

    //         id_remove
    //     };

    //     v.len = v.len - 1;
    //     elem
    // }


    // === Chunks ===

    fun chunk_index<Element: store>(v: &DynVec<Element>, idx: u64): (u64, u64) {
        debug::print(&utf8(b">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><"));
        debug::print(&utf8(b"Dividing idx:"));
        debug::print(&idx);
        debug::print(&utf8(b"By the limit:"));
        debug::print(&v.limit);
        let chunk_idx = idx / v.limit;
        let _idx = idx % v.limit;
        debug::print(&utf8(b"results in:"));
        debug::print(&chunk_idx);
        debug::print(&utf8(b">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><"));

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

        elem
    }

    fun how_many_chunks(total_items: u64, limit: u64): u64 {
        let chunk_idx = total_items / limit;
        let remainder = total_items % limit;

        if (remainder > 0) {
            chunk_idx = chunk_idx + 1;
        };

        chunk_idx
    }

    // === Tests ===

    #[test_only]
    use sui::test_scenario::{Self, ctx};

    #[test_only]
    fun destroy_test<Element: store + drop>(v: DynVec<Element>) {
        let DynVec<Element> { vec_0: _, vecs, current_chunk: _, tip_length: _, total_length: _, limit: _ } = v;

        object::delete(vecs);
    }

    #[test]
    fun test_how_many_chunks() {
        let limit = 7;

        while (limit < 8_000) {
            let expected_chunks = 1;
            let counter = 0;

            let i = 1;
            while (i <= 10_000) {
                let actual_chunks = how_many_chunks(i, limit);

                if (counter == limit) {
                    expected_chunks = expected_chunks + 1;
                    counter = 0;
                };

                assert!(actual_chunks == expected_chunks, 0);

                counter = counter + 1;
                i = i + 1;
            };

            limit = limit * 10;
        }
    }

    #[test]
    fun test_chunk_index() {
        let scenario = test_scenario::begin(@0x0);

        let vec = empty<u64>(10, ctx(&mut scenario));
        let i = 0;

        while (i < 100) {
            let (_chunk_idx, _elem_idx) = chunk_index(&vec, i);

            i = i + 1;
        };

        destroy_test(vec);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_chunk_lengths() {
        let scenario = test_scenario::begin(@0x0);

        let limit = 7_500;
        let total_items = 50_000;
        let total_chunks = how_many_chunks(total_items, limit);

        let vec = empty<u64>(limit, ctx(&mut scenario));

        let i = 1;
        while (i <= total_items) {
            push_back(&mut vec, i);
            i = i + 1;
        };

        let j = 1;
        while (j <= total_chunks) {
            let chunk = borrow_chunk(&vec, j - 1);

            // The last chunk is not completely filled always, so we need to adjust
            let expected_length = if (limit * j > total_items) {
                let k = total_chunks - 1; // this is index 6
                total_items - (limit * k)
            } else {
                limit
            };

            assert!(vector::length(chunk) == expected_length, 0);

            j = j + 1;
        };

        destroy_test(vec);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_orderly_popping_elements() {
        let scenario = test_scenario::begin(@0x0);

        let limit = 75;
        let total_items = 500;
        // let total_chunks = how_many_chunks(total_items, limit);

        let exp_tip_len = 0;

        let vec = empty<u64>(limit, ctx(&mut scenario));

        let i = 1;
        while (i <= total_items) {
            push_back(&mut vec, i);
            debug::print(&tip_length(&vec));

            if (i % limit == 0) {
                exp_tip_len = limit;
                assert!(tip_length(&vec) == exp_tip_len, 0);

                // Reset for the next iteration
                exp_tip_len = 0;
            } else {
                exp_tip_len = exp_tip_len + 1;
                assert!(tip_length(&vec) == exp_tip_len , 0);
            };

            i = i + 1;
        };

        let i = total_items;


        while (i > 0) {
            let elem = pop_back(&mut vec);
            debug::print(&tip_length(&vec));

            assert!(elem == i, 0);

            i = i - 1;

            if (i % limit == 0) {
                if (i == 0) {
                    // For the last iteration the tip should be zero
                    exp_tip_len = 0;
                } else {
                    // For all others we reset the tip to the limit
                    exp_tip_len = limit;
                };

                assert!(tip_length(&vec) == exp_tip_len, 0);
            } else {
                exp_tip_len = exp_tip_len - 1;
                assert!(tip_length(&vec) == exp_tip_len , 0);
            };


        };

        assert!(total_length(&vec) == 0, 0);
        assert!(current_chunk(&vec) == 0, 0);
        assert!(tip_length(&vec) == 0, 0);

        destroy_test(vec);
        test_scenario::end(scenario);
    }
}
