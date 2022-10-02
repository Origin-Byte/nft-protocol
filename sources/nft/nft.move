/// Module of a generic `NFT` type.
/// 
/// It acts as a generic interface for NFTs and it allows for
/// the creation of arbitrary domain specific implementations.
/// 
/// The `NFT` type is a hybrid object that can take two shapes: The shape of an
/// NFT which embeds is own data, an Embedded NFT; and the shape of an
/// NFT which does not embed its own data and containst solely a pointer to its
/// data object, a Loose NFT.
/// 
/// With this deisgn we can keep only one ultimate type whilst the NFT can be
/// embedded or loose depending on the use case. It is also possible to
/// dynamically join or split the data object from the NFT object, therefore
/// allowing for dynamic behaviour.
/// 
/// For embedded NFTs, the `Data` object and the `NFT` object is minted in one
/// step. For loose NFTsm the `Data` object is first minted and only then the 
/// NFT(s) associated to that object is(are) minted.
/// 
/// Embedded NFTs are nevertheless only useful to represent 1-to-1 relationships
/// between the NFT object and the Data object. In contrast, loose NFTs can
/// represent 1-to-many relationships. Essentially this allows us to build
/// NFTs which effectively have a supply.
/// 
module nft_protocol::nft {
    use std::option::{Self, Option};
    
    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};

    // TODO: Mention that stands for `D`ata
    struct Nft<D: store> has key, store {
        id: UID,
        data_id: ID,
        data: Option<D>,
    }

    struct MintEvent has copy, drop {
        nft_id: ID,
        data_id: ID,
    }

    struct BurnEvent has copy, drop {
        nft_id: ID,
        data_id: ID,
    }

    /// Create a Nft and increase the total supply
    /// in metadata `cap` accordingly.
    public fun mint_nft_loose<D: store>(
        // TODO: Need to refer launchpad shared object
        data_id: ID,
        ctx: &mut TxContext,
    ): Nft<D> {
        let nft_id = object::new(ctx);

        event::emit(
            MintEvent {
                nft_id: object::uid_to_inner(&nft_id),
                data_id: data_id,
            }
        );

        Nft {
            id: nft_id,
            data_id: data_id,
            data: option::none(),
        }
    }

    public fun mint_nft_embedded<D: store>(
        data_id: ID,
        data: D,
        ctx: &mut TxContext,
    ): Nft<D> {
        let nft_id = object::new(ctx);

        event::emit(
            MintEvent {
                nft_id: object::uid_to_inner(&nft_id),
                data_id: data_id,
            }
        );

        Nft {
            id: nft_id,
            data_id: data_id,
            data: option::some(data),
        }
    }

    public fun join_nft_data<D: store>(
        nft: &mut Nft<D>,
        data: D,
    ) {
        assert!(option::is_none(&nft.data), 0);

        option::fill(&mut nft.data, data);
    }

    public fun split_nft_data<D: store>(
        nft: &mut Nft<D>,
    ): D {
        assert!(!option::is_none(&nft.data), 0);

        option::extract(&mut nft.data)
    }

    public fun burn_loose_nft<D: store>(
        nft: Nft<D>,
    ) {
        assert!(is_loose(&nft), 0);

        event::emit(
            BurnEvent {
                nft_id: id(&nft),
                data_id: nft.data_id,
            }
        );

        let Nft {
            id,
            data_id: _,
            data,
        } = nft;

        object::delete(id);

        option::destroy_none(data);
    }

    public fun burn_embedded_nft<D: store>(
        nft: Nft<D>,
    ): Option<D> {
        assert!(is_loose(&nft), 0);

        event::emit(
            BurnEvent {
                nft_id: id(&nft),
                data_id: nft.data_id,
            }
        );

        let Nft {
            id,
            data_id: _,
            data,
        } = nft;

        object::delete(id);

        data
    }

    public fun is_loose<D: store>(
        nft: &Nft<D>,
    ): bool {
        option::is_none(&nft.data)
    }

    // === Getter Functions  ===

    public fun id<D: store>(
        nft: &Nft<D>,
    ): ID {
        object::uid_to_inner(&nft.id)
    }

    public fun id_ref<D: store>(
        nft: &Nft<D>,
    ): &ID {
        object::uid_as_inner(&nft.id)
    }

    public fun data_id<D: store>(
        nft: &Nft<D>,
    ): ID {
        nft.data_id
    }

    public fun data_id_ref<D: store>(
        nft: &Nft<D>,
    ): &ID {
        &nft.data_id
    }

    public fun data_ref<D: store>(
        nft: &Nft<D>,
    ): &D {
        option::borrow(&nft.data)
    }

    public fun data_ref_mut<D: store>(
        nft: &mut Nft<D>,
    ): &mut D {
        option::borrow_mut(&mut nft.data)
    }
}