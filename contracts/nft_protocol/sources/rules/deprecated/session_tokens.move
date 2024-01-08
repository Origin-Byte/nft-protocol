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

    #[allow(unused_field)]
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
    #[allow(unused_field)]
    struct TimeOutDfKey has store, copy, drop { nft_id: ID }

    #[allow(unused_field)]
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
    }

    #[allow(unused_type_parameter)]
    public fun issue_session_token_field<T: key + store, Field: store>(
        _kiosk: &mut Kiosk,
        _nft_id: TypedID<T>,
        _receiver: address,
        _expiry_ms: u64,
        _ctx: &mut TxContext,
    ) {
        abort(EDeprecatedApi)
    }

    /// Registers a type to use `AccessPolicy` during the borrowing.
    public entry fun enforce<T, P>(
        _policy: &mut Policy<WithNft<T, P>>, _cap: &PolicyCap,
    ) {
        abort(EDeprecatedApi)
    }

    public fun drop<T, P>(_policy: &mut Policy<WithNft<T, P>>, _cap: &PolicyCap) {
        abort(EDeprecatedApi)
    }

    public fun confirm<Auth: drop, T: key + store>(
        _self: &SessionToken<T>, _req: &mut BorrowRequest<Auth, T>,
    ) {
        abort(EDeprecatedApi)
    }

    public fun assert_field_auth<Auth: drop, T: key + store>(
        _self: &SessionToken<T>,
        _req: &BorrowRequest<Auth, T>
    ) {
        abort(EDeprecatedApi)
    }

    public fun assert_parent_auth<Auth: drop, T: key + store>(
        _self: &SessionToken<T>,
        _req: &BorrowRequest<Auth, T>
    ) {
        abort(EDeprecatedApi)
    }
}
