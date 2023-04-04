/// The rolling hot potato pattern was designed by us in conjunction with
/// Mysten team.
///
/// We have adapted this pattern to work for any generic authorization pattern.
module nft_protocol::request {
    use std::vector;
    use std::type_name::{Self, TypeName};

    use sui::tx_context::TxContext;
    use sui::object::{Self, ID, UID};
    use sui::vec_set::{Self, VecSet};

    /// A completed rule is not set in the `Policy`.
    const EIllegalRule: u64 = 1;
    /// The number of receipts does not match the `Policy` requirement.
    const EPolicyNotSatisfied: u64 = 2;
    const EPolicyCapMismatch: u64 = 3;

    /// A "Hot Potato" forcing the buyer to get a auth permission
    /// from the a purchase attempt from a market `Venue`.
    struct Request {
        policy_id: ID,
        /// Collected Receipts.
        ///
        /// Used to verify that all of the rules were followed and
        /// `TransferRequest` can be confirmed.
        receipts: VecSet<TypeName>,
    }

    /// A unique capability that containing the information about the rules
    /// that need to be filled in order to accept a request.
    struct Policy has key, store {
        id: UID,
        /// Set of types of attached rules - used to verify `receipts` when
        /// a `TransferRequest` is received in `confirm_request` function.
        ///
        /// Additionally provides a way to look up currently attached Rules.
        rules: VecSet<TypeName>
    }

    /// A Capability granting the owner permission to add/remove rules as well
    /// as to `withdraw` and `destroy_and_withdraw` the `Policy`.
    struct PolicyCap has key, store {
        id: UID,
        policy_id: ID
    }

    public fun empty_policy(ctx: &mut TxContext): (Policy, PolicyCap) {
        let policy_uid = object::new(ctx);
        let policy_id = object::uid_to_inner(&policy_uid);

        let policy = Policy {
            id: policy_uid,
            rules: vec_set::empty(),
        };

        let cap = PolicyCap {
            id: object::new(ctx),
            policy_id,
        };

        (policy, cap)
    }

    public fun new_policy(
        rules: VecSet<TypeName>,
        ctx: &mut TxContext
    ): (Policy, PolicyCap) {
        let policy_uid = object::new(ctx);
        let policy_id = object::uid_to_inner(&policy_uid);

        let policy = Policy {
            id: policy_uid,
            rules,
        };

        let cap = PolicyCap {
            id: object::new(ctx),
            policy_id,
        };

        (policy, cap)
    }

    public fun add_rule(
        policy: &mut Policy,
        policy_cap: &PolicyCap,
        rule: TypeName,
    ) {
        assert_policy_cap(policy, policy_cap);

        vec_set::insert(&mut policy.rules, rule);
    }

    /// Construct a new `Request` hot potato which requires an
    /// approving action from the policy creator to be destroyed / resolved.
    public fun new(
        policy: &Policy,
    ): Request {
        Request {
            policy_id: object::id(policy),
            receipts: vec_set::empty(),
        }
    }

    /// Adds a `Receipt` to the `Request`, unblocking the request and
    /// confirming that the policy requirements are satisfied.
    public fun add_receipt<Rule>(self: &mut Request, _rule: &Rule) {
        vec_set::insert(&mut self.receipts, type_name::get<Rule>())
    }

    // === Request confirmation ===

    /// Allow a `TransferRequest` for the type `T`.
    /// The call is protected by the type constraint, as only the publisher of
    /// the `T` can get `Policy<T>`.
    ///
    /// Note: unless there's a policy for `T` to allow transfers,
    /// Kiosk trades will not be possible.
    /// If there is no transfer policy in the OB ecosystem, try using
    /// `into_sui` to convert the `TransferRequest` to the SUI ecosystem.
    public fun confirm_request(
        self: &Policy, request: Request,
    ) {
        let Request {
            policy_id: _,
            receipts,
        } = request;

        let completed = vec_set::into_keys(receipts);
        let total = vector::length(&completed);

        assert!(total == vec_set::size(&self.rules), EPolicyNotSatisfied);

        while (total > 0) {
            let rule_type = vector::pop_back(&mut completed);
            assert!(vec_set::contains(&self.rules, &rule_type), EIllegalRule);
            total = total - 1;
        };
    }

    // === Fields access ===

    public fun policy_id(request: &Request): ID {
        request.policy_id
    }

    public fun receipts(request: &Request): &VecSet<TypeName> {
        &request.receipts
    }

    public fun rules(policy: &Policy): &VecSet<TypeName> {
        &policy.rules
    }

    public fun policy_id_from_cap(cap: &PolicyCap): ID {
        cap.policy_id
    }

    // === Assertions ===

    public fun assert_policy_cap(
        policy: &mut Policy,
        policy_cap: &PolicyCap,
    ) {
        assert!(
            object::id(policy) == policy_cap.policy_id, EPolicyCapMismatch
        );
    }

}
