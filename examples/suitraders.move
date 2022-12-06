module nft_protocol::suitraders {
    use std::string;

    use sui::balance;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer::transfer;

    use nft_protocol::nft;
    use nft_protocol::tags;
    use nft_protocol::royalty;
    use nft_protocol::display;
    use nft_protocol::attribution;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::inventory::{Self, NftCertificate};

    struct SUITRADERS has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: SUITRADERS, ctx: &mut TxContext) {
        let (mint_cap, collection) = collection::create<SUITRADERS>(
            &witness,
            100, // max supply
            ctx,
        );

        transfer(mint_cap, tx_context::sender(ctx));

        collection::add_domain(
            &mut collection,
            attribution::from_address(@0x6c86ac4a796204ea09a87b6130db0c38263c1890)
        );

        // Register custom domains
        display::add_collection_display_domain(
            &mut collection,
            string::utf8(b"Suitraders"),
            string::utf8(b"A unique NFT collection of Suitraders on Sui"),
        );

        display::add_collection_url_domain(
            &mut collection,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        display::add_collection_symbol_domain(
            &mut collection,
            string::utf8(b"SUITR")
        );

        let tags = tags::empty(ctx);
        tags::add_tag(&mut tags, tags::art());
        tags::add_collection_tag_domain(&mut collection, tags);

        collection::share<SUITRADERS>(collection);
    }

    public entry fun collect_royalty<FT>(
        payment: &mut TradePayment<SUITRADERS, FT>,
        collection: &mut Collection<SUITRADERS>,
        ctx: &mut TxContext,
    ) {
        let b = royalties::balance_mut(Witness {}, payment);

        let domain = royalty::royalty_domain_mut(collection);
        let royalty_owed =
            royalty::calculate_proportional_royalty(domain, balance::value(b));

        royalty::transfer_royalties(domain, b, royalty_owed);
        royalties::transfer_remaining_to_beneficiary(Witness {}, payment, ctx);
    }

    // TODO: Premint flow needs to be reconsidered
    // public entry fun mint_nft(
    //     name: vector<u8>,
    //     description: vector<u8>,
    //     url: vector<u8>,
    //     attribute_keys: vector<vector<u8>>,
    //     attribute_values: vector<vector<u8>>,
    //     mint_authority: &mut MintCap<SUIMARINES>,
    //     sale_index: u64,
    //     launchpad: &mut Launchpad,
    //     slot: &mut Slot,
    //     ctx: &mut TxContext,
    // ) {
    //     unique_nft::mint_regulated_nft(
    //         name,
    //         description,
    //         url,
    //         attribute_keys,
    //         attribute_values,
    //         mint_authority,
    //         sale_index,
    //         launchpad,
    //         ctx,
    //     );
    // }

    public entry fun redeem_certificate(
        certificate: NftCertificate,
        ctx: &mut TxContext
    ) {
        // TODO: Check whether NftCertificate is issued for this collection
        // Pending on Launchpad refactor completion
        inventory::burn_certificate(certificate);

        let nft = nft::new<SUITRADERS>(ctx);

        display::add_display_domain(
            &mut nft,
            string::utf8(b"Suimarine"),
            string::utf8(b"A Unique NFT collection of Suimarines on Sui"),
            ctx,
        );

        transfer(nft, tx_context::sender(ctx));
    }
}
