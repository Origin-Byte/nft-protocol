module nft_protocol::suimarines {
    use std::vector;
    use std::string;

    use sui::balance;
    use sui::coin;
    use sui::transfer::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url;

    use nft_protocol::nft::{Self, NFT};
    use nft_protocol::domains;
    use nft_protocol::sale::{Self, NftCertificate};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::fixed_price;
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::std_collection;

    /// Modules can define their own domains and define the API through which
    /// they are accessible.
    ///
    /// Only the current module can define mutable API on the domain.
    struct SuimarineDomain has store {
        experience: u64
    }

    /// One time witness is only instantiated in the init method
    struct SUIMARINES has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: SUIMARINES, ctx: &mut TxContext) {
        let tags: vector<vector<u8>> = vector::empty();
        vector::push_back(&mut tags, b"Art");

        let collection_id = std_collection::mint<SUIMARINES>(
            b"Suimarines",
            b"A Unique NFT collection of Suimarines on Sui",
            b"SUIM", // symbol
            100, // max_supply
            @0x6c86ac4a796204ea09a87b6130db0c38263c1890, // Royalty receiver
            tags, // tags
            100, // royalty_fee_bps
            false, // is_mutable
            b"Some extra data",
            tx_context::sender(ctx), // mint authority
            ctx,
        );

        let whitelist = vector::empty();
        vector::push_back(&mut whitelist, true);
        vector::push_back(&mut whitelist, false);

        let prices = vector::empty();
        vector::push_back(&mut prices, 1000);
        vector::push_back(&mut prices, 2000);

        fixed_price::create_market(
            witness,
            tx_context::sender(ctx), // admin
            collection_id,
            @0x6c86ac4a796204ea09a87b6130db0c38263c1890,
            true, // is_embedded
            whitelist, prices,
            ctx,
        );
    }

    public entry fun redeem_certificate(
        certificate: NftCertificate,
        ctx: &mut TxContext
    ): NFT<SUIMARINES> {
        // TODO: Check whether NftCertificate is issued for this collection
        // Pending on Launchpad refactor completion
        sale::burn_certificate(certificate);

        let display = domains::display_new(
            string::utf8(b"Suimarine"),
            string::utf8(b"A Unique NFT collection of Suimarines on Sui"),
            url::new_unsafe_from_bytes(b"OriginByte.io")
        );

        let suimarine = SuimarineDomain {
            experience: 0,
        };

        let nft = nft::new<SUIMARINES>(ctx);
        // Suimarines now support the display standard
        nft::add_domain(&mut nft, display);
        nft::add_domain(&mut nft, suimarine);

        nft
    }

    public entry fun collect_royalty<FT>(
        payment: &mut TradePayment<SUIMARINES, Witness, FT>,
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
