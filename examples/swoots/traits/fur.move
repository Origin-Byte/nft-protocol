module nft_protocol::swoots_fur {
    use std::string::String;

    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};

    friend nft_protocol::swoots;

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
