module nft_protocol::suimarines {
    use std::ascii;
    use std::string::{Self, String};
    use std::vector;

    use sui::object::{Self, UID};
    use sui::balance;
    use sui::transfer;
    use sui::dynamic_field as df;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::mut_lock::{Self, MutLock, ReturnFieldPromise};
    use nft_protocol::tags;
    use nft_protocol::utils;
    use nft_protocol::royalty;
    use nft_protocol::witness;
    use nft_protocol::creators;
    use nft_protocol::attributes;
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::transfer_allowlist;
    use nft_protocol::warehouse::{Self, Warehouse};
    use nft_protocol::collection;
    use nft_protocol::transfer_allowlist_domain;

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

    fun init(witness: SUIMARINES, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);

        let (mint_cap, collection) = nft::new_collection(&witness, ctx);

        // Creates a new policy and registers an allowlist rule to it.
        // Therefore now to finish a transfer, the allowlist must be included
        // in the chain.
        let publisher = sui::package::claim(witness, ctx);

        let (transfer_policy, transfer_policy_cap) =
            nft_protocol::transfer_policy::new<SUIMARINES>(&publisher, ctx);
        nft_protocol::transfer_allowlist::add_policy_rule(
            &mut transfer_policy,
            &transfer_policy_cap,
        );

        transfer::public_transfer(mint_cap, sender);
        transfer::public_transfer(publisher, sender);
        transfer::public_transfer(transfer_policy_cap, sender);
        transfer::public_share_object(transfer_policy);
        transfer::public_share_object(collection);
    }

    public entry fun get_nft_field<Field: store>(
        locked_nft: &mut MutLock<Submarine>,
    ): (Field, ReturnFieldPromise<Field>) {

        let nft = mut_lock::borrow_nft_as_witness(Witness {}, locked_nft);

        // TODO: Change FIELDS to use MARKER INSTEAD OF KEY!
        let field = df::remove(&mut nft.id, utils::marker<Field>());

        let promise = mut_lock::issue_return_field_promise<Field>();

        (field, promise)
    }

    public entry fun return_nft_field<Field: store>(
        locked_nft: &mut MutLock<Submarine>,
        field: Field,
        promise: ReturnFieldPromise<Field>
    ) {
        let nft = mut_lock::borrow_nft_as_witness(Witness {}, locked_nft);

        mut_lock::consume_field_promise(Witness {}, locked_nft, &field, promise);

        df::add(&mut nft.id, utils::marker<Field>(), field);
    }

    public entry fun mint_nft(
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
}
