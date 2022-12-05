module nft_protocol::transfer_whitelist {
    //! Whitelists NFT transfers.
    //!
    //! Three generics at play:
    //! 1. Admin (whitelist witness) enables any organization to start their own
    //!     whitelist and manage it according to their own rules;
    //! 2. CW (collection witness) enpowers creators to add or remove their
    //!     collections to whitelists;
    //! 3. Auth (3rd party witness) is used to authorize contracts via their
    //!     witness types. If e.g. an orderbook trading contract wants to be
    //!     included in a whitelist, the whitelist admin adds the stringified
    //!     version of their witness type. The OB then uses this witness type
    //!     to authorize transfers.

    use nft_protocol::utils;
    use nft_protocol::err;
    use std::option::{Self, Option};
    use std::type_name::{Self, TypeName};
    use sui::object;
    use sui::object::UID;
    use sui::tx_context::TxContext;
    use sui::vec_set::{Self, VecSet};

    struct Whitelist has key, store {
        id: UID,
        /// We don't store it as generic because then it has to be propagated
        /// around and it's very unergonomic.
        admin_witness: TypeName,
        /// Which collections does this whitelist apply to?
        ///
        /// We use reflection to avoid generics.
        collections: VecSet<TypeName>,
        /// If None, then there's no whitelist and everyone is allowed.
        ///
        /// Otherwise we use a witness pattern but store the witness object as
        /// the output of `type_name::get`.
        authorities: Option<VecSet<TypeName>>,
    }

    /// Gives the collection admin a capability to insert and remove their
    /// collection from a whitelist.
    struct CollectionCap<phantom C> has key, store {
        id: UID,
    }

    public fun create<Admin: drop>(
        _witness: Admin,
        ctx: &mut TxContext,
    ): Whitelist {
        Whitelist {
            id: object::new(ctx),
            admin_witness: type_name::get<Admin>(),
            collections: vec_set::empty(),
            authorities: option::none(),
        }
    }

    public fun create_collection_cap<C, W>(
        _witness: &W,
        ctx: &mut TxContext,
    ): CollectionCap<C> {
        utils::assert_same_module_as_witness<C, W>();
        CollectionCap {
            id: object::new(ctx),
        }
    }

    /// To add a collection to the list, we need a confirmation by both the
    /// whitelist authority and the collection creator via witness pattern.
    ///
    /// If the whitelist authority wants to enable any creator to add their
    /// collection to the whitelist, they can reexport this function in their
    /// module without the witness protection. However, we opt for witness
    /// collection to give the whitelist owner a way to combat spam.
    public fun insert_collection<Admin: drop, C>(
        _whitelist_witness: Admin,
        _authority: &CollectionCap<C>,
        list: &mut Whitelist,
        ctx: &mut TxContext,
    ) {
        assert_admin_witness<Admin>(list);

        vec_set::insert(&mut list.collections, type_name::get<C>());
    }

    /// Any collection is allowed to remove itself from any whitelist at any
    /// time.
    ///
    /// It's always the creator's right to decide at any point what authorities
    /// can transfer NFTs of that collection.
    public fun remove_itself<C>(
        _authority: &CollectionCap<C>,
        list: &mut Whitelist,
        ctx: &mut TxContext,
    ) {
        vec_set::remove(&mut list.collections, &type_name::get<C>());
    }

    /// The whitelist owner can remove any collection at any point.
    public fun remove_collection<Admin: drop, C>(
        _whitelist_witness: Admin,
        list: &mut Whitelist,
    ) {
        assert_admin_witness<Admin>(list);
        vec_set::remove(&mut list.collections, &type_name::get<C>());
    }

    /// Removes all collections from this list.
    public fun clear_collections<Admin: drop>(
        _whitelist_witness: Admin,
        list: &mut Whitelist,
    ) {
        assert_admin_witness<Admin>(list);
        list.collections = vec_set::empty();
    }

    /// To insert a new authority into a list we need confirmation by the
    /// whitelist authority (via witness.)
    public fun insert_authority<Admin: drop, Auth>(
        _whitelist_witness: Admin,
        list: &mut Whitelist,
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

    /// The whitelist authority (via witness) can at any point remove any
    /// authority from their list.
    public fun remove_authority<Admin: drop, Auth>(
        _whitelist_witness: Admin,
        list: &mut Whitelist,
    ) {
        assert_admin_witness<Admin>(list);

        vec_set::remove(
            option::borrow_mut(&mut list.authorities),
            &type_name::get<Auth>(),
        );
    }

    /// Checks whether given authority witness is in the whitelist, and also
    /// whether given collection witness (C) is in the whitelist.
    public fun can_be_transferred<C, Auth: drop>(
        _authority_witness: Auth,
        whitelist: &Whitelist,
    ): bool {
        let applies_to_collection =
            vec_set::contains(&whitelist.collections, &type_name::get<C>());

        if (option::is_none(&whitelist.authorities)) {
            return applies_to_collection
        };

        let e = option::borrow(&whitelist.authorities);

        applies_to_collection && vec_set::contains(e, &type_name::get<Auth>())
    }

    fun assert_admin_witness<Admin>(
        list: &Whitelist,
    ) {
        assert!(
            type_name::get<Admin>() == list.admin_witness,
            err::sender_not_whitelist_admin(),
        );
    }
}
