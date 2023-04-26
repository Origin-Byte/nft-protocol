module nft_protocol::authlist {
    use std::vector;
    use std::option::{Self, Option};
    use std::string::utf8;
    use std::type_name::{Self, TypeName};
    use std::string::String;

    use sui::display;
    use sui::object::{Self, ID, UID};
    use sui::package::{Self, Publisher};
    use sui::transfer;
    use sui::vec_set::{Self, VecSet};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};
    use sui::dynamic_field as df;
    use sui::ed25519;

    const ED25519_LENGTH: u64 = 32;

    // === Errors ===

    /// Package publisher mismatch
    const EPackagePublisherMismatch: u64 = 1;

    /// Invalid admin
    ///
    /// Create new `AuthList` using `create` with desired admin.
    const EInvalidAdmin: u64 = 2;

    /// Invalid collection
    ///
    /// Call `insert_collection` to insert a collection.
    const EInvalidCollection: u64 = 3;

    /// Collection was already registered
    const EExistingCollection: u64 = 4;

    /// Invalid transfer authority
    ///
    /// Call `insert_authority` to insert an authority.
    const EInvalidAuthority: u64 = 5;

    /// Transfer authority was already registered
    const EExistingAuthority: u64 = 6;

    /// Expected 32-byte Ed25519 public key
    const EInvalidKey: u64 = 7;

    /// Invalid signature provided for given message and public key
    const EInvalidSignature: u64 = 8;

    // === Structs ===

    struct AuthList has key, store {
        /// `AuthList` ID
        id: UID,
        /// `AuthList` is controlled by `AuthListOwnerCap` but can be
        /// optionally configured to be controlled by a contract identified by
        /// the admin witness
        admin_witness: Option<TypeName>,
        /// Names of authorized public keys
        ///
        /// Note that keys do not have to have attributed names.
        names: VecMap<vector<u8>, String>,
        /// Authorized public keys which are allowed to authorize operations
        /// under this `AuthList`
        ///
        /// We do not expect a large number of authorities therefore expect
        /// that vector lookup is cheaper than dynamic fields.
        ///
        /// Uses `vector<u8>` instead of `address` due to not having to perform
        /// `BCS` deserialization, where performance instead of memory is a
        /// concern.
        authorities: VecSet<vector<u8>>,
    }

    struct AuthListOwnerCap has key, store {
        /// `AuthListOwnerCap` ID
        id: UID,
        /// `AuthList` ID
        for: ID,
    }

    /// Key used to index applicable collections on `AuthList`
    struct CollectionKey {
        type_name: TypeName,
    }

    /// Creates a new `AuthList`
    public fun new(ctx: &mut TxContext): (AuthList, AuthListOwnerCap) {
        new_with_authorities(vec_set::empty(), ctx)
    }

    /// Creates a new `AuthList` with preset authorities
    public fun new_with_authorities(
        authorities: VecSet<vector<u8>>,
        ctx: &mut TxContext,
    ): (AuthList, AuthListOwnerCap) {
        let auth_list_id = object::new(ctx);

        let cap = AuthListOwnerCap {
            id: object::new(ctx),
            for: object::uid_to_inner(&auth_list_id),
        };

        let auth_list = AuthList {
            id: auth_list_id,
            admin_witness: option::none(),
            names: vec_map::empty(),
            authorities,
        };

        (auth_list, cap)
    }

    /// Clone an existing `AuthList`
    public fun clone(
        auth_list: &AuthList,
        ctx: &mut TxContext,
    ): (AuthList, AuthListOwnerCap) {
        new_with_authorities(
            *borrow_authorities(auth_list),
            ctx,
        )
    }

    /// Creates and shares a new `AuthList`
    public entry fun init_auth_list(ctx: &mut TxContext) {
        let (auth_list, cap) = new(ctx);

        transfer::public_transfer(cap, tx_context::sender(ctx));
        transfer::public_share_object(auth_list);
    }

    /// Clones and shares a new `AuthList`
    public entry fun init_cloned(
        auth_list: &AuthList,
        ctx: &mut TxContext,
    ) {
        let (auth_list, cap) = clone(auth_list, ctx);

        transfer::public_transfer(cap, tx_context::sender(ctx));
        transfer::public_share_object(auth_list);
    }

    /// Borrows authorities from `AuthList`
    public fun borrow_authorities(self: &AuthList): &VecSet<vector<u8>> {
        &self.authorities
    }

    /// Borrows names from `AuthList`
    public fun borrow_names(self: &AuthList): &VecMap<vector<u8>, String> {
        &self.names
    }

    /// Delete `AuthList`
    public entry fun delete_auth_list(auth_list: AuthList) {
        let AuthList { id, admin_witness: _, names: _, authorities: _ } =
            auth_list;
        object::delete(id);
    }

    /// Delete `AuthListOwnerCap`
    ///
    /// This will make it impossible to insert or remove authorities from the
    /// `AuthList` that `AuthListOwnerCap` controlled.
    public entry fun delete_owner_cap(owner_cap: AuthListOwnerCap) {
        let AuthListOwnerCap { id, for: _ } = owner_cap;
        object::delete(id);
    }

    /// Create a new `AuthList` controlled by an admin witness
    public fun new_embedded<Admin: drop>(
        witness: Admin,
        ctx: &mut TxContext,
    ): AuthList {
        new_embedded_with_authorities(
            witness, vec_set::empty(), vec_map::empty(), ctx,
        )
    }

    /// Create a new `AuthList` controlled by an admin witness with preset
    /// authorities
    public fun new_embedded_with_authorities<Admin: drop>(
        _witness: Admin,
        authorities: VecSet<vector<u8>>,
        names: VecMap<vector<u8>, String>,
        ctx: &mut TxContext,
    ): AuthList {
        AuthList {
            id: object::new(ctx),
            admin_witness: option::some(type_name::get<Admin>()),
            names,
            authorities,
        }
    }

    // === Collection management ===

    /// Check if collection `T` is registered on `AuthList`
    public fun contains_collection(
        self: &AuthList,
        collection: TypeName,
    ): bool {
        df::exists_(&self.id, collection)
    }

    /// Register collection `T` with `AuthList` using `Publisher`
    ///
    /// #### Panics
    ///
    /// Panics if `Publisher` is not of type `T`.
    public entry fun insert_collection<T>(
        self: &mut AuthList,
        collection_pub: &Publisher,
    ) {
        assert_publisher<T>(collection_pub);
        insert_collection_<T>(self)
    }

    /// Register collection and provide error reporting
    fun insert_collection_<T>(self: &mut AuthList) {
        let collection = type_name::get<T>();
        assert!(!contains_collection(self, collection), EExistingCollection);
        df::add(&mut self.id, collection, true);
    }

    /// Deregister collection `T` with `AuthList` using `Publisher`
    ///
    /// #### Panics
    ///
    /// Panics if `Publisher` is not of type `T` or collection was not
    /// registered
    public entry fun remove_collection<T>(
        self: &mut AuthList,
        collection_pub: &Publisher,
    ) {
        assert_publisher<T>(collection_pub);
        remove_collection_<T>(self)
    }

    /// Register collection and provide error reporting
    public entry fun remove_collection_<T>(self: &mut AuthList) {
        let collection_type = type_name::get<T>();
        assert_collection(self, collection_type);
        df::remove<TypeName, bool>(&mut self.id, collection_type);
    }

    // === Authority management ===

    /// Returns whether `AuthList` contains authority
    public fun contains_authority(self: &AuthList, auth: &vector<u8>): bool {
        vec_set::contains(&self.authorities, auth)
    }

    /// Returns whether `AuthList` contains name for authority
    public fun contains_name(self: &AuthList, auth: &vector<u8>): bool {
        vec_map::contains(&self.names, auth)
    }

    /// Insert a new authority into `AuthList` using admin witness
    ///
    /// #### Panics
    ///
    /// Panics if the provided `AuthListOwnerCap` is not the `AuthList`
    /// admin.
    public entry fun insert_authority(
        cap: &AuthListOwnerCap,
        self: &mut AuthList,
        authority: vector<u8>,
    ) {
        assert_cap(self, cap);
        insert_authority_(self, authority)
    }

    /// Insert a new authority into `AuthList` using admin witness
    ///
    /// #### Panics
    ///
    /// Panics if the provided witness is not the `AuthList` admin, use
    /// `insert_authority` endpoint instead.
    public fun insert_authority_with_witness<Admin: drop>(
        _witness: Admin,
        self: &mut AuthList,
        authority: vector<u8>,
    ) {
        assert_admin_witness<Admin>(self);
        insert_authority_(self, authority);
    }

    /// Register authority and provide error reporting
    fun insert_authority_(self: &mut AuthList, authority: vector<u8>) {
        assert!(vector::length(&authority) == ED25519_LENGTH, EInvalidKey);
        assert!(!contains_authority(self, &authority), EExistingAuthority);
        vec_set::insert(&mut self.authorities, authority);
    }

    /// Register an authority name on `AuthList` using admin witness
    ///
    /// #### Panics
    ///
    /// Panics if the provided `AuthListOwnerCap` is not the `AuthList`
    /// admin.
    public entry fun set_name(
        cap: &AuthListOwnerCap,
        self: &mut AuthList,
        authority: vector<u8>,
        name: String,
    ) {
        assert_cap(self, cap);
        set_name_(self, &authority, name)
    }

    /// Register an authority name on `AuthList` using admin witness
    ///
    /// #### Panics
    ///
    /// Panics if the provided witness is not the `AuthList` admin, use
    /// `insert_name` endpoint instead.
    public fun set_name_with_witness<Admin: drop>(
        _witness: Admin,
        self: &mut AuthList,
        authority: &vector<u8>,
        name: String,
    ) {
        assert_admin_witness<Admin>(self);
        set_name_(self, authority, name);
    }

    /// Register authority name and provide error reporting
    fun set_name_(
        self: &mut AuthList,
        authority: &vector<u8>,
        name: String,
    ) {
        assert_authority(self, authority);

        if (contains_name(self, authority)) {
            *vec_map::get_mut(&mut self.names, authority) = name;
        } else {
            vec_map::insert(&mut self.names, *authority, name);
        }
    }

    /// Remove authority from `AuthList`
    ///
    /// #### Panics
    ///
    /// Panics if the provided `AuthListOwnerCap` is not the `AuthList`
    /// admin.
    public entry fun remove_authority(
        cap: &AuthListOwnerCap,
        self: &mut AuthList,
        authority: vector<u8>
    ) {
        assert_cap(self, cap);
        remove_authority_(self, &authority)
    }

    /// Remove authority from `AuthList` using admin witness
    ///
    /// #### Panics
    ///
    /// Panics if the provided witness is not the `AuthList` admin, use
    /// `remove_authority` endpoint instead.
    public fun remove_authority_with_witness<Admin: drop>(
        _witness: Admin,
        self: &mut AuthList,
        authority: &vector<u8>
    ) {
        assert_admin_witness<Admin>(self);
        remove_authority_(self, authority)
    }

    /// Deregister authority and provide error reporting
    fun remove_authority_(self: &mut AuthList, authority: &vector<u8>) {
        assert_authority(self, authority);
        vec_set::remove(&mut self.authorities, authority);

        if (contains_name(self, authority)) {
            vec_map::remove(&mut self.names, authority);
        };
    }

    // === Assertions ===

    /// Asserts that `Publisher` is of type `T`
    ///
    /// #### Panics
    ///
    /// Panics if `Publisher` is mismatched
    public fun assert_publisher<T>(pub: &Publisher) {
        assert!(package::from_package<T>(pub), EPackagePublisherMismatch);
    }

    /// Asserts that `AuthListOwnerCap` is admin of `AuthList`
    ///
    /// #### Panics
    ///
    /// Panics if admin is mismatched.
    public fun assert_cap(list: &AuthList, cap: &AuthListOwnerCap) {
        assert!(&cap.for == &object::id(list), EInvalidAdmin)
    }

    /// Asserts that witness is admin of `AuthList`
    ///
    /// #### Panics
    ///
    /// Panics if admin is mismatched or `AuthList` cannot be controlled using
    /// witness.
    public fun assert_admin_witness<Admin: drop>(list: &AuthList) {
        assert!(option::is_some(&list.admin_witness), EInvalidAdmin);
        assert!(
            &type_name::get<Admin>() == option::borrow(&list.admin_witness),
            EInvalidAdmin,
        );
    }

    /// Assert that `T` may be transferred using this `AuthList`
    ///
    /// #### Panics
    ///
    /// Panics if `T` may not be transferred.
    public fun assert_collection(auth_list: &AuthList, collection: TypeName) {
        assert!(
            contains_collection(auth_list, collection), EInvalidCollection,
        );
    }

    /// Assert that authority may be used to transfer using this `AuthList`
    ///
    /// #### Panics
    ///
    /// Panics if `T` may not be used.
    public fun assert_authority(auth_list: &AuthList, authority: &vector<u8>) {
        assert!(
            contains_authority(auth_list, authority), EInvalidAuthority,
        );
    }

    /// Assert that `T` is transferrable and authority may be used to transfer
    /// using this `AuthList`.
    ///
    /// #### Panics
    ///
    /// Panics if neither `T` is not transferrable or authority is not valid.
    public fun assert_transferable(
        auth_list: &AuthList,
        collection: TypeName,
        authority: &vector<u8>,
        msg: &vector<u8>,
        signature: &vector<u8>,
    ) {
        assert_collection(auth_list, collection);
        assert_authority(auth_list, authority);

        assert!(
            ed25519::ed25519_verify(signature, authority, msg),
            EInvalidSignature,
        )
    }

    // === Display standard ===

    struct AUTHLIST has drop {}

    fun init(otw: AUTHLIST, ctx: &mut TxContext) {
        let publisher = package::claim(otw, ctx);
        let display = display::new<AuthList>(&publisher, ctx);

        display::add(&mut display, utf8(b"name"), utf8(b"Transfer AuthList"));
        display::add(&mut display, utf8(b"link"), utf8(b"https://docs.originbyte.io"));
        display::add(
            &mut display,
            utf8(b"description"),
            utf8(b"Defines which pubkeys are allowed to perform protected actions on collections."),
        );

        transfer::public_share_object(display);
        package::burn_publisher(publisher);
    }
}
