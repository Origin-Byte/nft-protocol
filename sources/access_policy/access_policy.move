module nft_protocol::access_policy {
    use std::type_name::{Self, TypeName};
    use std::vector;

    use sui::event;
    use sui::bag;
    use sui::dynamic_field as df;
    use sui::package::{Self, Publisher};
    use sui::transfer;
    use sui::table::{Self, Table};
    use sui::table_vec::{Self, TableVec};
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set::{Self, VecSet};

    use nft_protocol::lock::{Self, MutLock};
    use nft_protocol::utils::{Self, UidType};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::consumable_witness::{Self as cw, ConsumableWitness};

    /// When trying to create an access policy when it already exists
    const EACCESS_POLICY_ALREADY_EXISTS: u64 = 1;

    const EFIELD_ACCESS_DENIED: u64 = 2;
    const EPARENT_ACCESS_DENIED: u64 = 3;

    // TODO: Add accessors to Kiosk once merged
    // get_mutable_access_by_sender
    // get_mutable_access_by_uid
    // get_mutable_access_by_token
    // get_mutable_access_by_ott

    struct AccessPolicy<phantom T: key + store> has key, store {
        id: UID,
        version: u64,
        parent_access: VecSet<address>,
        // TODO: Consider if TypeName is safe here
        field_access: Table<TypeName, VecSet<address>>,
    }

    struct Witness has drop {}

    // struct AccessToken<phantom T: key + store> has key, store {
    //     id: UID,
    //     version: u64,
    // }

    // struct OneTimeToken<phantom T: key + store> has key {
    //     id: UID,
    //     version: u64,
    // }

    /// Event signalling that a `AccessPolicy` was created
    struct NewPolicyEvent has copy, drop {
        policy_id: ID,
        type_name: TypeName,
        // Version starts at 1
        version: u64,
    }

    public fun create_empty<OTW: drop, T: key + store>(
        pub: &Publisher,
        collection: &mut Collection<OTW>,
        ctx: &mut TxContext,
    ): AccessPolicy<T> {
        // This assert is redundant because it's being asserted
        // downstream in assert_no_access_policy
        assert!(package::from_package<OTW>(pub), 0);
        // TODO: We should not assert that OTW and T are from the
        // same package, because T maybe be an extended type from the collection
        // using some plugin --> need to reconsider
        assert!(package::from_package<T>(pub), 0);
        assert_no_access_policy<OTW, T>(pub, collection);

        let id = object::new(ctx);

        event::emit(NewPolicyEvent {
            policy_id: object::uid_to_inner(&id),
            type_name: type_name::get<T>(),
            version: 1,
        });

        let parent_access = empty_parent_access();
        let field_access = empty_field_access(ctx);

        AccessPolicy {
            id,
            version: 1,
            parent_access,
            field_access,
        }
    }

    fun empty_parent_access(): VecSet<address> {
        vec_set::empty()
    }

    fun empty_field_access(ctx: &mut TxContext): Table<TypeName, VecSet<address>> {
        table::new(ctx)
    }

    public fun add_parent_access<OTW: drop, T: key + store>(
        pub: &Publisher,
        access_policy: &mut AccessPolicy<T>,
        addresses: vector<address>,
    ) {
        assert!(package::from_package<OTW>(pub), 0);
        // TODO: We should not assert that OTW and T are from the
        // same package, because T maybe be an extended type from the collection
        // using some plugin --> need to reconsider
        assert!(package::from_package<T>(pub), 0);

        utils::insert_vec_in_vec_set(&mut access_policy.parent_access, addresses);
    }

    //
    public fun add_field_access<OTW: drop, T: key + store, Field: store>(
        pub: &Publisher,
        access_policy: &mut AccessPolicy<T>,
        addresses: vector<address>,
    ) {
        assert!(package::from_package<OTW>(pub), 0);
        // TODO: We should not assert that OTW and T are from the
        // same package, because T maybe be an extended type from the collection
        // using some plugin --> need to reconsider
        assert!(package::from_package<T>(pub), 0);


        // Get table vec
        let vec_set = table::borrow_mut(
            &mut access_policy.field_access, type_name::get<Field>()
        );

        utils::insert_vec_in_vec_set(vec_set, addresses);
    }


    // public fun issue_token<T: key + store, W>(
    //     pub: &Publisher,
    //     access_policy: &mut AccessPolicy<T>,
    //     ctx: &mut TxContext
    // ): AccessToken<T> {
    //     AccessToken {
    //         id: object::new(ctx),
    //         version: access_policy.version,
    //     }
    // }

    // public fun issue_one_time_token<T: key + store, W>(
    //     pub: &Publisher,
    //     access_policy: &mut AccessPolicy<T>,
    //     ctx: &mut TxContext
    // ): OneTimeToken<T> {
    //     OneTimeToken {
    //         id: object::new(ctx),
    //         version: access_policy.version,
    //     }
    // }

    public fun access_for_field<OTW: drop, T: key + store, Field: store>(
        // TODO: Add way to get collection bag
        collection: &Collection<OTW>,
        // access_policy: &AccessPolicy<T>,
        ctx: &TxContext,
    ): ConsumableWitness<T> {
        let access_policy = collection::get_bag_field<OTW, Witness, AccessPolicy<T>>(
            Witness {},
            collection
        );

        let vec_set = table::borrow(
            &access_policy.field_access, type_name::get<Field>()
        );

        assert!(
            vec_set::contains(vec_set, &tx_context::sender(ctx)),
            EFIELD_ACCESS_DENIED
        );

        cw::from_access_policy<T>(type_name::get<Field>())
    }

    public fun lock_nft_for_mutation<T: key + store, Field: store>(
        nft: T,
        consumable: &ConsumableWitness<T>
    ): MutLock<T> {
        // Checks if fields correspond
        cw::assert_consumable<T, Field>(consumable);

        lock::new(nft, type_name::get<Field>())
    }

    public fun assert_field_auth<OTW: drop, T: key + store, Field: store>(
        // TODO: Add way to get collection bag
        collection: &Collection<OTW>,
        // access_policy: &AccessPolicy<T>,
        ctx: &TxContext,
    ) {
        let access_policy = collection::get_bag_field<OTW, Witness, AccessPolicy<T>>(
            Witness {},
            collection
        );

        let vec_set = table::borrow(
            &access_policy.field_access, type_name::get<Field>()
        );

        assert!(
            vec_set::contains(vec_set, &tx_context::sender(ctx)),
            EFIELD_ACCESS_DENIED
        );
    }

    public fun assert_parent_auth<OTW: drop, T: key + store, Field: store>(
        // TODO: Add way to get collection bag
        collection: &Collection<OTW>,
        // access_policy: &AccessPolicy<T>,
        ctx: &TxContext,
    ) {
        let access_policy = collection::get_bag_field<OTW, Witness, AccessPolicy<T>>(
            Witness {},
            collection
        );

        assert!(
            vec_set::contains(&access_policy.parent_access, &tx_context::sender(ctx)),
            EPARENT_ACCESS_DENIED
        );
    }


    fun assert_no_access_policy<OTW: drop, T: key + store>(
        pub: &Publisher,
        collection: &Collection<OTW>
    ) {
        let bag = collection::get_bag_as_publisher(pub, collection);

        assert!(
            !bag::contains(bag, type_name::get<AccessPolicy<T>>()),
            EACCESS_POLICY_ALREADY_EXISTS
        );
    }

}
