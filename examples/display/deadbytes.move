module nft_protocol::deadbytes {
    use std::string::{Self, utf8, String};

    use sui::object::UID;
    use nft_protocol::package::{Self, Publisher};
    use nft_protocol::display;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};


    use nft_protocol::url;
    use nft_protocol::display_domain;

    use nft_protocol::creators;
    use nft_protocol::collection;

    /// One time witness is only instantiated in the init method
    struct DEADBYTES has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    struct Gun<phantom T> has key, store {
        id: UID,
    }

    fun init(witness: DEADBYTES, ctx: &mut TxContext) {
        let (mint_cap, collection) = collection::create(&witness, ctx);

        collection::add_domain(
            &Witness {},
            &mut collection,
            creators::from_address<DEADBYTES, Witness>(
                &Witness {}, tx_context::sender(ctx),
            ),
        );

        // Register custom domains
        display_domain::add_collection_display_domain(
            &Witness {},
            &mut collection,
            string::utf8(b"Deadbytes"),
            string::utf8(b"A unique NFT collection of Deadly 01s"),
        );

        url::add_collection_url_domain(
            &Witness {},
            &mut collection,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        display_domain::add_collection_symbol_domain(
            &Witness {},
            &mut collection,
            string::utf8(b"DEADB"),
        );

        let publisher = package::claim<DEADBYTES>(witness, ctx);

        transfer::transfer(mint_cap, tx_context::sender(ctx));
        transfer::transfer(publisher, tx_context::sender(ctx));
        transfer::share_object(collection);
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
        transfer::transfer(display, tx_context::sender(ctx));
    }
}
