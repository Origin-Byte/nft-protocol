/// @title box
/// @notice Generalized box for transferring objects that only have `store` but not `key`.
module originmate::box {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::TxContext;

    struct Box<T: store> has key, store {
        id: UID,
        obj: T
    }

    /// @dev Stores the sent object in an box object.
    /// @param recipient The destination address of the box object.
    public entry fun box<T: store>(recipient: address, obj_in: T, ctx: &mut TxContext) {
        let box = Box<T> {
            id: object::new(ctx),
            obj: obj_in
        };
        transfer::public_transfer(box, recipient);
    }

    /// @dev Unboxes the object inside the box.
    public fun unbox<T: store>(box: Box<T>): T {
        let Box {
            id: id,
            obj: obj,
        } = box;
        object::delete(id);
        obj
    }
}
