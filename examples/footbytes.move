module nft_protocol::footbytes {
    use std::string::{Self, String};

    use sui::balance;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft;
    use nft_protocol::url;
    use nft_protocol::tags;
    use nft_protocol::royalty;
    use nft_protocol::display;
    use nft_protocol::creators;
    use nft_protocol::metadata;
    use nft_protocol::metadata_bag;
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

        collection::add_domain(
            &Witness {},
            &mut collection,
            creators::from_address<FOOTBYTES, Witness>(
                &Witness {}, tx_context::sender(ctx),
            ),
        );

        // Register custom domains
        display::add_collection_display_domain(
            &Witness {},
            &mut collection,
            string::utf8(b"Football digital stickers"),
            string::utf8(b"A NFT collection of football player collectibles"),
        );

        url::add_collection_url_domain(
            &Witness {},
            &mut collection,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        display::add_collection_symbol_domain(
            &Witness {},
            &mut collection,
            string::utf8(b"FOOT"),
        );

        let royalty = royalty::from_address(tx_context::sender(ctx), ctx);
        royalty::add_proportional_royalty(&mut royalty, 100);
        royalty::add_royalty_domain(
            &Witness {},
            &mut collection,
            royalty,
        );

        let tags = tags::empty(ctx);
        tags::add_tag(&mut tags, tags::art());
        tags::add_collection_tag_domain(
            &Witness {},
            &mut collection,
            tags,
        );

        metadata_bag::init_metadata_bag<FOOTBYTES, Witness>(
            &Witness {},
            &mut collection,
            ctx,
        );

        transfer::public_transfer(mint_cap, tx_context::sender(ctx));
        transfer::public_share_object(collection);
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
        let url = sui::url::new_unsafe_from_bytes(url);

        let nft = nft::from_mint_cap(mint_cap, name, url, ctx);

        display::add_display_domain(
            &Witness {}, &mut nft, name, description,
        );

        url::add_url_domain(&Witness {}, &mut nft, url);

        let metadata = metadata::new_regulated(nft, supply, ctx);
        metadata_bag::add_metadata_to_collection(mint_cap, collection, metadata);
    }
}
