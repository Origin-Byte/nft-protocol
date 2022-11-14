module nft_protocol::suimarines {
    use std::vector;

    use sui::tx_context::{Self, TxContext};

    use nft_protocol::collection::{MintAuthority};
    use nft_protocol::fixed_price::{Self, FixedPriceMarket};
    use nft_protocol::slingshot::Slingshot;
    use nft_protocol::std_collection;
    use nft_protocol::unique_nft;

    struct SUIMARINES has drop {}

    fun init(witness: SUIMARINES, ctx: &mut TxContext) {
        let tags: vector<vector<u8>> = vector::empty();

        vector::push_back(&mut tags, b"Art");

        let collection_id = std_collection::mint<SUIMARINES>(
            b"Suimarines",
            b"A Unique NFT collection of Suimarines on Sui",
            b"SUIM", // symbol
            100, // max_supply
            @0x6c86ac4a796204ea09a87b6130db0c38263c1890, // Royalty receiver
            tags, // tags
            100, // royalty_fee_bps
            false, // is_mutable
            b"Some extra data",
            tx_context::sender(ctx), // mint authority
            ctx,
        );

        let whitelisting = vector::empty();
        vector::push_back(&mut whitelisting, true);
        vector::push_back(&mut whitelisting, false);

        let pricing = vector::empty();
        vector::push_back(&mut pricing, 1000);
        vector::push_back(&mut pricing, 2000);

        fixed_price::create_market(
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

    public entry fun prepare_mint(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        mint_authority: &mut MintAuthority<SUIMARINES>,
        sale_outlet: u64,
        launchpad: &mut Slingshot<SUIMARINES, FixedPriceMarket>,
        ctx: &mut TxContext,
    ) {
        unique_nft::prepare_launchpad_mint<SUIMARINES, FixedPriceMarket>(
            name,
            description,
            url,
            attribute_keys,
            attribute_values,
            mint_authority,
            sale_outlet,
            launchpad,
            ctx,
        );
    }
}
