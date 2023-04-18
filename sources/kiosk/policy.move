module nft_protocol::policy {
    use std::type_name::{Self, TypeName};
    use sui::package::{Self, Publisher};
    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};
    use sui::vec_set::{Self, VecSet};
    use sui::dynamic_field as df;

    use nft_protocol::request::{Self, RequestBody};

    /// The number of receipts does not match the `TransferPolicy` requirement.
    const EPolicyNotSatisfied: u64 = 0;
    /// A completed rule is not set in the `TransferPolicy`.
    const EIllegalRule: u64 = 1;
    /// A Rule is not set.
    const EUnknownRequirement: u64 = 2;
    /// Attempting to create a Rule that is already set.
    const ERuleAlreadySet: u64 = 3;

    /// A unique capability that allows the owner of the `T` to authorize
    /// transfers. Can only be created with the `Publisher` object. Although
    /// there's no limitation to how many policies can be created, for most
    /// of the cases there's no need to create more than one since any of the
    /// policies can be used to confirm the `TransferRequest`.
    struct Policy has key, store {
        id: UID,
        /// Set of types of attached rules - used to verify `receipts` when
        /// a `TransferRequest` is received in `confirm_request` function.
        ///
        /// Additionally provides a way to look up currently attached Rules.
        rules: VecSet<TypeName>
    }

    // /// A Capability granting the owner permission to add/remove rules as well
    // /// as to `withdraw` and `destroy_and_withdraw` the `TransferPolicy`.
    // struct TransferPolicyCap<phantom T> has key, store {
    //     id: UID,
    //     policy_id: ID
    // }

    /// Key to store "Rule" configuration for a specific `TransferPolicy`.
    struct RuleKey<phantom T: drop> has copy, store, drop {}

    /// Register a type in the Kiosk system and receive an `TransferPolicyCap`
    /// which is required to confirm kiosk deals for the `T`. If there's no
    /// `TransferPolicyCap` available for use, the type can not be traded in
    /// kiosks.
    public fun new<T>(
        pub: &Publisher, ctx: &mut TxContext
    ): Policy {
        assert!(package::from_package<T>(pub), 0);
        let id = object::new(ctx);

        Policy { id, rules: vec_set::empty() }
    }

    /// Destroy a Policy.
    /// Can be performed by any party as long as they own it.
    public fun destroy(
        self: Policy,
    ) {
        let Policy { id, rules: _ } = self;

        object::delete(id);
    }

    /// Allow a `TransferRequest` for the type `T`. The call is protected
    /// by the type constraint, as only the publisher of the `T` can get
    /// `Policy`.
    ///
    /// Note: unless there's a policy for `T` to allow transfers,
    /// Kiosk trades will not be possible.
    public fun confirm_request<FT>(
        self: &Policy, request: RequestBody, ctx: &mut TxContext
    ) {
        request::confirm<FT>(request, &self.rules, ctx);
    }

    // === Rules Logic ===

    /// Add a custom Rule to the `TransferPolicy`. Once set, `TransferRequest` must
    /// receive a confirmation of the rule executed so the hot potato can be unpacked.
    ///
    /// - T: the type to which Policy is applied.
    /// - Rule: the witness type for the Custom rule
    /// - Config: a custom configuration for the rule
    ///
    /// Config requires `drop` to allow creators to remove any policy at any moment,
    /// even if graceful unpacking has not been implemented in a "rule module".
    public fun add_rule<T, Rule: drop, Config: store + drop>(
        _: Rule, policy: &mut Policy, cfg: Config
    ) {
        assert!(!has_rule<T, Rule>(policy), ERuleAlreadySet);
        df::add(&mut policy.id, RuleKey<Rule> {}, cfg);
        vec_set::insert(&mut policy.rules, type_name::get<Rule>())
    }

    /// Get the custom Config for the Rule (can be only one per "Rule" type).
    public fun get_rule<T, Rule: drop, Config: store + drop>(
        _: Rule, policy: &Policy)
    : &Config {
        df::borrow(&policy.id, RuleKey<Rule> {})
    }

    /// Check whether a custom rule has been added to the `TransferPolicy`.
    public fun has_rule<T, Rule: drop>(policy: &Policy): bool {
        df::exists_(&policy.id, RuleKey<Rule> {})
    }

    /// Remove the Rule from the `TransferPolicy`.
    public fun remove_rule<T, Rule: drop, Config: store + drop>(
        policy: &mut Policy
    ) {
        let _: Config = df::remove(&mut policy.id, RuleKey<Rule> {});
    }

    // === Fields access ===

    /// Allows reading custom attachments to the `TransferPolicy` if there are any.
    public fun uid<T>(self: &Policy): &UID { &self.id }

    /// Get a mutable reference to the `self.id` to enable custom attachments
    /// to the `TransferPolicy`.
    public fun uid_mut_as_owner<T>(
        self: &mut Policy
    ): &mut UID {
        &mut self.id
    }
}
