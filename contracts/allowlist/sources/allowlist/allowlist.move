/// Allowlists NFT transfers.
///
/// This module is a set of functions for implementing and managing a
/// allowlist for NFT (non-fungible token) transfers.
/// The allowlist is used to authorize which contracts are allowed to
/// transfer NFTs of a particular collection.
/// The module includes functions for creating and managing the allowlist,
/// adding and removing collections from the allowlist, and checking whether
/// a contract is authorized to transfer a particular NFT.
/// The module uses generics and reflection to allow for flexibility in
/// implementing and managing the allowlist.
///
/// Generics at play:
/// 1. Admin (allowlist witness) enables any organization to start their own
///     allowlist and manage it according to their own rules;
/// 2. Auth (3rd party witness) is used to authorize contracts via their
///     witness types. If e.g. an orderbook trading contract wants to be
///     included in a allowlist, the allowlist admin adds the stringified
///     version of their witness type. The OB then uses this witness type
///     to authorize transfers.
module ob_allowlist::allowlist {
    use std::string::utf8;
    use std::option::{Self, Option};
    use std::type_name::{Self, TypeName};

    use sui::display;
    use sui::transfer;
    use sui::dynamic_field as df;
    use sui::vec_set::{Self, VecSet};
    use sui::object::{Self, ID, UID};
    use sui::package::{Self, Publisher};
    use sui::tx_context::{Self, TxContext};

    // Track the current version of the module
    const VERSION: u64 = 1;

    const ENotUpgrade: u64 = 999;
    const EWrongVersion: u64 = 1000;

    // === Errors ===

    /// Package publisher mismatch
    const EInvalidPublisher: u64 = 0;

    /// Invalid admin
    ///
    /// Create new `Allowlist` using `create` with desired admin.
    const EInvalidAdmin: u64 = 1;

    /// Invalid collection
    ///
    /// Call `insert_collection` to insert a collection.
    const EInvalidCollection: u64 = 2;

    /// Collection was already registered
    const EExistingCollection: u64 = 3;

    /// Invalid transfer authority
    ///
    /// Call `insert_authority` to insert an authority.
    const EInvalidAuthority: u64 = 4;

    /// Transfer authority was already registered
    const EExistingAuthority: u64 = 5;

    // === Structs ===

    struct Allowlist has key, store {
        /// `Allowlist` ID
        id: UID,
        version: u64,
        /// `Allowlist` is controlled by `AllowlistOwnerCap` but can be
        /// optionally configured to be controlled by a contract identified by
        /// the admin witness
        admin_witness: Option<TypeName>,
        /// Witnesses of contracts which are allowed to trade under this
        /// `Allowlist`
        //
        // We do not expect a large number of authorities therefore expect
        // that vector lookup is cheaper than dynamic fields.
        authorities: VecSet<TypeName>,
    }

    struct AllowlistOwnerCap has key, store {
        /// `AllowlistOwnerCap` ID
        id: UID,
        /// `Allowlist` ID
        for: ID,
    }

    /// Key used to index applicable collections on `Allowlist`
    struct CollectionKey {
        type_name: TypeName,
    }

    /// Creates a new `Allowlist`
    public fun new(ctx: &mut TxContext): (Allowlist, AllowlistOwnerCap) {
        new_with_authorities(vec_set::empty(), ctx)
    }

    /// Creates a new `Allowlist` with preset authorities
    public fun new_with_authorities(
        authorities: VecSet<TypeName>,
        ctx: &mut TxContext,
    ): (Allowlist, AllowlistOwnerCap) {
        let allowlist_id = object::new(ctx);

        let cap = AllowlistOwnerCap {
            id: object::new(ctx),
            for: object::uid_to_inner(&allowlist_id),
        };

        let allowlist = Allowlist {
            id: allowlist_id,
            version: VERSION,
            admin_witness: option::none(),
            authorities,
        };

        (allowlist, cap)
    }

    /// Clone an existing `Allowlist`
    public fun clone(
        allowlist: &Allowlist,
        ctx: &mut TxContext,
    ): (Allowlist, AllowlistOwnerCap) {
        new_with_authorities(*borrow_authorities(allowlist), ctx)
    }

    /// Creates and shares a new `Allowlist`
    public fun init_allowlist(ctx: &mut TxContext): (ID, ID) {
        let (allowlist, cap) = new(ctx);

        let allowlist_id = object::id(&allowlist);
        let cap_id = object::id(&cap);

        transfer::public_transfer(cap, tx_context::sender(ctx));
        transfer::public_share_object(allowlist);

        (allowlist_id, cap_id)
    }

    /// Clones and shares a new `Allowlist`
    public fun init_cloned(
        allowlist: &Allowlist,
        ctx: &mut TxContext,
    ): (ID, ID) {
        let (allowlist, cap) =
            new_with_authorities(*borrow_authorities(allowlist), ctx);

        let allowlist_id = object::id(&allowlist);
        let cap_id = object::id(&cap);

        transfer::public_transfer(cap, tx_context::sender(ctx));
        transfer::public_share_object(allowlist);

        (allowlist_id, cap_id)
    }

    /// Borrows authorities from `Allowlist`
    public fun borrow_authorities(self: &Allowlist): &VecSet<TypeName> {
        &self.authorities
    }

    /// Delete `Allowlist`
    public entry fun delete_allowlist(allowlist: Allowlist) {
        assert_version(&allowlist);

        let Allowlist { id, version: _, admin_witness: _, authorities: _ } = allowlist;
        object::delete(id);
    }

    /// Delete `AllowlistOwnerCap`
    ///
    /// This will make it impossible to insert or remove authorities from the
    /// `Allowlist` that `AllowlistOwnerCap` controlled.
    public entry fun delete_owner_cap(owner_cap: AllowlistOwnerCap) {
        let AllowlistOwnerCap { id, for: _ } = owner_cap;
        object::delete(id);
    }

    /// Create a new `Allowlist` controlled by an admin witness
    public fun new_embedded<Admin: drop>(
        witness: Admin,
        ctx: &mut TxContext,
    ): Allowlist {
        new_embedded_with_authorities(witness, vec_set::empty(), ctx)
    }

    /// Create a new `Allowlist` controlled by an admin witness with preset
    /// authorities
    public fun new_embedded_with_authorities<Admin: drop>(
        _witness: Admin,
        authorities: VecSet<TypeName>,
        ctx: &mut TxContext,
    ): Allowlist {
        Allowlist {
            id: object::new(ctx),
            version: VERSION,
            admin_witness: option::some(type_name::get<Admin>()),
            authorities,
        }
    }

    // === Collection management ===

    /// Check if collection `T` is registered on `Allowlist`
    public fun contains_collection(
        self: &Allowlist,
        collection: TypeName,
    ): bool {
        df::exists_(&self.id, collection)
    }

    /// Register collection `T` with `Allowlist` using `Publisher`
    ///
    /// #### Panics
    ///
    /// Panics if `Publisher` is not of type `T`.
    public entry fun insert_collection<T>(
        self: &mut Allowlist,
        collection_pub: &Publisher,
    ) {
        assert_version(self);
        assert_publisher<T>(collection_pub);

        insert_collection_<T>(self)
    }

    /// Register collection and provide error reporting
    fun insert_collection_<T>(self: &mut Allowlist) {
        let collection = type_name::get<T>();
        assert!(!contains_collection(self, collection), EExistingCollection);
        df::add(&mut self.id, collection, true);
    }

    /// Deregister collection `T` with `Allowlist` using `Publisher`
    ///
    /// #### Panics
    ///
    /// Panics if `Publisher` is not of type `T` or collection was not
    /// registered
    public entry fun remove_collection<T>(
        self: &mut Allowlist,
        collection_pub: &Publisher,
    ) {
        assert_version(self);
        assert_publisher<T>(collection_pub);
        remove_collection_<T>(self)
    }

    /// Register collection and provide error reporting
    public entry fun remove_collection_<T>(self: &mut Allowlist) {
        assert_version(self);

        let collection_type = type_name::get<T>();
        assert_collection(self, collection_type);
        df::remove<TypeName, bool>(&mut self.id, collection_type);
    }

    // === Authority management ===

    /// Returns whether `Allowlist` contains authority
    public fun contains_authority(self: &Allowlist, auth: &TypeName): bool {
        vec_set::contains(&self.authorities, auth)
    }

    /// Insert a new authority into `Allowlist` using admin witness
    ///
    /// #### Panics
    ///
    /// Panics if the provided `AllowlistOwnerCap` is not the `Allowlist`
    /// admin.
    public entry fun insert_authority<Auth>(
        cap: &AllowlistOwnerCap,
        self: &mut Allowlist,
    ) {
        assert_version(self);
        assert_cap(self, cap);

        insert_authority_<Auth>(self)
    }

    /// Insert a new authority into `Allowlist` using admin witness
    ///
    /// #### Panics
    ///
    /// Panics if the provided witness is not the `Allowlist` admin, use
    /// `insert_authority` endpoint instead.
    public fun insert_authority_with_witness<Admin: drop, Auth>(
        _witness: Admin,
        self: &mut Allowlist,
    ) {
        assert_version(self);
        assert_admin_witness<Admin>(self);

        insert_authority_<Auth>(self)
    }

    /// Register authority and provide error reporting
    fun insert_authority_<Auth>(self: &mut Allowlist) {
        let auth = type_name::get<Auth>();
        assert!(!contains_authority(self, &auth), EExistingAuthority);
        vec_set::insert(&mut self.authorities, auth);
    }

    /// Remove authority from `Allowlist`
    ///
    /// #### Panics
    ///
    /// Panics if the provided `AllowlistOwnerCap` is not the `Allowlist`
    /// admin.
    public entry fun remove_authority<Auth>(
        cap: &AllowlistOwnerCap,
        self: &mut Allowlist,
    ) {
        assert_version(self);
        assert_cap(self, cap);

        remove_authority_<Auth>(self)
    }

    /// Remove authority from `Allowlist` using admin witness
    ///
    /// #### Panics
    ///
    /// Panics if the provided witness is not the `Allowlist` admin, use
    /// `remove_authority` endpoint instead.
    public fun remove_authority_with_witness<Admin: drop, Auth>(
        _witness: Admin,
        self: &mut Allowlist,
    ) {
        assert_version(self);
        assert_admin_witness<Admin>(self);

        remove_authority_<Auth>(self)
    }

    /// Deregister authority and provide error reporting
    fun remove_authority_<Auth>(self: &mut Allowlist) {
        let authority = type_name::get<Auth>();
        assert_authority(self, &authority);
        vec_set::remove(&mut self.authorities, &authority);
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

    /// Asserts that `AllowlistOwnerCap` is admin of `Allowlist`
    ///
    /// #### Panics
    ///
    /// Panics if admin is mismatched.
    public fun assert_cap(list: &Allowlist, cap: &AllowlistOwnerCap) {
        assert!(&cap.for == &object::id(list), EInvalidAdmin)
    }

    /// Asserts that witness is admin of `Allowlist`
    ///
    /// #### Panics
    ///
    /// Panics if admin is mismatched or `Allowlist` cannot be controlled using
    /// witness.
    public fun assert_admin_witness<Admin: drop>(list: &Allowlist) {
        assert!(option::is_some(&list.admin_witness), EInvalidAdmin);
        assert!(
            &type_name::get<Admin>() == option::borrow(&list.admin_witness),
            EInvalidAdmin,
        );
    }

    /// Assert that `T` may be transferred using this `Allowlist`
    ///
    /// #### Panics
    ///
    /// Panics if `T` may not be transferred.
    public fun assert_collection(allowlist: &Allowlist, collection: TypeName) {
        assert!(
            contains_collection(allowlist, collection), EInvalidCollection,
        );
    }

    /// Assert that authority may be used to transfer using this `Allowlist`
    ///
    /// #### Panics
    ///
    /// Panics if `T` may not be used.
    public fun assert_authority(allowlist: &Allowlist, auth: &TypeName) {
        assert!(
            contains_authority(allowlist, auth), EInvalidAuthority,
        );
    }

    /// Assert that `T` is transferrable and `Auth` may be used to
    /// transfer using this `Allowlist`.
    ///
    /// #### Panics
    ///
    /// Panics if neither `T` is not transferrable or `Auth` is not a
    /// valid authority.
    public fun assert_transferable(allowlist: &Allowlist, collection: TypeName, auth: &TypeName) {
        // TODO: add --> assert_version(allowlist);
        assert_collection(allowlist, collection);
        assert_authority(allowlist, auth);
    }

    // === Display standard ===

    struct ALLOWLIST has drop {}

    fun init(otw: ALLOWLIST, ctx: &mut TxContext) {
        let publisher = package::claim(otw, ctx);
        let display = display::new<Allowlist>(&publisher, ctx);

        display::add(&mut display, utf8(b"name"), utf8(b"Transfer Allowlist"));
        display::add(&mut display, utf8(b"link"), utf8(b"https://docs.originbyte.io"));
        display::add(
            &mut display,
            utf8(b"description"),
            utf8(b"Defines which contracts are allowed to transfer collections"),
        );

        transfer::public_share_object(display);
        package::burn_publisher(publisher);
    }

    // === Upgradeability ===

    fun assert_version(allowlist: &Allowlist) {
        assert!(allowlist.version == VERSION, EWrongVersion);
    }

    entry fun migrate(allowlist: &mut Allowlist, cap: &AllowlistOwnerCap) {
        assert_cap(allowlist, cap);
        assert!(allowlist.version < VERSION, ENotUpgrade);
        allowlist.version = VERSION;
    }
}
