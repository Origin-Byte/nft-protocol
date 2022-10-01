/// Module of a generic `NFT` type.
/// 
/// It acts as a generic interface for NFTs and it allows for
/// the creation of arbitrary domain specific implementations.
/// 
/// TODO: We need to consider that there are two types of supply, 
/// vertical (Collection Width) and horizontal supply (Collection Depth).
/// Collection Width stands for how many different NFTs are there in a 
/// collection whilst Collection Depth stands for how many are there of each NFT
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