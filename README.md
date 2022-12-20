- Sui v0.19.0

# Install

This codebase requires installation of the [Sui CLI](https://docs.sui.io/build/install).

# Built and Test

1. `$ sui move build` to build the available move modules
2. `$ sui move test` to run the move tests
3. `./bin/publish.sh` to publish the modules on localnet or devnet

# Deploy an NFT collection

To deploy an NFT collection you will need to create a SUI [Move](https://docs.sui.io/build/move) contract, which plugs into our protocol.

We provide an example on how to build such collection in the examples folder. Additionally below follows an example of an NFT Collection, the SUIMARINES!

```move
module nft_protocol::suimarines {
    use std::string;

    use sui::balance;
    use sui::object::ID;
    use sui::transfer::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft;
    use nft_protocol::tags;
    use nft_protocol::royalty;
    use nft_protocol::display;
    use nft_protocol::attribution;
    use nft_protocol::slot::{Self, Slot};
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::collection::{Self, Collection, MintCap};

    /// One time witness is only instantiated in the init method
    struct SUIMARINES has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: SUIMARINES, ctx: &mut TxContext) {
        let (mint_cap, collection) = collection::create<SUIMARINES>(
            &witness,
            100, // max supply
            ctx,
        );

        collection::add_domain(
            &mut collection,
            &mut mint_cap,
            attribution::from_address(tx_context::sender(ctx))
        );

        // Register custom domains
        display::add_collection_display_domain(
            &mut collection,
            &mut mint_cap,
            string::utf8(b"Suimarines"),
            string::utf8(b"A unique NFT collection of Suimarines on Sui"),
        );

        display::add_collection_url_domain(
            &mut collection,
            &mut mint_cap,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        display::add_collection_symbol_domain(
            &mut collection,
            &mut mint_cap,
            string::utf8(b"SUIM")
        );

        let royalty = royalty::new(ctx);
        royalty::add_proportional_royalty(
            &mut royalty,
            nft_protocol::royalty_strategy_bps::new(100),
        );
        royalty::add_royalty_domain(&mut collection, &mut mint_cap, royalty);

        let tags = tags::empty(ctx);
        tags::add_tag(&mut tags, tags::art());
        tags::add_collection_tag_domain(&mut collection, &mut mint_cap, tags);

        transfer(mint_cap, tx_context::sender(ctx));
        collection::share<SUIMARINES>(collection);
    }

    public entry fun collect_royalty<FT>(
        payment: &mut TradePayment<SUIMARINES, FT>,
        collection: &mut Collection<SUIMARINES>,
        ctx: &mut TxContext,
    ) {
        let b = royalties::balance_mut(Witness {}, payment);

        let domain = royalty::royalty_domain(collection);
        let royalty_owed =
            royalty::calculate_proportional_royalty(domain, balance::value(b));

        royalty::collect_royalty(collection, b, royalty_owed);
        royalties::transfer_remaining_to_beneficiary(Witness {}, payment, ctx);
    }

    public entry fun mint_nft(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        mint_cap: &mut MintCap<SUIMARINES>,
        slot: &mut Slot,
        market_id: ID,
        ctx: &mut TxContext,
    ) {
        let nft = nft::new<SUIMARINES>(tx_context::sender(ctx), ctx);

        collection::increment_supply(mint_cap, 1);

        display::add_display_domain(
            &mut nft,
            string::utf8(name),
            string::utf8(description),
            ctx,
        );

        slot::add_nft(slot, market_id, nft, ctx);
    }
}
```

and in your `Move.toml`, define the following dependency:

```toml
[dependencies.NftProtocol]
git = "https://github.com/Origin-Byte/nft-protocol.git"
# v1.0.0
rev = "c37e1bd800a52e450421e9c881e6e676da3e98ed"
```
