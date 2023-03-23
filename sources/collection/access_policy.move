module nft_protocol::access_policy {
    use std::type_name::{Self, TypeName};
    use std::vector;

    use sui::event;
    use sui::transfer;
    use sui::table_vec::{Self, TableVec};
    use sui::object::{Self, UID, ID};
    use sui::tx_context::TxContext;

    use nft_protocol::utils;

    // TODO: Add accessors to Kiosk once merged
    // get_mutable_access_by_sender
    // get_mutable_access_by_uid
    // get_mutable_access_by_token
    // get_mutable_access_by_ott

    struct AccessPolicy<phantom T: key + store> has key, store {
        id: UID,
        version: u64,
        rules: Rules,
        owner_sign_off: bool,
    }

    // Wrapper of rules
    struct Rules has store {
        // Address access type --> Can represent user addresses or UID access type
        addresses: TableVec<address>,
        // Bearer Token access type
        token: bool,
        // Bearer One-Time Token access type
        ott: bool
    }

    // Unique object per Type that defines the version counter
    struct VersionCounter<phantom T: key + store> has key, store {
        version: u64,
        frozen: bool,
    }

    struct AccessToken<phantom T: key + store> has key, store {
        id: UID,
        version: u64,
    }

    struct OneTimeToken<phantom T: key + store> has key {
        id: UID,
        version: u64,
    }

    struct DfKeys has store, copy, drop { index: u64 }

    /// Event signalling that a `AccessPolicy` was created
    struct NewPolicyEvent has copy, drop {
        policy_id: ID,
        type_name: TypeName,
        version: u64,
    }

    public fun create<T: key + store, W>(
        _witness: &W,
        version_counter: &mut VersionCounter<T>,
        ctx: &mut TxContext,
    ): AccessPolicy<T> {
        utils::assert_same_module_as_witness<T, W>();

        version_counter.version = version_counter.version + 1;

        let id = object::new(ctx);

        event::emit(NewPolicyEvent {
            policy_id: object::uid_to_inner(&id),
            type_name: type_name::get<T>(),
            version: version_counter.version,
        });

        let rules = empty_rules(ctx);

        AccessPolicy {
            id,
            version: version_counter.version,
            rules,
            owner_sign_off: false,
        }
    }

    fun empty_rules(ctx: &mut TxContext): Rules {
        Rules {
            addresses: table_vec::empty(ctx),
            token: false,
            ott: false,
        }
    }

    public fun add_addresses_access<T: key + store, W>(
        _witness: &W,
        addresses: vector<address>,
        access_policy: &mut AccessPolicy<T>,
    ) {
        utils::assert_same_module_as_witness<T, W>();

        let len = vector::length(&addresses);
        while (len > 0) {
            let addr = vector::pop_back(&mut addresses);
            table_vec::push_back(&mut access_policy.rules.addresses, addr);
            len = len - 1;
        };
    }

    public fun add_token_access<T: key + store, W>(
        _witness: &W,
        access_policy: &mut AccessPolicy<T>,
    ) {
        utils::assert_same_module_as_witness<T, W>();
        access_policy.rules.token = true;
    }

    public fun add_one_time_token_access<T: key + store, W>(
        _witness: &W,
        access_policy: &mut AccessPolicy<T>,
    ) {
        utils::assert_same_module_as_witness<T, W>();
        access_policy.rules.ott = true;
    }

    public fun issue_token<T: key + store, W>(
        _witness: &W,
        access_policy: &mut AccessPolicy<T>,
        ctx: &mut TxContext
    ): AccessToken<T> {
        AccessToken {
            id: object::new(ctx),
            version: access_policy.version,
        }
    }

    public fun issue_one_time_token<T: key + store, W>(
        _witness: &W,
        access_policy: &mut AccessPolicy<T>,
        ctx: &mut TxContext
    ): OneTimeToken<T> {
        OneTimeToken {
            id: object::new(ctx),
            version: access_policy.version,
        }
    }

    public fun activate_policy<T: key + store, W>(
        _witness: &W,
        access_policy: AccessPolicy<T>,
    ) {
        transfer::freeze_object(access_policy);
    }

}
