module nft_protocol::blacklist {
    //! Show cases an implementation of blacklisting of NFT transfers.
    //!
    //! The whitelist is by default open to all. Therefore returning a mutable
    //! reference to it with `borrow_mut_inner` means anyone can call transfer.
    //!
    //! However, we require a one time witness type to give that reference. And
    //! if such witness is banned, then we fail the tx.

    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer::{transfer, share_object};
    use std::ascii::String;
    use nft_protocol::transfer_whitelist::{Self, Whitelist};
    use std::type_name;
    use sui::vec_set::{Self, VecSet};
    use sui::types::is_one_time_witness;

    struct BLACKLIST has drop {}

    struct Blacklist has key {
        id: UID,
        banned_witnesses: VecSet<String>,
        inner: Whitelist<BLACKLIST>,
    }

    /// The owner of this single writer object is the admin of this blacklist
    /// organization.
    struct OwnerCap has key {
        id: UID,
    }

    /// Anyone can create their own blacklist.
    public entry fun create(ctx: &mut TxContext) {
        share_object(Blacklist {
            id: object::new(ctx),
            banned_witnesses: vec_set::empty(),
            inner: transfer_whitelist::create(BLACKLIST {}, ctx),
        });

        transfer(OwnerCap { id: object::new(ctx) }, tx_context::sender(ctx));
    }

    /// Only the creator is allowed to insert their collection.
    ///
    /// However, any creator can insert their collection into simple whitelist.
    public fun insert_collection<CW: drop>(
        collection_witness: CW,
        list: &mut Blacklist,
    ) {
        transfer_whitelist::insert_collection(
            BLACKLIST {},
            collection_witness,
            &mut list.inner,
        );
    }

    /// Anyone can use this list to authorize a transfer as long as they have
    /// an access to a witness that is not banned.
    public fun borrow_mut_inner<Admin: drop>(
        authority_witness: Admin,
        list: &mut Blacklist,
    ): &mut Whitelist<BLACKLIST> {
        assert!(is_one_time_witness(&authority_witness), 0);

        let is_banned = vec_set::contains(
            &list.banned_witnesses,
            &type_name::into_string(type_name::get<Admin>()),
        );
        assert!(!is_banned, 0);

        &mut list.inner
    }

    /// Only the owner of the whitelist can manage it
    public entry fun ban(
        authority_witness_type: String,
        _owner: &OwnerCap,
        list: &mut Blacklist,
        _ctx: &mut TxContext,
    ) {
        vec_set::insert(&mut list.banned_witnesses, authority_witness_type);
    }

    /// Only the owner of the whitelist can manage it
    public entry fun unban(
        authority_witness_type: String,
        _owner: &OwnerCap,
        list: &mut Blacklist,
        _ctx: &mut TxContext,
    ) {
        vec_set::remove(&mut list.banned_witnesses, &authority_witness_type);
    }
}
