module nft_protocol::session_token {
    use std::type_name::{Self, TypeName};
    use std::option::{Self, Option};
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{TxContext, sender};
    use sui::dynamic_field as df;
    use sui::transfer;
    use nft_protocol::access_policy as ap;
    use nft_protocol::ob_kiosk;
    use nft_protocol::collection::Collection;
    use nft_protocol::mut_lock::{Self, MutLock, ReturnPromise};
    use nft_protocol::ob_transfer_request::{Self, TransferRequest};
    use originmate::typed_id::{Self, TypedID};
    use std::string::utf8;
    use sui::display;
    use sui::clock::{Self, Clock};
    use sui::kiosk::{Self, Kiosk, uid_mut as ext};
    use sui::package;
    use sui::table::{Self, Table};
    use sui::transfer::{transfer, public_share_object};
    use sui::vec_set::{Self, VecSet};

    use nft_protocol::utils;
    use nft_protocol::witness::{Witness as DelegatedWitness};

    const ELOCK_PROMISE_MISMATCH: u64 = 1;
    const ELOCK_AUTHORITY_MISMATCH: u64 = 2;

    struct AccessToken<phantom T> has key, store {
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
        let nft_id = typed_id::to_id(nft_id);

        // Only the owner can issue session tokens
        ob_kiosk::assert_owner_address(kiosk, sender(ctx));

        let ss_uid = object::new(ctx);

        let timeout = TimeOut<T> {
            id: object::new(ctx),
            expiry_ms,
            access_token: object::uid_to_inner(&ss_uid),
        };

        let session_token = AccessToken<T> {
            id: object::new(ctx),
            nft_id,
            field: option::none(),
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

    public fun issue_session_token_field<T: key + store, Field: store>(
        kiosk: &mut Kiosk,
        nft_id: TypedID<T>,
        receiver: address,
        expiry_ms: u64,
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

        let session_token = AccessToken<T> {
            id: object::new(ctx),
            nft_id,
            field: option::none(),
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

    public fun issue_session_token_field_<Auth: drop, T: key + store, Field: store>(
        _auth: Auth,
        nft_id: ID,
        receiver: address,
        ctx: &mut TxContext,
    ){
        let ss = SessionToken<T> {
            id: object::new(ctx),
            nft_id,
            authority: type_name::get<Auth>(),
            field: option::some(type_name::get<Field>()),
        };

        transfer::transfer(ss, receiver);
    }

    // TODO: Consider the consequences of this being accessible to everyone
    // Most likely the lock_nft should be made in a way that forces the unlock function
    // to be called from the same module --> probably by using witness
    public fun lock_nft_with_session_token<Auth: drop, T: key + store>(
        _auth: Auth,
        nft: T,
        session_token: SessionToken<T>,
        ctx: &mut TxContext,
    ): (MutLock<T>, ReturnPromise<T>) {
        let SessionToken { id, nft_id, authority, field } = session_token;

        assert!(
            object::id(&nft) == nft_id,
            0
        );

        assert!(
            type_name::get<Auth>() == authority,
            0
        );

        let mut_lock = MutLock {
            id: object::new(ctx),
            nft,
            authority: type_name::get<Auth>(),
            field,
        };

        let promise = ReturnPromise { nft_id };
        object::delete(id);

        (mut_lock, promise)
    }

    public fun nft_id<T: key + store>(session_token: &SessionToken<T>): ID {
        session_token.nft_id
    }
}
