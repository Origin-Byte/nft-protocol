module nft_protocol::suinamis {
    use std::vector;

    use sui::tx_context::{Self, TxContext};

    use nft_protocol::collection::{MintAuthority};
    use nft_protocol::fixed_price;
    use nft_protocol::std_collection;
    use nft_protocol::collectible;
    

    struct SUINAMIS has drop {}

    fun init(witness: SUINAMIS, ctx: &mut TxContext) {
        let tags: vector<vector<u8>> = vector::empty();
        
        vector::push_back(&mut tags, b"Art");
        vector::push_back(&mut tags, b"PFP");

        let collection_id = std_collection::mint<SUINAMIS>(
            b"Suinamis",
            b"A Unique NFT collection of Suinamis on Sui",
            b"SUIN", // symbol
            100, // max_supply
            @0x6c86ac4a796204ea09a87b6130db0c38263c1890, // Royalty receiver
            tags, // tags
            100, // royalty_fee_bps
            true, // is_mutable
            b"Some extra data",
            tx_context::sender(ctx), // mint authority
            ctx,
        );

        let whitelisting = vector::empty();
        vector::push_back(&mut whitelisting, false);

        let pricing = vector::empty();
        vector::push_back(&mut pricing, 1000);

        fixed_price::create_market(
            witness,
            tx_context::sender(ctx), // admin
            collection_id,
            @0x6c86ac4a796204ea09a87b6130db0c38263c1890,
            false, // is_embedded
            whitelisting, // whitelist
            pricing, // price
            ctx,
        );
    }

    public entry fun mint_nft<T>(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        max_supply: u64,
        mint: &mut MintAuthority<SUINAMIS>,
        ctx: &mut TxContext,
    ) {
        collectible::mint_regulated_nft_data(
            name,
            description,
            url,
            attribute_keys,
            attribute_values,
            max_supply,
            mint,
            ctx,
        );
    }
}
