module nft_protocol::wallets {
    use std::vector;

    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui::vec_set::{Self, VecSet};

    use ob_request::request::{Self, RequestBody, Policy, PolicyCap, WithNft};
    use ob_witness::witness::Witness as DelegatedWitness;

    // === Errors ===

    const EUnauthorisedAddress: u64 = 1;

    // === Structs ===

    struct Wallets<phantom T> has key, store {
        id: UID,
        wallets: VecSet<address>,
    }

    struct WalletsRule has drop {}

    // === Management ===

    /// Creates a new `Wallets` list
    fun create<T>(
        _witness: DelegatedWitness<T>,
        wallets: VecSet<address>,
        ctx: &mut TxContext,
    ): Wallets<T> {
        Wallets {
            id: object::new(ctx),
            wallets,
        }
    }

    /// Creates and shares a new `Wallets`
    public fun init_wallets<Admin>(
        witness: DelegatedWitness<Admin>, wallets: VecSet<address>, ctx: &mut TxContext,
    ): ID {
        let wallets = create(witness, wallets, ctx);
        let wallets_id = object::id(&wallets);
        transfer::public_share_object(wallets);
        wallets_id
    }

    public fun insert_addresses<T>(
        _witness: DelegatedWitness<T>,
        wallets: vector<address>,
        self: &mut Wallets<T>,
    ) {

        let len = vector::length(&wallets);

        while (len > 0) {
            let addr = vector::pop_back(&mut wallets);
            vec_set::insert(&mut self.wallets, addr);
            len = len - 1;
        };
    }

    public fun remove_addresses<T>(
        _witness: DelegatedWitness<T>,
        wallets: vector<address>,
        self: &mut Wallets<T>,
    ) {

        let len = vector::length(&wallets);

        while (len > 0) {
            let addr = vector::pop_back(&mut wallets);
            vec_set::insert(&mut self.wallets, addr);
            len = len - 1;
        };
    }

    // === Actions ===

    /// Registers collection to use `Allowlist` during the transfer.
    public fun enforce<T, P>(
        policy: &mut Policy<WithNft<T, P>>, cap: &PolicyCap,
    ) {
        request::enforce_rule_no_state<WithNft<T, P>, WalletsRule>(policy, cap);
    }

    public fun drop<T, P>(policy: &mut Policy<WithNft<T, P>>, cap: &PolicyCap) {
        request::drop_rule_no_state<WithNft<T, P>, WalletsRule>(policy, cap);
    }

    /// Confirms that the transfer is allowed by the `Allowlist`.
    /// It adds a signature to the request.
    /// In the end, if the allowlist rule is included in the transfer policy,
    /// the transfer request can only be finished if this rule is present.
    public fun confirm<T: key + store, P>(
        nft: T, receiver: address, self: &Wallets<T>, req: &mut RequestBody<WithNft<T, P>>,
    ) {
        assert!(vec_set::contains(&self.wallets, &receiver), EUnauthorisedAddress);
        transfer::public_transfer(nft, receiver);
        request::add_receipt(req, &WalletsRule {});
    }
}
