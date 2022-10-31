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

    use std::ascii::String;
    use std::option::{Self, Option};
    use std::type_name;
    use sui::object;
    use sui::object::UID;
    use sui::tx_context::TxContext;
    use sui::vec_set::{Self, VecSet};

    struct Whitelist<phantom Admin> has key, store {
        id: UID,
        /// Which collections does this whitelist apply to?
        ///
        /// This is a string gotten from `type_name::get` function
        collections: VecSet<String>,
        /// If None, then there's no whitelist and everyone is allowed.
        ///
        /// Otherwise we use a witness pattern but store the witness object as
        /// the output of `type_name::get`.
        authorities: Option<VecSet<String>>,
    }

    public fun create<Admin: drop>(
        _witness: Admin,
        ctx: &mut TxContext
    ): Whitelist<Admin> {
        Whitelist {
            id: object::new(ctx),
            collections: vec_set::empty(),
            authorities: option::none(),
        }
    }

    /// To add a collection to the list, we need a confirmation by both the
    /// whitelist authority and the collection creator via witness pattern.
    ///
    /// If the whitelist authority wants to enable any creator to add their
    /// collection to the whitelist, they can reexport this function in their
    /// module without the witness protection. However, we opt for witness
    /// collection to give the whitelist owner a way to combat spam.
    public fun insert_collection<Admin: drop, CW: drop>(
        _whitelist_witness: Admin,
        _collection_witness: CW,
        list: &mut Whitelist<Admin>,
    ) {
        vec_set::insert(&mut list.collections, type_into_string<CW>());
    }

    /// Any collection is allowed to remove itself from any whitelist at any
    /// time.
    ///
    /// It's always the creator's right to decide at any point what authorities
    /// can transfer NFTs of that collection.
    public fun remove_itself<Admin, CW: drop>(
        _collection_witness: CW,
        list: &mut Whitelist<Admin>,
    ) {
        vec_set::remove(&mut list.collections, &type_into_string<CW>());
    }

    /// The whitelist owner can remove any collection at any point.
    public fun remove_collection<Admin: drop>(
        _whitelist_witness: Admin,
        collection_witness_type: &String,
        list: &mut Whitelist<Admin>,
    ) {
        vec_set::remove(&mut list.collections, collection_witness_type);
    }

    /// To insert a new authority into a list we need confirmation by the
    /// whitelist authority (via witness.)
    public fun insert_authority<Admin: drop>(
        _whitelist_witness: Admin,
        authority_witness_type: String,
        list: &mut Whitelist<Admin>,
    ) {
        if (option::is_none(&list.authorities)) {
            list.authorities = option::some(
                vec_set::singleton(authority_witness_type)
            );
        } else {
            vec_set::insert(
                option::borrow_mut(&mut list.authorities),
                authority_witness_type,
            );
        }
    }

    /// The whitelist authority (via witness) can at any point remove any
    /// authority from their list.
    public fun remove_authority<Admin: drop>(
        _whitelist_witness: Admin,
        authority_witness_type: &String,
        list: &mut Whitelist<Admin>,
    ) {
        vec_set::remove(
            option::borrow_mut(&mut list.authorities),
            authority_witness_type,
        );
    }

    /// Checks whether given authority witness is in the whitelist, and also
    /// whether given collection witness (CW) is in the whitelist.
    public fun can_be_transferred<Admin, CW, Auth: drop>(
        _authority_witness: Auth,
        whitelist: &Whitelist<Admin>,
    ): bool {
        if (option::is_none(&whitelist.authorities)) {
            return true
        };

        let e = option::borrow(&whitelist.authorities);

        vec_set::contains(e, &type_into_string<Auth>()) &&
            vec_set::contains(&whitelist.collections, &type_into_string<CW>())
    }

    fun type_into_string<T>(): String {
        type_name::into_string(type_name::get<T>())
    }
}
