module nft_protocol::suimarines {
    use std::vector;
    use std::string;

    use sui::balance;
    use sui::coin;
    use sui::transfer::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft;
    use nft_protocol::outlet::{Self, NftCertificate};
    use nft_protocol::collection::{Self, Collection, MintAuthority};
    use nft_protocol::fixed_price;
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::launchpad::{Self, Launchpad, Slot};

    use nft_protocol::display;

    /// One time witness is only instantiated in the init method
    struct SUIMARINES has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: SUIMARINES, ctx: &mut TxContext) {
        let tags: vector<vector<u8>> = vector::empty();
        vector::push_back(&mut tags, b"Art");

        let collection = collection::create<SUIMARINES>(
            b"SUIM", // symbol
            100, // max supply
            @0x6c86ac4a796204ea09a87b6130db0c38263c1890, // royalty receiver
            tags,
            100, // royalty fee bps
            false, // is mutable
            tx_context::sender(ctx), // mint authority
            ctx,
        );

        // Register custom domains
        display::add_collection_display_domain(
            &mut collection,
            string::utf8(b"Suimarines"),
            string::utf8(b"A unique NFT collection of Suimarines on Sui"),
        );

        display::add_collection_url_domain(
            &mut collection,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        let collection_id = collection::share<SUIMARINES>(collection);

        let whitelist = vector::empty();
        vector::push_back(&mut whitelist, true);
        vector::push_back(&mut whitelist, false);

        let prices = vector::empty();
        vector::push_back(&mut prices, 1000);
        vector::push_back(&mut prices, 2000);

        let admin = @0x6c86ac4a796204ea09a87b6430db0c38263c1890;

        let collections = vector::singleton(collection_id);
    }

    public entry fun collect_royalty<FT>(
        payment: &mut TradePayment<SUIMARINES, FT>,
        collection: &Collection<SUIMARINES>,
        ctx: &mut TxContext,
    ) {
        let b = royalties::balance_mut(Witness {}, payment);

        let amount = balance::value(b);
        let bps = collection::royalty(collection);
        // TODO: how do basis point work? what's the basis?
        // TODO: decimal precision
        let royalty = amount / 100 * bps;

        transfer(
            coin::take(b, royalty, ctx),
            collection::receiver(collection),
        );

        royalties::transfer_remaining_to_beneficiary(Witness {}, payment, ctx);
    }

    public entry fun mint_nft(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        mint_authority: &mut MintAuthority<SUIMARINES>,
        sale_index: u64,
        launchpad: &mut Launchpad,
        slot: &mut Slot,
        ctx: &mut TxContext,
    ) {
        unique_nft::mint_regulated_nft(
            name,
            description,
            url,
            attribute_keys,
            attribute_values,
            mint_authority,
            sale_index,
            launchpad,
            ctx,
        );
    }

    public entry fun redeem_certificate(
        certificate: NftCertificate,
        ctx: &mut TxContext
    ) {
        // TODO: Check whether NftCertificate is issued for this collection
        // Pending on Launchpad refactor completion
        outlet::burn_certificate(certificate);

        let nft = nft::new<SUIMARINES>(ctx);

        display::add_display_domain(
            &mut nft,
            string::utf8(b"Suimarine"),
            string::utf8(b"A Unique NFT collection of Suimarines on Sui"),
            ctx,
        );

        transfer(nft, tx_context::sender(ctx));
    }
}
