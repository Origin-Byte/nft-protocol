module nft_protocol::{module_name} {{
    use std::vector;

    use sui::tx_context::{{Self, TxContext}};

    use nft_protocol::collection::{{MintAuthority}};
    use nft_protocol::{market_module}{market_module_imports};
    use nft_protocol::std_collection;
    use nft_protocol::{nft_type};
{slingshot_import}

    struct {witness} has drop {{}}

    fun init(witness: {witness}, ctx: &mut TxContext) {{
        {tags}
        let collection_id = std_collection::mint<{witness}>(
            b"{name}",
            b"{description}",
            b"{symbol}", // symbol
            {max_supply}, // max_supply
            @{receiver}, // Royalty receiver
            tags, // tags
            {royalty_fee_bps}, // royalty_fee_bps
            {is_mutable}, // is_mutable
            b"{extra_data}",
            tx_context::sender(ctx), // mint authority
            ctx,
        );

        {define_market_arguments}
        {market_module}::create_market(
            witness,
            tx_context::sender(ctx), // admin
            collection_id,
            @{receiver},
            {is_embedded}, // is_embedded
            {market_arguments}
            ctx,
        );
    }}

    {mint_function}
}}
