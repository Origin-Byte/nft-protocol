module nft_protocol::football {
    use std::string::{Self, String};

    use sui::url;
    use sui::balance;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft;
    use nft_protocol::tags;
    use nft_protocol::royalty;
    use nft_protocol::display;
    use nft_protocol::creators;
    use nft_protocol::flyweight;
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::collection::{Self, Collection, MintCap};

    /// One time witness is only instantiated in the init method
    struct FOOTBALL has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: FOOTBALL, ctx: &mut TxContext) {
        let (mint_cap, collection) = collection::create(
            &witness, ctx,
        );

        collection::add_domain(
            &mut collection,
            &mint_cap,
            creators::from_address(tx_context::sender(ctx), ctx)
        );

        // Register custom domains
        display::add_collection_display_domain(
            &mut collection,
            &mint_cap,
            string::utf8(b"Football digital stickers"),
            string::utf8(b"A NFT collection of football player collectibles"),
            ctx,
        );

        display::add_collection_url_domain(
            &mut collection,
            &mint_cap,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
            ctx,
        );

        display::add_collection_symbol_domain(
            &mut collection,
            &mint_cap,
            string::utf8(b"FOOT"),
            ctx
        );

        let royalty = royalty::from_address(tx_context::sender(ctx), ctx);
        royalty::add_proportional_royalty(&mut royalty, 100);
        royalty::add_royalty_domain(&mut collection, &mint_cap, royalty);

        let tags = tags::empty(ctx);
        tags::add_tag(&mut tags, tags::art());
        tags::add_collection_tag_domain(&mut collection, &mint_cap, tags);

        flyweight::init_registry<FOOTBALL>(&mut collection, &mint_cap, ctx);

        transfer::transfer(mint_cap, tx_context::sender(ctx));
        transfer::share_object(collection);
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
        name: String,
        description: String,
        url: vector<u8>,
        collection: &mut Collection<FOOTBALL>,
        mint_cap: &MintCap<FOOTBALL>,
        supply: u64,
        ctx: &mut TxContext,
    ) {
        let nft = nft::new<FOOTBALL, Witness>(
            &Witness {}, tx_context::sender(ctx), ctx
        );

        display::add_display_domain(
            &mut nft, name, description, ctx,
        );

        display::add_url_domain(
            &mut nft, url::new_unsafe_from_bytes(url), ctx,
        );

        let archetype = flyweight::new_regulated(nft, supply, ctx);
        flyweight::add_collection_archetype(collection, mint_cap, archetype);
    }
}
