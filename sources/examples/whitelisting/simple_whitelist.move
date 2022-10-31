module nft_protocol::simple_whitelist {
    //! Show cases simple whitelist implementation.
    //!
    //! Anyone can create a new whitelist.
    //! Any creator can add/remove their collection from any simple whitelist.
    //! Only the owner of a whitelist can add/remove authorities (such as
    //! orderbook or auction contracts.)

    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer::{transfer, share_object};
    use std::ascii::String;
    use nft_protocol::transfer_whitelist::{Self, Whitelist};

    struct SIMPLEWHITELIST has drop {}

    /// The owner of this single writer object is the admin of this whitelisting
    /// organization.
    struct OwnerCap has key {
        id: UID,
    }

    /// Anyone can create their own simple whitelist.
    public entry fun create(ctx: &mut TxContext) {
        share_object(transfer_whitelist::create(SIMPLEWHITELIST {}, ctx));
        transfer(OwnerCap { id: object::new(ctx) }, tx_context::sender(ctx));
    }

    /// Only the creator is allowed to insert their collection.
    ///
    /// However, any creator can insert their collection into simple whitelist.
    public fun insert_collection<CW: drop>(
        collection_witness: CW,
        list: &mut Whitelist<SIMPLEWHITELIST>,
    ) {
        transfer_whitelist::insert_collection(
            SIMPLEWHITELIST {},
            collection_witness,
            list,
        );
    }

    /// Only the owner of the whitelist can manage it
    public entry fun insert_authority(
        authority_witness_type: String,
        _owner: &OwnerCap,
        list: &mut Whitelist<SIMPLEWHITELIST>,
        _ctx: &mut TxContext,
    ) {
        transfer_whitelist::insert_authority(
            SIMPLEWHITELIST {},
            authority_witness_type,
            list,
        );
    }

    /// Only the owner of the whitelist can manage it
    public entry fun remove_authority(
        authority_witness_type: String,
        _owner: &OwnerCap,
        list: &mut Whitelist<SIMPLEWHITELIST>,
        _ctx: &mut TxContext,
    ) {
        transfer_whitelist::remove_authority(
            SIMPLEWHITELIST {},
            &authority_witness_type,
            list,
        );
    }
}
