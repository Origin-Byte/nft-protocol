module nft_protocol::new_nft {
    use sui::event;
    use sui::object::{Self, UID, ID};
    use std::string::{String};
    use sui::tx_context::{Self, TxContext};
    use std::option::{Self, Option};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::cap::{Self, Limited, Unlimited};

    /// For when a type passed to create_supply is not a one-time witness.
    const EBadWitness: u64 = 0;

    /// For when invalid arguments are passed to a function.
    const EInvalidArg: u64 = 1;

    /// For when trying to split a coin more times than its balance allows.
    const ENotEnough: u64 = 2;

    struct Nft<Data: store> has key, store {
        id: UID,
        data_id: ID,
        data: Option<Data>,
    }

    struct MintEvent has copy, drop {
        object_id: ID,
        data_id: ID,
    }

    // TODO: Need to use this
    struct BurnEvent has copy, drop {
        object_id: ID,
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
                object_id: object::uid_to_inner(&nft_id),
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
                object_id: object::uid_to_inner(&nft_id),
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

    // public fun destroy_nft<T, Meta: store, Data: store>(
    //     nft: Nft<Data>,
    //     nft_data: &mut NftData<T, Meta>,
    // ) {
    //     supply::decrease_supply(&mut nft_data.supply, 1);

    //     // Only allow burning if NftData id matches
    //     let data_id = object::borrow_id(nft_data);

    //     // Only delete NFT object if collection ID in NFT field
    //     // matches the ID of the collection passed to the function
    //     assert!(data_id == &nft.data_id, 0);

    //     let Nft {
    //         id,
    //         data_id: _,
    //         data: data, // TODO: this will break the borrow checker
    //     } = nft;

    //     object::delete(id);
    // }
}