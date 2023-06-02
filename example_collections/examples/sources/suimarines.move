module examples::suimarines {
    use std::string::{Self, String};
    use std::option;
    use sui::display;

    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use ob_utils::utils;
    use nft_protocol::tags;
    use nft_protocol::mint_event;
    use nft_protocol::royalty;
    use nft_protocol::creators;
    use nft_protocol::transfer_allowlist;
    use nft_protocol::p2p_list;
    use ob_utils::display as ob_display;
    use nft_protocol::collection;
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::royalty_strategy_bps;
    use ob_permissions::witness;

    use ob_request::transfer_request;
    use ob_request::borrow_request::{Self, BorrowRequest, ReturnPromise};
    use ob_launchpad::warehouse::{Self, Warehouse};

    const EWRONG_DESCRIPTION_LENGTH: u64 = 1;
    const EWRONG_URL_LENGTH: u64 = 2;
    const EWRONG_ATTRIBUTE_KEYS_LENGTH: u64 = 3;
    const EWRONG_ATTRIBUTE_VALUES_LENGTH: u64 = 4;

    struct Submarine has key, store {
        id: UID,
        name: String,
        index: u64,
    }

    /// One time witness is only instantiated in the init method
    struct SUIMARINES has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(otw: SUIMARINES, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);

        // 1. Init Collection & MintCap with unlimited supply
        let (collection, mint_cap) = collection::create_with_mint_cap<SUIMARINES, Submarine>(
            &otw, option::none(), ctx
        );

        // 2. Init Publisher & Delegated Witness
        let publisher = sui::package::claim(otw, ctx);
        let dw = witness::from_witness(Witness {});

        // === NFT DISPLAY ===

        // 3. Init Display
        let tags = vector[tags::art(), tags::collectible()];

        let display = display::new<Submarine>(&publisher, ctx);
        display::add(&mut display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::add(&mut display, string::utf8(b"tags"), ob_display::from_vec(tags));
        display::add(&mut display, string::utf8(b"collection_id"), ob_display::id_to_string(&object::id(&collection)));
        display::update_version(&mut display);
        transfer::public_transfer(display, tx_context::sender(ctx));

        // === COLLECTION DOMAINS ===

        // 4. Add Creator metadata to the collection

        // Insert Creator addresses here
        let creators = vector[
            @0xA01, @0xA05, @0xA06, @0xA07, @0x08
        ];

        collection::add_domain(
            dw,
            &mut collection,
            creators::new(utils::vec_set_from_vec(&creators)),
        );

        // 5. Setup royalty basis points
        // 2_000 BPS == 20%
        let shares = vector[2_000, 2_000, 2_000, 2_000, 2_000];
        let shares = utils::from_vec_to_map(creators, shares);

        royalty_strategy_bps::create_domain_and_add_strategy(
            dw, &mut collection, royalty::from_shares(shares, ctx), 100, ctx,
        );

        // === TRANSFER POLICIES ===

        // 6. Creates a new policy and registers an allowlist rule to it.
        // Therefore now to finish a transfer, the allowlist must be included
        // in the chain.
        let (transfer_policy, transfer_policy_cap) =
            transfer_request::init_policy<Submarine>(&publisher, ctx);

        royalty_strategy_bps::enforce(&mut transfer_policy, &transfer_policy_cap);
        transfer_allowlist::enforce(&mut transfer_policy, &transfer_policy_cap);

        // 7. P2P Transfers are a separate transfer workflow and therefore require a
        // separate policy
        let (p2p_policy, p2p_policy_cap) =
            transfer_request::init_policy<Submarine>(&publisher, ctx);

        p2p_list::enforce(&mut p2p_policy, &p2p_policy_cap);

        // === CLOSE ===

        transfer::public_transfer(mint_cap, sender);
        transfer::public_transfer(publisher, sender);
        transfer::public_transfer(transfer_policy_cap, sender);
        transfer::public_transfer(p2p_policy_cap, sender);
        transfer::public_share_object(collection);
        transfer::public_share_object(transfer_policy);
        transfer::public_share_object(p2p_policy);
    }

    public fun get_nft_field<Auth: drop, Field: store>(
        request: &mut BorrowRequest<Auth, Submarine>,
    ): (Field, ReturnPromise<Submarine, Field>) {
        let dw = witness::from_witness(Witness {});
        let nft = borrow_request::borrow_nft_ref_mut(dw, request);

        borrow_request::borrow_field(dw, &mut nft.id)
    }

    public fun return_nft_field<Auth: drop, Field: store>(
        request: &mut BorrowRequest<Auth, Submarine>,
        field: Field,
        promise: ReturnPromise<Submarine, Field>,
    ) {
        let dw = witness::from_witness(Witness {});
        let nft = borrow_request::borrow_nft_ref_mut(dw, request);

        borrow_request::return_field(dw, &mut nft.id, promise, field)
    }

    public fun get_nft<Auth: drop>(
        request: &mut BorrowRequest<Auth, Submarine>,
    ): Submarine {
        let dw = witness::from_witness(Witness {});
        borrow_request::borrow_nft(dw, request)
    }

    public fun return_nft<Auth: drop>(
        request: &mut BorrowRequest<Auth, Submarine>,
        nft: Submarine,
    ) {
        let dw = witness::from_witness(Witness {});
        borrow_request::return_nft(dw, request, nft);
    }

    public entry fun mint_nft(
        mint_cap: &MintCap<Submarine>,
        name: String,
        index: u64,
        warehouse: &mut Warehouse<Submarine>,
        ctx: &mut TxContext,
    ) {
        let nft = mint(
            name,
            index,
            ctx
        );

        mint_event::emit_mint(
            witness::from_witness(Witness {}),
            mint_cap::collection_id(mint_cap),
            &nft,
        );

        warehouse::deposit_nft(warehouse, nft);
    }


    fun mint(
        name: String,
        index: u64,
        ctx: &mut TxContext,
    ): Submarine {
        Submarine {
            id: object::new(ctx),
            name,
            index,
        }
    }

    #[test_only]
    use sui::test_scenario::{Self, ctx};
    #[test_only]
    const CREATOR: address = @0xA1C04;

    #[test]
    fun it_inits_collection() {
        let scenario = test_scenario::begin(CREATOR);
        init(SUIMARINES {}, ctx(&mut scenario));

        test_scenario::end(scenario);
    }
}
