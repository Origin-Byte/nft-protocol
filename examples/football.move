module nft_protocol::football {
    use std::string;

    use sui::balance;
    use sui::object::ID;
    use sui::transfer::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft;
    use nft_protocol::flyweight::{Self, Pointer, Archetype, Registry};
    use nft_protocol::tags;
    use nft_protocol::royalty;
    use nft_protocol::display;
    use nft_protocol::attribution;
    use nft_protocol::launchpad::{Self as lp, Slot};
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::collection::{Self, Collection, MintCap};

    /// One time witness is only instantiated in the init method
    struct FOOTBALL has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: FOOTBALL, ctx: &mut TxContext) {
        let (mint_cap, collection) = collection::create<FOOTBALL>(
            &witness,
            100, // max supply
            ctx,
        );

        collection::add_domain(
            &mut collection,
            &mint_cap,
            attribution::from_address(tx_context::sender(ctx))
        );

        // Register custom domains
        display::add_collection_display_domain(
            &mut collection,
            &mint_cap,
            string::utf8(b"Football digital stickers"),
            string::utf8(b"A NFT collection of football player collectibles"),
        );

        display::add_collection_url_domain(
            &mut collection,
            &mint_cap,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        display::add_collection_symbol_domain(
            &mut collection,
            &mint_cap,
            string::utf8(b"FOOT")
        );

        let royalty = royalty::new(ctx);
        royalty::add_proportional_royalty(
            &mut royalty,
            nft_protocol::royalty_strategy_bps::new(100),
        );
        royalty::add_royalty_domain(&mut collection, &mint_cap, royalty);

        let tags = tags::empty(ctx);
        tags::add_tag(&mut tags, tags::art());
        tags::add_collection_tag_domain(&mut collection, &mint_cap, tags);

        let registry = flyweight::init_registry<FOOTBALL>(ctx, &mint_cap);

        flyweight::add_archetypes_domain<FOOTBALL>(
            &mut collection,
            &mint_cap,
            registry
        );

        transfer(mint_cap, tx_context::sender(ctx));
        collection::share<FOOTBALL>(collection);
    }

    public entry fun collect_royalty<FT>(
        payment: &mut TradePayment<FOOTBALL, FT>,
        collection: &mut Collection<FOOTBALL>,
        ctx: &mut TxContext,
    ) {
        let b = royalties::balance_mut(Witness {}, payment);

        let domain = royalty::royalty_domain(collection);
        let royalty_owed =
            royalty::calculate_proportional_royalty(domain, balance::value(b));

        royalty::collect_royalty(collection, b, royalty_owed);
        royalties::transfer_remaining_to_beneficiary(Witness {}, payment, ctx);
    }

    public entry fun mint_nft_archetype(
        name: vector<u8>,
        description: vector<u8>,
        // url: vector<u8>,
        // attribute_keys: vector<vector<u8>>,
        // attribute_values: vector<vector<u8>>,
        mint_cap: &mut MintCap<FOOTBALL>,
        supply: u64,
        slot: &mut Slot,
        market_id: ID,
        ctx: &mut TxContext,
    ) {
        let archetype = flyweight::new<FOOTBALL>(supply, mint_cap, ctx);

        let nft = flyweight::borrow_nft_mut(&mut archetype, mint_cap);

        collection::increment_supply(mint_cap, 1);

        display::add_display_domain(
            nft,
            string::utf8(name),
            string::utf8(description),
            ctx,
        );

        lp::add_nft(slot, market_id, nft);
    }
}
