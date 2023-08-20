module nft_protocol::session_token {
    use std::type_name::TypeName;
    use std::option::Option;

    use sui::object::{ID, UID};
    use sui::tx_context::{TxContext};
    use sui::kiosk::Kiosk;

    use ob_request::request::{Policy, PolicyCap, WithNft};
    use ob_request::borrow_request::BorrowRequest;

    use originmate::typed_id::TypedID;

    const EDeprecatedApi: u64 = 998;

    /// When trying to create an access policy when it already exists
    const ESessionPolicyAlreadyExists: u64 = 1;
    const ETokenRequestMismatch: u64 = 2;
    const EFieldAccessDenied: u64 = 3;
    const EParentAccessDenied: u64 = 4;

    struct SessionToken<phantom T> has key, store {
        id: UID,
        nft_id: ID,
        // We add type reflection here due to it being an option,
        // since the borrow can occur globally, in which case the
        // Option is None
        field: Option<TypeName>,
        expiry_ms: u64,
        timeout_id: ID,
        entity: address,
    }

    struct SessionTokenRule has drop {}
    struct TimeOutDfKey has store, copy, drop { nft_id: ID }

    struct TimeOut<phantom T> has key, store {
        id: UID,
        expiry_ms: u64,
        access_token: ID,
    }

    public fun issue_session_token<T: key + store>(
        _kiosk: &mut Kiosk,
        _nft_id: TypedID<T>,
        _receiver: address,
        _expiry_ms: u64,
        _ctx: &mut TxContext,
    ): ID {
        abort(EDeprecatedApi)
        // let field = option::none();
        // issue_session_token_(
        //     kiosk,
        //     nft_id,
        //     receiver,
        //     expiry_ms,
        //     field,
        //     ctx,
        // )
    }

    public fun issue_session_token_field<T: key + store, Field: store>(
        _kiosk: &mut Kiosk,
        _nft_id: TypedID<T>,
        _receiver: address,
        _expiry_ms: u64,
        _ctx: &mut TxContext,
    ) {
        abort(EDeprecatedApi)
        // let field = option::some(type_name::get<Field>());
        // issue_session_token_(
        //     kiosk,
        //     nft_id,
        //     receiver,
        //     expiry_ms,
        //     field,
        //     ctx,
        // );
    }

    /// Registers a type to use `AccessPolicy` during the borrowing.
    public entry fun enforce<T, P>(
        _policy: &mut Policy<WithNft<T, P>>, _cap: &PolicyCap,
    ) {
        abort(EDeprecatedApi)
        // request::enforce_rule_no_state<WithNft<T, P>, SessionTokenRule>(policy, cap);
    }

    public fun drop<T, P>(_policy: &mut Policy<WithNft<T, P>>, _cap: &PolicyCap) {
        abort(EDeprecatedApi)
        // request::drop_rule_no_state<WithNft<T, P>, SessionTokenRule>(policy, cap);
    }

    public fun confirm<Auth: drop, T: key + store>(
        _self: &SessionToken<T>, _req: &mut BorrowRequest<Auth, T>,
    ) {
        abort(EDeprecatedApi)
        // if (borrow_request::is_borrow_field(req)) {
        //     assert_field_auth<Auth, T>(self, req);
        // } else {
        //     assert_parent_auth<Auth, T>(self, req);
        // };

        // borrow_request::add_receipt(req, &SessionTokenRule {});
    }

    public fun assert_field_auth<Auth: drop, T: key + store>(
        _self: &SessionToken<T>,
        _req: &BorrowRequest<Auth, T>
    ) {
        abort(EDeprecatedApi)
        // assert!(
        //     borrow_request::nft_id(req) == self.nft_id, ETokenRequestMismatch
        // );

        // let field = borrow_request::field(req);
        // assert!(
        //     *option::borrow(&self.field) == field, EFieldAccessDenied
        // );
    }

    public fun assert_parent_auth<Auth: drop, T: key + store>(
        _self: &SessionToken<T>,
        _req: &BorrowRequest<Auth, T>
    ) {
        abort(EDeprecatedApi)
        // assert!(
        //     borrow_request::nft_id(req) == self.nft_id, ETokenRequestMismatch
        // );

        // assert!(
        //     option::is_none(&self.field), EParentAccessDenied
        // );
    }
}
