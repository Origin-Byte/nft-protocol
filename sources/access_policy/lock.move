/// Module of the `ConsumableWitness` used for generating Witnesses that must
/// be consumed by a specific object of a specific module
module nft_protocol::lock {
    use std::type_name::{Self, TypeName};
    use nft_protocol::utils;

    friend nft_protocol::access_policy;

    /// Collection generic witness type
    struct MutLock<T> {
        nft: T,
        field: TypeName,
    }

    /// Create a new `ConsumableWitness` from collection witness
    public(friend) fun new<T: key + store>(nft: T, field: TypeName): MutLock<T> {
        MutLock { nft, field }
    }
}
