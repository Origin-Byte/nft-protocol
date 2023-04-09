module nft_protocol::yoots_fur {
    use std::string::String;

    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};

    use nft_protocol::mint_event;
    use nft_protocol::mint_cap::{MintCap};

    friend nft_protocol::yoots;

    struct Fur has key, store {
        id: UID,
        type: String
    }

    public fun mint_fur(
        mint_cap: &mut MintCap<Fur>,
        type: String,
        ctx: &mut TxContext,
    ): Fur {
        let fur = Fur {
            id: object::new(ctx),
            type,
        };

        mint_event::mint_limited(mint_cap, &fur);

        fur
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
