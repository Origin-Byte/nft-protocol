module nft_protocol::yoots_eyewear {
    use std::string::String;

    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};

    use nft_protocol::mint_event;
    use nft_protocol::mint_cap::{MintCap};

    friend nft_protocol::yoots;

    struct Eyewear has key, store {
        id: UID,
        type: String
    }

    public fun mint_eyewear(
        mint_cap: &mut MintCap<Eyewear>,
        type: String,
        ctx: &mut TxContext,
    ): Eyewear {
        let eyewear = Eyewear {
            id: object::new(ctx),
            type,
        };

        mint_event::mint_limited(mint_cap, &eyewear);

        eyewear
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
