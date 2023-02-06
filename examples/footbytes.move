module nft_protocol::footbytes {
    use std::string::{Self, String};
    use std::option::{Self, Option};

    use sui::url;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft;
    use nft_protocol::display;
    use nft_protocol::metadata;
    use nft_protocol::metadata_bag::{Self, MetadataBagDomain};
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

        display::add_collection_display_domain(
            &Witness {},
            &mut collection,
            string::utf8(b"Football digital stickers"),
            string::utf8(b"A NFT collection of football player collectibles"),
        );

        let metadata_bag = metadata_bag::new_metadata_bag<FOOTBYTES>(ctx);

        transfer::transfer(mint_cap, tx_context::sender(ctx));
        transfer::transfer(metadata_bag, tx_context::sender(ctx));
        transfer::share_object(collection);
    }

    /// Register `MetadataBagDomain` with `Collection`
    public entry fun add_metadata_domain(
        _mint_cap: &MintCap<FOOTBYTES>,
        collection: &mut Collection<FOOTBYTES>,
        metadata_bag: MetadataBagDomain<FOOTBYTES>,
    ) {
        collection::add_domain(&Witness {}, collection, metadata_bag);
    }

    /// Add template to `MetadataBagDomain`
    ///
    /// Later register `MetadataBagDomain` with `Collection` using
    /// `add_metadata_domain`.
    public entry fun mint_nft_template(
        name: String,
        description: String,
        url: vector<u8>,
        mint_cap: &MintCap<FOOTBYTES>,
        supply: Option<u64>,
        metadata_bag: &mut MetadataBagDomain<FOOTBYTES>,
        ctx: &mut TxContext,
    ) {
        let url = url::new_unsafe_from_bytes(url);

        let nft = nft::from_mint_cap(mint_cap, name, url, ctx);

        display::add_display_domain(
            &Witness {}, &mut nft, name, description,
        );

        display::add_url_domain(&Witness {}, &mut nft, url);

        let metadata = if (option::is_none(&supply)) {
            metadata::new_regulated(nft, option::destroy_some(supply), ctx)
        } else {
            metadata::new_unregulated(nft, ctx)
        };

        metadata_bag::add_metadata(mint_cap, metadata_bag, metadata);
    }
}
