module nft_protocol::access_policy {
    // TODO: Consider adding functionality for one time tokens
    // Borrow NFT from &UID (Programmatic entity)
    // Borrow NFT from with Token
    // Borrow NFT with one-time Token
    use std::type_name::{Self, TypeName};

    use sui::event;
    use sui::table::{Self, Table};
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set::{Self, VecSet};

    use nft_protocol::witness::Witness as DelegatedWitness;
    use nft_protocol::utils;
    use nft_protocol::collection::{Self, Collection};

    /// When trying to create an access policy when it already exists
    const EACCESS_POLICY_ALREADY_EXISTS: u64 = 1;

    const EFIELD_ACCESS_DENIED: u64 = 2;
    const EPARENT_ACCESS_DENIED: u64 = 3;
    const EOWNER_SIGN_OFF_NEEDED: u64 = 4;

    struct AccessPolicy<phantom T: key + store> has key, store {
        id: UID,
        version: u64,
        owner_signoff: bool,
        parent_access: VecSet<address>,
        // TODO: Consider if TypeName is safe here
        field_access: Table<TypeName, VecSet<address>>,
    }

    struct Witness has drop {}

    /// Event signalling that a `AccessPolicy` was created
    struct NewPolicyEvent has copy, drop {
        policy_id: ID,
        type_name: TypeName,
        // Version starts at 1
        version: u64,
    }

    // === Instantiators ===

   /// Creates a new `AccessPolicy<T>` and returns it.
   ///
   /// This endpoint is witness protected on the type `T` level.
    public fun create_new<T: key + store>(
        _witness: DelegatedWitness<T>,
        owner_signoff: bool,
        ctx: &mut TxContext,
    ): AccessPolicy<T> {

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
            owner_signoff,
            parent_access,
            field_access,
        }
    }

    /// Creates a new `AccessPolicy<T>` and adds it to the Collection object.
    ///
    /// This endpoint is witness protected on a collection `T` level.
    ///
    /// #### Panics
    ///
    /// Panics if domain already exists.
    public fun add_new<T: key + store>(
        witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        owner_signoff: bool,
        ctx: &mut TxContext,
    ) {
        let id = object::new(ctx);

        event::emit(NewPolicyEvent {
            policy_id: object::uid_to_inner(&id),
            type_name: type_name::get<T>(),
            version: 1,
        });

        let parent_access = empty_parent_access();
        let field_access = empty_field_access(ctx);

        let access_policy = AccessPolicy<T> {
            id,
            version: 1,
            owner_signoff,
            parent_access,
            field_access,
        };

        collection::add_domain(witness, collection, access_policy);
    }


    // === Access Policy Management ===

    /// Adds a vector of addresses to the access policy `AccessPolicy<T>`
    /// to the `parent_access` list. Addresses with Parent Access have
    /// write-access to all the fields in the given NFT of type `T`.
    ///
    /// This endpoint is witness protected on the type `T` level.
    public fun add_parent_access_to_policy<T: key + store>(
        _witness: DelegatedWitness<T>,
        access_policy: &mut AccessPolicy<T>,
        addresses: vector<address>,
    ) {
        utils::insert_vec_in_vec_set(
            &mut access_policy.parent_access,
            addresses
        );
    }

    /// Adds a vector of addresses to the access policy `AccessPolicy<T>`
    /// to the `field_access` list. Addresses with Field Access have
    /// write-access to the field `Field` in the given NFT of type `T`.
    ///
    /// This endpoint is witness protected on the type `T` level.
    public fun add_field_access_to_policy<T: key + store, Field: store>(
        _witness: DelegatedWitness<T>,
        access_policy: &mut AccessPolicy<T>,
        addresses: vector<address>,
    ) {
        // Get table vec
        let vec_set = table::borrow_mut(
            &mut access_policy.field_access, type_name::get<Field>()
        );

        utils::insert_vec_in_vec_set(vec_set, addresses);
    }


    /// Adds a vector of addresses to the access policy `AccessPolicy<T>`
    /// to the `parent_access` list. Addresses with Parent Access have
    /// write-access to all the fields in the given NFT of type `T`.
    ///
    /// This endpoint is witness protected on a collection `C` level.
    public fun add_parent_access<T: key + store>(
        witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        addresses: vector<address>,
    ) {
        let access_policy = collection::borrow_domain_mut<T, AccessPolicy<T>>(
            witness,
            collection
        );

        utils::insert_vec_in_vec_set(&mut access_policy.parent_access, addresses);
    }

    /// Adds a vector of addresses to the access policy `AccessPolicy<T>`
    /// to the `field_access` list. Addresses with Field Access have
    /// write-access to the field `Field` in the given NFT of type `T`.
    ///
    /// This endpoint is witness protected on a collection `C` level.
    public fun add_field_access<T: key + store, Field: store>(
        witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        addresses: vector<address>,
    ) {
        let access_policy = collection::borrow_domain_mut<T, AccessPolicy<T>>(
            witness,
            collection
        );

        // Get table vec
        let vec_set = table::borrow_mut(
            &mut access_policy.field_access, type_name::get<Field>()
        );

        utils::insert_vec_in_vec_set(vec_set, addresses);
    }

    public fun assert_field_auth<T: key + store, Field: store>(
        collection: &Collection<T>,
        ctx: &TxContext,
    ) {
        let access_policy = collection::borrow_domain<T, AccessPolicy<T>>(
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

    public fun assert_parent_auth<T: key + store>(
        collection: &Collection<T>,
        entity: address,
    ) {
        let access_policy = collection::borrow_domain<T, AccessPolicy<T>>(
            collection
        );

        assert!(
            vec_set::contains(&access_policy.parent_access, &entity),
            EPARENT_ACCESS_DENIED
        );
    }

    public fun assert_no_owner_signoff<T: key + store>(
        collection: &Collection<T>,
    ) {
        let access_policy = collection::borrow_domain<T, AccessPolicy<T>>(
            collection
        );

        assert!(!access_policy.owner_signoff, EOWNER_SIGN_OFF_NEEDED);
    }

    fun assert_no_access_policy<T: key + store>(
        collection: &Collection<T>
    ) {
        assert!(
            !collection::has_domain<T, AccessPolicy<T>>(collection),
            EACCESS_POLICY_ALREADY_EXISTS
        );
    }

    fun empty_parent_access(): VecSet<address> {
        vec_set::empty()
    }

    fun empty_field_access(ctx: &mut TxContext): Table<TypeName, VecSet<address>> {
        table::new(ctx)
    }

}
