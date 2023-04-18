/// The rolling hot potato pattern was designed by us in conjunction with
/// Mysten team.
///
/// We have adapted this pattern to work for any generic authorization pattern.
module launchpad_v2::auth_policy {
    use std::type_name::TypeName;

    use sui::tx_context::{TxContext, sender};
    use sui::object::{Self, ID, UID};
    use sui::vec_set::VecSet;

    use nft_protocol::request::{Self, RequestBody};
    use nft_protocol::policy::{Self, Policy};

    /// A completed rule is not set in the `Policy`.
    const EIllegalRule: u64 = 1;
    /// The number of receipts does not match the `Policy` requirement.
    const EPolicyNotSatisfied: u64 = 2;
    const EPolicyCapMismatch: u64 = 3;
    const EPolicyReceiptMismatch: u64 = 4;

    /// A "Hot Potato" forcing the buyer to get a auth permission
    /// from the a purchase attempt from a market `Venue`.
    struct AuthRequest {
        policy_id: ID,
        /// Collected Receipts.
        ///
        /// Used to verify that all of the rules were followed and
        /// `Request` can be confirmed.
        body: RequestBody,
    }

    /// A unique capability that containing the information about the rules
    /// that need to be filled in order to accept a request.
    struct AuthPolicy has key, store {
        id: UID,
        body: Policy,
    }

    /// A Capability granting the owner permission to add/remove rules to `Policy`.
    struct AuthPolicyCap has key, store {
        id: UID,
        policy_id: ID
    }

    /// Creates an empty `Policy` and returns it along with a `PolicyCap`.
    public fun empty_policy(ctx: &mut TxContext): (AuthPolicy, AuthPolicyCap) {
        let policy_uid = object::new(ctx);
        let policy_id = object::uid_to_inner(&policy_uid);

        let policy = AuthPolicy {
            id: policy_uid,
            body: policy::new(ctx),
        };

        let cap = AuthPolicyCap {
            id: object::new(ctx),
            policy_id,
        };

        (policy, cap)
    }

    /// Creates an new `Policy` with rules and returns it along with a `PolicyCap`.
    public fun new_policy(
        rules: VecSet<TypeName>,
        ctx: &mut TxContext
    ): (AuthPolicy, AuthPolicyCap) {
        let policy_uid = object::new(ctx);
        let policy_id = object::uid_to_inner(&policy_uid);

        let policy = AuthPolicy {
            id: policy_uid,
            body: policy::new_with_rules(rules, ctx),
        };

        let cap = AuthPolicyCap {
            id: object::new(ctx),
            policy_id,
        };

        (policy, cap)
    }

    /// Adds rule to `Policy`. This action is only available to the `PolicyCap` owner.
    public fun add_rule<Rule: drop>(
        policy: &mut AuthPolicy,
        policy_cap: &AuthPolicyCap,
    ) {
        assert_policy_cap(policy, policy_cap);

        policy::add_rule<Rule>(&mut policy.body);
    }

    /// Construct a new `Request` hot potato which requires an
    /// approving action from the policy creator to be destroyed / resolved.
    public fun new(
        venue_id: ID,
        policy: &AuthPolicy,
        ctx: &mut TxContext,
    ): AuthRequest {
        AuthRequest {
            policy_id: object::id(policy),
            body: request::new(
                venue_id,
                sender(ctx),
                ctx,
            ),
        }
    }

    /// Adds a `Receipt` to the `AuthRequest`, unblocking the request and
    /// confirming that the policy requirements are satisfied.
    public fun add_receipt<Rule>(self: &mut AuthRequest, rule: &Rule) {
        request::add_receipt(&mut self.body, rule);
    }

    // === AuthRequest confirmation ===

    /// Consumes a `AuthRequest` hot potato.
    /// The call is protected by the type constraint, as only the publisher of
    /// the `T` can get `Policy<T>`.
    ///
    /// Note: unless there's a policy for `T` to allow transfers,
    /// Kiosk trades will not be possible.
    /// If there is no transfer policy in the OB ecosystem, try using
    /// `into_sui` to convert the `TransferRequest` to the SUI ecosystem.
    public fun confirm(
        policy: &AuthPolicy,
        request: AuthRequest,
    ) {
        let AuthRequest {
            policy_id,
            body
        } = request;

        assert!(object::id(policy) == policy_id, EPolicyReceiptMismatch);

        request::confirm(body, policy::rules(&policy.body));
    }

    // === Fields access ===

    public fun policy_id(request: &AuthRequest): ID {
        request.policy_id
    }

    public fun receipts(request: &AuthRequest): &VecSet<TypeName> {
        request::receipts(&request.body)
    }

    public fun rules(policy: &AuthPolicy): &VecSet<TypeName> {
        policy::rules(&policy.body)
    }

    public fun policy_id_from_cap(cap: &AuthPolicyCap): ID {
        cap.policy_id
    }

    // === Assertions ===

    public fun assert_policy_cap(
        policy: &mut AuthPolicy,
        policy_cap: &AuthPolicyCap,
    ) {
        assert!(
            object::id(policy) == policy_cap.policy_id, EPolicyCapMismatch
        );
    }

}
