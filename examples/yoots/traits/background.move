module nft_protocol::yoots_background {
    use std::string::String;

    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};

    use nft_protocol::mint_event;
    use nft_protocol::mint_cap::{MintCap};

    friend nft_protocol::yoots;

    struct Background has key, store {
        id: UID,
        type: String
    }

    public fun mint_background(
        mint_cap: &mut MintCap<Background>,
        type: String,
        ctx: &mut TxContext,
    ): Background {
        let bckgrd = Background {
            id: object::new(ctx),
            type,
        };

        mint_event::mint_limited(mint_cap, &bckgrd);

        bckgrd
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
