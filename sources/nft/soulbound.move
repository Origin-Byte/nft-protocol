module nft_protocol::soulbound {
    //! We cannot prevent a transfer of an object to another owner. However,
    //! with this struct, we can render an object bricked unless the owner is
    //! the expected address.

    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};

    struct SoulBound<N> has key {
        id: UID,
        inner: N,
    }

    public fun lock_nft<N: key + store>(
        inner: N,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let soulbound = SoulBound {
            id: object::new(ctx),
            inner: inner,
        };

        transfer::transfer(
            soulbound,
            recipient,
        );
    }

    public fun unlock_nft<N: key + store>(
        soulbound: SoulBound<N>,
    ): N {
        
        let SoulBound {
            id,
            inner,
        } = soulbound;
        
        object::delete(id);

        inner
    }
}
