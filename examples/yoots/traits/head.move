module nft_protocol::yoots_head {
    use std::string::String;

    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};

    use nft_protocol::mint_event;
    use nft_protocol::mint_cap::{MintCap};

    friend nft_protocol::yoots;

    struct Head has key, store {
        id: UID,
        type: String
    }

    public fun mint_head(
        mint_cap: &mut MintCap<Head>,
        type: String,
        ctx: &mut TxContext,
    ): Head {
        let head = Head {
            id: object::new(ctx),
            type,
        };

        mint_event::mint_limited(mint_cap, &head);

        head
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
