/// Module of a generic `Launcher` type.
/// 
/// It acts as a generic interface for Launchpads and it allows for
/// the creation of arbitrary domain specific implementations.
module nft_protocol::launcher {
    use std::vector;
    use sui::object::{Self, ID , UID};
    use sui::tx_context::{TxContext};

    struct Launcher<phantom T, Config> has key, store{
        id: UID,
        collection: ID,
        go_live_date: u64, // TODO: this should be a timestamp
        nfts: vector<ID>,
        config: Config,
    }

    struct InitLauncher has drop {
        collection: ID,
        go_live_date: u64,
    }

    /// Initialises a `Launcher` object and returns it
    public fun create<T: drop, Config: store>(
        _witness: T,
        args: InitLauncher,
        config: Config,
        ctx: &mut TxContext,
    ): Launcher<T, Config> {
        let id = object::new(ctx);

        let nfts = vector::empty();

        Launcher {
            id,
            collection: args.collection,
            go_live_date: args.go_live_date,
            nfts: nfts,
            config: config,
        }
    }

    /// Burn the `Launchpad` and return the `Config` object
    public fun burn<T: drop, Config: store>(
        launcher: Launcher<T, Config>,
        _: &mut TxContext
    ): Config {
        assert!(vector::length(&launcher.nfts) > 0, 0);

        let Launcher {
            id,
            collection: _,
            go_live_date: _,
            nfts: _,
            config,
        } = launcher;

        object::delete(id);

        config
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