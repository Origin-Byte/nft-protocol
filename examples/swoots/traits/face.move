module nft_protocol::swoots_face {
    use std::string::String;

    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};

    friend nft_protocol::swoots;

    struct Face has key, store {
        id: UID,
        type: String
    }

    public(friend) fun mint_face_(
        type: String,
        ctx: &mut TxContext,
    ): Face {
        Face {
            id: object::new(ctx),
            type,
        }
    }
}
