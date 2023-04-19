module nft_protocol::borrow_request {
    use std::option::{Self, Option, some};
    use std::type_name::{Self, TypeName};

    use sui::dynamic_field as df;
    use sui::object::{Self, ID};
    use sui::package::Publisher;
    use sui::tx_context::TxContext;

    use nft_protocol::request::{Self, RequestBody, Policy, PolicyCap, WithNft};
    use nft_protocol::witness::{Self, Witness as DelegatedWitness};
    use nft_protocol::utils::{Self, Marker};
    use originmate::typed_id::{Self, TypedID};

    // === Error ===

    const EPolicyMismatch: u64 = 1;

    // === Structs ===

    struct Witness has drop {}
    struct BORROW_REQUEST has drop {}

    // Hot Potato
    struct ReturnPromise<Field: store> {
        field: Option<Field>,
        nft_id: ID
    }

    struct BorrowRequest<T: key + store> {
        nft: Option<T>,
        sender: address,
        field: Option<TypeName>,
        auth: TypeName,
        is_returned: bool,
        inner: RequestBody<WithNft<T, BORROW_REQUEST>>,
    }

    // === Fns ===

    // TODO: Consider security implications of this being opened to the public.
    // We don't want to leave any possibility of spoofing requests..
    public fun new<Auth: drop, T: key + store>(
        _witness: Auth,
        nft: T,
        sender: address,
        field: Option<TypeName>,
        ctx: &mut TxContext,
    ): BorrowRequest<T> {
        BorrowRequest<T> {
            nft: some(nft),
            sender,
            field,
            auth: type_name::get<Auth>(),
            is_returned: false,
            inner: request::new(ctx),
        }
    }

    public fun init_policy<T: key + store>(publisher: &Publisher, ctx: &mut TxContext): (Policy<WithNft<T, BORROW_REQUEST>>, PolicyCap) {
        request::new_policy_with_type(witness::from_witness(Witness {}), publisher, ctx)
    }

    /// Adds a `Receipt` to the `Request`, unblocking the request and
    /// confirming that the policy requirements are satisfied.
    public fun add_receipt<T: key + store, Rule>(self: &mut BorrowRequest<T>, rule: &Rule) {
        request::add_receipt(&mut self.inner, rule);
    }

    // TODO: SHOULD THIS BE PROTECTED?
    public fun inner_mut<T: key + store>(
        self: &mut BorrowRequest<T>
    ): &mut RequestBody<WithNft<T, BORROW_REQUEST>> { &mut self.inner }

    public fun confirm<Auth: drop, T: key + store>(
        _witness: Auth, self: BorrowRequest<T>, policy: &Policy<WithNft<T, BORROW_REQUEST>>
    ): T {
        // Can only be called by Auth, which in our case is the OBKiosk
        assert_witness<Auth, T>(&self);
        assert_is_is_returned(&self);

        let BorrowRequest {
            nft,
            sender: _,
            field: _,
            auth: _,
            is_returned: _,
            inner,
        } = self;

        request::confirm(inner, policy);
        option::destroy_some(nft)
    }

    public fun borrow_nft<T: key + store>(
        // Creator Witness: Only the creator's contract should have
        // the ability to operate on the inner object extract a field
        _witness: DelegatedWitness<T>,
        request: &mut BorrowRequest<T>,
    ): (&mut T, NftId) {
        let nft = option::borrow_mut(&mut request.nft);
        let nft_id = object::id(nft);
        (nft, NftId { nft_id })
    }

    public fun borrow_field(
        nft_uid: Nft,
    ) {
        utils::pop_df_from_marker<Field>(&mut nft.id);
    }

    public fun return_field<T: key + store, Field: store>(
        _witness: DelegatedWitness<T>,
        nft_uid: &mut UID,
        uid_type: TypedID<T>,
        request: &mut BorrowRequest<T>,
    ) {

    }

    public fun tx_sender<T: key + store>(self: &BorrowRequest<T>): address { self.sender }

    public fun is_borrow_field<T: key + store>(self: &BorrowRequest<T>): bool {
        option::is_some(&self.field)
    }

    public fun field<T: key + store>(self: &BorrowRequest<T>): TypeName {
        *option::borrow(&self.field)
    }

    public fun nft_id<T: key + store>(self: &BorrowRequest<T>): ID {
        object::id(option::borrow(&self.nft))
    }

    public fun assert_is_borrow_nft<T: key + store>(request: &BorrowRequest<T>) {
        assert!(option::is_none(&request.field), 0);
    }
    public fun assert_is_borrow_field<T: key + store>(request: &BorrowRequest<T>) {
        assert!(option::is_some(&request.field), 0);
    }
    public fun assert_is_is_returned<T: key + store>(request: &BorrowRequest<T>) {
        assert!(request.is_returned, 0);
    }

    public fun assert_witness<Auth: drop, T: key + store>(request: &BorrowRequest<T>) {
        assert!(type_name::get<Auth>() == request.auth, 0);
    }
}
