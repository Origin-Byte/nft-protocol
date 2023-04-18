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

    /// Collects receipts which are later checked in `confirm` function.
    ///
    /// `P` represents the policy type that can confirm this request body.
    struct RequestBody<phantom T, phantom P> {
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
    struct Policy<phantom T, phantom P> has key, store {
        id: UID,
        rules: VecSet<TypeName>,
    }

    /// Should be kept by the creator.
    /// Allows adding and removing policy rules.
    struct PolicyCap<phantom T, phantom P> has key, store {
        id: UID,
        for: ID,
    }

    /// We use this to store a state for a particular rule.
    struct RuleStateDfKey<phantom Rule> has copy, drop, store {}

    // === RequestBody ===

    public fun new<T, P>(ctx: &mut TxContext): RequestBody<T, P> {
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
    public fun destroy<T, P>(self: RequestBody<T, P>): VecSet<TypeName> {
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
    public fun metadata_mut<T, P>(self: &mut RequestBody<T, P>): &mut UID { &mut self.metadata }

    /// Reads what metadata is already there.
    public fun metadata<T, P>(self: &RequestBody<T, P>): &UID { &self.metadata }

    /// Adds a `Receipt` to the `RequestBody`, unblocking the request and
    /// confirming that the policy RequestBodys are satisfied.
    public fun add_receipt<T, P, Rule>(self: &mut RequestBody<T, P>, _rule: &Rule) {
        vec_set::insert(&mut self.receipts, type_name::get<Rule>())
    }

    /// Asserts all rules have been met.
    public fun confirm<T, P>(self: RequestBody<T, P>, policy: &Policy<T, P>) {
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

    // === Policy ===

    public fun new_policy<T, P>(
        _witness: DelegatedWitness<P>,
        publisher_of_t: &Publisher,
        ctx: &mut TxContext,
    ): (Policy<T, P>, PolicyCap<T, P>) {
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

    public fun enforce_rule<T, P, Rule, State: store>(
        self: &mut Policy<T, P>,
        cap: &PolicyCap<T, P>,
        state: State,
    ) {
        assert!(object::id(self) == cap.for, ENotAllowed);
        df::add(&mut self.id, RuleStateDfKey<Rule> {}, state);
        vec_set::insert(&mut self.rules, type_name::get<Rule>());
    }

    public fun drop_rule<T, P, Rule, State: store>(
        self: &mut Policy<T, P>,
        cap: &PolicyCap<T, P>,
    ): State {
        assert!(object::id(self) == cap.for, ENotAllowed);
        vec_set::remove(&mut self.rules, &type_name::get<Rule>());
        df::remove(&mut self.id, RuleStateDfKey<Rule> {})
    }

    public fun rule_state<T, P, Rule: drop, State: store + drop>(
        self: &Policy<T, P>, _: Rule,
    ): &State {
        df::borrow(&self.id, RuleStateDfKey<Rule> {})
    }

    public fun rule_state_mut<T, P, Rule: drop, State: store + drop>(
        self: &mut Policy<T, P>, _: Rule,
    ): &State {
        df::borrow_mut(&mut self.id, RuleStateDfKey<Rule> {})
    }
}
