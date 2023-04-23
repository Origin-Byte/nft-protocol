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
module nft_protocol::transfer_allowlist {
    use nft_protocol::request::{Self, RequestBody, Policy, PolicyCap, WithNft};
    use sui::transfer_policy::{Self, TransferPolicy, TransferPolicyCap};
    use nft_protocol::ob_kiosk;
    use nft_protocol::ob_transfer_request::{Self, TransferRequest};
    use nft_protocol::utils;
    use nft_protocol::witness::Witness as DelegatedWitness;
    use std::option::{Self, Option};
    use std::string::utf8;
    use std::type_name::{Self, TypeName};
    use sui::display;
    use sui::dynamic_field as df;
    use sui::table_vec::{Self, TableVec};
    use sui::object::{Self, UID};
    use sui::package::{Self, Publisher};
    use sui::transfer::{Self, public_share_object};
    use sui::tx_context::TxContext;
    use sui::vec_set::{Self, VecSet};

    // === Errors ===

    /// Package publisher mismatch
    const EPackagePublisherMismatch: u64 = 0;

    /// Invalid admin
    ///
    /// Create new `Allowlist` using `create` with desired admin.
    const EInvalidAdmin: u64 = 1;

    /// Invalid collection
    ///
    /// Call `insert_collection` to insert a collection.
    const EInvalidCollection: u64 = 2;

    /// Invalid transfer authority
    ///
    /// Call `insert_authority` to insert an authority.
    const EInvalidAuthority: u64 = 3;

    // === Structs ===

    struct Allowlist has key, store {
        id: UID,
        /// We don't store it as generic because then it has to be propagated
        /// around and it's very unergonomic.
        admin_witness: TypeName,
        /// If None, then there's no allowlist and everyone is allowed.
        ///
        /// Otherwise we use a witness pattern but store the witness object as
        /// the output of `type_name::get`.
        authorities: Option<VecSet<TypeName>>,
    }

    /// `sui::transfer_policy::TransferPolicy` can have this rule to enforce
    /// that only allowlisted contracts can transfer NFTs.
    ///
    /// Note that this rule depends on `ob_kiosk::get_transfer_request_auth`
    /// and only works with `ob_transfer_request::TransferRequest`.
    ///
    /// That's because the sui implementation of `TransferRequest` is simplified
    /// and does not support safe metadata about the originator of the transfer.
    struct AllowlistRule has drop {}

    /// Dynamic field key for storing collection typenames.
    /// Which collections does this allowlist apply to?
    struct CollectionDfKey<phantom T> has copy, drop, store {}

    // === Management ===

    /// Creates a new `Allowlist`
    public fun create<Admin>(
        _witness: DelegatedWitness<Admin>, ctx: &mut TxContext,
    ): Allowlist {
        Allowlist {
            id: object::new(ctx),
            admin_witness: type_name::get<Admin>(),
            authorities: option::none(),
        }
    }

    /// Creates and shares a new `Allowlist`
    public fun init_allowlist<Admin>(
        witness: DelegatedWitness<Admin>, ctx: &mut TxContext,
    ) {
        transfer::public_share_object(create(witness, ctx));
    }

    public fun insert_collection<T, Admin>(
        _allowlist_witness: DelegatedWitness<Admin>,
        _collection_witness: DelegatedWitness<T>,
        self: &mut Allowlist,
    ) {
        assert_admin_witness<Admin>(self);
        // We only care about the DF Key, we store a bool as the DF value
        // as it's the smallest thing we can store
        df::add(&mut self.id, CollectionDfKey<T> {}, true);
    }

    /// To add a collection to the list, we need a confirmation by both the
    /// allowlist authority and the collection creator via publisher.
    ///
    /// If the allowlist authority wants to enable any creator to add their
    /// collection to the allowlist, they can reexport this function in their
    /// module without the witness protection.
    /// However, we opt for witness protection to give the allowlist owner a way
    /// to combat spam.
    public fun insert_collection_with_publisher<T, Admin>(
        _witness: DelegatedWitness<Admin>,
        self: &mut Allowlist,
        collection_pub: &Publisher,
    ) {
        utils::assert_package_publisher<T>(collection_pub);
        assert_admin_witness<Admin>(self);

        // We only care about the DF Key, we store a bool as the DF value
        // as it's the smallest thing we can store
        df::add(&mut self.id, CollectionDfKey<T> {}, true);
    }

    /// Any collection is allowed to remove itself from any allowlist at any
    /// time.
    ///
    /// It's always the creator's right to decide at any point what authorities
    /// can transfer NFTs of that collection.
    public fun remove_itself<T>(
        _witness: DelegatedWitness<T>, self: &mut Allowlist,
    ) {
        df::remove<CollectionDfKey<T>, bool>(&mut self.id, CollectionDfKey<T> {});
    }

    /// Any collection is allowed to remove itself from any allowlist at any
    /// time.
    ///
    /// It's always the creator's right to decide at any point what authorities
    /// can transfer NFTs of that collection.
    public fun remove_itself_with_publisher<T>(
        self: &mut Allowlist, collection_pub: &Publisher,
    ) {
        utils::assert_package_publisher<T>(collection_pub);
        df::remove<CollectionDfKey<T>, bool>(&mut self.id, CollectionDfKey<T> {});
    }

    /// The allowlist owner can remove any collection at any point.
    public fun remove_collection<T, Admin>(
        _witness: DelegatedWitness<Admin>, self: &mut Allowlist,
    ) {
        // TODO: Do we want to give the allowlist owner this power?
        assert_admin_witness<Admin>(self);
        df::remove<CollectionDfKey<T>, bool>(&mut self.id, CollectionDfKey<T> {});
    }

    /// To insert a new authority into a list we need confirmation by the
    /// allowlist authority (via witness.)
    public fun insert_authority<Admin, Auth>(
        _witness: DelegatedWitness<Admin>, self: &mut Allowlist,
    ) {
        assert_admin_witness<Admin>(self);

        if (option::is_none(&self.authorities)) {
            self.authorities = option::some(
                vec_set::singleton(type_name::get<Auth>())
            );
        } else {
            vec_set::insert(
                option::borrow_mut(&mut self.authorities),
                type_name::get<Auth>(),
            );
        }
    }

    /// The allowlist authority (via witness) can at any point remove any
    /// authority from their list.
    ///
    /// If this is the last authority in the list, we do NOT go back to a free
    /// for all allowlist.
    public fun remove_authority<Admin, Auth>(
        _witness: DelegatedWitness<Admin>, self: &mut Allowlist,
    ) {
        assert_admin_witness<Admin>(self);

        vec_set::remove(
            option::borrow_mut(&mut self.authorities),
            &type_name::get<Auth>(),
        );
    }

    // === Transfers ===

    /// Checks whether given authority witness is in the allowlist, and also
    /// whether given collection witness (T) is in the allowlist.
    public fun can_be_transferred<T>(self: &Allowlist, auth: &TypeName): bool {
        contains_authority(self, auth) &&
            contains_collection<T>(self)
    }

    /// Returns whether `Allowlist` contains collection `T`
    public fun contains_collection<T>(self: &Allowlist): bool {
        df::exists_(&self.id, CollectionDfKey<T> {})
    }

    /// Returns whether `Allowlist` contains type
    public fun contains_authority(self: &Allowlist, auth: &TypeName): bool {
        if (option::is_none(&self.authorities)) {
            // If no authorities are defined this effectively means that all
            // authorities are registered.
            true
        } else {
            let e = option::borrow(&self.authorities);
            vec_set::contains(e, auth)
        }
    }

    /// Returns whether `Allowlist` requires an authority to transfer
    public fun requires_authority(self: &Allowlist): bool {
        option::is_some(&self.authorities)
    }

    /// Registers collection to use `Allowlist` during the transfer.
    public fun enforce<T>(
        policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>,
    ) {
        transfer_policy::add_rule<T, AllowlistRule, bool>(
            AllowlistRule {}, policy, cap, false,
        );
    }

    public fun drop<T>(
        policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>
    ) {
        transfer_policy::remove_rule<T, AllowlistRule, bool>(policy, cap);
    }

    /// Confirms that the transfer is allowed by the `Allowlist`.
    /// It adds a signature to the request.
    /// In the end, if the allowlist rule is included in the transfer policy,
    /// the transfer request can only be finished if this rule is present.
    public fun confirm_transfer<T>(
        self: &Allowlist, req: &mut TransferRequest<T>,
    ) {
        let auth = ob_kiosk::get_transfer_request_auth(req);
        assert_transferable<T>(self, auth);
        transfer_policy::add_receipt(AllowlistRule {}, ob_transfer_request::inner_mut(req));
    }

    /// Registers collection to use `Allowlist` during the transfer.
    public fun enforce_<T, P>(
        policy: &mut Policy<WithNft<T, P>>, cap: &PolicyCap,
    ) {
        request::enforce_rule_no_state<WithNft<T, P>, AllowlistRule>(policy, cap);
    }

    public fun drop_<T, P>(policy: &mut Policy<WithNft<T, P>>, cap: &PolicyCap) {
        request::drop_rule_no_state<WithNft<T, P>, AllowlistRule>(policy, cap);
    }

    /// Confirms that the transfer is allowed by the `Allowlist`.
    /// It adds a signature to the request.
    /// In the end, if the allowlist rule is included in the transfer policy,
    /// the transfer request can only be finished if this rule is present.
    public fun confirm_transfer_<T, P>(
        self: &Allowlist, req: &mut RequestBody<WithNft<T, P>>,
    ) {
        let auth = ob_kiosk::get_transfer_request_auth_(req);
        assert_transferable<T>(self, auth);
        request::add_receipt(req, &AllowlistRule {});
    }

    // === Assertions ===

    /// Asserts that witness is admin of `Allowlist`
    ///
    /// #### Panics
    ///
    /// Panics if admin is mismatched
    public fun assert_admin_witness<Admin>(list: &Allowlist) {
        assert!(
            type_name::get<Admin>() == list.admin_witness,
            EInvalidAdmin,
        );
    }

    /// Assert that `T` may be transferred using this `Allowlist`
    ///
    /// #### Panics
    ///
    /// Panics if `T` may not be transferred.
    public fun assert_collection<T>(allowlist: &Allowlist) {
        assert!(
            contains_collection<T>(allowlist), EInvalidCollection,
        );
    }

    /// Assert that `auth` type may be used to transfer using this `Allowlist`
    public fun assert_authority(allowlist: &Allowlist, auth: &TypeName) {
        assert!(
            contains_authority(allowlist, auth), EInvalidAuthority,
        );
    }

    /// Assert that `C` is transferrable and `Auth` may be used to
    /// transfer using this `Allowlist`.
    ///
    /// #### Panics
    ///
    /// Panics if neither `C` is not transferrable or `Auth` is not a
    /// valid authority.
    public fun assert_transferable<T>(allowlist: &Allowlist, auth: &TypeName) {
        assert_collection<T>(allowlist);
        assert_authority(allowlist, auth);
    }

    // === Display standard ===

    struct TRANSFER_ALLOWLIST has drop {}

    fun init(otw: TRANSFER_ALLOWLIST, ctx: &mut TxContext) {
        let publisher = package::claim(otw, ctx);
        let display = display::new<Allowlist>(&publisher, ctx);

        display::add(&mut display, utf8(b"name"), utf8(b"Transfer Allowlist"));
        display::add(&mut display, utf8(b"link"), utils::originbyte_docs_url());
        display::add(
            &mut display,
            utf8(b"description"),
            utf8(b"Which authorities can transfer NFTs of which collections"),
        );

        public_share_object(display);
        package::burn_publisher(publisher);
    }
}
