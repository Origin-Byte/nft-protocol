module nft_protocol::transfer_token {
    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::TxContext;

    use ob_request::request::{Self, RequestBody, Policy, PolicyCap, WithNft};
    use ob_permissions::witness::Witness as DelegatedWitness;

    // === Errors ===

    const EUnauthorisedAddress: u64 = 1;

    // === Structs ===

    struct TransferToken<phantom T> has key {
        id: UID,
        receiver: address,
    }

    struct TransferTokenRule has drop {}

    // === Management ===

    /// Creates a new `TransferToken<T>` list
    public fun new<T>(
        _witness: DelegatedWitness<T>,
        future_recipient: address,
        ctx: &mut TxContext,
    ): TransferToken<T> {
        TransferToken {
            id: object::new(ctx),
            receiver: future_recipient,
        }
    }

    /// Creates a new `TransferToken<T>` list
    public fun create_and_transfer<T>(
        witness: DelegatedWitness<T>,
        receiver: address,
        current_owner: address,
        ctx: &mut TxContext,
    ): ID {
        let token = new(witness, receiver, ctx);
        let token_id = object::id(&token);

        transfer::transfer(token, current_owner);
        token_id
    }

    /// Creates a new `TransferToken<T>` list
    public entry fun airdrop<T>(
        witness: DelegatedWitness<T>,
        receiver: address,
        current_owner: address,
        ctx: &mut TxContext,
    ) {
        create_and_transfer(witness, receiver, current_owner, ctx);
    }


    // === Actions ===

    /// Registers collection to use `Allowlist` during the transfer.
    public entry fun enforce<T, P>(
        policy: &mut Policy<WithNft<T, P>>, cap: &PolicyCap,
    ) {
        request::enforce_rule_no_state<WithNft<T, P>, TransferTokenRule>(policy, cap);
    }

    public fun drop<T, P>(policy: &mut Policy<WithNft<T, P>>, cap: &PolicyCap) {
        request::drop_rule_no_state<WithNft<T, P>, TransferTokenRule>(policy, cap);
    }

    /// Confirms that the transfer is allowed by the `Allowlist`.
    /// It adds a signature to the request.
    /// In the end, if the allowlist rule is included in the transfer policy,
    /// the transfer request can only be finished if this rule is present.
    public fun confirm<T: key + store, P>(
        nft: T, token: TransferToken<T>, req: &mut RequestBody<WithNft<T, P>>,
    ) {
        let TransferToken {id, receiver} = token;
        object::delete(id);

        transfer::public_transfer(nft, receiver);
        request::add_receipt(req, &TransferTokenRule {});
    }
}
