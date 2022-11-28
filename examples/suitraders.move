module nft_protocol::suitraders {
    use std::vector;
    use std::string;

    use sui::tx_context::{Self, TxContext};

    use nft_protocol::dutch_auction;
    use nft_protocol::collection;

    use nft_protocol::display;

    struct SUITRADERS has drop {}

    fun init(witness: SUITRADERS, ctx: &mut TxContext) {
        let tags: vector<vector<u8>> = vector::empty();
        vector::push_back(&mut tags, b"Art");
        vector::push_back(&mut tags, b"PFP");

        let collection = collection::create<SUITRADERS>(
            b"SUITR", // symbol
            100, // max supply
            tags,
            true, // is mutable
            tx_context::sender(ctx), // mint authority
            ctx,
        );

        // Register custom domains
        display::add_collection_display_domain(
            &mut collection,
            string::utf8(b"Suitraders"),
            string::utf8(b"A unique NFT collection of Suitraders on Sui"),
        );

        display::add_collection_url_domain(
            &mut collection,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        let collection_id = collection::mint<SUITRADERS>(collection);

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
