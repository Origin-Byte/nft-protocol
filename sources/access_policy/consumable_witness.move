/// Module of the `ConsumableWitness` used for generating Witnesses that must
/// be consumed by a specific object of a specific module
module nft_protocol::consumable_witness {
    use std::type_name::{Self, TypeName};
    use nft_protocol::utils;

    friend nft_protocol::access_policy;

    /// Collection generic witness type
    struct ConsumableWitness<phantom T> {
        field: TypeName,
    }

    /// Create a new `ConsumableWitness` from collection witness
    public fun new<T, W>(_witness: &W, field: TypeName): ConsumableWitness<T> {
        utils::assert_same_module_as_witness<T, W>();
        ConsumableWitness { field }
    }

    // TODO
    public(friend)fun from_access_policy<T: key>(field: TypeName): ConsumableWitness<T> {
        ConsumableWitness {field}
    }

    public fun get_consumable_from_witness<W: drop, T: key>(
        _witness: W,
    ): ConsumableWitness<T> {
        utils::assert_same_module_as_witness<T, W>();

        ConsumableWitness<T> {
            field: type_name::get<T>(),
        }
    }

    // TODO: Explain that this needs to be used in the context of programmable
    // transactions
    public fun consume<T, F>(consumable: ConsumableWitness<T>, field: &mut F) {
        // field has to be & mut to prove that the caller has mutable access
        assert!(consumable.field == type_name::get<F>(), 0);

        // Consume witness
        ConsumableWitness { field: _ } = consumable;
    }

    public fun assert_consumable<T, Field>(consumable: &ConsumableWitness<T>) {
        assert!(consumable.field == type_name::get<Field>(), 0);
    }
}
