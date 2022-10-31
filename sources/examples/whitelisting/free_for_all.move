module nft_protocol::free_for_all {
    //! A whitelist which permits any collection to add itself and any authority
    //! to use it to transfer.
    //!
    //! Basically any collection which adds itself to this whitelist is saying:
    //! we're ok with anyone transferring NFTs.

    use sui::tx_context::TxContext;
    use sui::transfer::share_object;
    use nft_protocol::transfer_whitelist::{Self, Whitelist};

    struct Witness has drop {}

    fun init(ctx: &mut TxContext) {
        share_object(transfer_whitelist::create(Witness {}, ctx));
    }

    /// Only the creator is allowed to insert their collection.
    ///
    /// However, any creator can insert their collection into simple whitelist.
    public fun insert_collection<CW: drop>(
        collection_witness: CW,
        list: &mut Whitelist<Witness>,
    ) {
        transfer_whitelist::insert_collection(
            Witness {},
            collection_witness,
            list,
        );
    }
}
