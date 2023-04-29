module ob_utils::sized_vec {
    use std::vector;

    struct SizedVec<Element> has copy, drop, store {
        capacity: u64,
        vec: vector<Element>
    }

    /// The index into the vector is out of bounds
    const EINDEX_OUT_OF_BOUNDS: u64 = 1;

    const ECAPACITY_REACHED: u64 = 2;

    const ECAPACITY_DECREASE_EXCEEDS_LENGTH: u64 = 3;

    /// Create an empty sized vector.
    public fun empty<Element>(capacity: u64): SizedVec<Element> {
        SizedVec {
            capacity,
            vec: vector::empty(),
        }
    }

    public fun slack<Element>(v: &SizedVec<Element>): u64 {
        v.capacity - length(v)
    }

    public fun capacity<Element>(v: &SizedVec<Element>): u64 {
        v.capacity
    }

    /// Return the current length of the vector.
    public fun length<Element>(v: &SizedVec<Element>): u64 {
        vector::length(&v.vec)
    }

    /// Acquire an immutable reference to the `i`th element of the vector `v`.
    /// Aborts if `i` is out of bounds.
    public fun borrow<Element>(v: &SizedVec<Element>, i: u64): &Element {
        vector::borrow(&v.vec, i)
    }

    /// Return the current length of the vector.
    public fun increase_capacity<Element>(v: &mut SizedVec<Element>, bump: u64) {
        v.capacity = v.capacity + bump;
    }

    public fun decrease_capacity<Element>(v: &mut SizedVec<Element>, bump: u64) {
        assert!(bump <= length(v), ECAPACITY_DECREASE_EXCEEDS_LENGTH);
        v.capacity = v.capacity - bump;
    }

    /// Add element `e` to the end of the vector `v`.
    public fun push_back<Element>(v: &mut SizedVec<Element>, e: Element) {
        assert!(vector::length(&v.vec) < v.capacity, ECAPACITY_REACHED);
        vector::push_back(&mut v.vec, e)
    }

    /// Return a mutable reference to the `i`th element in the vector `v`.
    /// Aborts if `i` is out of bounds.
    public fun borrow_mut<Element>(v: &mut SizedVec<Element>, i: u64): &mut Element {
        vector::borrow_mut(&mut v.vec, i)
    }

    /// Pop an element from the end of vector `v`.
    /// Aborts if `v` is empty.
    public fun pop_back<Element>(v: &mut SizedVec<Element>): Element {
        vector::pop_back(&mut v.vec)
    }

    /// Destroy the vector `v`.
    /// Aborts if `v` is not empty.
    public fun destroy_empty<Element>(v: SizedVec<Element>) {
        let SizedVec { capacity: _, vec } = v;
        vector::destroy_empty(vec);
    }

    /// Swaps the elements at the `i`th and `j`th indices in the vector `v`.
    /// Aborts if `i` or `j` is out of bounds.
    public fun swap<Element>(v: &mut SizedVec<Element>, i: u64, j: u64) {
        vector::swap(&mut v.vec, i, j);
    }

    /// Return an vector of size one containing element `e`.
    public fun singleton<Element>(capacity: u64, e: Element): SizedVec<Element> {
        let vec = vector::empty();
        vector::push_back(&mut vec, e);

        SizedVec {
            capacity,
            vec
        }
    }

    /// Reverses the order of the elements in the vector `v` in place.
    public fun reverse<Element>(v: &mut SizedVec<Element>) {
        vector::reverse(&mut v.vec)
    }

    /// Pushes all of the elements of the `other` vector into the `lhs` vector.
    public fun append<Element>(lhs: &mut SizedVec<Element>, other: SizedVec<Element>) {
        let SizedVec { capacity, vec } = other;

        lhs.capacity = lhs.capacity + capacity;
        vector::append(&mut lhs.vec, vec);
    }

    /// Return `true` if the vector `v` has no elements and `false` otherwise.
    public fun is_empty<Element>(v: &SizedVec<Element>): bool {
        vector::length(&v.vec) == 0
    }

    /// Return true if `e` is in the vector `v`.
    /// Otherwise, returns false.
    public fun contains<Element>(v: &SizedVec<Element>, e: &Element): bool {
        vector::contains(&v.vec, e)
    }

    /// Return `(true, i)` if `e` is in the vector `v` at index `i`.
    /// Otherwise, returns `(false, 0)`.
    public fun index_of<Element>(v: &SizedVec<Element>, e: &Element): (bool, u64) {
        vector::index_of(&v.vec, e)
    }

    /// Remove the `i`th element of the vector `v`, shifting all subsequent elements.
    /// This is O(n) and preserves ordering of elements in the vector.
    /// Aborts if `i` is out of bounds.
    public fun remove<Element>(v: &mut SizedVec<Element>, i: u64): Element {
        vector::remove(&mut v.vec, i)
    }

    /// Insert `e` at position `i` in the vector `v`.
    /// If `i` is in bounds, this shifts the old `v[i]` and all subsequent elements to the right.
    /// If `i == length(v)`, this adds `e` to the end of the vector.
    /// This is O(n) and preserves ordering of elements in the vector.
    /// Aborts if `i > length(v)`
    public fun insert<Element>(v: &mut SizedVec<Element>, e: Element, i: u64) {
        vector::insert(&mut v.vec, e, i);
    }

    /// Swap the `i`th element of the vector `v` with the last element and then pop the vector.
    /// This is O(1), but does not preserve ordering of elements in the vector.
    /// Aborts if `i` is out of bounds.
    public fun swap_remove<Element>(v: &mut SizedVec<Element>, i: u64): Element {
        vector::swap_remove(&mut v.vec, i)
    }
}
