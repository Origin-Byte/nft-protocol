module ob_authlist::authlist {
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

    // Track the current version of the module
    const VERSION: u64 = 2;

    const ENotUpgraded: u64 = 999;
    const EWrongVersion: u64 = 1000;

    // === Errors ===

    /// Package publisher mismatch
    const EInvalidPublisher: u64 = 1;

    /// Invalid admin
    ///
    /// Create new `Authlist` using `create` with desired admin.
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

    struct Authlist has key, store {
        /// `Authlist` ID
        id: UID,
        version: u64,
        /// `Authlist` is controlled by `AuthlistOwnerCap` but can be
        /// optionally configured to be controlled by a contract identified by
        /// the admin witness
        admin_witness: Option<TypeName>,
        /// Names of authorized public keys
        ///
        /// Note that keys do not have to have attributed names.
        names: VecMap<vector<u8>, String>,
        /// Authorized public keys which are allowed to authorize operations
        /// under this `Authlist`
        ///
        /// We do not expect a large number of authorities therefore expect
        /// that vector lookup is cheaper than dynamic fields.
        ///
        /// Uses `vector<u8>` instead of `address` due to not having to perform
        /// `BCS` deserialization, where performance instead of memory is a
        /// concern.
        authorities: VecSet<vector<u8>>,
    }

    struct AuthlistOwnerCap has key, store {
        /// `AuthlistOwnerCap` ID
        id: UID,
        /// `Authlist` ID
        for: ID,
    }

    // TODO: Deprecate
    #[allow(unused_field)]
    /// Key used to index applicable collections on `Authlist`
    struct CollectionKey {
        type_name: TypeName,
    }

    /// Creates a new `Authlist`
    public fun new(ctx: &mut TxContext): (Authlist, AuthlistOwnerCap) {
        new_with_authorities(vec_set::empty(), ctx)
    }

    /// Creates a new `Authlist` with preset authorities
    public fun new_with_authorities(
        authorities: VecSet<vector<u8>>,
        ctx: &mut TxContext,
    ): (Authlist, AuthlistOwnerCap) {
        let authlist_id = object::new(ctx);

        let cap = AuthlistOwnerCap {
            id: object::new(ctx),
            for: object::uid_to_inner(&authlist_id),
        };

        let authlist = Authlist {
            id: authlist_id,
            version: VERSION,
            admin_witness: option::none(),
            names: vec_map::empty(),
            authorities,
        };

        (authlist, cap)
    }

    /// Clone an existing `Authlist`
    public fun clone(
        authlist: &Authlist,
        ctx: &mut TxContext,
    ): (Authlist, AuthlistOwnerCap) {
        new_with_authorities(
            *borrow_authorities(authlist),
            ctx,
        )
    }

    #[lint_allow(share_owned, self_transfer)]
    /// Creates and shares a new `Authlist`
    public fun init_authlist(ctx: &mut TxContext): (ID, ID) {
        let (authlist, cap) = new(ctx);

        let authlist_id = object::id(&authlist);
        let cap_id = object::id(&cap);

        transfer::public_transfer(cap, tx_context::sender(ctx));
        transfer::public_share_object(authlist);

        (authlist_id, cap_id)
    }

    #[lint_allow(share_owned, self_transfer)]
    /// Clones and shares a new `Authlist`
    public entry fun init_cloned(
        authlist: &Authlist,
        ctx: &mut TxContext,
    ): (ID, ID) {
        let (authlist, cap) = clone(authlist, ctx);

        let authlist_id = object::id(&authlist);
        let cap_id = object::id(&cap);

        transfer::public_transfer(cap, tx_context::sender(ctx));
        transfer::public_share_object(authlist);

        (authlist_id, cap_id)
    }

    /// Borrows authorities from `Authlist`
    public fun borrow_authorities(self: &Authlist): &VecSet<vector<u8>> {
        &self.authorities
    }

    /// Borrows names from `Authlist`
    public fun borrow_names(self: &Authlist): &VecMap<vector<u8>, String> {
        &self.names
    }

    /// Delete `Authlist`
    public entry fun delete_authlist(authlist: Authlist) {
        let Authlist { id, version: _, admin_witness: _, names: _, authorities: _ } =
            authlist;
        object::delete(id);
    }

    /// Delete `AuthlistOwnerCap`
    ///
    /// This will make it impossible to insert or remove authorities from the
    /// `Authlist` that `AuthlistOwnerCap` controlled.
    public entry fun delete_owner_cap(owner_cap: AuthlistOwnerCap) {
        let AuthlistOwnerCap { id, for: _ } = owner_cap;
        object::delete(id);
    }

    /// Create a new `Authlist` controlled by an admin witness
    public fun new_embedded<Admin: drop>(
        witness: Admin,
        ctx: &mut TxContext,
    ): Authlist {
        new_embedded_with_authorities(
            witness, vec_set::empty(), vec_map::empty(), ctx,
        )
    }

    /// Create a new `Authlist` controlled by an admin witness with preset
    /// authorities
    public fun new_embedded_with_authorities<Admin: drop>(
        _witness: Admin,
        authorities: VecSet<vector<u8>>,
        names: VecMap<vector<u8>, String>,
        ctx: &mut TxContext,
    ): Authlist {
        Authlist {
            id: object::new(ctx),
            version: VERSION,
            admin_witness: option::some(type_name::get<Admin>()),
            names,
            authorities,
        }
    }

    // === Collection management ===

    /// Check if collection `T` is registered on `Authlist`
    public fun contains_collection(
        self: &Authlist,
        collection: TypeName,
    ): bool {
        df::exists_(&self.id, collection)
    }

    /// Register collection `T` with `Authlist` using `Publisher`
    ///
    /// #### Panics
    ///
    /// Panics if `Publisher` is not of type `T`.
    public entry fun insert_collection<T>(
        self: &mut Authlist,
        collection_pub: &Publisher,
    ) {
        assert_version_and_upgrade(self);
        assert_publisher<T>(collection_pub);
        insert_collection_<T>(self)
    }

    /// Register collection and provide error reporting
    fun insert_collection_<T>(self: &mut Authlist) {
        let collection = type_name::get<T>();
        assert!(!contains_collection(self, collection), EExistingCollection);
        df::add(&mut self.id, collection, true);
    }

    /// Deregister collection `T` with `Authlist` using `Publisher`
    ///
    /// #### Panics
    ///
    /// Panics if `Publisher` is not of type `T` or collection was not
    /// registered
    public entry fun remove_collection<T>(
        self: &mut Authlist,
        collection_pub: &Publisher,
    ) {
        assert_version_and_upgrade(self);
        assert_publisher<T>(collection_pub);
        remove_collection_<T>(self)
    }

    /// Register collection and provide error reporting
    public entry fun remove_collection_<T>(self: &mut Authlist) {
        assert_version_and_upgrade(self);
        let collection_type = type_name::get<T>();
        assert_collection(self, collection_type);
        df::remove<TypeName, bool>(&mut self.id, collection_type);
    }

    // === Authority management ===

    /// Convert `address` to `vector<u8>`
    public fun address_to_bytes(addr: address): vector<u8> {
        object::id_to_bytes(&object::id_from_address(addr))
    }

    /// Returns whether `Authlist` contains authority
    public fun contains_authority(self: &Authlist, auth: &vector<u8>): bool {
        vec_set::contains(&self.authorities, auth)
    }

    /// Returns whether `Authlist` contains name for authority
    public fun contains_name(self: &Authlist, auth: &vector<u8>): bool {
        vec_map::contains(&self.names, auth)
    }

    /// Insert a new authority into `Authlist` using admin witness
    ///
    /// #### Panics
    ///
    /// Panics if the provided `AuthlistOwnerCap` is not the `Authlist`
    /// admin.
    public entry fun insert_authority(
        cap: &AuthlistOwnerCap,
        self: &mut Authlist,
        authority: vector<u8>,
    ) {
        assert_version_and_upgrade(self);
        assert_cap(self, cap);
        insert_authority_(self, authority)
    }

    /// Insert a new authority into `Authlist` using admin witness
    ///
    /// #### Panics
    ///
    /// Panics if the provided witness is not the `Authlist` admin, use
    /// `insert_authority` endpoint instead.
    public fun insert_authority_with_witness<Admin: drop>(
        _witness: Admin,
        self: &mut Authlist,
        authority: vector<u8>,
    ) {
        assert_version_and_upgrade(self);
        assert_admin_witness<Admin>(self);
        insert_authority_(self, authority);
    }

    /// Register authority and provide error reporting
    fun insert_authority_(self: &mut Authlist, authority: vector<u8>) {
        assert!(vector::length(&authority) == ED25519_LENGTH, EInvalidKey);
        assert!(!contains_authority(self, &authority), EExistingAuthority);
        vec_set::insert(&mut self.authorities, authority);
    }

    /// Register an authority name on `Authlist` using admin witness
    ///
    /// #### Panics
    ///
    /// Panics if the provided `AuthlistOwnerCap` is not the `Authlist`
    /// admin.
    public entry fun set_name(
        cap: &AuthlistOwnerCap,
        self: &mut Authlist,
        authority: vector<u8>,
        name: String,
    ) {
        assert_version_and_upgrade(self);
        assert_cap(self, cap);
        set_name_(self, &authority, name)
    }

    /// Register an authority name on `Authlist` using admin witness
    ///
    /// #### Panics
    ///
    /// Panics if the provided witness is not the `Authlist` admin, use
    /// `insert_name` endpoint instead.
    public fun set_name_with_witness<Admin: drop>(
        _witness: Admin,
        self: &mut Authlist,
        authority: &vector<u8>,
        name: String,
    ) {
        assert_version_and_upgrade(self);
        assert_admin_witness<Admin>(self);
        set_name_(self, authority, name);
    }

    /// Register authority name and provide error reporting
    fun set_name_(
        self: &mut Authlist,
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

    /// Remove authority from `Authlist`
    ///
    /// #### Panics
    ///
    /// Panics if the provided `AuthlistOwnerCap` is not the `Authlist`
    /// admin.
    public entry fun remove_authority(
        cap: &AuthlistOwnerCap,
        self: &mut Authlist,
        authority: vector<u8>
    ) {
        assert_version_and_upgrade(self);
        assert_cap(self, cap);
        remove_authority_(self, &authority)
    }

    /// Remove authority from `Authlist` using admin witness
    ///
    /// #### Panics
    ///
    /// Panics if the provided witness is not the `Authlist` admin, use
    /// `remove_authority` endpoint instead.
    public fun remove_authority_with_witness<Admin: drop>(
        _witness: Admin,
        self: &mut Authlist,
        authority: &vector<u8>
    ) {
        assert_version_and_upgrade(self);
        assert_admin_witness<Admin>(self);
        remove_authority_(self, authority)
    }

    /// Deregister authority and provide error reporting
    fun remove_authority_(self: &mut Authlist, authority: &vector<u8>) {
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
        assert!(package::from_package<T>(pub), EInvalidPublisher);
    }

    /// Asserts that `AuthlistOwnerCap` is admin of `Authlist`
    ///
    /// #### Panics
    ///
    /// Panics if admin is mismatched.
    public fun assert_cap(list: &Authlist, cap: &AuthlistOwnerCap) {
        assert!(&cap.for == &object::id(list), EInvalidAdmin)
    }

    /// Asserts that witness is admin of `Authlist`
    ///
    /// #### Panics
    ///
    /// Panics if admin is mismatched or `Authlist` cannot be controlled using
    /// witness.
    public fun assert_admin_witness<Admin: drop>(list: &Authlist) {
        assert!(option::is_some(&list.admin_witness), EInvalidAdmin);
        assert!(
            &type_name::get<Admin>() == option::borrow(&list.admin_witness),
            EInvalidAdmin,
        );
    }

    /// Assert that `T` may be transferred using this `Authlist`
    ///
    /// #### Panics
    ///
    /// Panics if `T` may not be transferred.
    public fun assert_collection(authlist: &Authlist, collection: TypeName) {
        assert!(
            contains_collection(authlist, collection), EInvalidCollection,
        );
    }

    /// Assert that authority may be used to transfer using this `Authlist`
    ///
    /// #### Panics
    ///
    /// Panics if `T` may not be used.
    public fun assert_authority(authlist: &Authlist, authority: &vector<u8>) {
        assert!(
            contains_authority(authlist, authority), EInvalidAuthority,
        );
    }

    /// Assert that `T` is transferrable and authority may be used to transfer
    /// using this `Authlist`.
    ///
    /// #### Panics
    ///
    /// Panics if neither `T` is not transferrable or authority is not valid.
    public fun assert_transferable(
        authlist: &Authlist,
        collection: TypeName,
        authority: &vector<u8>,
        msg: &vector<u8>,
        signature: &vector<u8>,
    ) {
        assert_collection(authlist, collection);
        assert_authority(authlist, authority);

        assert!(
            ed25519::ed25519_verify(signature, authority, msg),
            EInvalidSignature,
        )
    }

    // === Display standard ===

    struct AUTHLIST has drop {}

    #[allow(unused_function)]
    fun init(otw: AUTHLIST, ctx: &mut TxContext) {
        let publisher = package::claim(otw, ctx);
        let display = display::new<Authlist>(&publisher, ctx);

        display::add(&mut display, utf8(b"name"), utf8(b"Transfer Authlist"));
        display::add(&mut display, utf8(b"link"), utf8(b"https://docs.originbyte.io"));
        display::add(
            &mut display,
            utf8(b"description"),
            utf8(b"Defines which pubkeys are allowed to perform protected actions on collections."),
        );

        display::update_version(&mut display);
        transfer::public_transfer(display, tx_context::sender(ctx));
        package::burn_publisher(publisher);
    }

    // === Upgradeability ===

    fun assert_version(authlist: &Authlist) {
        assert!(authlist.version == VERSION, EWrongVersion);
    }

    fun assert_version_and_upgrade(self: &mut Authlist) {
        if (self.version < VERSION) {
            self.version = VERSION;
        };
        assert_version(self);
    }

    entry fun migrate(authlist: &mut Authlist, cap: &AuthlistOwnerCap) {
        assert_cap(authlist, cap);
        assert!(authlist.version < VERSION, ENotUpgraded);
        authlist.version = VERSION;
    }
}
