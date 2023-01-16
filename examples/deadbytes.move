module nft_protocol::deadbytes {
    use std::string::{Self, String};

    use sui::url;
    use sui::balance;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft;
    use nft_protocol::tags;
    use nft_protocol::c_nft;
    use nft_protocol::royalty;
    use nft_protocol::display;
    use nft_protocol::creators;
    use nft_protocol::inventory::{Self, Inventory};
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::collection::{Self, Collection, MintCap};

    /// One time witness is only instantiated in the init method
    struct DEADBYTES has drop {}

    /// Types
    struct Avatar has copy, drop, store {}
    struct Skin has copy, drop, store {}
    struct Hat has copy, drop, store {}
    struct Glasses has copy, drop, store {}
    struct Gun has copy, drop, store {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: DEADBYTES, ctx: &mut TxContext) {
        let (mint_cap, collection) = collection::create<DEADBYTES>(
            &witness,
            ctx,
        );

        collection::add_domain(
            &mut collection,
            &mut mint_cap,
            creators::from_address(tx_context::sender(ctx))
        );

        // Register custom domains
        display::add_collection_display_domain(
            &mut collection,
            &mut mint_cap,
            string::utf8(b"Suimarines"),
            string::utf8(b"A unique NFT collection of Suimarines on Sui"),
        );

        display::add_collection_url_domain(
            &mut collection,
            &mut mint_cap,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        display::add_collection_symbol_domain(
            &mut collection,
            &mut mint_cap,
            string::utf8(b"SUIM")
        );

        let royalty = royalty::new(ctx);
        royalty::add_proportional_royalty(
            &mut royalty,
            nft_protocol::royalty_strategy_bps::new(100),
        );
        royalty::add_royalty_domain(&mut collection, &mut mint_cap, royalty);

        let tags = tags::empty(ctx);
        tags::add_tag(&mut tags, tags::art());
        tags::add_collection_tag_domain(&mut collection, &mut mint_cap, tags);

        // Composability
        let blueprint = c_nft::new_blueprint(ctx);
        c_nft::add_parent_child_relationship<Avatar>(
            &mut blueprint,
            c_nft::new_child_node<Skin>(1, 1, ctx), // limit, order, ctx
            ctx
        );
        c_nft::add_parent_child_relationship<Avatar>(
            &mut blueprint,
            c_nft::new_child_node<Hat>(1, 1, ctx), // limit, order, ctx
            ctx
        );
        c_nft::add_parent_child_relationship<Avatar>(
            &mut blueprint,
            c_nft::new_child_node<Glasses>(1, 1, ctx), // limit, order, ctx
            ctx
        );
        c_nft::add_parent_child_relationship<Avatar>(
            &mut blueprint,
            c_nft::new_child_node<Gun>(1, 1, ctx), // limit, order, ctx
            ctx
        );

        c_nft::add_blueprint_domain(&mut collection, &mut mint_cap, blueprint);

        transfer::transfer(mint_cap, tx_context::sender(ctx));
        transfer::share_object(collection);
    }

    /// Calculates and transfers royalties to the `RoyaltyDomain`
    public entry fun collect_royalty<FT>(
        payment: &mut TradePayment<DEADBYTES, FT>,
        collection: &mut Collection<DEADBYTES>,
        ctx: &mut TxContext,
    ) {
        let b = royalties::balance_mut(Witness {}, payment);

        let domain = royalty::royalty_domain(collection);
        let royalty_owed =
            royalty::calculate_proportional_royalty(domain, balance::value(b));

        royalty::collect_royalty(collection, b, royalty_owed);
        royalties::transfer_remaining_to_beneficiary(Witness {}, payment, ctx);
    }

    public entry fun mint_nft<T: drop + store>(
        name: String,
        description: String,
        url: vector<u8>,
        attribute_keys: vector<String>,
        attribute_values: vector<String>,
        _mint_cap: &MintCap<DEADBYTES>,
        inventory: &mut Inventory,
        ctx: &mut TxContext,
    ) {
        let nft = nft::new<DEADBYTES, Witness>(&Witness {}, tx_context::sender(ctx), ctx);

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

        c_nft::add_type_domain<DEADBYTES, T>(&mut nft, ctx);

        inventory::deposit_nft(inventory, nft);
    }
}
