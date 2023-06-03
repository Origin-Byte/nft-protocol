module liquidity_layer::trade_request {
    use sui::object::{Self, ID};
    use sui::tx_context::{TxContext, sender};

    use ob_request::request::{Self, RequestBody, Policy, PolicyCap};

    // === Error ===

    const EPolicyMismatch: u64 = 1;

    // === Structs ===

    struct TRADE has drop {}

    struct TradeRequest {
        policy_id: ID,
        action: u8,
        inner: RequestBody<TRADE>
    }

    // === Fns ===

    /// Construct a new `Request` hot potato which requires an
    /// approving action from the policy creator to be destroyed / resolved.
    public (friend) fun new(
        action: u8, policy: &Policy<TRADE>, ctx: &mut TxContext,
    ): TradeRequest {
        TradeRequest {
            policy_id: object::id(policy),
            action,
            inner: request::new(ctx),
        }
    }

    public (friend) fun init_policy(ctx: &mut TxContext): (Policy<TRADE>, PolicyCap) {
        request::new_policy(TRADE {}, ctx)
    }

    /// Adds a `Receipt` to the `Request`, unblocking the request and
    /// confirming that the policy requirements are satisfied.
    public fun add_receipt<Rule>(self: &mut TradeRequest, rule: &Rule) {
        request::add_receipt(&mut self.inner, rule);
    }

    public fun inner_mut(self: &mut TradeRequest): &mut RequestBody<TRADE> {
        &mut self.inner
    }

    public fun confirm(self: TradeRequest, policy: &Policy<TRADE>) {
        let TradeRequest {
            policy_id,
            action: _,
            inner,
        } = self;
        assert!(policy_id == object::id(policy), EPolicyMismatch);
        request::confirm(inner, policy);
    }

    public fun policy_id(self: &TradeRequest): ID { self.policy_id }

    // === Test-Only Functions ===

    #[test_only]
    public fun consume_test(self: TradeRequest) {
        let TradeRequest {
            policy_id: _,
            action: _,
            inner,
        } = self;

        request::consume_test(inner);
    }
}
