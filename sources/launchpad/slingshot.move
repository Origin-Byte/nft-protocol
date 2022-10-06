//! Module of a generic `Slingshot` type.
//! 
//! It acts as a generic interface for Launchpads and it allows for
//! the creation of arbitrary domain specific implementations.
//! 
//! The slingshot acts as the object that configures the primary NFT realease
//! strategy, that is the primary market sale. Primary market sales can take
//! many shapes, depending on the business level requirements.
module nft_protocol::slingshot {
    use std::vector;

    use sui::transfer;
    use sui::object::{Self, ID , UID};
    use sui::tx_context::{Self, TxContext};
    
    use nft_protocol::sale::Sale;

    struct Slingshot<phantom T, M> has key, store{
        id: UID,
        /// The ID of the NFT Collection object
        collection_id: ID,
        /// Boolean indicating if the sale is live
        live: bool,
        /// The address of the administrator
        admin: address,
        /// The address of the receiver of funds
        receiver: address,
        /// Vector of all IDs owned by the slingshot
        sales: vector<Sale<T, M>>,
        /// Field determining if NFTs are embedded or looose.
        /// Embedded NFTs will be directly owned by the Slingshot whilst
        /// loose NFTs will be minted on the fly under the authorithy of the
        /// launchpad.
        is_embedded: bool,
    }

    struct InitSlingshot has drop {
        collection_id: ID,
        admin: address,
        receiver: address,
        is_embedded: bool,
    }

    struct CreateSlingshotEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    struct DeleteSlingshotEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    /// Initialises a `Slingshot` object and shares it
    public fun create<T: drop, M: store>(
        _witness: T,
        sales: vector<Sale<T, M>>,
        args: InitSlingshot,
        ctx: &mut TxContext,
    ) {
        let id = object::new(ctx);

        let slingshot: Slingshot<T, M> = Slingshot {
            id,
            collection_id: args.collection_id,
            live: false,
            admin: args.admin,
            receiver: args.receiver,
            sales: sales,
            is_embedded: args.is_embedded,
        };

        transfer::share_object(slingshot);
    }

    /// Burn the `Slingshot` and return the `M` object
    public fun delete<T: drop, M: store>(
        slingshot: Slingshot<T, M>,
        ctx: &mut TxContext,
    ): vector<Sale<T, M>> {
        // assert!(vector::length(&slingshot.nfts) > 0, 0);

        assert!(tx_context::sender(ctx) == admin(&slingshot), 0);

        let Slingshot {
            id,
            collection_id: _,
            live: _,
            admin: _,
            receiver: _,
            sales,
            is_embedded: _,
        } = slingshot;

        object::delete(id);

        sales
    }

    // /// Adds an NFT's ID to the `nfts` field in `Slingshot` object
    // public fun add_nft<T, M>(
    //     slingshot: &mut Slingshot<T, M>,
    //     id: ID,
    // ) {
    //     let nfts = &mut slingshot.nfts;
    //     vector::push_back(nfts, id);
    // }

    // /// Pops an NFT's ID from the `nfts` field in `Slingshot` object
    // /// and returns respective `ID`
    // public fun pop_nft<T, M>(
    //     slingshot: &mut Slingshot<T, M>,
    // ): ID {
    //     let nfts = &mut slingshot.nfts;
    //     vector::pop_back(nfts)
    // }

    public fun init_args(
        collection_id: ID,
        admin: address,
        receiver: address,
        is_embedded: bool, 
    ): InitSlingshot {

        InitSlingshot {
            collection_id,
            admin,
            receiver,
            is_embedded
        }
    }

    // === Modifier Functions ===

    /// Toggle the Slingshot's `live` to `true` therefore 
    /// making the NFT sale live.
    public fun sale_on<T, M>(
        slingshot: &mut Slingshot<T, M>,
    ) {
        slingshot.live = true
    }

    /// Toggle the Slingshot's `live` to `false` therefore 
    /// pausing or stopping the NFT sale.
    public fun sale_off<T, M>(
        slingshot: &mut Slingshot<T, M>,
    ) {
        slingshot.live = false
    }

    // /// We can return a mutable reference to the configuration without checking 
    // /// that it's the T contract calling this method, because it's the 
    // /// responsibility of the T contract to write their public interface such
    // /// that the mutation of the metadata is according to the desired logic.
    // public fun config_mut<T, M>(
    //     slingshot: &mut Slingshot<T, M>,
    // ): &mut M {
    //     &mut slingshot.config
    // }

    // === Getter Functions ===

    /// Get the Slingshot's `collection_id` ID
    public fun collection_id<T, M>(
        slingshot: &Slingshot<T, M>,
    ): ID {
        slingshot.collection_id
    }

    /// Get the Slingshot's `collection_id` ID as reference
    public fun collection_id_ref<T, M>(
        slingshot: &Slingshot<T, M>,
    ): &ID {
        &slingshot.collection_id
    }
    
    /// Get the Slingshot's `live`
    public fun live<T, M>(
        slingshot: &Slingshot<T, M>,
    ): bool {
        slingshot.live
    }

    // /// Get the Slingshot's `config` as reference
    // public fun config<T, M>(
    //     slingshot: &Slingshot<T, M>,
    // ): &M {
    //     &slingshot.config
    // }

    /// Get the Slingshot's `receiver` address
    public fun receiver<T, M>(
        slingshot: &Slingshot<T, M>,
    ): address {
        slingshot.receiver
    }

    /// Get the Slingshot's `admin` address
    public fun admin<T, M>(
        slingshot: &Slingshot<T, M>,
    ): address {
        slingshot.admin
    }

    /// Get the Slingshot's `sales` address
    public fun sales<T, M>(
        slingshot: &Slingshot<T, M>,
    ): &vector<Sale<T, M>> {
        &slingshot.sales
    }

    /// Get the Slingshot's `sale` address
    public fun sale<T, M>(
        slingshot: &Slingshot<T, M>,
        index: u64,
    ): &Sale<T, M> {
        vector::borrow(&slingshot.sales, index)
    }

    /// Get the Slingshot's `sale` address
    public fun sale_mut<T, M>(
        slingshot: &mut Slingshot<T, M>,
        index: u64,
    ): &mut Sale<T, M> {
        vector::borrow_mut(&mut slingshot.sales, index)
    }

    /// Get the Slingshot's `is_embedded` bool
    public fun is_embedded<T, M>(
        slingshot: &Slingshot<T, M>,
    ): bool {
        slingshot.is_embedded
    }

    // /// Get the Slingshot's `nfts` vector as reference
    // public fun nfts<T, M>(
    //     slingshot: &Slingshot<T, M>,
    // ): &vector<ID> {
    //     &slingshot.nfts
    // }

    // === Private Functions ===

    // /// Removes an NFT's ID from the `nfts` field in `Slingshot` object
    // /// and returns respective `ID`
    // fun remove_nft_by_id<T, M>(
    //     slingshot: &mut Slingshot<T, M>,
    //     nft: &ID,
    // ): ID {
    //     let nfts = &mut slingshot.nfts;
    //     let (is_in_vec, index) = vector::index_of(nfts, nft);
        
    //     assert!(is_in_vec == true, 0);

    //     vector::remove(nfts, index)
    // }
}