/// Defines the `Coin` type - platform wide representation of fungible
/// tokens and coins. `Coin` can be described as a secure wrapper around
/// `Balance` type.
module nft_protocol::new_nft {
    use sui::object::{Self, UID, ID};
    use std::string::{String};
    use sui::tx_context::{Self, TxContext};
    use std::option::{Self, Option};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::collection_cap::{Self, Capped, Uncapped};

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

    struct NftData<phantom T, Meta: store> has key, store {
        id: UID,
        name: String,
        supply: Supply,
        meta: Meta,
    }

    // == NftData morphing and accessors  ===

    public fun name<C, Meta: store>(nft_data: &NftData<C, Meta>): String {
        nft_data.name
    }

    public fun nft_data_id<C, Meta: store>(nft_data: &NftData<C, Meta>): ID {
        object::uid_to_inner(&nft_data.id)
    }

    public fun supply<C, Meta: store>(nft_data: &NftData<C, Meta>): &Supply {
        &nft_data.supply
    }

    // ===  ===

    public fun mint_data_from_uncapped_collection<T: drop, MetaColl: store, MetaNft: store>(
        name: String,
        collection: &mut Collection<MetaColl, Uncapped>,
        meta: MetaNft,
        nft_supply: Option<u64>,
        ctx: &mut TxContext,
    ): NftData<T, MetaNft> {
        NftData {
            id: object::new(ctx),
            name: name,
            supply: supply::new(nft_supply),
            meta: meta,
        }
    }

    /// Create a Metadata and increase the total supply
    /// in collection `cap` accordingly.
    public fun mint_data_from_capped_collection<T: drop, MetaColl: store, MetaNft: store>(
        name: String,
        collection: &mut Collection<MetaColl, Capped>,
        meta: MetaNft,
        nft_supply: Option<u64>,
        ctx: &mut TxContext,
    ): NftData<T, MetaNft> {

        collection::increase_supply(collection, 1);

        NftData {
            id: object::new(ctx),
            name: name,
            supply: supply::new(nft_supply),
            meta: meta,
        }
    }

    /// Create a Nft and increase the total supply
    /// in metadata `cap` accordingly.
    public fun mint_nft<C: drop, Data: store>(
        // TODO: Need to refer launchpad shared object
        nft_data: &mut NftData<C, Data>,
        ctx: &mut TxContext,
    ): Nft<Data> {
        supply::increase_supply(&mut nft_data.supply, 1);

        Nft {
            id: object::new(ctx),
            data_id: nft_data_id(nft_data),
            data: option::none(),
        }
    }

    public fun destroy_nft<T, Meta: store, Data: store>(
        nft: Nft<Data>,
        nft_data: &mut NftData<T, Meta>,
    ) {
        supply::decrease_supply(&mut nft_data.supply, 1);

        // Only allow burning if NftData id matches
        let data_id = object::borrow_id(nft_data);

        // Only delete NFT object if collection ID in NFT field
        // matches the ID of the collection passed to the function
        assert!(data_id == &nft.data_id, 0);

        let Nft {
            id,
            data_id: _,
            data: data, // TODO: this will break the borrow checker
        } = nft;

        object::delete(id);
    }
}