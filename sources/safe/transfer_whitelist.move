module nft_protocol::transfer_whitelist {
    use std::option::{Self, Option};
    use sui::vec_set::{Self, VecSet};
    use sui::object::{Self, ID, UID};

    struct Whitelist<phantom W> has key {
        id: UID,
        /// Which collections does this whitelist apply to?
        ///
        /// A collection can be inserted only if with `&UID` reference. We treat
        /// a reference to `&UID` as an authorization token to avoid generics.
        collections: VecSet<ID>,
        /// If None, then there's no whitelist and everyone is allowed.
        /// Otherwise the ID must be in the vec set.
        authorities: Option<VecSet<ID>>,
    }

    /// To add a collection to the list, we need a confirmation by both the
    /// whitelist authority (via witness) and the collection creator (via &UID.)
    ///
    /// If the whitelist authority wants to enable any creator to add their
    /// collection to the whitelist, they can reexport this function in their
    /// module without the witness protection. However, we opt for witness
    /// collection to give the whitelist owner a way to combat spam.
    public fun insert_collection<W: drop>(
        _witness: W,
        collection: &UID,
        list: &mut Whitelist<W>,
    ) {
        vec_set::insert(
            &mut list.collections,
            object::uid_to_inner(collection)
        );
    }

    /// Any collection is allowed to remove itself from any whitelist at any
    /// time.
    ///
    /// It's always the creator's right to decide at any point what authorities
    /// can transfer NFTs of that collection.
    public fun remove_itself<W>(collection: &UID, list: &mut Whitelist<W>) {
        vec_set::remove(
            &mut list.collections,
            object::uid_as_inner(collection)
        );
    }

    /// The whitelist owner can remove any collection at any point.
    public fun remove_collection<W: drop>(
        _witness: W,
        collection: &ID,
        list: &mut Whitelist<W>,
    ) {
        vec_set::remove(&mut list.collections, collection);
    }

    /// To insert a new entity into a list we need confirmation by the whitelist
    /// authority (via witness.)
    public fun insert_entity<W: drop>(
        _witness: W,
        entity: &ID,
        list: &mut Whitelist<W>,
    ) {
        if (option::is_none(&list.authorities)) {
            list.authorities = option::some(vec_set::singleton(*entity));
        } else {
            vec_set::insert(
                option::borrow_mut(&mut list.authorities),
                *entity,
            );
        }
    }

    /// The whitelist authority (via witness) can at any point remove any
    /// entity from their list.
    public fun remove_entity<W: drop>(
        _witness: W,
        entity: &ID,
        list: &mut Whitelist<W>,
    ) {
        vec_set::remove(
            option::borrow_mut(&mut list.authorities),
            entity,
        );
    }

    public fun can_be_transferred<W>(
        collection: &ID,
        authority: &ID,
        whitelist: &Whitelist<W>,
    ): bool {
        if (option::is_none(&whitelist.authorities)) {
            return true
        };

        let e = option::borrow(&whitelist.authorities);

        vec_set::contains(e, authority) &&
            vec_set::contains(&whitelist.collections, collection)
    }
}
