module ob_launchpad_v2::auth_request {
    use sui::object::{Self, ID};
    use sui::tx_context::{TxContext, sender};

    use ob_request::request::{Self, RequestBody, Policy, PolicyCap};

    // === Error ===

    const EPolicyMismatch: u64 = 1;

    // === Structs ===

    struct AUTH_REQ has drop {}

    struct AuthRequest {
        policy_id: ID,
        sender: address,
        venue_id: ID,
        inner: RequestBody<AUTH_REQ>
    }

    // === Fns ===

    /// Construct a new `Request` hot potato which requires an
    /// approving action from the policy creator to be destroyed / resolved.
    public fun new(
        venue_id: ID, policy: &Policy<AUTH_REQ>, ctx: &mut TxContext,
    ): AuthRequest {
        AuthRequest {
            policy_id: object::id(policy),
            sender: sender(ctx),
            venue_id,
            inner: request::new(ctx),
        }
    }

    public fun init_policy(ctx: &mut TxContext): (Policy<AUTH_REQ>, PolicyCap) {
        request::new_policy(AUTH_REQ {}, ctx)
    }

    /// Adds a `Receipt` to the `Request`, unblocking the request and
    /// confirming that the policy requirements are satisfied.
    public fun add_receipt<Rule>(self: &mut AuthRequest, rule: &Rule) {
        request::add_receipt(&mut self.inner, rule);
    }

    public fun inner_mut(self: &mut AuthRequest): &mut RequestBody<AUTH_REQ> {
        &mut self.inner
    }

    public fun confirm(self: AuthRequest, policy: &Policy<AUTH_REQ>) {
        let AuthRequest {
            policy_id,
            sender: _,
            venue_id: _,
            inner,
        } = self;
        assert!(policy_id == object::id(policy), EPolicyMismatch);
        request::confirm(inner, policy);
    }

    public fun venue_id(self: &AuthRequest): ID { self.venue_id }

    public fun auth_sender(self: &AuthRequest): address { self.sender }

    public fun policy_id(self: &AuthRequest): ID { self.policy_id }

    // === Test-Only Functions ===

    #[test_only]
    public fun consume_test(self: AuthRequest) {
        let AuthRequest {
            policy_id: _,
            sender: _,
            venue_id: _,
            inner,
        } = self;

        request::consume_test(inner);
    }
}
