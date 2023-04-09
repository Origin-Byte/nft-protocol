module nft_protocol::yoots {
    use std::string::{Self, String};

    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};

    use nft_protocol::mint_event;
    use nft_protocol::mint_cap;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::display_info;
    use nft_protocol::mint_cap::{MintCap};
    use nft_protocol::warehouse::{Self, Warehouse};
    use nft_protocol::composable_nft::{Self as c_nft};
    use nft_protocol::witness;

    use nft_protocol::yoots_background::{Self, Background};
    use nft_protocol::yoots_clothes::{Self, Clothes};
    use nft_protocol::yoots_eyewear::{Self, Eyewear};
    use nft_protocol::yoots_face::{Self, Face};
    use nft_protocol::yoots_fur::{Self, Fur};
    use nft_protocol::yoots_head::{Self, Head};

    /// One time witness is only instantiated in the init method
    struct YOOTS has drop {}

    struct Yoot has key, store {
        id: UID,
        background: Background,
        clothes: Clothes,
        eyewear: Eyewear,
        face: Face,
        fur: Fur,
        head: Head,
    }

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(otw: YOOTS, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        // Get the Delegated Witness
        let dw = witness::from_witness(Witness {});

        // Init Collection
        let collection: Collection<YOOTS> = collection::create(dw, ctx);

        let collection_id = object::id(&collection);

        // Init MintCap
        // Creates a regulated mint cap for Avatar
        let mint_cap_1 = mint_cap::new_limited<YOOTS, Background>(
            &otw, collection_id, 10_000, ctx,
        );
        // Creates unregulated mint cap for the rest
        let mint_cap_2 = mint_cap::new_limited<YOOTS, Clothes>(
            &otw, collection_id, 10_000, ctx,
        );
        let mint_cap_3 = mint_cap::new_limited<YOOTS, Eyewear>(
            &otw, collection_id, 10_000, ctx,
        );
        let mint_cap_4 = mint_cap::new_limited<YOOTS, Face>(
            &otw, collection_id, 10_000, ctx,
        );
        let mint_cap_5 = mint_cap::new_limited<YOOTS, Fur>(
            &otw, collection_id, 10_000, ctx,
        );
        let mint_cap_6 = mint_cap::new_limited<YOOTS, Head>(
            &otw, collection_id, 10_000, ctx,
        );

        // Init Publisher
        let publisher = sui::package::claim(otw, ctx);

        // Add name and description to Collection
        collection::add_domain(
            dw,
            &mut collection,
            display_info::new(
                string::utf8(b"SuiYoots"),
                string::utf8(b"A composable NFT collection on Sui"),
            ),
        );

        // === Avatar composability ===

        let blueprint = c_nft::new_composition<Yoot>();
        c_nft::add_relationship<Yoot, Background>(&mut blueprint, 1);
        c_nft::add_relationship<Yoot, Clothes>(&mut blueprint, 1);
        c_nft::add_relationship<Yoot, Eyewear>(&mut blueprint, 1);
        c_nft::add_relationship<Yoot, Face>(&mut blueprint, 1);
        c_nft::add_relationship<Yoot, Fur>(&mut blueprint, 1);
        c_nft::add_relationship<Yoot, Head>(&mut blueprint, 1);

        collection::add_domain(dw, &mut collection, blueprint);

        transfer::public_transfer(mint_cap_1, sender);
        transfer::public_transfer(mint_cap_2, sender);
        transfer::public_transfer(mint_cap_3, sender);
        transfer::public_transfer(mint_cap_4, sender);
        transfer::public_transfer(mint_cap_5, sender);
        transfer::public_transfer(mint_cap_6, sender);
        transfer::public_transfer(publisher, sender);
        transfer::public_share_object(collection);
    }

    public entry fun mint_yoot(
        background: String,
        clothes: String,
        eyewear: String,
        face: String,
        fur: String,
        head: String,
        mint_cap: &mut MintCap<Yoot>,
        warehouse: &mut Warehouse<Yoot>,
        ctx: &mut TxContext,
    ) {
        let nft = Yoot {
            id: object::new(ctx),
            background: yoots_background::mint_background_(background, ctx),
            clothes: yoots_clothes::mint_clothes_(clothes, ctx),
            eyewear: yoots_eyewear::mint_eyewear_(eyewear, ctx),
            face: yoots_face::mint_face_(face, ctx),
            fur: yoots_fur::mint_fur_(fur, ctx),
            head: yoots_head::mint_head_(head, ctx),
        };

        mint_event::mint_limited(mint_cap, &nft);
        warehouse::deposit_nft(warehouse, nft);
    }

    #[test_only]
    use sui::test_scenario::{Self, ctx};
    #[test_only]
    const USER: address = @0xA1C04;

    #[test]
    fun it_inits_collection() {
        let scenario = test_scenario::begin(USER);
        init(YOOTS {}, ctx(&mut scenario));

        test_scenario::end(scenario);
    }
}
