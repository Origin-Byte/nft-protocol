module nft_protocol::suitraders {
    use std::vector;

    use sui::tx_context::{Self, TxContext};

    use nft_protocol::dutch_auction;
    use nft_protocol::std_collection;

    struct SUITRADERS has drop {}

    fun init(witness: SUITRADERS, ctx: &mut TxContext) {
        let tags: vector<vector<u8>> = vector::empty();
        vector::push_back(&mut tags, b"Art");
        vector::push_back(&mut tags, b"PFP");

        let collection_id = std_collection::mint<SUITRADERS>(
            b"Suitraders",
            b"A Unique NFT collection of Suitraders on Sui",
            b"SUITR", // symbol
            100, // max_supply
            @0x6c86ac4a796204ea09a87b6130db0c38263c1890, // Royalty receiver
            tags, // tags
            100, // royalty_fee_bps
            true, // is_mutable
            b"Some extra data",
            tx_context::sender(ctx), // mint authority
            ctx,
        );

        let whitelist = vector::empty();
        vector::push_back(&mut whitelist, true);
        vector::push_back(&mut whitelist, false);

        let reserve_prices = vector::empty();
        vector::push_back(&mut reserve_prices, 1000);
        vector::push_back(&mut reserve_prices, 2000);

        dutch_auction::create_market(
            witness,
            tx_context::sender(ctx), // admin
            collection_id,
            @0x6c86ac4a796204ea09a87b6130db0c38263c1890,
            true, // is_embedded
            whitelist, reserve_prices,
            ctx,
        );
    }
}
