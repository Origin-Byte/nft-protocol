module nft_protocol::object_vec {

use std::option::Option;
use sui::object::{Self, ID, UID};
use sui::dynamic_object_field as ofield;
use sui::tx_context::TxContext;

// Attempted to destroy a non-empty table
const ETableNotEmpty: u64 = 0;

struct ObjectVec<phantom V: key + store> has key, store {
    /// the ID of this table
    id: UID,
    /// the number of key-value pairs in the table
    size: u64,
}

/// Creates a new, empty table
public fun new<V: key + store>(ctx: &mut TxContext): ObjectVec<V> {
    ObjectVec {
        id: object::new(ctx),
        size: 0,
    }
}

/// Adds a key-value pair to the table `table: &mut ObjectVec<V>`
/// Aborts with `sui::dynamic_field::EFieldAlreadyExists` if the table already has an entry with
/// that key `k: K`.
public fun add<V: key + store>(table: &mut ObjectVec<V>, v: V) {
    ofield::add(&mut table.id, table.size + 1, v);
    table.size = table.size + 1;
}

/// Immutable borrows the value associated with the key in the table `table: &ObjectVec<V>`.
/// Aborts with `sui::dynamic_field::EFieldDoesNotExist` if the table does not have an entry with
/// that key `k: K`.
public fun borrow<V: key + store>(table: &ObjectVec<V>, index: u64): &V {
    ofield::borrow(&table.id, index)
}

/// Mutably borrows the value associated with the key in the table `table: &mut ObjectVec<V>`.
/// Aborts with `sui::dynamic_field::EFieldDoesNotExist` if the table does not have an entry with
/// that key `k: K`.
public fun borrow_mut<V: key + store>(
    table: &mut ObjectVec<V>,
    index: u64,
): &mut V {
    ofield::borrow_mut(&mut table.id, index)
}

/// Mutably borrows the key-value pair in the table `table: &mut ObjectVec<V>` and returns the
/// value.
/// Aborts with `sui::dynamic_field::EFieldDoesNotExist` if the table does not have an entry with
/// that key `k: K`.
public fun remove<V: key + store>(table: &mut ObjectVec<V>, index: u64): V {
    let v = ofield::remove(&mut table.id, index);
    table.size = table.size - 1;
    v
}

/// Returns true iff there is a value associated with the key `k: K` in table
/// `table: &ObjectVec<V>`
public fun contains<V: key + store>(table: &ObjectVec<V>, index: u64): bool {
    ofield::exists_(&table.id, index)
}

/// Returns the size of the table, the number of key-value pairs
public fun length<V: key + store>(table: &ObjectVec<V>): u64 {
    table.size
}

/// Returns true iff the table is empty (if `length` returns `0`)
public fun is_empty<V: key + store>(table: &ObjectVec<V>): bool {
    table.size == 0
}

/// Destroys an empty table
/// Aborts with `ETableNotEmpty` if the table still contains values
public fun destroy_empty<V: key + store>(table: ObjectVec<V>) {
    let ObjectVec { id, size } = table;
    assert!(size == 0, ETableNotEmpty);
    object::delete(id)
}

/// Returns the ID of the object associated with the key if the table has an entry with key `k: K`
/// Returns none otherwise
public fun value_id<V: key + store>(
    table: &ObjectVec<V>,
    index: u64,
): Option<ID> {
    ofield::id(&table.id, index)
}

}
