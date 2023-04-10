module swoots::clothes {
    use std::string::String;

    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};

    friend swoots::swoots;

    struct Clothes has key, store {
        id: UID,
        type: String
    }

    public(friend) fun mint_clothes_(
        type: String,
        ctx: &mut TxContext,
    ): Clothes {
        Clothes {
            id: object::new(ctx),
            type,
        }
    }
}
