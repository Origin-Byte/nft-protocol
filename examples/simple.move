/// Implements a simple NFT collection contract
module nft_protocol::example_simple {
    use std::string::{Self, String};

    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::collection;
    use nft_protocol::display;
    use nft_protocol::url;
    use nft_protocol::mint_cap::MintCap;

    /// One time witness is only instantiated in the init method
    struct EXAMPLE_SIMPLE has drop {}

    /// Used for authorization of other protected actions.
    ///
    /// `Witness` must not be freely exposed to any contract.
    struct Witness has drop {}

    // === Contract functions ===

    /// Called during contract publishing
    fun init(witness: EXAMPLE_SIMPLE, ctx: &mut TxContext) {
        let (mint_cap, collection) = nft::new_collection(
            &witness, ctx
        );

        collection::add_domain(
            &Witness {},
            &mut collection,
            display::new_display_domain(
                string::utf8(b"Simple"),
                string::utf8(b"Simple collection on Sui"),
            )
        );

        nft_protocol::supply_domain::regulate(
            &Witness {},
            mint_cap,
            &mut collection,
            1000,
            true
        );

        // Request a `MintCap` that has the right to mint 1000 NFTs
        let mint_cap = nft_protocol::supply_domain::delegate(
            &mut collection, 1000, ctx,
        );

        transfer::public_transfer(mint_cap, tx_context::sender(ctx));
        transfer::public_share_object(collection);
    }

    /// Mint `Nft`
    public entry fun mint_nft(
        name: String,
        description: String,
        url: vector<u8>,
        _mint_cap: &MintCap<Nft<EXAMPLE_SIMPLE>>,
        ctx: &mut TxContext,
    ) {
        let url = sui::url::new_unsafe_from_bytes(url);

        let nft: Nft<EXAMPLE_SIMPLE> = nft::new(
            &Witness {}, name, url, ctx,
        );

        display::add_display_domain(
            &Witness {}, &mut nft, name, description,
        );

        url::add_url_domain(&Witness {}, &mut nft, url);

        transfer::public_transfer(nft, tx_context::sender(ctx));
    }
}
