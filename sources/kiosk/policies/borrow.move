module nft_protocol::borrow_request {
    use std::option::{Self, Option};
    use std::type_name::TypeName;

    use sui::package::Publisher;
    use sui::tx_context::TxContext;

    use nft_protocol::request::{Self, RequestBody, Policy, PolicyCap, WithNft};
    use nft_protocol::witness;

    // === Error ===

    const EPolicyMismatch: u64 = 1;

    // === Structs ===

    struct Witness has drop {}
    struct BORROW_REQUEST has drop {}

    struct BorrowRequest<T> {
        nft: T,
        sender: address,
        field: Option<TypeName>,
        inner: RequestBody<WithNft<T, BORROW_REQUEST>>,
    }

    // === Fns ===

    // TODO: Consider security implications of this being opened to the public.
    // We don't want to leave any possibility of spoofing requests..
    public fun new<T>(
        nft: T,
        sender: address,
        field: Option<TypeName>,
        ctx: &mut TxContext,
    ): BorrowRequest<T> {
        BorrowRequest<T> {
            nft,
            sender,
            field,
            inner: request::new(ctx),
        }
    }

    public fun init_policy<T>(publisher: &Publisher, ctx: &mut TxContext): (Policy<WithNft<T, BORROW_REQUEST>>, PolicyCap) {
        request::new_policy_with_type(witness::from_witness(Witness {}), publisher, ctx)
    }

    /// Adds a `Receipt` to the `Request`, unblocking the request and
    /// confirming that the policy requirements are satisfied.
    public fun add_receipt<T, Rule>(self: &mut BorrowRequest<T>, rule: &Rule) {
        request::add_receipt(&mut self.inner, rule);
    }

    public fun inner_mut<T>(
        self: &mut BorrowRequest<T>
    ): &mut RequestBody<WithNft<T, BORROW_REQUEST>> { &mut self.inner }

    public fun confirm<T>(self: BorrowRequest<T>, policy: &Policy<WithNft<T, BORROW_REQUEST>>): T {
        let BorrowRequest {
            nft,
            sender: _,
            field: _,
            inner,
        } = self;

        request::confirm(inner, policy);

        nft
    }

    public fun tx_sender<T>(self: &BorrowRequest<T>): address { self.sender }

    public fun is_borrow_field<T>(self: &BorrowRequest<T>): bool {
        option::is_some(&self.field)
    }

    public fun field<T>(self: &BorrowRequest<T>): TypeName {
        *option::borrow(&self.field)
    }
}
