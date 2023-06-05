module liquidity_layer::trade_request {
    use sui::object::{Self, ID};
    use sui::tx_context::TxContext;

    use ob_request::request::{Self, RequestBody, Policy, PolicyCap};

    // === Error ===

    const EPolicyMismatch: u64 = 1;

    // === Structs ===

    struct BUY_NFT has drop {}
    struct CREATE_BID has drop {}
    struct CREATE_ASK has drop {}

    struct TradeRequest<phantom TRADE> {
        policy_id: ID,
        inner: RequestBody<TRADE>
    }

    // === Fns ===

    /// Construct a new `Request` hot potato, for buying NFTs, which requires an
    /// approving action from the policy creator to be destroyed / resolved.
    public fun buy_nft(
        policy: &Policy<BUY_NFT>, ctx: &mut TxContext,
    ): TradeRequest<BUY_NFT> {
        TradeRequest {
            policy_id: object::id(policy),
            inner: request::new(ctx),
        }
    }

    /// Construct a new `Request` hot potato, for creating an NFT bid order, which requires an
    /// approving action from the policy creator to be destroyed / resolved.
    public fun create_bid(
        policy: &Policy<CREATE_BID>, ctx: &mut TxContext,
    ): TradeRequest<CREATE_BID> {
        TradeRequest {
            policy_id: object::id(policy),
            inner: request::new(ctx),
        }
    }

    /// Construct a new `Request` hot potato, for creating an NFT ask order, which requires an
    /// approving action from the policy creator to be destroyed / resolved.
    public fun create_ask(
        policy: &Policy<CREATE_ASK>, ctx: &mut TxContext,
    ): TradeRequest<CREATE_ASK> {
        TradeRequest {
            policy_id: object::id(policy),
            inner: request::new(ctx),
        }
    }

    public (friend) fun init_buy_nft_policy(ctx: &mut TxContext): (Policy<BUY_NFT>, PolicyCap) {
        request::new_policy(BUY_NFT {}, ctx)
    }

    public (friend) fun init_create_bid_policy(ctx: &mut TxContext): (Policy<CREATE_BID>, PolicyCap) {
        request::new_policy(CREATE_BID {}, ctx)
    }
    public (friend) fun init_create_ask_policy(ctx: &mut TxContext): (Policy<CREATE_ASK>, PolicyCap) {
        request::new_policy(CREATE_ASK {}, ctx)
    }

    /// Adds a `Receipt` to the `Request`, unblocking the request and
    /// confirming that the policy requirements are satisfied.
    public fun add_receipt<TRADE, Rule>(self: &mut TradeRequest<TRADE>, rule: &Rule) {
        request::add_receipt(&mut self.inner, rule);
    }

    public fun inner_mut<TRADE>(self: &mut TradeRequest<TRADE>): &mut RequestBody<TRADE> {
        &mut self.inner
    }

    public fun confirm<TRADE>(self: TradeRequest<TRADE>, policy: &Policy<TRADE>) {
        let TradeRequest {
            policy_id,
            inner,
        } = self;
        assert!(policy_id == object::id(policy), EPolicyMismatch);
        request::confirm(inner, policy);
    }

    public fun policy_id<TRADE>(self: &TradeRequest<TRADE>): ID { self.policy_id }

    // === Test-Only Functions ===

    #[test_only]
    public fun consume_test<TRADE>(self: TradeRequest<TRADE>) {
        let TradeRequest {
            policy_id: _,
            inner,
        } = self;

        request::consume_test(inner);
    }
}
