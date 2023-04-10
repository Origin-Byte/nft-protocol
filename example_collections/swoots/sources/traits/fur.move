module swoots::fur {
    use std::string::String;

    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};

    friend swoots::swoots;

    struct Fur has key, store {
        id: UID,
        type: String
    }

    public(friend) fun mint_fur_(
        type: String,
        ctx: &mut TxContext,
    ): Fur {
        Fur {
            id: object::new(ctx),
            type,
        }
    }
}
