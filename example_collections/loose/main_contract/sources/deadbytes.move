module loose::deadbytes {
    use std::string::{utf8, String};
    use std::option;

    use sui::object::UID;
    use sui::transfer;
    use sui::display;
    use sui::package::{Self, Publisher};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::collection;

    /// One time witness is only instantiated in the init method
    struct DEADBYTES has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    #[allow(unused_field)]
    struct DeadByte has key, store {
        id: UID,
    }

    #[allow(unused_field)]
    struct Gun<phantom T> has key, store {
        id: UID,
    }

    #[lint_allow(share_owned)]
    fun init(otw: DEADBYTES, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);

        // Init Collection & MintCap with unlimited supply
        let (collection, mint_cap) = collection::create_with_mint_cap<DEADBYTES, DeadByte>(
            &otw, option::none(), ctx
        );

        // Init Publisher
        let publisher = package::claim<DEADBYTES>(otw, ctx);

        transfer::public_transfer(mint_cap, sender);
        transfer::public_transfer(publisher, sender);
        transfer::public_share_object(collection);
    }

    #[lint_allow(self_transfer)]
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
