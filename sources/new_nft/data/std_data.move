module nft_protocol::std_data {
    use sui::object::{Self, UID, ID};
    use std::string::{String};
    use sui::tx_context::{Self, TxContext};
    use std::option::{Self, Option};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::collection_cap::{Self, Capped, Uncapped};
    use nft_protocol::utils::{to_string_vector};
    use sui::url::{Self, Url};

    /// For when a type passed to create_supply is not a one-time witness.
    const EBadWitness: u64 = 0;

    /// For when invalid arguments are passed to a function.
    const EInvalidArg: u64 = 1;

    /// For when trying to split a coin more times than its balance allows.
    const ENotEnough: u64 = 2;

    // struct Nft<Data: store> has key, store {
    //     id: UID,
    //     data_id: ID,
    //     data: Option<Data>,
    // }

    struct NftData has key, store {
        id: UID,
        name: String,
        index: u64,
        supply: Supply,
        url: Url,
        attributes: Attributes,
        // TODO: need to add more fields here
    }

    struct Attributes has store, drop, copy {
        // TODO: Consider using key-value pair
        keys: vector<String>,
        values: vector<String>,
    }

    struct InitArgs has drop {
        name: String,
        index: u64,
        max_supply: Option<u64>,
        url: Url,
        is_mutable: bool,
        attributes: Attributes,
    }

    // == NftData morphing and accessors  ===

    public fun name<T, Meta: store>(nft_data: &NftData): String {
        nft_data.name
    }

    public fun nft_data_id<T, Meta: store>(nft_data: &NftData): ID {
        object::uid_to_inner(&nft_data.id)
    }

    public fun supply<T, Meta: store>(nft_data: &NftData): &Supply {
        &nft_data.supply
    }

    // ===  ===

    public entry fun mint_nft_data_from_uncapped_collection<MetaColl: store>(
        args: InitArgs,
        max_supply: Option<u64>,
        collection: &Collection<MetaColl, Uncapped>,
        ctx: &mut TxContext,
    ): NftData {
        NftData {
            id: object::new(ctx),
            name: args.name,
            index: args.index,
            supply: supply::new(max_supply),
            url: args.url,
            attributes: args.attributes,
        }
    }

    public entry fun mint_nft_data_from_capped_collection<MetaColl: store>(
        args: InitArgs,
        max_supply: Option<u64>,
        collection: &mut Collection<MetaColl, Capped>,
        ctx: &mut TxContext,
    ): NftData {
        collection::increase_supply(collection, 1);

        NftData {
            id: object::new(ctx),
            name: args.name,
            index: args.index,
            supply: supply::new(max_supply),
            url: args.url,
            attributes: args.attributes,
        }
    }

    public entry fun mint_nft_loose() {}

    public entry fun mint_nft_embedded() {}

    fun mint_args(
        name: String,
        index: u64,
        max_supply: Option<u64>,
        url: Url,
        is_mutable: bool,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
    ): InitArgs {
        let attributes = Attributes {
            keys: to_string_vector(&mut attribute_keys),
            values: to_string_vector(&mut attribute_values),
        };

        InitArgs {
            name,
            index,
            max_supply,
            url,
            is_mutable,
            attributes,
        }
    }
}