module launchpad_v2::proceeds_request {
    use nft_protocol::request::{Self, RequestBody, Policy, PolicyCap};
    use nft_protocol::witness;
    use sui::object::{Self, ID};
    use sui::tx_context::{TxContext, sender};

    // === Error ===

    const EPolicyMismatch: u64 = 1;

    // === Structs ===

    struct Witness has drop {}
    struct AUTH_REQUEST has drop {}

    struct AuthRequest {
        policy_id: ID,
        sender: address,
        venue_id: ID,
        inner: RequestBody<AUTH_REQUEST>
    }

    // === Fns ===

    /// Construct a new `Request` hot potato which requires an
    /// approving action from the policy creator to be destroyed / resolved.
    public fun new(
        venue_id: ID, policy: &Policy<AUTH_REQUEST>, ctx: &mut TxContext,
    ): AuthRequest {
        AuthRequest {
            policy_id: object::id(policy),
            sender: sender(ctx),
            venue_id,
            inner: request::new(ctx),
        }
    }

    public fun init_policy(ctx: &mut TxContext): (Policy<AUTH_REQUEST>, PolicyCap) {
        request::new_policy(witness::from_witness(Witness {}), ctx)
    }

    /// Adds a `Receipt` to the `Request`, unblocking the request and
    /// confirming that the policy requirements are satisfied.
    public fun add_receipt<Rule>(self: &mut AuthRequest, rule: &Rule) {
        request::add_receipt(&mut self.inner, rule);
    }

    public fun inner_mut(self: &mut AuthRequest): &mut RequestBody<AUTH_REQUEST> {
        &mut self.inner
    }

    public fun confirm(self: AuthRequest, policy: &Policy<AUTH_REQUEST>) {
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
}
