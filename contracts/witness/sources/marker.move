module witness::marker {
    /// Used to mark type fields in dynamic fields
    struct Marker<phantom T> has copy, drop, store {}

    public fun marker<T>(): Marker<T> {
        Marker<T> {}
    }
}
