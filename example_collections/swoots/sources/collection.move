module swoots::swoots {
    use std::string::{Self, String};
    use std::option;

    use sui::transfer;
    use sui::display;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};

    use nft_protocol::mint_cap;
    use nft_protocol::mint_event;
    use nft_protocol::collection;
    use ob_utils::display_info;
    use nft_protocol::mint_cap::{MintCap};
    use nft_protocol::composable_nft::{Self as c_nft};
    use ob_witness::witness;

    use ob_launchpad::warehouse::{Self, Warehouse};

    use swoots::background::{Self, Background};
    use swoots::clothes::{Self, Clothes};
    use swoots::eyewear::{Self, Eyewear};
    use swoots::face::{Self, Face};
    use swoots::fur::{Self, Fur};
    use swoots::head::{Self, Head};

    /// One time witness is only instantiated in the init method
    struct SWOOTS has drop {}

    struct Swoot has key, store {
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

    fun init(otw: SWOOTS, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);

        // Init Collection & MintCap with limited 10_000 supply
        let (collection, mint_cap) = collection::create_with_mint_cap<SWOOTS, Swoot>(
            &otw, option::some(10_000), ctx
        );

        // Init Publisher
        let publisher = sui::package::claim(otw, ctx);

        // Init Display
        let display = display::new<Swoot>(&publisher, ctx);
        display::add(&mut display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::update_version(&mut display);
        transfer::public_transfer(display, tx_context::sender(ctx));

        // Get the Delegated Witness
        let dw = witness::from_witness(Witness {});

        // Add name and description to Collection
        collection::add_domain(
            dw,
            &mut collection,
            display_info::new(
                string::utf8(b"Swoot"),
                string::utf8(b"A composable NFT collection on Sui"),
            ),
        );

        // === Avatar composability ===

        let blueprint = c_nft::new_composition<Swoot>();
        c_nft::add_relationship<Swoot, Background>(&mut blueprint, 1);
        c_nft::add_relationship<Swoot, Clothes>(&mut blueprint, 1);
        c_nft::add_relationship<Swoot, Eyewear>(&mut blueprint, 1);
        c_nft::add_relationship<Swoot, Face>(&mut blueprint, 1);
        c_nft::add_relationship<Swoot, Fur>(&mut blueprint, 1);
        c_nft::add_relationship<Swoot, Head>(&mut blueprint, 1);

        collection::add_domain(dw, &mut collection, blueprint);

        transfer::public_transfer(mint_cap, sender);
        transfer::public_transfer(publisher, sender);
        transfer::public_share_object(collection);
    }

    public entry fun mint_swoot(
        background: String,
        clothes: String,
        eyewear: String,
        face: String,
        fur: String,
        head: String,
        mint_cap: &mut MintCap<Swoot>,
        warehouse: &mut Warehouse<Swoot>,
        ctx: &mut TxContext,
    ) {
        let nft = Swoot {
            id: object::new(ctx),
            background: background::mint_background_(background, ctx),
            clothes: clothes::mint_clothes_(clothes, ctx),
            eyewear: eyewear::mint_eyewear_(eyewear, ctx),
            face: face::mint_face_(face, ctx),
            fur: fur::mint_fur_(fur, ctx),
            head: head::mint_head_(head, ctx),
        };

        mint_cap::increment_supply(mint_cap, 1);
        mint_event::emit_mint(
            witness::from_witness(Witness {}),
            mint_cap::collection_id(mint_cap),
            &nft,
        );

        warehouse::deposit_nft(warehouse, nft);
    }

    #[test_only]
    use sui::test_scenario::{Self, ctx};
    #[test_only]
    const USER: address = @0xA1C04;

    #[test]
    fun it_inits_collection() {
        let scenario = test_scenario::begin(USER);
        init(SWOOTS {}, ctx(&mut scenario));

        test_scenario::end(scenario);
    }
}
