module nft_protocol::obiwan {
    use std::string::{Self, String};

    use sui::url;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft;
    use nft_protocol::display;
    use nft_protocol::witness;
    use nft_protocol::creators;
    use nft_protocol::collection;

    /// One time witness is only instantiated in the init method
    struct OBIWAN has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: OBIWAN, ctx: &mut TxContext) {
        let (mint_cap, collection) = collection::create(&witness, ctx);
        let delegated_witness = witness::from_witness(&Witness {});

        collection::add_domain(
            delegated_witness,
            &mut collection,
            creators::from_address<OBIWAN, Witness>(
                &Witness {}, tx_context::sender(ctx), ctx,
            ),
        );

        // Register custom domains
        display::add_collection_display_domain(
            delegated_witness,
            &mut collection,
            string::utf8(b"Obiwan"),
            string::utf8(b"He's our only hope!"),
            ctx,
        );

        mint_nft(
            string::utf8(b"Leia"),
            string::utf8(b"Obiwan you're my only hope!"),
            b"https://nuno-bucket-1.s3.amazonaws.com/suimarines/images/1.png",
            ctx,
        );

        transfer::transfer(mint_cap, tx_context::sender(ctx));
        transfer::share_object(collection);
    }

    public entry fun mint_nft(
        name: String,
        description: String,
        url: vector<u8>,
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        let nft = nft::new(&Witness {}, sender, ctx);
        let delegated_witness = witness::from_witness<OBIWAN, Witness>(&Witness {});

        display::add_display_domain(
            delegated_witness, &mut nft, name, description, ctx,
        );

        display::add_url_domain(
            delegated_witness, &mut nft, url::new_unsafe_from_bytes(url), ctx,
        );

        transfer::transfer(nft, sender);
    }
}
