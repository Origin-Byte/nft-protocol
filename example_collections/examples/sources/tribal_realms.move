module examples::tribal_realms {
    use std::string::{Self, String};

    use sui::transfer;
    use sui::url::{Self, Url};
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};

    use nft_protocol::mint_cap;
    use nft_protocol::mint_event;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::display_info;
    use nft_protocol::mint_cap::{MintCap};
    use nft_protocol::composable_nft::{Self as c_nft};
    use ob_witness::witness;

    use launchpad::warehouse::{Self, Warehouse};

    /// One time witness is only instantiated in the init method
    struct TRIBAL_REALMS has drop {}

    struct Avatar has key, store {
        id: UID,
        name: String,
        url: Url,
        color: String,
        mood: String,
    }

    struct Hat has key, store {
        id: UID,
        type: String,
    }

    struct Glasses has key, store {
        id: UID,
        type: String
    }

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(otw: TRIBAL_REALMS, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);

        // Create Collection
        let dw = witness::from_witness(Witness {});
        let collection: Collection<TRIBAL_REALMS> = collection::create(dw, ctx);
        let collection_id = object::id(&collection);

        // Initialize per-type MintCaps
        let mint_cap_avatar: MintCap<Avatar> =
            mint_cap::new_limited(&otw, collection_id, 10_000, ctx);

        let mint_cap_hat: MintCap<Hat> =
            mint_cap::new_unlimited(&otw, collection_id, ctx);

        let mint_cap_glasses: MintCap<Glasses> =
            mint_cap::new_unlimited(&otw, collection_id, ctx);

        // Init Publisher
        let publisher = sui::package::claim(otw, ctx);

        // Add name and description to Collection
        collection::add_domain(
            dw,
            &mut collection,
            display_info::new(
                string::utf8(b"TribalRealms"),
                string::utf8(b"A composable NFT collection on Sui"),
            ),
        );

        // === Avatar composability ===

        let avatar_blueprint = c_nft::new_composition<Avatar>();
        c_nft::add_relationship<Avatar, Hat>(
            &mut avatar_blueprint, 1,
        );
        c_nft::add_relationship<Avatar, Glasses>(
            &mut avatar_blueprint, 1,
        );

        collection::add_domain(
            dw, &mut collection, avatar_blueprint,
        );

        transfer::public_transfer(mint_cap_avatar, sender);
        transfer::public_transfer(mint_cap_hat, sender);
        transfer::public_transfer(mint_cap_glasses, sender);
        transfer::public_transfer(publisher, sender);
        transfer::public_share_object(collection);
    }

    public entry fun mint_avatar(
        name: String,
        color: String,
        mood: String,
        url: vector<u8>,
        // Need to be mut because supply is capped at 10_000 Avatars
        mint_cap: &mut MintCap<Avatar>,
        warehouse: &mut Warehouse<Avatar>,
        ctx: &mut TxContext,
    ) {
        let nft = Avatar {
            id: object::new(ctx),
            name,
            url: url::new_unsafe_from_bytes(url),
            color,
            mood,
        };

        mint_cap::increment_supply(mint_cap, 1);
        mint_event::emit_mint(
            witness::from_witness(Witness {}),
            mint_cap::collection_id(mint_cap),
            &nft,
        );

        warehouse::deposit_nft(warehouse, nft);
    }

    public entry fun mint_hat(
        type: String,
        // Does not need to be mut because supply is unregulated
        mint_cap: &MintCap<Hat>,
        warehouse: &mut Warehouse<Hat>,
        ctx: &mut TxContext,
    ) {
        let nft = Hat {
            id: object::new(ctx),
            type,
        };

        mint_event::emit_mint(
            witness::from_witness(Witness {}),
            mint_cap::collection_id(mint_cap),
            &nft,
        );

        warehouse::deposit_nft(warehouse, nft);
    }

    public entry fun mint_glasses(
        type: String,
        // Does not need to be mut because supply is unregulated
        mint_cap: &MintCap<Glasses>,
        warehouse: &mut Warehouse<Glasses>,
        ctx: &mut TxContext,
    ) {
        let nft = Glasses {
            id: object::new(ctx),
            type,
        };

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
        init(TRIBAL_REALMS {}, ctx(&mut scenario));

        test_scenario::end(scenario);
    }
}
