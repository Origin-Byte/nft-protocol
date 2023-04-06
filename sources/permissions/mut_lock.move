module nft_protocol::mut_lock {
    use std::type_name::{Self, TypeName};
    use std::option::{Self, Option};
    use sui::object::{Self, ID, UID};
    use sui::tx_context::TxContext;
    use sui::dynamic_field as df;
    use nft_protocol::utils;

    const ELOCK_PROMISE_MISMATCH: u64 = 1;
    const ELOCK_AUTHORITY_MISMATCH: u64 = 2;

    // TODO: Consider using Witness as type reflection
    struct MutLock<T> has key {
        id: UID,
        nft: T,
        // We add authority as type name because otherwise
        // we have 4 generics in the extract function
        authority: TypeName,
        // We add type reflection here because it's an option,
        // since the borrow can occur globally, in which case the
        // Option is None
        field: Option<TypeName>,
    }

    struct ReturnPromise<phantom T> { nft_id: ID }

    struct ReturnFieldPromise<phantom Field> {}

    // TODO: Consider the consequences of this being accessible to everyone
    // Most likely the lock_nft should be made in a way that forces the unlock function
    // to be called from the same module --> probably by using witness
    public fun lock_nft_global<Auth: drop, T: key + store>(
        _auth: Auth,
        nft: T,
        ctx: &mut TxContext,
    ): (MutLock<T>, ReturnPromise<T>) {
        let nft_id = object::id(&nft);

        let mut_lock = MutLock {
            id: object::new(ctx),
            nft,
            authority: type_name::get<Auth>(),
            field: option::none()
        };

        let promise = ReturnPromise { nft_id };

        (mut_lock, promise)
    }

    // TODO: Consider the consequences of this being accessible to everyone
    // Most likely the lock_nft should be made in a way that forces the unlock function
    // to be called from the same module --> probably by using witness
    public fun lock_nft<Auth: drop, T: key + store, Field: store>(
        _auth: Auth,
        nft: T,
        ctx: &mut TxContext,
    ): (MutLock<T>, ReturnPromise<T>) {
        let nft_id = object::id(&nft);

        let mut_lock = MutLock {
            id: object::new(ctx),
            nft,
            authority: type_name::get<Auth>(),
            field: option::some(type_name::get<Field>())
        };

        let promise = ReturnPromise { nft_id };

        (mut_lock, promise)
    }

    public fun unlock_nft<Auth: drop, T: key + store>(
        _auth: Auth,
        locked_nft: MutLock<T>,
        promise: ReturnPromise<T>,
    ): T {
        assert!(
            type_name::get<Auth>() == locked_nft.authority,
            ELOCK_AUTHORITY_MISMATCH
        );

        let MutLock { id, nft, authority: _, field: _ } = locked_nft;

        object::delete(id);

        assert!(promise.nft_id == object::id(&nft), ELOCK_PROMISE_MISMATCH);

        let ReturnPromise { nft_id: _ } = promise;

        nft
    }

    public fun borrow_nft_as_witness<W: drop, T: key + store>(
        // Creator Witness: Only the creator's contract should have
        // the ability to operate on the inner object extract a field
        _witness: W,
        locked_nft: &mut MutLock<T>,
    ): &mut T {
        utils::assert_same_module<T, W>();

        &mut locked_nft.nft
    }

    public fun borrow_field_with_promise<Field: store>(
        nft_uid: &mut UID
    ): (Field, ReturnFieldPromise<Field>) {
        let field = df::remove(nft_uid, utils::marker<Field>());

        (field, ReturnFieldPromise {})
    }

    // TODO: We need to explore more the security aspects of this function,
    // I am worried the client could swap MutLocks and ReturnFieldPromises
    // and somehow get away with something. It's hard to reason about this
    public fun consume_field_promise<Field: store>(
        // Creator Control: Only the creator's contract should have
        // the ability to operate on the inner object extract a field, this is
        // built in because only the creator can define how to get &mut UID
        nft_uid: &mut UID,
        field: Field,
        promise: ReturnFieldPromise<Field>,
    ) {
        df::add(nft_uid, utils::marker<Field>(), field);

        let ReturnFieldPromise {} = promise;
    }
}
