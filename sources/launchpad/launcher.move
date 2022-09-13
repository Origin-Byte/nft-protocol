/// Module of a generic `Launcher` type.
/// 
/// It acts as a generic interface for Launchpads and it allows for
/// the creation of arbitrary domain specific implementations.
module nft_protocol::launcher {
    use std::vector;
    use sui::object::{ID , UID};

    struct Launcher<phantom T, Config> has key, store{
        id: UID,
        collection: ID,
        price: u64,
        go_live_date: u64, // TODO: this should be a timestamp
        nfts: vector<ID>,
        config: Config,
    }

    /// Adds an NFT's ID to the `nfts` field in `Launcher` object
    public fun add_nft<T, Config>(
        launcher: &mut Launcher<T, Config>,
        id: ID,
    ) {
        let nfts = &mut launcher.nfts;
        vector::push_back(nfts, id);
    }

}