/// A generic way of validating some action.
///
/// Instances are for example
/// - `Request<T, OB_TRANSFER_REQUEST>` which is responsible for checking that
/// a transfer of NFT can be performed.
/// It's heavily integrated with `nft_protocol::ob_kiosk`.
module nft_protocol::request {
    use nft_protocol::utils;
    use nft_protocol::witness::{Witness as DelegatedWitness};
    use std::type_name::{Self, TypeName};
    use std::vector;
    use sui::dynamic_field as df;
    use sui::object::{Self, ID, UID};
    use sui::package::Publisher;
    use sui::tx_context::TxContext;
    use sui::vec_set::{Self, VecSet};

    // === Errors ===

    /// A completed rule is not set in the list of required rules
    const EIllegalRule: u64 = 1;
    /// The number of receipts does not match the list of required rules
    const EPolicyNotSatisfied: u64 = 2;
    /// Wrong capability, cannot authorize action
    const ENotAllowed: u64 = 3;

    // === Structs ===

    /// `T` is a type this request is concerned with, e.g. NFT type.
    /// `P` represents the policy type that can confirm this request body.
    ///
    /// Used as `RequestBody<WithNft<Suimarines, OB_TRANSFER_REQUEST>>`
    struct WithNft<phantom T, phantom P> {}

    /// Collects receipts which are later checked in `confirm` function.
    ///
    /// `P` represents the policy type that can confirm this request body.
    struct RequestBody<phantom P> {
        /// Collected Receipts.
        ///
        /// Used to verify that all of the rules were followed and
        /// `RequestBody` can be confirmed.
        receipts: VecSet<TypeName>,
        /// Optional metadata can be attached to the request.
        /// The metadata are dropped at the destruction of the request.
        /// It doesn't have to be emptied out for this type to be destroyed.
        metadata: UID,
    }

    /// Defines what receipts does the `RequestBody` have to have to be confirmed
    /// and destroyed.
    ///
    /// `P` represents the policy type that can confirm this request body.
    struct Policy<phantom P> has key, store {
        id: UID,
        rules: VecSet<TypeName>,
    }

    /// Should be kept by the creator.
    /// Allows adding and removing policy rules.
    struct PolicyCap has key, store {
        id: UID,
        for: ID,
    }

    /// We use this to store a state for a particular rule.
    struct RuleStateDfKey<phantom Rule> has copy, drop, store {}

    // === RequestBody ===

    public fun new<P>(ctx: &mut TxContext): RequestBody<P> {
        RequestBody {
            metadata: object::new(ctx),
            receipts: vec_set::empty(),
        }
    }

    /// Anyone can destroy the hotpotato.
    /// That's why it's customary to wrap it in a custom hotpotato type and
    /// define under which conditions is it ok to destroy it _without_ rule
    /// checks.
    /// To destroy it _with_ rule checks, use `confirm` function.
    public fun destroy<P>(self: RequestBody<P>): VecSet<TypeName> {
        let RequestBody { metadata, receipts } = self;
        object::delete(metadata);
        receipts
    }

    /// Anyone can attach any metadata (dynamic fields).
    /// The UID is eventually dropped when the `RequestBody` is destroyed.
    ///
    /// Implementations are responsible for not leaving dangling data inside the
    /// metadata.
    /// If they do, the data will haunt the chain forever.
    public fun metadata_mut<P>(self: &mut RequestBody<P>): &mut UID { &mut self.metadata }

    /// Reads what metadata is already there.
    public fun metadata<P>(self: &RequestBody<P>): &UID { &self.metadata }

    /// Adds a `Receipt` to the `RequestBody`, unblocking the request and
    /// confirming that the policy RequestBodys are satisfied.
    public fun add_receipt<P, Rule: drop>(
        self: &mut RequestBody<P>,
        _rule: Rule,
    ) {
        vec_set::insert(&mut self.receipts, type_name::get<Rule>())
    }

    /// Asserts all rules have been met.
    public fun confirm<P>(self: RequestBody<P>, policy: &Policy<P>) {
        let receipts = destroy(self);

        let completed = vec_set::into_keys(receipts);
        let total = vector::length(&completed);
        assert!(total == vec_set::size(&policy.rules), EPolicyNotSatisfied);
        while (total > 0) {
            let rule_type = vector::pop_back(&mut completed);
            assert!(vec_set::contains(&policy.rules, &rule_type), EIllegalRule);
            total = total - 1;
        };
    }

    public fun receipts<P>(request: &RequestBody<P>): &VecSet<TypeName> {
        &request.receipts
    }

    // === Policy ===

    public fun new_policy<P>(
        _witness: DelegatedWitness<P>,
        ctx: &mut TxContext,
    ): (Policy<P>, PolicyCap) {
        let policy = Policy {
            id: object::new(ctx),
            rules: vec_set::empty(),
        };
        let cap = PolicyCap {
            id: object::new(ctx),
            for: object::id(&policy),
        };

        (policy, cap)
    }

    /// Useful for generic policies which can be defined per type.
    ///
    /// For example, one might want to have a royalty policy which is defined
    /// for a specific NFT type.
    /// In such scheme, the NFT type would be `T`, and the royalty policy
    /// would be `P`.
    /// In fact, this is how `ob_transfer_request::TransferRequest<T>` is
    /// implemented.
    public fun new_policy_with_type<T, P>(
        _witness: DelegatedWitness<P>,
        publisher_of_t: &Publisher,
        ctx: &mut TxContext,
    ): (Policy<WithNft<T, P>>, PolicyCap) {
        utils::assert_package_publisher<T>(publisher_of_t);

        let policy = Policy {
            id: object::new(ctx),
            rules: vec_set::empty(),
        };
        let cap = PolicyCap {
            id: object::new(ctx),
            for: object::id(&policy),
        };

        (policy, cap)
    }

    public fun enforce_rule<P, Rule, State: store>(
        self: &mut Policy<P>, cap: &PolicyCap, state: State,
    ) {
        assert!(object::id(self) == cap.for, ENotAllowed);
        df::add(&mut self.id, RuleStateDfKey<Rule> {}, state);
        vec_set::insert(&mut self.rules, type_name::get<Rule>());
    }

    public fun enforce_rule_no_state<P, Rule>(
        self: &mut Policy<P>, cap: &PolicyCap,
    ) {
        assert!(object::id(self) == cap.for, ENotAllowed);
        df::add(&mut self.id, RuleStateDfKey<Rule> {}, true);
        vec_set::insert(&mut self.rules, type_name::get<Rule>());
    }

    public fun drop_rule<P, Rule, State: store>(
        self: &mut Policy<P>, cap: &PolicyCap,
    ): State {
        assert!(object::id(self) == cap.for, ENotAllowed);
        vec_set::remove(&mut self.rules, &type_name::get<Rule>());
        df::remove(&mut self.id, RuleStateDfKey<Rule> {})
    }

    public fun drop_rule_no_state<P, Rule>(
        self: &mut Policy<P>, cap: &PolicyCap,
    ) {
        assert!(object::id(self) == cap.for, ENotAllowed);
        vec_set::remove(&mut self.rules, &type_name::get<Rule>());
        assert!(df::remove(&mut self.id, RuleStateDfKey<Rule> {}), 0);
    }

    public fun rule_state<P, Rule: drop, State: store + drop>(
        self: &Policy<P>, _: Rule,
    ): &State {
        df::borrow(&self.id, RuleStateDfKey<Rule> {})
    }

    public fun rule_state_mut<P, Rule: drop, State: store + drop>(
        self: &mut Policy<P>, _: Rule,
    ): &State {
        df::borrow_mut(&mut self.id, RuleStateDfKey<Rule> {})
    }

    public fun rules<P>(policy: &Policy<P>): &VecSet<TypeName> {
        &policy.rules
    }

    public fun policy_cap_for(policy: &PolicyCap): &ID {
        &policy.for
    }

    public fun policy_metadata_mut<P>(policy: &mut Policy<P>): &mut UID {
        &mut policy.id
    }

    public fun policy_metadata<P>(policy: &Policy<P>): &UID {
        &policy.id
    }
}
