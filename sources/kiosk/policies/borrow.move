module nft_protocol::borrow_request {
    use std::option::{Self, Option, some};
    use std::type_name::TypeName;

    use sui::dynamic_field as df;
    use sui::object::{Self, ID, UID};
    use sui::package::Publisher;
    use sui::tx_context::TxContext;
    use sui::kiosk::Borrow;

    use nft_protocol::request::{Self, RequestBody, Policy, PolicyCap, WithNft};
    use nft_protocol::witness::{Self, Witness as DelegatedWitness};
    use nft_protocol::utils;

    // === Error ===

    const EPolicyMismatch: u64 = 1;

    // === Structs ===

    struct Witness has drop {}
    struct BORROW_REQUEST has drop {}

    // Hot Potato
    struct ReturnPromise<phantom T, phantom Field> {
        nft_id: ID
    }

    struct BorrowRequest<phantom Auth: drop, T: key + store> {
        nft_id: ID,
        nft: Option<T>,
        sender: address,
        field: Option<TypeName>,
        promise: Borrow,
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
        promise: Borrow,
        ctx: &mut TxContext,
    ): BorrowRequest<Auth, T> {
        let nft_id = object::id(&nft);

        BorrowRequest<Auth, T> {
            nft_id,
            nft: some(nft),
            sender,
            field,
            promise,
            inner: request::new(ctx),
        }
    }

    public fun init_policy<Auth: drop, T: key + store>(publisher: &Publisher, ctx: &mut TxContext): (Policy<WithNft<T, BORROW_REQUEST>>, PolicyCap) {
        request::new_policy_with_type(witness::from_witness(Witness {}), publisher, ctx)
    }

    /// Adds a `Receipt` to the `Request`, unblocking the request and
    /// confirming that the policy requirements are satisfied.
    public fun add_receipt<Auth: drop, T: key + store, Rule>(self: &mut BorrowRequest<Auth, T>, rule: &Rule) {
        request::add_receipt(&mut self.inner, rule);
    }

    // TODO: SHOULD THIS BE PROTECTED?
    public fun inner_mut<Auth: drop, T: key + store>(
        self: &mut BorrowRequest<Auth, T>
    ): &mut RequestBody<WithNft<T, BORROW_REQUEST>> { &mut self.inner }

    public fun confirm<Auth: drop, T: key + store>(
        _witness: Auth, self: BorrowRequest<Auth, T>, policy: &Policy<WithNft<T, BORROW_REQUEST>>
    ): (T, Borrow) {
        assert!(option::is_some(&self.nft), 0);

        let BorrowRequest {
            nft_id: _,
            nft,
            sender: _,
            field: _,
            promise,
            inner,
        } = self;


        // TODO: Right now there are no guarantees that the Field was not removed,
        // it relies on faithful implementation on behalf of the creator, this is not
        // ideal we would ideally have a bulletproof here.

        request::confirm(inner, policy);
        (option::destroy_some(nft), promise)
    }

    public fun borrow_nft<Auth: drop, T: key + store>(
        // Creator Witness: Only the creator's contract should have
        // the ability to operate on the inner object extract a field
        _witness: DelegatedWitness<T>,
        request: &mut BorrowRequest<Auth, T>,
    ): T {
        assert!(option::is_none(&request.field), 0);
        option::extract(&mut request.nft)
    }

    public fun borrow_nft_ref_mut<Auth: drop, T: key + store>(
        // Creator Witness: Only the creator's contract should have
        // the ability to operate on the inner object extract a field
        _witness: DelegatedWitness<T>,
        request: &mut BorrowRequest<Auth, T>,
    ): &mut T {
        option::borrow_mut(&mut request.nft)
    }

    public fun borrow_field<T: key + store, Field: store>(
        _witness: DelegatedWitness<T>,
        nft_uid: &mut UID,
    ): (Field, ReturnPromise<T, Field>) {
        let nft_id = object::uid_to_inner(nft_uid);
        let field = utils::pop_df_from_marker<Field>(nft_uid);

        (field, ReturnPromise { nft_id })
    }

    public fun return_field<T: key + store, Field: store>(
        _witness: DelegatedWitness<T>,
        nft_uid: &mut UID,
        promise: ReturnPromise<T, Field>,
        field: Field,
    ) {
        // No need to call the following assertion, we will confirm that the field
        // is present before resolving the BorrowRequest
        // assert!(request.is_returned == false, 0);
        assert!(object::uid_to_inner(nft_uid) == promise.nft_id, 0);
        df::add(nft_uid, utils::marker<Field>(), field);

        let ReturnPromise { nft_id: _ } = promise;

    }

    public fun return_nft<Auth: drop, T: key + store>(
        _witness: DelegatedWitness<T>,
        request: &mut BorrowRequest<Auth, T>,
        nft: T,
    ) {
        assert!(object::id(&nft) == request.nft_id, 0);
        option::fill(&mut request.nft, nft);
    }

    public fun tx_sender<Auth: drop, T: key + store>(self: &BorrowRequest<Auth, T>): address { self.sender }

    public fun is_borrow_field<Auth: drop, T: key + store>(self: &BorrowRequest<Auth, T>): bool {
        option::is_some(&self.field)
    }

    public fun field<Auth: drop, T: key + store>(self: &BorrowRequest<Auth, T>): TypeName {
        *option::borrow(&self.field)
    }

    public fun nft_id<Auth: drop, T: key + store>(self: &BorrowRequest<Auth, T>): ID {
        object::id(option::borrow(&self.nft))
    }

    public fun assert_is_borrow_nft<Auth: drop, T: key + store>(request: &BorrowRequest<Auth, T>) {
        assert!(option::is_none(&request.field), 0);
    }
    public fun assert_is_borrow_field<Auth: drop, T: key + store>(request: &BorrowRequest<Auth, T>) {
        assert!(option::is_some(&request.field), 0);
    }
}
