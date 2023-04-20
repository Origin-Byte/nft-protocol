module examples::suimarines {
    use std::string::{Self, String};
    use std::option;
    use sui::display;

    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::tags;
    use nft_protocol::ob_transfer_request;
    use nft_protocol::transfer_allowlist;
    use nft_protocol::display as ob_display;
    use nft_protocol::collection;
    use nft_protocol::borrow_request::{Self, BorrowRequest, ReturnPromise};
    // use nft_protocol::mut_lock::{Self, MutLock, ReturnFieldPromise};
    use nft_protocol::mint_cap::MintCap;
    use nft_protocol::royalty_strategy_bps;
    use nft_protocol::witness;

    use launchpad::warehouse::{Self, Warehouse};

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

        // Init Collection & MintCap with unlimited supply
        let (collection, mint_cap) = collection::create_with_mint_cap<SUIMARINES, Submarine>(
            &otw, option::none(), ctx
        );

        // Init Publisher
        let publisher = sui::package::claim(otw, ctx);

        // Init NFT Display
        let tags = vector[tags::art(), tags::collectible()];

        let display = display::new<Submarine>(&publisher, ctx);
        display::add(&mut display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::add(&mut display, string::utf8(b"tags"), ob_display::from_vec(tags));
        display::update_version(&mut display);
        transfer::public_transfer(display, tx_context::sender(ctx));

        // Creates a new policy and registers an allowlist rule to it.
        // Therefore now to finish a transfer, the allowlist must be included
        // in the chain.
        let (transfer_policy, transfer_policy_cap) =
            ob_transfer_request::init_policy<Submarine>(&publisher, ctx);

        transfer_allowlist::enforce(
            &mut transfer_policy,
            &transfer_policy_cap,
        );

        royalty_strategy_bps::create_domain_and_add_strategy<Submarine>(
            witness::from_witness(Witness {}), &mut collection, 100, ctx,
        );

        transfer::public_transfer(mint_cap, sender);
        transfer::public_transfer(publisher, sender);
        transfer::public_transfer(transfer_policy_cap, sender);
        transfer::public_share_object(transfer_policy);
        transfer::public_share_object(collection);
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
        _mint_cap: &MintCap<Submarine>,
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
