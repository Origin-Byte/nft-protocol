module nft_protocol::sui_gods {
    use std::ascii;
    use std::vector;
    use std::string::{Self, String};

    use sui::balance;
    use sui::object::UID;
    use nft_protocol::package::{Self, Publisher};
    use nft_protocol::display;
    use sui::table_vec::TableVec;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft;
    use nft_protocol::url;
    use nft_protocol::tags;
    use nft_protocol::royalty;
    use nft_protocol::display_domain;
    use nft_protocol::witness;
    use nft_protocol::creators;
    use nft_protocol::attributes;
    use nft_protocol::warehouse::{Self, Warehouse};
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::mint_cap::{Self, MintCap};

    /// One time witness is only instantiated in the init method
    struct DEADBYTES has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

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
            string::utf8(b"Suitraders"),
            string::utf8(b"A unique NFT collection of Suitraders on Sui"),
        );

        url::add_collection_url_domain(
            &Witness {},
            &mut collection,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        display_domain::add_collection_symbol_domain(
            &Witness {},
            &mut collection,
            string::utf8(b"SUITR"),
        );

        let royalty = royalty::from_address(tx_context::sender(ctx), ctx);
        royalty::add_proportional_royalty(&mut royalty, 100);
        royalty::add_royalty_domain(
            &Witness {},
            &mut collection,
            royalty,
        );

        let tags = tags::empty(ctx);
        tags::add_tag(&mut tags, tags::art());
        tags::add_collection_tag_domain(
            &Witness {},
            &mut collection,
            tags,
        );

        let publisher = package::claim<DEADBYTES>(DEADBYTES {}, ctx);

        transfer::transfer(mint_cap, tx_context::sender(ctx));
        transfer::transfer(publisher, tx_context::sender(ctx));
        transfer::share_object(collection);
    }


    struct Gun<phantom T> has key, store {
        id: UID,
    }

    struct Ar15 has drop {}
    struct Mp40 has drop {}
    struct DesertEagle has drop {}
    struct Colt has drop {}

    // GunDisplay<T> {
    //     name: ,
    //     accuracy: ,
    //     recoil: ,
    // }

    // GunDisplayAr15 {
    //     name: "AR15",
    //     accuracy: 75,
    //     recoil: 15,
    // }

    // GunDisplayAr15 {
    //     name: "AR15",
    //     accuracy: 75,
    //     recoil: 15,
    // }

    public fun mint_gun_metadata<T>(
        publisher: &Publisher,
        name: String,
        accuracy: String,
        recoil: String,
    ) {
        let fields = vector[
            utf8(b"name"),
            utf8(b"accuracy"),
            utf8(b"recoil"),
        ];

        create_display();
        activate_display();
    }
}
