module nft_protocol::auth {
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, ID, UID};
    use sui::dynamic_field as df;
    use sui::vec_set::{Self, VecSet};
    use std::type_name::TypeName;
    use std::vector;

    use nft_protocol::utils::{Self, Marker};

    /// The number of receipts does not match the `TransferPolicy` requirement.
    const EPolicyNotSatisfied: u64 = 0;
    /// A completed rule is not set in the `TransferPolicy`.
    const EIllegalRule: u64 = 1;


    struct AuthConfig has key, store {
        id: UID,
        rules: VecSet<TypeName>,
    }

    struct AuthRequest {
        venue_id: ID,
        receipts: VecSet<TypeName>,
    }

    public fun start_auth(
        venue_id: ID,
    ): AuthRequest {
        AuthRequest {
            venue_id,
            receipts: vec_set::empty(),
        }
    }

    public fun confirm_auth(
        config: &AuthConfig,
        request: AuthRequest
    ) {
        let AuthRequest {
            venue_id: _,
            receipts,
        } = request;
        let completed = vec_set::into_keys(receipts);
        let total = vector::length(&completed);

        assert!(total == vec_set::size(&config.rules), EPolicyNotSatisfied);

        while (total > 0) {
            let rule_type = vector::pop_back(&mut completed);
            assert!(vec_set::contains(&config.rules, &rule_type), EIllegalRule);
            total = total - 1;
        };
    }

    /// Add a custom Rule to the `TransferPolicy`. Once set, `TransferRequest` must
    /// receive a confirmation of the rule executed so the hot potato can be unpacked.
    ///
    /// - T: the type to which TransferPolicy<T> is applied.
    /// - Rule: the witness type for the Custom rule
    /// - Config: a custom configuration for the rule
    ///
    /// Config requires `drop` to allow creators to remove any policy at any moment,
    /// even if graceful unpacking has not been implemented in a "rule module".
    public fun add_rule<T, Rule: drop, Config: store + drop>(
        _: Rule, policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>, cfg: Config
    ) {
        assert!(object::id(policy) == cap.policy_id, ENotOwner);
        assert!(!has_rule<T, Rule>(policy), ERuleAlreadySet);
        df::add(&mut policy.id, RuleKey<Rule> {}, cfg);
        vec_set::insert(&mut policy.rules, type_name::get<Rule>())
    }

    /// Adds a `Receipt` to the `TransferRequest`, unblocking the request and
    /// confirming that the policy requirements are satisfied.
    public fun add_receipt<T, Rule: drop>(
        _: Rule, request: &mut TransferRequest<T>
    ) {
        vec_set::insert(&mut request.receipts, type_name::get<Rule>())
    }

    /// Check whether a custom rule has been added to the `TransferPolicy`.
    public fun has_rule<T, Rule: drop>(policy: &TransferPolicy<T>): bool {
        df::exists_(&policy.id, RuleKey<Rule> {})
    }

    /// Remove the Rule from the `TransferPolicy`.
    public fun remove_rule<T, Rule: drop, Config: store + drop>(
        policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>
    ) {
        assert!(object::id(policy) == cap.policy_id, ENotOwner);
        let _: Config = df::remove(&mut policy.id, RuleKey<Rule> {});
    }

}
