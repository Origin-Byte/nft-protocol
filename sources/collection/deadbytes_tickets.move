module nft_protocol::deadbytes_tickets {
    use std::string::{Self, String};

    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft;
    use nft_protocol::gaming;
    use nft_protocol::creators;
    use nft_protocol::inventory::{Self, Inventory};
    use nft_protocol::collection::{Self, MintCap};

    /// One time witness is only instantiated in the init method
    struct DEADBYTES_TICKETS has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: DEADBYTES_TICKETS, ctx: &mut TxContext) {
        let (mint_cap, collection) = collection::create(
            &witness, ctx,
        );

        collection::add_domain(
            &mut collection,
            &mut mint_cap,
            creators::from_address(tx_context::sender(ctx))
        );

        // Register custom domains
        gaming::add_collection_match_invite_domain(
            &mut collection,
            &mut mint_cap,
            string::utf8(b"DummyMatchId"),
        );

        transfer::transfer(mint_cap, tx_context::sender(ctx));
        transfer::share_object(collection);
    }

    public entry fun mint_nft(
        matchId: String,
        _attribute_keys: vector<String>,
        _attribute_values: vector<String>,
        _mint_cap: &MintCap<DEADBYTES_TICKETS>,
        inventory: &mut Inventory,
        ctx: &mut TxContext,
    ) {
        let nft = nft::new<DEADBYTES_TICKETS, Witness>(
            &Witness {}, tx_context::sender(ctx), ctx
        );

        gaming::add_match_invite_domain(
            &mut nft,
            matchId,
            ctx,
        );

        inventory::deposit_nft(inventory, nft);
    }

    public entry fun airdrop(
        matchId: String,
        _mint_cap: &MintCap<DEADBYTES_TICKETS>,
        receiver: address,
        ctx: &mut TxContext,
    ) {
        let nft = nft::new<DEADBYTES_TICKETS, Witness>(
            &Witness {}, tx_context::sender(ctx), ctx
        );

        gaming::add_match_invite_domain(
            &mut nft,
            matchId,
            ctx,
        );

        transfer::transfer(nft, receiver);
    }
}