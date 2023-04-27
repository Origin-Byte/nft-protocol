module nft_protocol::nft_protocol {
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use liquidity_layer::bidding;
    use liquidity_layer::orderbook;

    use ob_allowlist::allowlist;

    use ob_authlist::authlist;

    struct NFT_PROTOCOL has drop {}

    fun init(_otw: NFT_PROTOCOL, ctx: &mut TxContext) {
        init_allowlist(ctx);
        init_authlist(ctx);
    }

    /// Initialize official OriginByte `Allowlist`
    fun init_allowlist(ctx: &mut TxContext) {
        let (allowlist, cap) = allowlist::new(ctx);

        // Thus far only `orderbook` and `bidding` can perform trades
        allowlist::insert_authority<orderbook::Witness>(&cap, &mut allowlist);
        allowlist::insert_authority<bidding::Witness>(&cap, &mut allowlist);

        transfer::public_transfer(cap, tx_context::sender(ctx));
        transfer::public_share_object(allowlist);
    }

    const PERMISSIONLESS_PUBLIC_KEY: address = @0x8a1a8348dde5d979c85553c03e204c73efc3b91a2c9ce96b1004c9ec26eaacc8;
    const PERMISSIONLESS_PRIVATE_KEY: address = @0xac5dbb29bea100f5f6382ebcb116afc66fc7b05ff64d2d1e3fc60849504a29f0;

    /// Initialize official OriginByte `Authlist`
    ///
    /// This initially contains a public keypair such that users can sign P2P
    /// transactions client-side until ecosystem achieves wide adoption.
    ///
    /// This keypair is expected to be removed in the early stages of mainnet
    /// and replaced with genuine authorities.
    fun init_authlist(ctx: &mut TxContext) {
        let (authlist, cap) = authlist::new(ctx);

        authlist::insert_authority(
            &cap, &mut authlist, authlist::address_to_bytes(PERMISSIONLESS_PUBLIC_KEY),
        );

        transfer::public_transfer(cap, tx_context::sender(ctx));
        transfer::public_share_object(authlist);
    }

    public fun permissionless_public_key(): address {
        PERMISSIONLESS_PUBLIC_KEY
    }

    public fun permissionless_private_key(): address {
        PERMISSIONLESS_PRIVATE_KEY
    }
}
