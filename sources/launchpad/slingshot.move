/// Module of a generic `Slingshot` type.
/// 
/// It acts as a generic interface for Launchpads and it allows for
/// the creation of arbitrary domain specific implementations.
module nft_protocol::slingshot {
    use std::vector;
    use sui::object::{Self, ID , UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use nft_protocol::nft::{Self, Nft};

    struct Slingshot<phantom T, Config> has key, store{
        id: UID,
        // The ID of the NFT Collection object
        collection_id: ID,
        // Boolean indicating if the sale is live
        live: bool,
        // The address of the administrator
        admin: address,
        // The address of the receiver of funds
        receiver: address,
        // Vector of all IDs owned by the slingshot
        nfts: vector<ID>,
        config: Config,
    }

    struct InitSlingshot has drop {
        collection_id: ID,
        admin: address,
        receiver: address,
    }

    /// Initialises a `Slingshot` object and returns it
    public fun create<T: drop, Config: store>(
        _witness: T,
        args: InitSlingshot,
        config: Config,
        ctx: &mut TxContext,
    ): Slingshot<T, Config> {
        let id = object::new(ctx);

        let nfts = vector::empty();

        Slingshot {
            id,
            collection_id: args.collection_id,
            live: false,
            admin: args.admin,
            receiver: args.receiver,
            nfts: nfts,
            config: config,
        }
    }

    /// Burn the `Slingshot` and return the `Config` object
    public fun delete<T: drop, Config: store>(
        slingshot: Slingshot<T, Config>,
        ctx: &mut TxContext,
    ): Config {
        assert!(vector::length(&slingshot.nfts) > 0, 0);

        assert!(tx_context::sender(ctx) == admin(&slingshot), 0);

        let Slingshot {
            id,
            collection_id: _,
            live: _,
            admin: _,
            receiver: _,
            nfts: _,
            config,
        } = slingshot;

        object::delete(id);

        config
    }

    /// Adds an NFT's ID to the `nfts` field in `Slingshot` object
    public fun add_nft<T, Config>(
        slingshot: &mut Slingshot<T, Config>,
        id: ID,
    ) {
        let nfts = &mut slingshot.nfts;
        vector::push_back(nfts, id);
    }

    /// Pops an NFT's ID from the `nfts` field in `Slingshot` object
    /// and returns respective `ID`
    public fun pop_nft<T, Config>(
        slingshot: &mut Slingshot<T, Config>,
    ): ID {
        let nfts = &mut slingshot.nfts;
        vector::pop_back(nfts)
    }

    public fun init_args(
        collection_id: ID,
        admin: address,
        receiver: address,
    ): InitSlingshot {

        InitSlingshot {
            collection_id,
            admin,
            receiver,
        }
    }

    public fun transfer_back<T, Config: store, D: store>(
        slingshot: &mut Slingshot<T, Config>,
        nft: Nft<D>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);

        if (admin(slingshot) != sender) {
            transfer::transfer_to_object(
                nft,
                slingshot,
            );
        } else {

            remove_nft_by_id(
                slingshot,
                nft::id_ref(&nft)
            );

            transfer::transfer(
                nft,
                recipient,
            );
        }
    }

    // === Modifier Functions ===

    /// Toggle the Slingshot's `live` to `true` therefore 
    /// making the NFT sale live.
    public fun sale_on<T, Config>(
        slingshot: &mut Slingshot<T, Config>,
    ) {
        slingshot.live = true
    }

    /// Toggle the Slingshot's `live` to `false` therefore 
    /// pausing or stopping the NFT sale.
    public fun sale_off<T, Config>(
        slingshot: &mut Slingshot<T, Config>,
    ) {
        slingshot.live = false
    }

    /// We can return a mutable reference to the configuration without checking 
    /// that it's the T contract calling this method, because it's the 
    /// responsibility of the T contract to write their public interface such
    /// that the mutation of the metadata is according to the desired logic.
    public fun config_mut<T, Config>(
        slingshot: &mut Slingshot<T, Config>,
    ): &mut Config {
        &mut slingshot.config
    }

    // === Getter Functions ===

    /// Get the Slingshot's `collection_id` ID
    public fun collection_id<T, Config>(
        slingshot: &Slingshot<T, Config>,
    ): ID {
        slingshot.collection_id
    }

    /// Get the Slingshot's `collection_id` ID as reference
    public fun collection_id_ref<T, Config>(
        slingshot: &Slingshot<T, Config>,
    ): &ID {
        &slingshot.collection_id
    }
    
    /// Get the Slingshot's `live`
    public fun live<T, Config>(
        slingshot: &Slingshot<T, Config>,
    ): bool {
        slingshot.live
    }

    /// Get the Slingshot's `config` as reference
    public fun config<T, Config>(
        slingshot: &Slingshot<T, Config>,
    ): &Config {
        &slingshot.config
    }

    /// Get the Slingshot's `receiver` address
    public fun receiver<T, Config>(
        slingshot: &Slingshot<T, Config>,
    ): address {
        slingshot.receiver
    }

    /// Get the Slingshot's `admin` address
    public fun admin<T, Config>(
        slingshot: &Slingshot<T, Config>,
    ): address {
        slingshot.admin
    }

    /// Get the Slingshot's `nfts` vector as reference
    public fun nfts<T, Config>(
        slingshot: &Slingshot<T, Config>,
    ): &vector<ID> {
        &slingshot.nfts
    }

    // === Private Functions ===

    /// Removes an NFT's ID from the `nfts` field in `Slingshot` object
    /// and returns respective `ID`
    fun remove_nft_by_id<T, Config>(
        slingshot: &mut Slingshot<T, Config>,
        nft: &ID,
    ): ID {
        let nfts = &mut slingshot.nfts;
        let (is_in_vec, index) = vector::index_of(nfts, nft);
        
        assert!(is_in_vec == true, 0);

        vector::remove(nfts, index)
    }
}