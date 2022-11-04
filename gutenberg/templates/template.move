module nft_protocol::{module_name} {{
    use std::vector;

    use sui::tx_context::{{Self, TxContext}};

    // NFT Modules
    use nft_protocol::{nft_type};
    use nft_protocol::std_collection;
    use nft_protocol::collection::{{MintAuthority}};

    // Market Modules
    {slingshot_import}
    use nft_protocol::{market_module}{market_module_imports};

    struct {witness} has drop {{}}

    fun init(witness: {witness}, ctx: &mut TxContext) {{
        let tags: vector<vector<u8>> = vector::empty();{tags}

        let collection_id = std_collection::mint<{witness}>(
            b"{name}",
            b"{description}",
            b"{symbol}", // symbol
            {max_supply}, // max_supply
            @{receiver}, // Royalty receiver
            tags,
            {royalty_fee_bps}, // royalty_fee_bps
            {is_mutable}, // is_mutable
            b"{extra_data}",
            tx_context::sender(ctx), // mint authority
            ctx,
        );

        {define_whitelists}
        {define_prices}

        {market_module}::{sale_type}(
            witness,
            tx_context::sender(ctx), // admin
            collection_id,
            @{receiver},
            {is_embedded}, // is_embedded
            whitelisting,
            pricing,
            ctx,
        );
    }}

    {mint_function}
}}
