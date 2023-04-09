module nft_protocol::suimarines {
    use std::string::String;
    use std::option;

    use sui::transfer;
    use sui::dynamic_field as df;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::mut_lock::{Self, MutLock, ReturnFieldPromise};
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::royalty_strategy_bps;
    use nft_protocol::utils;
    use nft_protocol::warehouse::{Self, Warehouse};
    use nft_protocol::witness;

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

        // Get the Delegated Witness
        let dw = witness::from_witness(Witness {});

        // Init Collection
        let collection: Collection<SUIMARINES> =
            collection::create(dw, ctx);

        // Init MintCap with unlimited supply
        let mint_cap = mint_cap::new<SUIMARINES, Submarine>(
            &otw, object::id(&collection), option::none(), ctx,
        );

        // Init Publisher
        let publisher = sui::package::claim(otw, ctx);

        // Creates a new policy and registers an allowlist rule to it.
        // Therefore now to finish a transfer, the allowlist must be included
        // in the chain.
        let (transfer_policy, transfer_policy_cap) =
            sui::transfer_policy::new<SUIMARINES>(&publisher, ctx);
        nft_protocol::transfer_allowlist::add_policy_rule(
            &mut transfer_policy,
            &transfer_policy_cap,
        );

        royalty_strategy_bps::create_domain_and_add_strategy<SUIMARINES, Submarine>(
            witness::from_witness(Witness {}), &mut collection, 100, ctx,
        );

        transfer::public_transfer(mint_cap, sender);
        transfer::public_transfer(publisher, sender);
        transfer::public_transfer(transfer_policy_cap, sender);
        transfer::public_share_object(transfer_policy);
        transfer::public_share_object(collection);
    }

    public fun get_nft_field<Field: store>(
        locked_nft: &mut MutLock<Submarine>,
    ): (Field, ReturnFieldPromise<Field>) {

        let nft = mut_lock::borrow_nft_as_witness(Witness {}, locked_nft);

        let field = df::remove(&mut nft.id, utils::marker<Field>());

        let promise = mut_lock::issue_return_field_promise<Field>();

        (field, promise)
    }

    public fun return_nft_field<Field: store>(
        locked_nft: &mut MutLock<Submarine>,
        field: Field,
        promise: ReturnFieldPromise<Field>
    ) {
        mut_lock::consume_field_promise(Witness {}, locked_nft, &field, promise);
        let nft = mut_lock::borrow_nft_as_witness(Witness {}, locked_nft);

        df::add(&mut nft.id, utils::marker<Field>(), field);
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
    const USER: address = @0xA1C04;

    #[test]
    fun it_inits_collection() {
        let scenario = test_scenario::begin(USER);
        init(SUIMARINES {}, ctx(&mut scenario));

        test_scenario::end(scenario);
    }
}
