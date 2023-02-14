module nft_protocol::tribal_realms {
    use std::string::{Self, String};

    use sui::url;
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
    use nft_protocol::collection;

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
                &Witness {}, tx_context::sender(ctx),
            ),
        );

        // Register custom domains
        display::add_collection_display_domain(
            delegated_witness,
            &mut collection,
            string::utf8(b"Suimarines"),
            string::utf8(b"A unique NFT collection of Suimarines on Sui"),
        );

        display::add_collection_url_domain(
            delegated_witness,
            &mut collection,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        display::add_collection_symbol_domain(
            delegated_witness,
            &mut collection,
            string::utf8(b"SUIM"),
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

        // === Avatar composability ===

        let blueprint = c_nft::new_blueprint<Avatar>(ctx);
        c_nft::add_relationship<Avatar, Hat>(
            &mut blueprint,
            1, // limit
            1, // order
        );
        c_nft::add_relationship<Avatar, Glasses>(
            &mut blueprint,
            1, // limit
            1, // order
        );
        c_nft::add_relationship<Avatar, Gun>(
            &mut blueprint,
            1, // limit
            1, // order
        );

        c_nft::add_blueprint_domain(delegated_witness, &mut collection, blueprint);

        // === Gun composability ===

        let blueprint = c_nft::new_blueprint<Gun>(ctx);
        c_nft::add_relationship<Gun, Skin>(
            &mut blueprint,
            1, // limit
            1, // order
        );

        c_nft::add_blueprint_domain(delegated_witness, &mut collection, blueprint);

        transfer::transfer(mint_cap, tx_context::sender(ctx));
        transfer::share_object(collection);
    }

    public entry fun mint_nft<T: drop + store>(
        name: String,
        description: String,
        url: vector<u8>,
        mint_cap: &MintCap<TRIBAL_REALMS>,
        warehouse: &mut Warehouse<TRIBAL_REALMS>,
        ctx: &mut TxContext,
    ) {
        let url = url::new_unsafe_from_bytes(url);

        let nft = nft::from_mint_cap(
            mint_cap, name, url, tx_context::sender(ctx), ctx,
        );
        let delegated_witness = witness::from_witness(&Witness {});

        display::add_display_domain(
            delegated_witness, &mut nft, name, description,
        );

        display::add_url_domain(delegated_witness, &mut nft, url);

        c_nft::add_type_domain<TRIBAL_REALMS, T>(delegated_witness, &mut nft, ctx);

        warehouse::deposit_nft(warehouse, nft);
    }
}
