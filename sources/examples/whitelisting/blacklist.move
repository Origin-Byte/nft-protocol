module nft_protocol::blacklist {
    //! Show cases an implementation of blacklisting of NFT transfers.
    //!
    //! The whitelist is by default open to all. Therefore returning a mutable
    //! reference to it with `borrow_mut_inner` means anyone can call transfer.
    //!
    //! However, we require a witness type to give that reference.
    //! If that a witness type is banned, then we fail the tx.

    use nft_protocol::collection::Collection;
    use nft_protocol::transfer_whitelist::{Self, Whitelist};
    use std::ascii::String;
    use std::type_name;
    use sui::object::{Self, UID, ID};
    use sui::transfer::{transfer, share_object};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set::{Self, VecSet};

    struct Witness has drop {}

    struct Blacklist has key {
        id: UID,
        banned_witnesses: VecSet<String>,
        inner: Whitelist<Witness>,
    }

    /// The owner of this single writer object is the admin of this blacklist
    /// organization.
    struct OwnerCap has key {
        id: UID,
        list_id: ID,
    }

    /// Anyone can create their own blacklist.
    public entry fun create(ctx: &mut TxContext) {
        let inner = transfer_whitelist::create(Witness {}, ctx);
        let list = Blacklist {
            id: object::new(ctx),
            banned_witnesses: vec_set::empty(),
            inner,
        };
        let list_id = object::id(&list);

        share_object(list);
        transfer(
            OwnerCap { id: object::new(ctx), list_id, },
            tx_context::sender(ctx),
        );
    }

    /// Only the creator is allowed to insert their collection.
    ///
    /// However, any creator can insert their collection into simple whitelist.
    public entry fun insert_collection<T, M: store>(
        collection: &Collection<T, M>,
        list: &mut Blacklist,
        ctx: &mut TxContext,
    ) {
        transfer_whitelist::insert_collection(
            Witness {},
            collection,
            &mut list.inner,
            ctx,
        );
    }

    /// Anyone can use this list to authorize a transfer as long as they have
    /// an access to a witness that is not banned.
    public fun borrow_inner<Admin: drop>(
        _authority_witness: Admin,
        list: &Blacklist,
    ): &Whitelist<Witness> {
        let is_banned = vec_set::contains(
            &list.banned_witnesses,
            &type_name::into_string(type_name::get<Admin>()),
        );
        assert!(!is_banned, 0);

        &list.inner
    }

    /// Only the owner of the whitelist can manage it
    public entry fun ban(
        authority_witness_type: String,
        owner: &OwnerCap,
        list: &mut Blacklist,
        _ctx: &mut TxContext,
    ) {
        assert!(object::id(list) == owner.list_id, 0);

        vec_set::insert(&mut list.banned_witnesses, authority_witness_type);
    }

    /// Only the owner of the whitelist can manage it
    public entry fun unban(
        authority_witness_type: String,
        owner: &OwnerCap,
        list: &mut Blacklist,
        _ctx: &mut TxContext,
    ) {
        assert!(object::id(list) == owner.list_id, 0);

        vec_set::remove(&mut list.banned_witnesses, &authority_witness_type);
    }
}
