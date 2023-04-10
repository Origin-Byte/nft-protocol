module nft_protocol::swoots_head {
    use std::string::String;

    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};

    friend nft_protocol::swoots;

    struct Head has key, store {
        id: UID,
        type: String
    }

    public(friend) fun mint_head_(
        type: String,
        ctx: &mut TxContext,
    ): Head {
        let head = Head {
            id: object::new(ctx),
            type,
        };

        head
    }
}
