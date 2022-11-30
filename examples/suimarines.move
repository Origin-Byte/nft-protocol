module nft_protocol::suimarines {
    use std::vector;

    use sui::balance;
    use sui::coin;
    use sui::transfer::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::collection::{Self, Collection, MintAuthority};
    use nft_protocol::fixed_price;
    use nft_protocol::generic;
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::launchpad::{Self, Launchpad, Trebuchet};


    /// One time witness is only instantiated in the init method
    struct SUIMARINES has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: SUIMARINES, ctx: &mut TxContext) {
        let tags: vector<vector<u8>> = vector::empty();
        vector::push_back(&mut tags, b"Art");

        let collection_id = collection::mint<SUIMARINES>(
            b"Suimarines",
            b"A Unique NFT collection of Suimarines on Sui",
            b"SUIM", // symbol
            100, // max supply
            @0x6c86ac4a796204ea09a87b6130db0c38263c1890, // royalty receiver
            tags,
            100, // royalty fee bps
            false, // is mutable
            tx_context::sender(ctx), // mint authority,
            ctx,
        );

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
        payment: &mut TradePayment<SUIMARINES, Witness, FT>,
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
        trebuchet: &mut Trebuchet,
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
}
