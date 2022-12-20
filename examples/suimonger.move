module nft_protocol::suimonger {
    use std::string::{Self, String};

    use sui::url;
    use sui::balance;
    use sui::object::ID;
    use sui::transfer::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft;
    use nft_protocol::tags;
    use nft_protocol::royalty;
    use nft_protocol::display;
    use nft_protocol::attribution;
    use nft_protocol::slot::{Self, Slot};
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::collection::{Self, Collection, MintCap};

    /// One time witness is only instantiated in the init method
    struct SUIMONGER has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: SUIMONGER, ctx: &mut TxContext) {
        let (mint_cap, collection) = collection::create<SUIMONGER>(
            &witness,
            100, // max supply
            ctx,
        );

        collection::add_domain(
            &mut collection,
            &mut mint_cap,
            attribution::from_address(tx_context::sender(ctx))
        );

        // Register custom domains
        display::add_collection_display_domain(
            &mut collection,
            &mut mint_cap,
            string::utf8(b"SUIMONGER"),
            string::utf8(b"XYZ"),
        );

        display::add_collection_url_domain(
            &mut collection,
            &mut mint_cap,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        display::add_collection_symbol_domain(
            &mut collection,
            &mut mint_cap,
            string::utf8(b"SUIMO")
        );

        let royalty = royalty::new(ctx);
        royalty::add_proportional_royalty(
            &mut royalty,
            nft_protocol::royalty_strategy_bps::new(200),
        );
        royalty::add_royalty_domain(&mut collection, &mut mint_cap, royalty);

        let tags = tags::empty(ctx);
        tags::add_tag(&mut tags, tags::art());
        tags::add_collection_tag_domain(&mut collection, &mut mint_cap, tags);

        transfer(mint_cap, tx_context::sender(ctx));
        collection::share<SUIMONGER>(collection);
    }

    public entry fun collect_royalty<FT>(
        payment: &mut TradePayment<SUIMONGER, FT>,
        collection: &mut Collection<SUIMONGER>,
        ctx: &mut TxContext,
    ) {
        let b = royalties::balance_mut(Witness {}, payment);

        let domain = royalty::royalty_domain(collection);
        let royalty_owed =
            royalty::calculate_proportional_royalty(domain, balance::value(b));

        royalty::collect_royalty(collection, b, royalty_owed);
        royalties::transfer_remaining_to_beneficiary(Witness {}, payment, ctx);
    }

    public entry fun mint_nft(
        name: String,
        description: String,
        url: vector<u8>,
        attribute_keys: vector<String>,
        attribute_values: vector<String>,
        mint_cap: &mut MintCap<SUIMONGER>,
        slot: &mut Slot,
        market_id: ID,
        ctx: &mut TxContext,
    ) {
        let nft = nft::new<SUIMONGER>(tx_context::sender(ctx), ctx);

        collection::increment_supply(mint_cap, 1);

        display::add_display_domain(
            &mut nft,
            name,
            description,
            ctx,
        );

        display::add_url_domain(
            &mut nft,
            url::new_unsafe_from_bytes(url),
            ctx,
        );

        display::add_attributes_domain_from_vec(
            &mut nft,
            attribute_keys,
            attribute_values,
            ctx,
        );

        slot::add_nft(slot, market_id, nft, ctx);
    }
}
