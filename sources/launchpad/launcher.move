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
        collection_id: ID,
        go_live_date: u64, // TODO: this should be a timestamp
        admin: address,
        receiver: address,
        nfts: vector<ID>,
        config: Config,
    }

    struct InitLauncher has drop {
        collection_id: ID,
        go_live_date: u64,
        admin: address,
        receiver: address,
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
            collection_id: args.collection_id,
            go_live_date: args.go_live_date,
            admin: args.admin,
            receiver: args.receiver,
            nfts: nfts,
            config: config,
        }
    }

    /// Burn the `Launcher` and return the `Config` object
    public fun delete<T: drop, Config: store>(
        launcher: Launcher<T, Config>,
        _: &mut TxContext
    ): Config {
        assert!(vector::length(&launcher.nfts) > 0, 0);

        let Launcher {
            id,
            collection_id: _,
            go_live_date: _,
            admin: _,
            receiver: _,
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

    /// Pops an NFT's ID from the `nfts` field in `Launcher` object
    /// and returns respective `ID`
    public fun pop_nft<T, Config>(
        launcher: &mut Launcher<T, Config>,
    ): ID {
        let nfts = &mut launcher.nfts;
        vector::pop_back(nfts)
    }

    public fun init_args(
        collection_id: ID,
        go_live_date: u64,
        admin: address,
        receiver: address,
    ): InitLauncher {

        InitLauncher {
            collection_id,
            go_live_date,
            admin,
            receiver,
        }
    }

    // === Getter Functions ===

    /// Get the Launcher's `collection_id` ID
    public fun collection_id<T, Config>(
        launcher: &Launcher<T, Config>,
    ): ID {
        launcher.collection_id
    }

    /// Get the Launcher's `collection_id` ID as reference
    public fun collection_id_ref<T, Config>(
        launcher: &Launcher<T, Config>,
    ): &ID {
        &launcher.collection_id
    }
    
    /// Get the Launcher's `go_live_date`
    public fun go_live_date<T, Config>(
        launcher: &Launcher<T, Config>,
    ): u64 {
        launcher.go_live_date
    }

    /// Get the Launcher's `config` as reference
    public fun config<T, Config>(
        launcher: &Launcher<T, Config>,
    ): &Config {
        &launcher.config
    }

    /// Get the Launcher's `receiver` address
    public fun receiver<T, Config>(
        launcher: &Launcher<T, Config>,
    ): address {
        launcher.receiver
    }

    /// Get the Launcher's `admin` address
    public fun admin<T, Config>(
        launcher: &Launcher<T, Config>,
    ): address {
        launcher.admin
    }

    /// Get the Launcher's `nfts` vector as reference
    public fun nfts<T, Config>(
        launcher: &Launcher<T, Config>,
    ): &vector<ID> {
        &launcher.nfts
    }
}