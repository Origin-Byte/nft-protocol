/// Module of a generic `NFT` type.
/// 
/// It acts as a generic interface for NFTs and it allows for
/// the creation of arbitrary domain specific implementations.
module nft_protocol::nft {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::collection_cap::{Self, Capped, Uncapped, Cap};

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

        // Only delete NFT object if collection ID in NFT field
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

    /// Get the NFT's `UID` as reference
    public fun uid_ref<T, Meta>(
        nft: &NftOwned<T, Meta>,
    ): &UID {
        &nft.id
    }

    /// Get the NFT's `ID`
    public fun id<T, Meta>(
        nft: &NftOwned<T, Meta>,
    ): ID {
        object::uid_to_inner(&nft.id)
    }

    /// Get the NFT's `ID` as reference
    public fun id_ref<T, Meta>(
        nft: &NftOwned<T, Meta>,
    ): &ID {
        object::uid_as_inner(&nft.id)
    }

    /// Get the NFT's `collection_id`
    public fun collection_id<T, Meta>(
        nft: &NftOwned<T, Meta>,
    ): ID {
        nft.collection_id
    }
}
