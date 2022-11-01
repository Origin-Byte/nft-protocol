module nft_protocol::simple_whitelist {
    //! Show cases simple whitelist implementation.
    //!
    //! Anyone can create a new whitelist.
    //! Any creator can add/remove their collection from any simple whitelist.
    //! Only the owner of a whitelist can add/remove authorities (such as
    //! orderbook or auction contracts.)

    use nft_protocol::collection::Collection;
    use nft_protocol::transfer_whitelist::{Self, Whitelist};
    use std::ascii::String;
    use sui::object::{Self, UID, ID};
    use sui::transfer::{transfer, share_object};
    use sui::tx_context::{Self, TxContext};

    struct Witness has drop {}

    /// The owner of this single writer object is the admin of this whitelisting
    /// organization.
    struct OwnerCap has key {
        id: UID,
        list_id: ID,
    }

    /// Anyone can create their own simple whitelist.
    public entry fun create(ctx: &mut TxContext) {
        let list = transfer_whitelist::create(Witness {}, ctx);
        let list_id = object::id(&list);

        share_object(list);
        transfer(
            OwnerCap { id: object::new(ctx), list_id },
            tx_context::sender(ctx),
        );
    }

    /// Only the creator is allowed to insert their collection.
    ///
    /// However, any creator can insert their collection into simple whitelist.
    public entry fun insert_collection<T, M: store>(
        collection: &Collection<T, M>,
        list: &mut Whitelist<Witness>,
        ctx: &mut TxContext,
    ) {
        transfer_whitelist::insert_collection(
            Witness {},
            collection,
            list,
            ctx,
        );
    }

    /// Only the owner of the whitelist can manage it
    public entry fun insert_authority(
        authority_witness_type: String,
        owner: &OwnerCap,
        list: &mut Whitelist<Witness>,
        _ctx: &mut TxContext,
    ) {
        assert!(object::id(list) == owner.list_id, 0);

        transfer_whitelist::insert_authority(
            Witness {},
            authority_witness_type,
            list,
        );
    }

    /// Only the owner of the whitelist can manage it
    public entry fun remove_authority(
        authority_witness_type: String,
        owner: &OwnerCap,
        list: &mut Whitelist<Witness>,
        _ctx: &mut TxContext,
    ) {
        assert!(object::id(list) == owner.list_id, 0);

        transfer_whitelist::remove_authority(
            Witness {},
            &authority_witness_type,
            list,
        );
    }
}
