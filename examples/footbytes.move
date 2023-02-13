module nft_protocol::footbytes {
    use std::string::{Self, String};

    use sui::url;
    use sui::balance;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft;
    use nft_protocol::tags;
    use nft_protocol::royalty;
    use nft_protocol::display;
    use nft_protocol::witness;
    use nft_protocol::creators;
    use nft_protocol::template;
    use nft_protocol::templates;
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::mint_cap::MintCap;

    /// One time witness is only instantiated in the init method
    struct FOOTBYTES has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: FOOTBYTES, ctx: &mut TxContext) {
        let (mint_cap, collection) = collection::create(&witness, ctx);
        let delegated_witness = witness::from_witness(&Witness {});

        collection::add_domain(
            delegated_witness,
            &mut collection,
            creators::from_address<FOOTBYTES, Witness>(
                &Witness {}, tx_context::sender(ctx),
            ),
        );

        // Register custom domains
        display::add_collection_display_domain(
            delegated_witness,
            &mut collection,
            string::utf8(b"Football digital stickers"),
            string::utf8(b"A NFT collection of football player collectibles"),
        );

        display::add_collection_url_domain(
            delegated_witness,
            &mut collection,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        display::add_collection_symbol_domain(
            delegated_witness,
            &mut collection,
            string::utf8(b"FOOT"),
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

        templates::init_templates<FOOTBYTES>(
            delegated_witness,
            &mut collection,
            ctx,
        );

        transfer::transfer(mint_cap, tx_context::sender(ctx));
        transfer::share_object(collection);
    }

    public entry fun collect_royalty<FT>(
        payment: &mut TradePayment<FOOTBYTES, FT>,
        collection: &mut Collection<FOOTBYTES>,
        ctx: &mut TxContext,
    ) {
        let b = royalties::balance_mut(Witness {}, payment);

        let domain = royalty::royalty_domain(collection);
        let royalty_owed =
            royalty::calculate_proportional_royalty(domain, balance::value(b));

        royalty::collect_royalty(collection, b, royalty_owed);
        royalties::transfer_remaining_to_beneficiary(Witness {}, payment, ctx);
    }

    public entry fun mint_nft_template(
        name: String,
        description: String,
        url: vector<u8>,
        collection: &mut Collection<FOOTBYTES>,
        mint_cap: &MintCap<FOOTBYTES>,
        supply: u64,
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

        let template = template::new_regulated(nft, supply, ctx);
        templates::add_collection_template(mint_cap, collection, template);
    }
}
