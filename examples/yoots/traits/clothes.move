module nft_protocol::yoots_clothes {
    use std::string::String;

    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};

    use nft_protocol::mint_event;
    use nft_protocol::mint_cap::{MintCap};

    friend nft_protocol::yoots;

    struct Clothes has key, store {
        id: UID,
        type: String
    }

    public fun mint_clothes(
        mint_cap: &mut MintCap<Clothes>,
        type: String,
        ctx: &mut TxContext,
    ): Clothes {
        let clothes = Clothes {
            id: object::new(ctx),
            type,
        };

        mint_event::mint_limited(mint_cap, &clothes);

        clothes
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
