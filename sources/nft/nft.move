module nft_protocol::nft {
    use std::option::{Self, Option};
    
    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};

    struct Nft<Data: store> has key, store {
        id: UID,
        data_id: ID,
        data: Option<Data>,
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
    public fun mint_nft_loose<Data: store>(
        // TODO: Need to refer launchpad shared object
        data_id: ID,
        ctx: &mut TxContext,
    ): Nft<Data> {
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

    public fun mint_nft_embedded<Data: store>(
        data_id: ID,
        data: Data,
        ctx: &mut TxContext,
    ): Nft<Data> {
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

    public fun join_nft_data<Data: store>(
        nft: &mut Nft<Data>,
        data: Data,
    ) {
        assert!(option::is_none(&nft.data), 0);

        option::fill(&mut nft.data, data);
    }

    public fun split_nft_data<Data: store>(
        nft: &mut Nft<Data>,
    ): Data {
        assert!(!option::is_none(&nft.data), 0);

        option::extract(&mut nft.data)
    }

    public fun burn_loose_nft<Data: store>(
        nft: Nft<Data>,
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

    public fun burn_embedded_nft<Data: store>(
        nft: Nft<Data>,
    ): Option<Data> {
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

    public fun is_loose<Data: store>(
        nft: &Nft<Data>,
    ): bool {
        option::is_none(&nft.data)
    }

    // === Getter Functions  ===

    public fun id<Data: store>(
        nft: &Nft<Data>,
    ): ID {
        object::uid_to_inner(&nft.id)
    }

    public fun id_ref<Data: store>(
        nft: &Nft<Data>,
    ): &ID {
        object::uid_as_inner(&nft.id)
    }

    public fun data_id<Data: store>(
        nft: &Nft<Data>,
    ): ID {
        nft.data_id
    }

    public fun data_id_ref<Data: store>(
        nft: &Nft<Data>,
    ): &ID {
        &nft.data_id
    }

    public fun data_ref<Data: store>(
        nft: &Nft<Data>,
    ): &Data {
        option::borrow(&nft.data)
    }

    public fun data_ref_mut<Data: store>(
        nft: &mut Nft<Data>,
    ): &mut Data {
        option::borrow_mut(&mut nft.data)
    }
}