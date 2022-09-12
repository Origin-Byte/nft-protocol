/// Module of a generic `NFT` type.
/// 
/// It acts as a generic interface for NFTs and it allows for
/// the creation of arbitrary domain specific implementations.
module nft_protocol::nft {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};
    use nft_protocol::collection::{Self, Collection};

    // The phantom type T links the NTF with a smart contract which implements
    // a standard interface for NFTs.
    //
    // The meta data is a type exported by the same contract which is used to
    // store additional information about the NFT.
    struct NftOwned<phantom T, Meta> has key, store {
        id: UID,
        /// Each NFT must be a part of a collection.
        ///
        /// To represent a stand alone NFTs, the collection can be of length
        /// one.
        collection_id: ID,
        metadata: Meta,
    }

    public fun create_owned<T: drop, MetaNft: store, K: drop, MetaColl: store>(
        _witness: T,
        metadata: MetaNft,
        coll: &mut Collection<K, MetaColl>,
        ctx: &mut TxContext,
    ): NftOwned<T, MetaNft> {
        let collection_id = object::id(coll);

        // Increase collection's current supply
        // Fails if max supply is already reached
        collection::increase_supply(coll);

        let id = object::new(ctx);

        NftOwned {
            id,
            collection_id,
            metadata,
        }
    }

    public fun destroy_owned<T: drop, MetaNft, K: drop, MetaColl: store>(
        _witness: T,
        nft: NftOwned<T, MetaNft>,
        coll: &mut Collection<K, MetaColl>,
    ): MetaNft {
        // Decreases collection's current supply
        // Fails if current supply is already zero
        collection::decrease_supply(coll);

        // Only allow burning if collection matches
        let coll_id = object::borrow_id(coll);

        // Only delete Nft object if collection ID in Nft field
        // matches the ID of the collection passed to the function
        assert!(coll_id == &nft.collection_id, 0);

        let NftOwned {
            id,
            collection_id: _,
            metadata
        } = nft;

        object::delete(id);

        metadata
    }

    public fun owned_metadata<T, Meta>(nft: &NftOwned<T, Meta>): &Meta {
        &nft.metadata
    }

    /// We can return a mutable reference to the metadata without checking that
    /// it's the T contract calling this method, because it's the responsibility
    /// of the T contract to write their public interface such that the mutation
    /// of the metadata is according to the desired logic.
    public fun owned_metadata_mut<T, Meta>(
        nft: &mut NftOwned<T, Meta>
    ): &mut Meta {
        &mut nft.metadata
    }
}
