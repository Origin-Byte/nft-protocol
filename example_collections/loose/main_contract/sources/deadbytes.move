module loose::deadbytes {
    use std::string::{utf8, String};
    use std::option;

    use sui::object::UID;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::package::{Self, Publisher};
    use nft_protocol::display;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::witness;
    use nft_protocol::mint_cap::{Self};


    /// One time witness is only instantiated in the init method
    struct DEADBYTES has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    struct DeadByte has key, store {
        id: UID,
    }

    struct Gun<phantom T> has key, store {
        id: UID,
    }

    fun init(otw: DEADBYTES, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);

        // Get the Delegated Witness
        let dw = witness::from_witness(Witness {});

        // Init Collection
        let collection: Collection<DEADBYTES> =
            collection::create(dw, ctx);

        // Init MintCap with unlimited supply
        let mint_cap = mint_cap::new<DEADBYTES, DeadByte>(
            dw, &collection, option::none(), ctx,
        );

        let publisher = package::claim<DEADBYTES>(otw, ctx);

        transfer::public_transfer(mint_cap, sender);
        transfer::public_transfer(publisher, sender);
        transfer::public_share_object(collection);
    }

    // public fun mint_metadata<T: key> (
    //     pub: &Publisher,
    //     json: String,
    // ) {

    // }

    public fun mint_gun_metadata<T: key>(
        pub: &Publisher,
        name: String,
        accuracy: String,
        recoil: String,
        ctx: &mut TxContext,
    ) {
        assert!(package::from_package<T>(pub), 0);

        let fields = vector[utf8(b"name"), utf8(b"accuracy"), utf8(b"recoil")];
        let values = vector[name, accuracy, recoil];

        // Get a new `Display` object for the `T` type.
        let display = display::new_with_fields<T>(
            pub, fields, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display);

        // TODO: should this be owned or shared?
        transfer::public_transfer(display, tx_context::sender(ctx));
    }

    #[test_only]
    use sui::test_scenario::{Self, ctx};
    #[test_only]
    const CREATOR: address = @0xA1C04;

    #[test]
    fun it_inits_collection() {
        let scenario = test_scenario::begin(CREATOR);
        init(DEADBYTES {}, ctx(&mut scenario));

        test_scenario::end(scenario);
    }
}
