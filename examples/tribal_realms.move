module nft_protocol::tribal_realms {
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
    use nft_protocol::witness;
    use nft_protocol::mint_cap::{MintCap};
    use nft_protocol::warehouse::{Self, Warehouse};
    use nft_protocol::composable_nft::{Self as c_nft};
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::collection::{Self, Collection};

    /// One time witness is only instantiated in the init method
    struct TRIBAL_REALMS has drop {}

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

    fun init(witness: TRIBAL_REALMS, ctx: &mut TxContext) {
        let (mint_cap, collection) = collection::create(&witness, ctx);
        let delegated_witness = witness::from_witness(&Witness {});

        collection::add_domain(
            delegated_witness,
            &mut collection,
            creators::from_address<TRIBAL_REALMS, Witness>(
                &Witness {}, tx_context::sender(ctx), ctx,
            ),
        );

        // Register custom domains
        display::add_collection_display_domain(
            delegated_witness,
            &mut collection,
            string::utf8(b"Suimarines"),
            string::utf8(b"A unique NFT collection of Suimarines on Sui"),
            ctx,
        );

        display::add_collection_url_domain(
            delegated_witness,
            &mut collection,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
            ctx,
        );

        display::add_collection_symbol_domain(
            delegated_witness,
            &mut collection,
            string::utf8(b"SUIM"),
            ctx
        );

        let royalty = royalty::from_address(tx_context::sender(ctx), ctx);
        royalty::add_proportional_royalty(&mut royalty, 100);
        royalty::add_royalty_domain(
            delegated_witness,
            &mut collection,
            royalty,
        );

        let tags = tags::empty(ctx);
        tags::add_tag(&mut tags, tags::art());
        tags::add_collection_tag_domain(
            delegated_witness,
            &mut collection,
            tags,
        );

        // Composability
        let blueprint = c_nft::new_blueprint(ctx);
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
        c_nft::add_parent_child_relationship<Gun>(
            &mut blueprint,
            c_nft::new_child_node<Skin>(1, 1, ctx), // limit, order, ctx
            ctx
        );

        c_nft::add_blueprint_domain(delegated_witness, &mut collection, blueprint);

        transfer::transfer(mint_cap, tx_context::sender(ctx));
        transfer::share_object(collection);
    }

    /// Calculates and transfers royalties to the `RoyaltyDomain`
    public entry fun collect_royalty<FT>(
        payment: &mut TradePayment<TRIBAL_REALMS, FT>,
        collection: &mut Collection<TRIBAL_REALMS>,
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
        mint_cap: &MintCap<TRIBAL_REALMS>,
        warehouse: &mut Warehouse<TRIBAL_REALMS>,
        ctx: &mut TxContext,
    ) {
        let nft =
            nft::new(&Witness {}, mint_cap, tx_context::sender(ctx), ctx);
        let delegated_witness = witness::from_witness(&Witness {});

        display::add_display_domain(
            delegated_witness, &mut nft, name, description, ctx,
        );

        display::add_url_domain(
            delegated_witness, &mut nft, url::new_unsafe_from_bytes(url), ctx,
        );

        display::add_attributes_domain_from_vec(
            delegated_witness, &mut nft, attribute_keys, attribute_values, ctx,
        );

        c_nft::add_type_domain<TRIBAL_REALMS, T>(delegated_witness, &mut nft, ctx);

        warehouse::deposit_nft(warehouse, nft);
    }
}
