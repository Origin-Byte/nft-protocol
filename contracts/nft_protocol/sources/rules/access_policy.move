module nft_protocol::access_policy {
    // Borrow NFT from &UID (Programmatic entity)
    use std::type_name::{Self, TypeName};

    use sui::event;
    use sui::package::{Self, Publisher};
    use sui::table::{Self, Table};
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set::{Self, VecSet};

    use ob_permissions::witness::Witness as DelegatedWitness;
    use ob_request::request::{Self, Policy, PolicyCap, WithNft};
    use ob_request::borrow_request::{Self, BorrowRequest};

    use ob_utils::utils;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::nft_protocol::NFT_PROTOCOL;

    // Track the current version of the module
    const VERSION: u64 = 1;

    const ENotUpgrade: u64 = 999;
    const EWrongVersion: u64 = 1000;

    /// When trying to create an access policy when it already exists
    const EACCESS_POLICY_ALREADY_EXISTS: u64 = 1;

    const EFIELD_ACCESS_DENIED: u64 = 2;
    const EPARENT_ACCESS_DENIED: u64 = 3;

    struct AccessPolicyRule has drop {}

    struct AccessPolicy<phantom T: key + store> has key, store {
        id: UID,
        version: u64,
        parent_access: VecSet<address>,
        field_access: Table<TypeName, VecSet<address>>,
    }

    struct Witness has drop {}

    /// Event signalling that a `AccessPolicy` was created
    struct NewPolicyEvent has copy, drop {
        policy_id: ID,
        type_name: TypeName,
    }

    // === Instantiators ===

   /// Creates a new `AccessPolicy<T>` and returns it.
   ///
   /// This endpoint is witness protected on the type `T` level.
    public fun create_new<T: key + store>(
        _witness: DelegatedWitness<T>,
        ctx: &mut TxContext,
    ): AccessPolicy<T> {

        let id = object::new(ctx);

        event::emit(NewPolicyEvent {
            policy_id: object::uid_to_inner(&id),
            type_name: type_name::get<T>(),
        });

        let parent_access = empty_parent_access();
        let field_access = empty_field_access(ctx);

        AccessPolicy {
            id,
            version: VERSION,
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
        ctx: &mut TxContext,
    ) {
        let id = object::new(ctx);

        event::emit(NewPolicyEvent {
            policy_id: object::uid_to_inner(&id),
            type_name: type_name::get<T>(),
        });

        let parent_access = empty_parent_access();
        let field_access = empty_field_access(ctx);

        let access_policy = AccessPolicy<T> {
            id,
            version: VERSION,
            parent_access,
            field_access,
        };

        collection::add_domain(witness, collection, access_policy);
    }

    /// Registers a type to use `AccessPolicy` during the borrowing.
    public fun enforce<T, P>(
        policy: &mut Policy<WithNft<T, P>>, cap: &PolicyCap,
    ) {
        request::enforce_rule_no_state<WithNft<T, P>, AccessPolicyRule>(policy, cap);
    }

    public fun drop<T, P>(policy: &mut Policy<WithNft<T, P>>, cap: &PolicyCap) {
        request::drop_rule_no_state<WithNft<T, P>, AccessPolicyRule>(policy, cap);
    }

    public fun confirm<Auth: drop, T: key + store>(
        self: &AccessPolicy<T>, req: &mut BorrowRequest<Auth, T>, ctx: &mut TxContext,
    ) {
        assert_version(self);

        if (borrow_request::is_borrow_field(req)) {
            let field = borrow_request::field(req);
            assert_field_auth<T>(self, field, ctx);
        } else {
            assert_parent_auth<T>(self, ctx);
        };

        borrow_request::add_receipt(req, &AccessPolicyRule {});
    }

    public fun confirm_from_collection<Auth: drop, T: key + store>(
        collection: &Collection<T>, req: &mut BorrowRequest<Auth, T>, ctx: &mut TxContext,
    ) {
        let access_policy = collection::borrow_domain<T, AccessPolicy<T>>(
            collection
        );

        assert_version(access_policy);
        confirm(access_policy, req, ctx);
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
        assert_version(access_policy);

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
        assert_version(access_policy);

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

        assert_version(access_policy);

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

        assert_version(access_policy);

        // Get table vec
        let vec_set = table::borrow_mut(
            &mut access_policy.field_access, type_name::get<Field>()
        );

        utils::insert_vec_in_vec_set(vec_set, addresses);
    }

    public fun assert_field_auth<T: key + store>(
        self: &AccessPolicy<T>,
        field: TypeName,
        ctx: &TxContext,
    ) {
        let vec_set = table::borrow(
            &self.field_access, field
        );

        assert!(
            vec_set::contains(vec_set, &tx_context::sender(ctx)),
            EFIELD_ACCESS_DENIED
        );
    }

    public fun assert_parent_auth<T: key + store>(
        self: &AccessPolicy<T>,
        ctx: &TxContext,
    ) {
        assert!(
            vec_set::contains(&self.parent_access, &tx_context::sender(ctx)),
            EPARENT_ACCESS_DENIED
        );
    }


    fun assert_no_access_policy<C: drop, T: key + store>(
        collection: &Collection<C>
    ) {
        assert!(
            !collection::has_domain<C, AccessPolicy<T>>(collection),
            EACCESS_POLICY_ALREADY_EXISTS
        );
    }


    fun empty_parent_access(): VecSet<address> {
        vec_set::empty()
    }

    fun empty_field_access(ctx: &mut TxContext): Table<TypeName, VecSet<address>> {
        table::new(ctx)
    }

    // === Upgradeability ===

    fun assert_version<T: key + store>(self: &AccessPolicy<T>) {
        assert!(self.version == VERSION, EWrongVersion);
    }

    // Only the publisher of type `T` can upgrade
    entry fun migrate_as_creator<T: key + store>(
        _witness: DelegatedWitness<T>,
        self: &mut AccessPolicy<T>,
    ) {
        self.version = VERSION;
    }

    entry fun migrate_as_pub<T: key + store>(
        self: &mut AccessPolicy<T>, pub: &Publisher
    ) {
        assert!(package::from_package<NFT_PROTOCOL>(pub), 0);
        self.version = VERSION;
    }
}
