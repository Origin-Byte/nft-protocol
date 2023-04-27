module ob_request::withdraw_request {
    use sui::package::Publisher;
    use sui::tx_context::TxContext;

    use ob_request::request::{Self, RequestBody, Policy, PolicyCap, WithNft};

    // === Error ===

    const EPolicyMismatch: u64 = 1;

    // === Structs ===

    struct Witness has drop {}
    struct WITHDRAW_REQ has drop {}

    struct WithdrawRequest<phantom T> {
        sender: address,
        inner: RequestBody<WithNft<T, WITHDRAW_REQ>>,
    }

    // === Fns ===

    public fun new<T>(
        sender: address,
        ctx: &mut TxContext,
    ): WithdrawRequest<T> {
        WithdrawRequest<T> {
            sender,
            inner: request::new(ctx),
        }
    }

    public fun init_policy<T>(publisher: &Publisher, ctx: &mut TxContext): (Policy<WithNft<T, WITHDRAW_REQ>>, PolicyCap) {
        request::new_policy_with_type(WITHDRAW_REQ {}, publisher, ctx)
    }

    /// Adds a `Receipt` to the `Request`, unblocking the request and
    /// confirming that the policy requirements are satisfied.
    public fun add_receipt<T, Rule>(self: &mut WithdrawRequest<T>, rule: &Rule) {
        request::add_receipt(&mut self.inner, rule);
    }

    public fun inner_mut<T>(
        self: &mut WithdrawRequest<T>
    ): &mut RequestBody<WithNft<T, WITHDRAW_REQ>> { &mut self.inner }

    public fun confirm<T>(self: WithdrawRequest<T>, policy: &Policy<WithNft<T, WITHDRAW_REQ>>) {
        let WithdrawRequest {
            sender: _,
            inner,
        } = self;

        request::confirm(inner, policy);
    }

    public fun tx_sender<T>(self: &WithdrawRequest<T>): address { self.sender }
}
