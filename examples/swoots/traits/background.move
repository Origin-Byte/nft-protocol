module nft_protocol::swoots_background {
    use std::string::String;

    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};

    friend nft_protocol::swoots;

    struct Background has key, store {
        id: UID,
        type: String
    }

    public(friend) fun mint_background_(
        type: String,
        ctx: &mut TxContext,
    ): Background {
        Background {
            id: object::new(ctx),
            type,
        }
    }
}
