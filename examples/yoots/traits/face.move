module nft_protocol::yoots_face {
    use std::string::String;

    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};

    use nft_protocol::mint_event;
    use nft_protocol::mint_cap::{MintCap};

    friend nft_protocol::yoots;

    struct Face has key, store {
        id: UID,
        type: String
    }

    public fun mint_face(
        mint_cap: &mut MintCap<Face>,
        type: String,
        ctx: &mut TxContext,
    ): Face {
        let face = Face {
            id: object::new(ctx),
            type,
        };

        mint_event::mint_limited(mint_cap, &face);

        face
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
