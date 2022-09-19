/// Module of a generic `Launcher` type.
/// 
/// It acts as a generic interface for Launchpads and it allows for
/// the creation of arbitrary domain specific implementations.
module nft_protocol::launcher {
    use std::vector;
    use sui::object::{Self, ID , UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use nft_protocol::nft::{Self, NftOwned};

    struct Launcher<phantom T, Config> has key, store{
        id: UID,
        // The ID of the NFT Collection object
        collection_id: ID,
        // Boolean indicating if the sale is live
        live: bool,
        // The address of the administrator
        admin: address,
        // The address of the receiver of funds
        receiver: address,
        // Vector of all IDs owned by the launcher
        nfts: vector<ID>,
        config: Config,
    }

    struct InitLauncher has drop {
        collection_id: ID,
        live: bool,
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
            live: args.live,
            admin: args.admin,
            receiver: args.receiver,
            nfts: nfts,
            config: config,
        }
    }

    /// Burn the `Launcher` and return the `Config` object
    public fun delete<T: drop, Config: store>(
        launcher: Launcher<T, Config>,
    ): Config {
        assert!(vector::length(&launcher.nfts) > 0, 0);

        let Launcher {
            id,
            collection_id: _,
            live: _,
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
        live: bool,
        admin: address,
        receiver: address,
    ): InitLauncher {

        InitLauncher {
            collection_id,
            live,
            admin,
            receiver,
        }
    }

    public fun transfer_back<T, Config: store, K, Meta: store>(
        launcher: &mut Launcher<T, Config>,
        nft: NftOwned<K, Meta>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);

        if (admin(launcher) != sender) {
                transfer::transfer_to_object(
                nft,
                launcher,
            );
        } else {

            remove_nft_by_id(
                launcher,
                nft::id_ref(&nft)
            );

            transfer::transfer(
                nft,
                recipient,
            );
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
    
    /// Get the Launcher's `live`
    public fun live<T, Config>(
        launcher: &Launcher<T, Config>,
    ): bool {
        launcher.live
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

    // === Private Functions ===

    /// Removes an NFT's ID from the `nfts` field in `Launcher` object
    /// and returns respective `ID`
    fun remove_nft_by_id<T, Config>(
        launcher: &mut Launcher<T, Config>,
        nft: &ID,
    ): ID {
        let nfts = &mut launcher.nfts;
        let (is_in_vec, index) = vector::index_of(nfts, nft);
        
        assert!(is_in_vec == true, 0);

        vector::remove(nfts, index)
    }
}