module nft_protocol::suimarines {
    use nft_protocol::collection::{Self, Collection, MintAuthority};
    use nft_protocol::fixed_price::{Self, FixedPriceMarket};
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::slingshot::Slingshot;
    use nft_protocol::std_collection;
    use nft_protocol::unique_nft;
    use std::vector;
    use sui::balance;
    use sui::coin;
    use sui::transfer::transfer;
    use sui::tx_context::{Self, TxContext};

    /// One time witness is only instantiated in the init method
    struct SUIMARINES has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: SUIMARINES, ctx: &mut TxContext) {
        let receiver = @0xA;

        let tags: vector<vector<u8>> = vector::empty();
        vector::push_back(&mut tags, b"Art");

        let collection_id = std_collection::mint<SUIMARINES>(
            b"Suimarines",
            b"A Unique NFT collection of Submarines on Sui",
            b"SUIM", // symbol
            100, // max_supply
            receiver, // Royalty receiver
            tags,
            100, // royalty_fee_bps
            false, // is_mutable
            b"Some extra data",
            tx_context::sender(ctx), // mint authority
            ctx,
        );

        fixed_price::create_single_market(
            witness,
            tx_context::sender(ctx), // admin
            collection_id,
            receiver,
            true, // is_embedded
            false, // whitelist
            100, // price
            ctx,
        );
    }

    public entry fun mint_nft_data(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        mint_authority: &mut MintAuthority<SUIMARINES>,
        sale_index: u64,
        launchpad: &mut Slingshot<SUIMARINES, FixedPriceMarket>,
        ctx: &mut TxContext,
    ) {
        unique_nft::mint_regulated_nft_data(
            name,
            description,
            url,
            attribute_keys,
            attribute_values,
            mint_authority,
            ctx,
        );
    }

    public entry fun collect_royalty<FT>(
        payment: &mut TradePayment<Witness, FT>,
        collection: &Collection<SUIMARINES, std_collection::StdMeta>,
        ctx: &mut TxContext,
    ) {
        let b = royalties::balance_mut(Witness {}, payment);

        let amount = balance::value(b);
        let bps = std_collection::royalty(collection);
        // TODO: how do basis point work? what's the basis?
        // TODO: decimal precision
        let royalty = amount / 100 * bps;

        transfer(
            coin::take(b, royalty, ctx),
            collection::receiver(collection),
        );

        royalties::transfer_remaining_to_beneficiary(Witness {}, payment, ctx);
    }
}
