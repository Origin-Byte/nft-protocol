module nft_protocol::transfer_whitelist {
    use std::option::{Self, Option};
    use std::type_name;
    use sui::vec_set::{Self, VecSet};
    use sui::object::UID;
    use std::ascii::String;

    struct Whitelist<phantom W> has key {
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

    /// To add a collection to the list, we need a confirmation by both the
    /// whitelist authority (via witness) and the collection creator (via &UID.)
    ///
    /// If the whitelist authority wants to enable any creator to add their
    /// collection to the whitelist, they can reexport this function in their
    /// module without the witness protection. However, we opt for witness
    /// collection to give the whitelist owner a way to combat spam.
    public fun insert_collection<WW: drop, CW: drop>(
        _whitelist_witness: WW,
        _collection_witness: CW,
        list: &mut Whitelist<WW>,
    ) {
        vec_set::insert(&mut list.collections, type_into_string<CW>());
    }

    /// Any collection is allowed to remove itself from any whitelist at any
    /// time.
    ///
    /// It's always the creator's right to decide at any point what authorities
    /// can transfer NFTs of that collection.
    public fun remove_itself<WW, CW: drop>(
        _collection_witness: CW,
        list: &mut Whitelist<WW>,
    ) {
        vec_set::remove(&mut list.collections, &type_into_string<CW>());
    }

    /// The whitelist owner can remove any collection at any point.
    public fun remove_collection<WW: drop>(
        _whitelist_witness: WW,
        collection_witness_type: &String,
        list: &mut Whitelist<WW>,
    ) {
        vec_set::remove(&mut list.collections, collection_witness_type);
    }

    /// To insert a new authority into a list we need confirmation by the whitelist
    /// authority (via witness.)
    public fun insert_authority<WW: drop>(
        _whitelist_witness: WW,
        authority_witness_type: String,
        list: &mut Whitelist<WW>,
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
    public fun remove_authority<WW: drop>(
        _whitelist_witness: WW,
        authority_witness_type: &String,
        list: &mut Whitelist<WW>,
    ) {
        vec_set::remove(
            option::borrow_mut(&mut list.authorities),
            authority_witness_type,
        );
    }

    public fun can_be_transferred<WW, CW, Auth: drop>(
        _authority_witness: Auth,
        whitelist: &Whitelist<WW>,
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
