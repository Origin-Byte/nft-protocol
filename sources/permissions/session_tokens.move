module nft_protocol::session_token {
    use std::type_name::{Self, TypeName};
    use std::option::{Self, Option};
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{TxContext, sender};
    use sui::dynamic_field as df;
    use sui::kiosk::{Self, Kiosk};
    use sui::transfer;
    use nft_protocol::request::{Self, Policy, PolicyCap, WithNft};
    use nft_protocol::borrow_request::{Self, BorrowRequest};
    use nft_protocol::ob_kiosk;
    use originmate::typed_id::{Self, TypedID};

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
        kiosk: &mut Kiosk,
        nft_id: TypedID<T>,
        receiver: address,
        expiry_ms: u64,
        ctx: &mut TxContext,
    ) {
        let field = option::none();
        issue_session_token_(
            kiosk,
            nft_id,
            receiver,
            expiry_ms,
            field,
            ctx,
        );
    }

    public fun issue_session_token_field<T: key + store, Field: store>(
        kiosk: &mut Kiosk,
        nft_id: TypedID<T>,
        receiver: address,
        expiry_ms: u64,
        ctx: &mut TxContext,
    ) {
        let field = option::some(type_name::get<Field>());
        issue_session_token_(
            kiosk,
            nft_id,
            receiver,
            expiry_ms,
            field,
            ctx,
        );
    }

    fun issue_session_token_<T: key + store>(
        kiosk: &mut Kiosk,
        nft_id: TypedID<T>,
        receiver: address,
        expiry_ms: u64,
        field: Option<TypeName>,
        ctx: &mut TxContext,
    ) {
        let nft_id = typed_id::to_id(nft_id);

        // Only the owner can issue session tokens
        ob_kiosk::assert_owner_address(kiosk, sender(ctx));

        let ss_uid = object::new(ctx);

        let timeout = TimeOut<T> {
            id: object::new(ctx),
            expiry_ms,
            access_token: object::uid_to_inner(&ss_uid),
        };

        let session_token = SessionToken<T> {
            id: ss_uid,
            nft_id,
            field,
            expiry_ms,
            timeout_id: object::id(&timeout),
            entity: receiver,
        };

        // Need to assert that NFT is not locked
        ob_kiosk::auth_exclusive_transfer(kiosk, nft_id, &timeout.id, ctx);
        let kiosk_uid = kiosk::uid_mut(kiosk);

        df::add(kiosk_uid, TimeOutDfKey { nft_id }, timeout);
        transfer::public_transfer(session_token, receiver);
    }

    /// Registers a type to use `AccessPolicy` during the borrowing.
    public fun enforce<T, P>(
        policy: &mut Policy<WithNft<T, P>>, cap: &PolicyCap,
    ) {
        request::enforce_rule_no_state<WithNft<T, P>, SessionTokenRule>(policy, cap);
    }

    public fun drop<T, P>(policy: &mut Policy<WithNft<T, P>>, cap: &PolicyCap) {
        request::drop_rule_no_state<WithNft<T, P>, SessionTokenRule>(policy, cap);
    }

    public fun confirm<T: key + store>(
        self: &SessionToken<T>, req: &mut BorrowRequest<T>,
    ) {
        if (borrow_request::is_borrow_field(req)) {
            assert_field_auth<T>(self, req);
        } else {
            assert_parent_auth<T>(self, req);
        };

        borrow_request::add_receipt(req, &SessionTokenRule {});
    }

    public fun assert_field_auth<T: key + store>(
        self: &SessionToken<T>,
        req: &BorrowRequest<T>
    ) {
        assert!(
            borrow_request::nft_id(req) == self.nft_id, ETokenRequestMismatch
        );

        let field = borrow_request::field(req);
        assert!(
            *option::borrow(&self.field) == field, EFieldAccessDenied
        );
    }

    public fun assert_parent_auth<T: key + store>(
        self: &SessionToken<T>,
        req: &BorrowRequest<T>
    ) {
        assert!(
            borrow_request::nft_id(req) == self.nft_id, ETokenRequestMismatch
        );

        assert!(
            option::is_none(&self.field), EParentAccessDenied
        );
    }
}
