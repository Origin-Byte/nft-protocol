module nft_protocol::suimarines {
    use std::vector;
    use std::string;

    use sui::balance;
    use sui::transfer::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::display;
    use nft_protocol::fixed_price;
    use nft_protocol::nft;
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::royalty;
    use nft_protocol::sale::{Self, NftCertificate};
    use nft_protocol::attribution;

    /// One time witness is only instantiated in the init method
    struct SUIMARINES has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: SUIMARINES, ctx: &mut TxContext) {
        let tags: vector<vector<u8>> = vector::empty();
        vector::push_back(&mut tags, b"Art");

        let collection = collection::create<SUIMARINES>(
            100, // max supply
            tags,
            false, // is mutable
            tx_context::sender(ctx), // mint authority
            ctx,
        );

        collection::add_domain(
            &mut collection,
            attribution::from_address(@0x6c86ac4a796204ea09a87b6130db0c38263c1890)
        );

        // Register custom domains
        display::add_collection_display_domain(
            &mut collection,
            string::utf8(b"Suimarines"),
            string::utf8(b"A unique NFT collection of Suimarines on Sui"),
        );

        display::add_collection_url_domain(
            &mut collection,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        display::add_collection_symbol_domain(
            &mut collection,
            string::utf8(b"SUIM")
        );

        royalty::add_collection_royalty_domain(&mut collection, ctx);
        royalty::add_proportional_royalty(
            &mut collection,
            nft_protocol::royalty_strategy_bps::new(100),
            ctx,
        );

        let collection_id = collection::share<SUIMARINES>(collection);

        let whitelist = vector::empty();
        vector::push_back(&mut whitelist, true);
        vector::push_back(&mut whitelist, false);

        let prices = vector::empty();
        vector::push_back(&mut prices, 1000);
        vector::push_back(&mut prices, 2000);

        fixed_price::create_market(
            witness,
            tx_context::sender(ctx), // admin
            collection_id,
            @0x6c86ac4a796204ea09a87b6130db0c38263c1890,
            true, // is_embedded
            whitelist, prices,
            ctx,
        );
    }

    public entry fun collect_royalty<FT>(
        payment: &mut TradePayment<SUIMARINES, FT>,
        collection: &mut Collection<SUIMARINES>,
        ctx: &mut TxContext,
    ) {
        let b = royalties::balance_mut(Witness {}, payment);

        let domain = royalty::collection_royalty_domain_mut(collection);
        let trade_value = balance::value(b);
        royalty::transfer_royalties(domain, b, trade_value);

        royalties::transfer_remaining_to_beneficiary(Witness {}, payment, ctx);
    }

    public entry fun redeem_certificate(
        certificate: NftCertificate,
        ctx: &mut TxContext
    ) {
        // TODO: Check whether NftCertificate is issued for this collection
        // Pending on Launchpad refactor completion
        sale::burn_certificate(certificate);

        let nft = nft::new<SUIMARINES>(ctx);

        display::add_display_domain(
            &mut nft,
            string::utf8(b"Suimarine"),
            string::utf8(b"A Unique NFT collection of Suimarines on Sui"),
            ctx,
        );

        transfer(nft, tx_context::sender(ctx));
    }
}
