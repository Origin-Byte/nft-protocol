module nft_protocol::swoots_eyewear {
    use std::string::String;

    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};

    friend nft_protocol::swoots;

    struct Eyewear has key, store {
        id: UID,
        type: String
    }

    public(friend) fun mint_eyewear_(
        type: String,
        ctx: &mut TxContext,
    ): Eyewear {
        Eyewear {
            id: object::new(ctx),
            type,
        }
    }
}
