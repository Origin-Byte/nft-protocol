/// P2PLists NFT transfers.
///
/// This module is a set of functions for implementing and managing a
/// P2PList for NFT (non-fungible token) transfers.
/// The P2PList is used to authorize which contracts are allowed to
/// transfer NFTs of a particular collection.
/// The module includes functions for creating and managing the P2PList,
/// adding and removing collections from the P2PList, and checking whether
/// a contract is authorized to transfer a particular NFT.
/// The module uses generics and reflection to allow for flexibility in
/// implementing and managing the P2PList.
///
/// Generics at play:
/// 1. Admin (P2PList witness) enables any organization to start their own
///     P2PList and manage it according to their own rules;
/// 2. Auth (3rd party witness) is used to authorize contracts via their
///     witness types. If e.g. an orderbook trading contract wants to be
///     included in a P2PList, the P2PList admin adds the stringified
///     version of their witness type. The OB then uses this witness type
///     to authorize transfers.
module nft_protocol::p2p_list {
    use std::string::String;
    use sui::display;
    use std::vector;
    use sui::object::{Self, ID, UID};
    use sui::package::{Self, Publisher};
    use sui::transfer;
    use sui::vec_set;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};
    use sui::dynamic_field as df;

    use nft_protocol::request::{Self, RequestBody, Policy, PolicyCap, WithNft};
    use sui::transfer_policy::{TransferPolicy, TransferPolicyCap};
    use nft_protocol::ob_kiosk;
    use nft_protocol::ob_transfer_request::{Self, TransferRequest};
    use nft_protocol::witness::Witness as DelegatedWitness;

    use std::option::{Self, Option};
    use std::string::utf8;
    use std::type_name::{Self, TypeName};

    // === Errors ===

    /// Package publisher mismatch
    const EPackagePublisherMismatch: u64 = 0;

    /// Invalid admin
    ///
    /// Create new `P2PList` using `create` with desired admin.
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

    struct P2PList has key, store {
        /// `P2PList` ID
        id: UID,
        /// `P2PList` is controlled by `P2PListOwnerCap` but can be
        /// optionally configured to be controlled by a contract identified by
        /// the admin witness
        admin_witness: Option<TypeName>,
        /// Witnesses of contracts which are allowed to trade under this
        /// `P2PList`
        //
        // We do not expect a large number of authorities therefore expect
        // that vector lookup is cheaper than dynamic fields.
        authorities: VecMap<address, Entity>,
    }

    struct Entity has copy, store, drop {
        name: String,
        pubkey: vector<u8>,
    }

    struct P2PListOwnerCap has key, store {
        /// `P2PListOwnerCap` ID
        id: UID,
        /// `P2PList` ID
        for: ID,
    }

    /// Key used to index applicable collections on `P2PList`
    struct CollectionKey {
        type_name: TypeName,
    }

    /// `sui::transfer_policy::TransferPolicy` can have this rule to enforce
    /// that only P2PListed contracts can transfer NFTs.
    ///
    /// Note that this rule depends on `ob_kiosk::get_transfer_request_auth`
    /// and only works with `ob_transfer_request::TransferRequest`.
    ///
    /// That's because the sui implementation of `TransferRequest` is simplified
    /// and does not support safe metadata about the originator of the transfer.
    struct P2PListRule has drop {}

    /// Creates a new `P2PList`
    public fun new(ctx: &mut TxContext): (P2PList, P2PListOwnerCap) {
        new_with_authorities(vector::empty(), vector::empty(), vector::empty(), ctx)
    }

    /// Creates a new `P2PList` with preset authorities
    public fun new_with_authorities(
        authority_addresses: vector<address>,
        authority_names: vector<String>,
        authority_pubkeys: vector<vector<u8>>,
        ctx: &mut TxContext,
    ): (P2PList, P2PListOwnerCap) {
        let p2p_list_id = object::new(ctx);

        let cap = P2PListOwnerCap {
            id: object::new(ctx),
            for: object::uid_to_inner(&p2p_list_id),
        };

        let authorities = vec_map::empty();
        let len = vector::length(&authority_addresses);

        assert!(
            len == vector::length(&authority_names) && len == vector::length(&authority_pubkeys), 0
        );

        while (len > 0) {
            let entity = Entity {
                name: vector::pop_back(&mut authority_names),
                pubkey: vector::pop_back(&mut authority_pubkeys),
            };

            vec_map::insert(&mut authorities, vector::pop_back(&mut authority_addresses), entity);
        };

        let p2p_list = P2PList {
            id: p2p_list_id,
            admin_witness: option::none(),
            authorities,
        };

        (p2p_list, cap)
    }

    public fun new_with_authorities_(
        authorities: VecMap<address, Entity>,
        ctx: &mut TxContext,
    ): (P2PList, P2PListOwnerCap) {
        let p2p_list_id = object::new(ctx);

        let cap = P2PListOwnerCap {
            id: object::new(ctx),
            for: object::uid_to_inner(&p2p_list_id),
        };

        let p2p_list = P2PList {
            id: p2p_list_id,
            admin_witness: option::none(),
            authorities,
        };

        (p2p_list, cap)
    }

    /// Clone an existing `P2PList`
    public fun clone(
        p2p_list: &P2PList,
        ctx: &mut TxContext,
    ): (P2PList, P2PListOwnerCap) {
        new_with_authorities_(*borrow_authorities(p2p_list), ctx)
    }

    /// Creates and shares a new `P2PList`
    public entry fun init_P2PList(ctx: &mut TxContext) {
        let (p2p_list, cap) = new(ctx);

        transfer::public_transfer(cap, tx_context::sender(ctx));
        transfer::public_share_object(p2p_list);
    }

    /// Clones and shares a new `P2PList`
    public entry fun init_cloned(
        p2p_list: &P2PList,
        ctx: &mut TxContext,
    ) {
        let (p2p_list, cap) =
            new_with_authorities_(*borrow_authorities(p2p_list), ctx);

        transfer::public_transfer(cap, tx_context::sender(ctx));
        transfer::public_share_object(p2p_list);
    }

    /// Borrows authorities from `P2PList`
    public fun borrow_authorities(self: &P2PList): &VecMap<address, Entity> {
        &self.authorities
    }

    /// Delete `P2PListOwnerCap`
    ///
    /// This will make it impossible to insert or remove authorities from the
    /// `P2PList` that `P2PListOwnerCap` controlled.
    public entry fun delete_owner_cap(owner_cap: P2PListOwnerCap) {
        let P2PListOwnerCap { id, for: _ } = owner_cap;
        object::delete(id);
    }

    /// Create a new `P2PList` controlled by an admin witness
    public fun new_embedded<Admin: drop>(
        witness: Admin,
        ctx: &mut TxContext,
    ): P2PList {
        new_embedded_with_authorities(witness, vec_map::empty(), ctx)
    }

    /// Create a new `P2PList` controlled by an admin witness with preset
    /// authorities
    public fun new_embedded_with_authorities<Admin: drop>(
        _witness: Admin,
        authorities: VecMap<address, Entity>,
        ctx: &mut TxContext,
    ): P2PList {
        P2PList {
            id: object::new(ctx),
            admin_witness: option::some(type_name::get<Admin>()),
            authorities,
        }
    }

    // === Collection management ===

    /// Check if collection `T` is registered on `P2PList`
    public fun contains_collection(
        self: &P2PList,
        collection: TypeName,
    ): bool {
        df::exists_(&self.id, collection)
    }

    /// Register collection `T` with `P2PList` using `Publisher`
    ///
    /// #### Panics
    ///
    /// Panics if `Publisher` is not of type `T`.
    public entry fun insert_collection<T>(
        self: &mut P2PList,
        collection_pub: &Publisher,
    ) {
        assert_publisher<T>(collection_pub);
        insert_collection_<T>(self)
    }

    /// Register collection `T` with `P2PList` using collection witness
    ///
    /// #### Panics
    ///
    /// Panics if `Publisher` is not of type `T`.
    public fun insert_collection_with_witness<T>(
        _witness: DelegatedWitness<T>,
        self: &mut P2PList,
    ) {
        insert_collection_<T>(self)
    }

    /// Register collection and provide error reporting
    fun insert_collection_<T>(self: &mut P2PList) {
        let collection = type_name::get<T>();
        assert!(!contains_collection(self, collection), EExistingCollection);
        df::add(&mut self.id, collection, true);
    }

    /// Deregister collection `T` with `P2PList` using `Publisher`
    ///
    /// #### Panics
    ///
    /// Panics if `Publisher` is not of type `T` or collection was not
    /// registered
    public entry fun remove_collection<T>(
        self: &mut P2PList,
        collection_pub: &Publisher,
    ) {
        assert_publisher<T>(collection_pub);
        remove_collection_<T>(self)
    }

    /// Deregister collection `T` with `P2PList` using collection witness
    ///
    /// #### Panics
    ///
    /// Panics if `Publisher` is not of type `T` or collection was not
    /// registered
    public fun remove_collection_with_witness<T>(
        _witness: DelegatedWitness<T>,
        self: &mut P2PList,
    ) {
        remove_collection_<T>(self)
    }

    /// Register collection and provide error reporting
    public entry fun remove_collection_<T>(self: &mut P2PList) {
        let collection_type = type_name::get<T>();
        assert_collection(self, collection_type);
        df::remove<TypeName, bool>(&mut self.id, collection_type);
    }

    // === Authority management ===

    /// Returns whether `P2PList` contains authority
    public fun contains_authority(self: &P2PList, auth: address): bool {
        vec_map::contains(&self.authorities, &auth)
    }

    /// Insert a new authority into `P2PList` using admin witness
    ///
    /// #### Panics
    ///
    /// Panics if the provided `P2PListOwnerCap` is not the `P2PList`
    /// admin.
    public entry fun insert_authority<Auth>(
        cap: &P2PListOwnerCap,
        self: &mut P2PList,
    ) {
        assert_cap(self, cap);
        insert_authority_<Auth>(self)
    }

    /// Insert a new authority into `P2PList` using admin witness
    ///
    /// #### Panics
    ///
    /// Panics if the provided witness is not the `P2PList` admin, use
    /// `insert_authority` endpoint instead.
    public fun insert_authority_with_witness<Admin: drop>(
        _witness: Admin,
        self: &mut P2PList,
        auth: address,
        name: String,
        pubkey: vector<u8>,
    ) {
        assert_admin_witness<Admin>(self);
        insert_authority_(self, auth, name, pubkey);
    }

    /// Register authority and provide error reporting
    fun insert_authority_(self: &mut P2PList, auth: address, name: String, pubkey: vector<u8>,) {
        assert!(!contains_authority(self, auth), EExistingAuthority);
        let entity = Entity {
            name,
            pubkey,
        };
        vec_map::insert(&mut self.authorities, auth, entity);
    }

    /// Remove authority from `P2PList`
    ///
    /// #### Panics
    ///
    /// Panics if the provided `P2PListOwnerCap` is not the `P2PList`
    /// admin.
    public entry fun remove_authority<Auth>(
        cap: &P2PListOwnerCap,
        self: &mut P2PList,
        auth: address,
    ) {
        assert_cap(self, cap);
        remove_authority_(self, auth)
    }

    /// Remove authority from `P2PList` using admin witness
    ///
    /// #### Panics
    ///
    /// Panics if the provided witness is not the `P2PList` admin, use
    /// `remove_authority` endpoint instead.
    public fun remove_authority_with_witness<Admin: drop, Auth>(
        _witness: Admin,
        self: &mut P2PList,
        auth: address,
    ) {
        assert_admin_witness<Admin>(self);
        remove_authority_(self, auth)
    }

    /// Deregister authority and provide error reporting
    fun remove_authority_(self: &mut P2PList, auth: address) {
        assert_authority(self, &auth);
        vec_map::remove(&mut self.authorities, &auth);
    }

    // === Transfers ===

    /// Checks whether given authority witness is in the P2PList, and also
    /// whether given collection witness (T) is in the P2PList.
    public fun can_be_transferred<T>(
        self: &P2PList,
        auth: address,
        collection: TypeName,
    ): bool {
        contains_authority(self, auth) &&
            contains_collection(self, collection)
    }

    /// Registers collection to use `P2PList` during the transfer.
    public fun enforce<T>(policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>) {
        ob_transfer_request::add_originbyte_rule<T, P2PListRule, bool>(
            P2PListRule {}, policy, cap, false,
        );
    }

    public fun drop<T>(policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>) {
        ob_transfer_request::remove_originbyte_rule<T, P2PListRule, bool>(
            policy, cap,
        );
    }

    public fun enforce_<T, P>(
        policy: &mut Policy<WithNft<T, P>>,
        cap: &PolicyCap,
    ) {
        request::enforce_rule_no_state<WithNft<T, P>, P2PListRule>(
            policy, cap,
        );
    }

    public fun drop_<T, P>(
        policy: &mut Policy<WithNft<T, P>>,
        cap: &PolicyCap,
    ) {
        request::drop_rule_no_state<WithNft<T, P>, P2PListRule>(policy, cap);
    }

    /// Confirms that the transfer is allowed by the `P2PList`.
    /// It adds a signature to the request.
    /// In the end, if the P2PList rule is included in the transfer policy,
    /// the transfer request can only be finished if this rule is present.
    public fun confirm_transfer<T>(
        self: &P2PList,
        req: &mut TransferRequest<T>,
    ) {
        let auth = ob_kiosk::get_transfer_request_auth(req);
        assert_transferable<T>(self, auth);
        ob_transfer_request::add_receipt(req, P2PListRule {});
    }

    /// Confirms that the transfer is allowed by the `P2PList`.
    /// It adds a signature to the request.
    /// In the end, if the P2PList rule is included in the transfer policy,
    /// the transfer request can only be finished if this rule is present.
    public fun confirm_transfer_<T, P>(
        self: &P2PList,
        req: &mut RequestBody<WithNft<T, P>>,
    ) {
        let auth = ob_kiosk::get_transfer_request_auth_(req);
        assert_transferable<T>(self, auth);
        request::add_receipt(req, &P2PListRule {});
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

    /// Asserts that `P2PListOwnerCap` is admin of `P2PList`
    ///
    /// #### Panics
    ///
    /// Panics if admin is mismatched.
    public fun assert_cap(list: &P2PList, cap: &P2PListOwnerCap) {
        assert!(&cap.for == &object::id(list), EInvalidAdmin)
    }

    /// Asserts that witness is admin of `P2PList`
    ///
    /// #### Panics
    ///
    /// Panics if admin is mismatched or `P2PList` cannot be controlled using
    /// witness.
    public fun assert_admin_witness<Admin: drop>(list: &P2PList) {
        assert!(option::is_some(&list.admin_witness), EInvalidAdmin);
        assert!(
            &type_name::get<Admin>() == option::borrow(&list.admin_witness),
            EInvalidAdmin,
        );
    }

    /// Assert that `T` may be transferred using this `P2PList`
    ///
    /// #### Panics
    ///
    /// Panics if `T` may not be transferred.
    public fun assert_collection(p2p_list: &P2PList, collection: TypeName) {
        assert!(
            contains_collection(p2p_list, collection), EInvalidCollection,
        );
    }

    /// Assert that authority may be used to transfer using this `P2PList`
    ///
    /// #### Panics
    ///
    /// Panics if `T` may not be used.
    public fun assert_authority(p2p_list: &P2PList, auth: address) {
        assert!(
            contains_authority(p2p_list, auth), EInvalidAuthority,
        );
    }

    /// Assert that `T` is transferrable and `Auth` may be used to
    /// transfer using this `P2PList`.
    ///
    /// #### Panics
    ///
    /// Panics if neither `T` is not transferrable or `Auth` is not a
    /// valid authority.
    public fun assert_transferable<T>(p2o_list: &P2PList, auth: address) {
        assert_collection(p2o_list, type_name::get<T>());
        assert_authority(p2o_list, auth);
    }

    // === Display standard ===

    struct TRANSFER_P2PList has drop {}

    fun init(otw: TRANSFER_P2PList, ctx: &mut TxContext) {
        let publisher = package::claim(otw, ctx);
        let display = display::new<P2PList>(&publisher, ctx);

        display::add(&mut display, utf8(b"name"), utf8(b"Transfer P2PList"));
        display::add(&mut display, utf8(b"link"), nft_protocol::utils::originbyte_docs_url());
        display::add(
            &mut display,
            utf8(b"description"),
            utf8(b"Defines which pubkeys are allowed to intermediate P2P transfers"),
        );

        transfer::public_share_object(display);
        package::burn_publisher(publisher);
    }
}
