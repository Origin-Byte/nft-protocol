module nft_protocol::suimarines {
    use sui::tx_context::{Self, TxContext};

    use std::vector;
    
    use nft_protocol::collection::{MintAuthority};
    use nft_protocol::fixed_price::{Self, FixedPriceMarket};
    use nft_protocol::slingshot::Slingshot;
    use nft_protocol::std_collection;
    use nft_protocol::unique_nft;

    struct SUIMARINES has drop {}

    fun init(witness: SUIMARINES, ctx: &mut TxContext) {
        let receiver = @0xA;

        std_collection::mint<SUIMARINES>(
            b"Suimarines",
            b"A Unique NFT collection of Submarines on Sui",
            b"SUIM", // symbol
            100, // max_supply
            receiver, // Royalty receiver
            vector::singleton(b"Art"), // tags
            100, // royalty_fee_bps
            false, // is_mutable
            b"Some extra data",
            tx_context::sender(ctx), // mint authority
            ctx,
        );

        fixed_price::create_single_market(
            witness,
            tx_context::sender(ctx), // admin
            receiver,
            true, // is_embedded
            false, // whitelist
            100, // price
            ctx,
        );
    }

    public entry fun mint_nft(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        mint_authority: &mut MintAuthority<SUIMARINES>,
        sale_index: u64,
        launchpad: &mut Slingshot<SUIMARINES, FixedPriceMarket>,
        ctx: &mut TxContext,
    ) {
        unique_nft::mint_regulated_nft(
            name,
            description,
            url,
            attribute_keys,
            attribute_values,
            mint_authority,
            sale_index,
            launchpad,
            ctx,
        );
    }
}
