module nft_protocol::suimonsters {
    use std::vector;

    use sui::tx_context::{Self, TxContext};
    
    use nft_protocol::collection::{MintAuthority};
    use nft_protocol::fixed_price::{Self, FixedPriceMarket};
    use nft_protocol::std_collection;
    use nft_protocol::unique_nft;
    use nft_protocol::slingshot::Slingshot;

    struct SUIMONSTERS has drop {}

    fun init(witness: SUIMONSTERS, ctx: &mut TxContext) {
        let tags: vector<vector<u8>> = vector::empty();
        
        vector::push_back(&mut tags, b"Art");
        vector::push_back(&mut tags, b"PFP");

        let collection_id = std_collection::mint<SUIMONSTERS>(
            b"SuiMonsters",
            b"A Unique NFT collection of SuiMonsters on Sui",
            b"SUIMO", // symbol
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
        vector::push_back(&mut whitelisting, true);
        vector::push_back(&mut whitelisting, true);
        vector::push_back(&mut whitelisting, true);


        let pricing = vector::empty();
        vector::push_back(&mut pricing, 1000);
        vector::push_back(&mut pricing, 2000);
        vector::push_back(&mut pricing, 3000);
        vector::push_back(&mut pricing, 4000);
        vector::push_back(&mut pricing, 5000);

        
        fixed_price::create_multi_market(
            witness,
            tx_context::sender(ctx), // admin
            collection_id,
            @0x6c86ac4a796204ea09a87b6130db0c38263c1890,
            true, // is_embedded
            whitelisting, // whitelist
            pricing, // price
            ctx,
        );
    }

    public entry fun mint_nft(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        mint_authority: &mut MintAuthority<SUIMONSTERS>,
        sale_index: u64,
        launchpad: &mut Slingshot<SUIMONSTERS, FixedPriceMarket>,
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
