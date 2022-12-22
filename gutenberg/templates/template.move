module nft_protocol::{module_name} {{
    use std::string::{{Self, String}};

    use sui::url;
    use sui::balance;
    use sui::transfer;
    use sui::tx_context::{{Self, TxContext}};

    use nft_protocol::nft;
    use nft_protocol::tags;
    use nft_protocol::royalty;
    use nft_protocol::display;
    use nft_protocol::attribution;
    use nft_protocol::inventory::{{Self, Inventory}};
    use nft_protocol::royalties::{{Self, TradePayment}};
    use nft_protocol::collection::{{Self, Collection, MintCap}};

    {launchpad_modules}

    /// One time witness is only instantiated in the init method
    struct {witness} has drop {{}}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {{}}

    fun init(witness: {witness}, ctx: &mut TxContext) {{
        let (mint_cap, collection) = collection::create<{witness}>(
            &witness,
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
            string::utf8(b"{name}"),
            string::utf8(b"{description}"),
        );

        display::add_collection_url_domain(
            &mut collection,
            &mut mint_cap,
            sui::url::new_unsafe_from_bytes(b"{url}"),
        );

        display::add_collection_symbol_domain(
            &mut collection,
            &mut mint_cap,
            string::utf8(b"{symbol}")
        );

        let royalty = royalty::new(ctx);
        royalty::add_proportional_royalty(
            &mut royalty,
            nft_protocol::royalty_strategy_bps::new({royalty_fee_bps}),
        );
        royalty::add_royalty_domain(&mut collection, &mut mint_cap, royalty);

        {tags}

        {launchpad}

        transfer::share_object(launchpad);
        transfer::share_object(slot);

        transfer::transfer(mint_cap, tx_context::sender(ctx));
        collection::share<{witness}>(collection);
    }}

    public entry fun collect_royalty<FT>(
        payment: &mut TradePayment<{witness}, FT>,
        collection: &mut Collection<{witness}>,
        ctx: &mut TxContext,
    ) {{
        let b = royalties::balance_mut(Witness {{}}, payment);

        let domain = royalty::royalty_domain(collection);
        let royalty_owed =
            royalty::calculate_proportional_royalty(domain, balance::value(b));

        royalty::collect_royalty(collection, b, royalty_owed);
        royalties::transfer_remaining_to_beneficiary(Witness {{}}, payment, ctx);
    }}

    public entry fun mint_nft(
        name: String,
        description: String,
        url: vector<u8>,
        attribute_keys: vector<String>,
        attribute_values: vector<String>,
        _mint_cap: &MintCap<{witness}>,
        inventory: &mut Inventory,
        ctx: &mut TxContext,
    ) {{
        let nft = nft::new<{witness}>(tx_context::sender(ctx), ctx);

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

        inventory::add_nft(inventory, nft);
    }}
}}
