module nft_protocol::suimarines {
    use std::string;

    use sui::balance;
    use sui::object::ID;
    use sui::transfer::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft;
    use nft_protocol::tags;
    use nft_protocol::royalty;
    use nft_protocol::display;
    use nft_protocol::attribution;
    use nft_protocol::launchpad::{Self as lp, Slot};
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::collection::{Self, Collection, MintCap};

    /// One time witness is only instantiated in the init method
    struct SUIMARINES has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: SUIMARINES, ctx: &mut TxContext) {
        let (mint_cap, collection) = collection::create<SUIMARINES>(
            &witness,
            100, // max supply
            false, // is mutable
            ctx,
        );

        transfer(mint_cap, tx_context::sender(ctx));

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

        royalty::add_royalty_domain(&mut collection, ctx);
        royalty::add_proportional_royalty(
            &mut collection,
            nft_protocol::royalty_strategy_bps::new(100),
            ctx,
        );

        let tags = tags::empty(ctx);
        tags::add_tag(&mut tags, tags::art(), ctx);
        tags::add_collection_tag_domain(&mut collection, tags);

        collection::share<SUIMARINES>(collection);
    }

    public entry fun collect_royalty<FT>(
        payment: &mut TradePayment<SUIMARINES, FT>,
        collection: &mut Collection<SUIMARINES>,
        ctx: &mut TxContext,
    ) {
        let b = royalties::balance_mut(Witness {}, payment);

        let domain = royalty::royalty_domain_mut(collection);
        let royalty_owed =
            royalty::calculate_proportional_royalty(domain, balance::value(b));

        royalty::transfer_royalties(domain, b, royalty_owed);
        royalties::transfer_remaining_to_beneficiary(Witness {}, payment, ctx);
    }

    public entry fun mint_nft(
        name: vector<u8>,
        description: vector<u8>,
        // url: vector<u8>,
        // attribute_keys: vector<vector<u8>>,
        // attribute_values: vector<vector<u8>>,
        mint_cap: &mut MintCap<SUIMARINES>,
        slot: &mut Slot,
        market_id: ID,
        ctx: &mut TxContext,
    ) {
        let nft = nft::new<SUIMARINES>(ctx);

        collection::increment_supply(mint_cap, 1);

        display::add_display_domain(
            &mut nft,
            string::utf8(name),
            string::utf8(description),
            ctx,
        );

        lp::add_nft(slot, market_id, nft);
    }
}
