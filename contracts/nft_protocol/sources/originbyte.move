module nft_protocol::originbyte {
    use sui::package;
    use sui::transfer;
    use sui::object::{Self, ID};
    use sui::tx_context::{Self, TxContext};

    use liquidity_layer::bidding;
    use liquidity_layer::orderbook;

    use ob_allowlist::allowlist;

    use ob_authlist::authlist;

    struct ORIGINBYTE has drop {}

    fun init(otw: ORIGINBYTE, ctx: &mut TxContext) {
        let pub = package::claim(otw, ctx);
        init_allowlist(ctx);
        init_authlist(ctx);

        transfer::public_transfer(pub, tx_context::sender(ctx));
    }

    /// Initialize official OriginByte `Allowlist`
    public fun init_allowlist(ctx: &mut TxContext): (ID, ID) {
        let (allowlist, cap) = allowlist::new(ctx);

        // Thus far only `orderbook` and `bidding` can perform trades
        allowlist::insert_authority<orderbook::Witness>(&cap, &mut allowlist);
        allowlist::insert_authority<bidding::Witness>(&cap, &mut allowlist);

        let allowlist_id = object::id(&allowlist);
        let cap_id = object::id(&cap);

        transfer::public_transfer(cap, tx_context::sender(ctx));
        transfer::public_share_object(allowlist);
        (allowlist_id, cap_id)
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
    public fun init_authlist(ctx: &mut TxContext): (ID, ID) {
        let (authlist, cap) = authlist::new(ctx);

        authlist::insert_authority(
            &cap, &mut authlist, authlist::address_to_bytes(PERMISSIONLESS_PUBLIC_KEY),
        );

        let authlist_id = object::id(&authlist);
        let cap_id = object::id(&cap);

        transfer::public_transfer(cap, tx_context::sender(ctx));
        transfer::public_share_object(authlist);
        (authlist_id, cap_id)
    }

    public fun permissionless_public_key(): address {
        PERMISSIONLESS_PUBLIC_KEY
    }

    public fun permissionless_private_key(): address {
        PERMISSIONLESS_PRIVATE_KEY
    }
}
