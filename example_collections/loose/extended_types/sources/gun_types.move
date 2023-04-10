module gun_extensions::gun_types {
    use std::string::{Self, utf8, String};
    use std::option;

    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::package::{Self, Publisher};
    use nft_protocol::display;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::creators;
    use nft_protocol::witness;
    use nft_protocol::mint_cap::{Self, MintCap};

    struct Ar15 has drop {}
    struct Mp40 has drop {}
    struct DesertEagle has drop {}
    struct Colt has drop {}

    /// One time witness is only instantiated in the init method
    struct DEADBYTES_GUNS has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(otw: DEADBYTES_GUNS, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);

        // Get the Delegated Witness
        let dw = witness::from_witness(Witness {});

        // Extend the collection

        // Init Collection
        let collection: Collection<DEADBYTES> =
            collection::create(dw, ctx);

        // Init MintCap with unlimited supply
        let mint_cap = mint_cap::new<DEADBYTES, DeadByte>(
            &otw, object::id(&collection), option::none(), ctx,
        );

        let publisher = package::claim<DEADBYTES>(otw, ctx);

        transfer::transfer(mint_cap, sender);
        transfer::transfer(publisher, sender);
        transfer::share_object(collection);
    }
}
