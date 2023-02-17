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
/// Three generics at play:
/// 1. Admin (allowlist witness) enables any organization to start their own
///     allowlist and manage it according to their own rules;
/// 2. CW (collection witness) enpowers creators to add or remove their
///     collections to allowlists;
/// 3. Auth (3rd party witness) is used to authorize contracts via their
///     witness types. If e.g. an orderbook trading contract wants to be
///     included in a allowlist, the allowlist admin adds the stringified
///     version of their witness type. The OB then uses this witness type
///     to authorize transfers.
module nft_protocol::transfer_allowlist {
    use std::option::{Self, Option};
    use std::type_name::{Self, TypeName};

    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::vec_set::{Self, VecSet};

    use nft_protocol::witness::Witness as DelegatedWitness;

    /// Invalid admin
    ///
    /// Create new `Allowlist` using `create` with desired admin.
    const EINVALID_ADMIN: u64 = 1;

    /// Invalid collection
    ///
    /// Call `insert_collection` to insert a collection.
    const EINVALID_COLLECTION: u64 = 2;

    /// Invalid transfer authority
    ///
    /// Call `insert_authority` to insert an authority.
    const EINVALID_AUTHORITY: u64 = 3;

    /// `Allowlist` requires an authority to be provided
    const EREQUIRES_AUTHORITTY: u64 = 4;

    struct Allowlist has key, store {
        id: UID,
        /// We don't store it as generic because then it has to be propagated
        /// around and it's very unergonomic.
        admin_witness: TypeName,
        /// Which collections does this allowlist apply to?
        ///
        /// We use reflection to avoid generics.
        collections: VecSet<TypeName>,
        /// If None, then there's no allowlist and everyone is allowed.
        ///
        /// Otherwise we use a witness pattern but store the witness object as
        /// the output of `type_name::get`.
        authorities: Option<VecSet<TypeName>>,
    }

    /// Gives the collection admin a capability to insert and remove their
    /// collection from a allowlist.
    ///
    /// To create this cap, the contract which defines the collection generic
    /// must call `create_collection_cap` with a witness that belongs to the
    /// same contract as the generic `C`.
    /// Additionally, the witness type must be called `Witness`.
    struct CollectionControlCap<phantom C> has key, store {
        id: UID,
    }

    /// Creates a new `Allowlist`
    public fun create<Admin>(
        _witness: &Admin,
        ctx: &mut TxContext,
    ): Allowlist {
        Allowlist {
            id: object::new(ctx),
            admin_witness: type_name::get<Admin>(),
            collections: vec_set::empty(),
            authorities: option::none(),
        }
    }

    /// Creates and shares a new `Allowlist`
    public fun init_allowlist<Admin>(
        witness: &Admin,
        ctx: &mut TxContext,
    ) {
        let allowlist = create(witness, ctx);
        transfer::share_object(allowlist);
    }

    /// See the docs for struct `CollectionControlCap`.
    public fun create_collection_cap<C>(
        _witness: DelegatedWitness<C>,
        ctx: &mut TxContext,
    ): CollectionControlCap<C> {
        CollectionControlCap { id: object::new(ctx) }
    }

    public fun insert_collection<C, Admin>(
        _allowlist_witness: &Admin,
        _collection_witness: DelegatedWitness<C>,
        list: &mut Allowlist,
    ) {
        assert_admin_witness<Admin>(list);
        vec_set::insert(&mut list.collections, type_name::get<C>());
    }

    /// To add a collection to the list, we need a confirmation by both the
    /// allowlist authority and the collection creator via witness pattern.
    ///
    /// If the allowlist authority wants to enable any creator to add their
    /// collection to the allowlist, they can reexport this function in their
    /// module without the witness protection. However, we opt for witness
    /// collection to give the allowlist owner a way to combat spam.
    public fun insert_collection_with_cap<C, Admin>(
        _allowlist_witness: &Admin,
        _authority: &CollectionControlCap<C>,
        list: &mut Allowlist,
    ) {
        assert_admin_witness<Admin>(list);

        vec_set::insert(&mut list.collections, type_name::get<C>());
    }

    /// Any collection is allowed to remove itself from any allowlist at any
    /// time.
    ///
    /// It's always the creator's right to decide at any point what authorities
    /// can transfer NFTs of that collection.
    public entry fun remove_itself<C>(
        _authority: &CollectionControlCap<C>,
        list: &mut Allowlist,
    ) {
        vec_set::remove(&mut list.collections, &type_name::get<C>());
    }

    /// The allowlist owner can remove any collection at any point.
    public fun remove_collection<Admin: drop, C>(
        _allowlist_witness: Admin,
        list: &mut Allowlist,
    ) {
        assert_admin_witness<Admin>(list);
        vec_set::remove(&mut list.collections, &type_name::get<C>());
    }

    /// Removes all collections from this list.
    public fun clear_collections<Admin: drop>(
        _allowlist_witness: Admin,
        list: &mut Allowlist,
    ) {
        assert_admin_witness<Admin>(list);
        list.collections = vec_set::empty();
    }

    /// To insert a new authority into a list we need confirmation by the
    /// allowlist authority (via witness.)
    public fun insert_authority<Admin: drop, Auth>(
        _allowlist_witness: Admin,
        list: &mut Allowlist,
    ) {
        assert_admin_witness<Admin>(list);

        if (option::is_none(&list.authorities)) {
            list.authorities = option::some(
                vec_set::singleton(type_name::get<Auth>())
            );
        } else {
            vec_set::insert(
                option::borrow_mut(&mut list.authorities),
                type_name::get<Auth>(),
            );
        }
    }

    /// The allowlist authority (via witness) can at any point remove any
    /// authority from their list.
    public fun remove_authority<Admin: drop, Auth>(
        _allowlist_witness: Admin,
        list: &mut Allowlist,
    ) {
        assert_admin_witness<Admin>(list);

        vec_set::remove(
            option::borrow_mut(&mut list.authorities),
            &type_name::get<Auth>(),
        );
    }

    /// Checks whether given authority witness is in the allowlist, and also
    /// whether given collection witness (C) is in the allowlist.
    public fun can_be_transferred<C, Auth>(allowlist: &Allowlist): bool {
        contains_authority<Auth>(allowlist) &&
            contains_collection<C>(allowlist)
    }

    /// Returns whether `Allowlist` contains collection `C`
    public fun contains_collection<C>(allowlist: &Allowlist): bool {
        vec_set::contains(&allowlist.collections, &type_name::get<C>())
    }

    /// Returns whether `Allowlist` contains authority `Auth`
    public fun contains_authority<Auth>(allowlist: &Allowlist): bool {
        if (option::is_none(&allowlist.authorities)) {
            // If no authorities are defined this effectively means that all
            // authorities are registered.
            true
        } else {
            let e = option::borrow(&allowlist.authorities);
            vec_set::contains(e, &type_name::get<Auth>())
        }
    }

    /// Returns whether `Allowlist` requires an authority to transfer
    public fun requires_authority(allowlist: &Allowlist): bool {
        option::is_some(&allowlist.authorities)
    }

    // === Assertions ===

    /// Asserts that witness is admin of `Allowlist`
    ///
    /// #### Panics
    ///
    /// Panics if admin is mismatched
    fun assert_admin_witness<Admin>(list: &Allowlist) {
        assert!(
            type_name::get<Admin>() == list.admin_witness,
            EINVALID_ADMIN,
        );
    }

    /// Assert that `Nft<C>` may be transferred using this `Allowlist`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft<C>` may not be transferred.
    public fun assert_collection<C>(allowlist: &Allowlist) {
        assert!(
            contains_collection<C>(allowlist), EINVALID_COLLECTION,
        );
    }

    /// Assert that `Auth` may be used to transfer using this `Allowlist`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft<C>` may not be transferred.
    public fun assert_authority<Auth>(allowlist: &Allowlist) {
        assert!(
            contains_authority<Auth>(allowlist), EINVALID_AUTHORITY,
        );
    }

    /// Assert that `Nft<C>` is transferrable and `Auth` may be used to
    /// transfer using this `Allowlist`.
    ///
    /// #### Panics
    ///
    /// Panics if neither `Nft<C>` is not transferrable or `Auth` is not a
    /// valid authority.
    public fun assert_transferable<C, Auth>(allowlist: &Allowlist) {
        assert_collection<C>(allowlist);
        assert_authority<Auth>(allowlist);
    }
}
