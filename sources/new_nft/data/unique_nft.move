// TODO: Mint to launchpad functions
module nft_protocol::unique_nft {
    use sui::event;
    use sui::object::{Self, UID, ID};
    use std::string::{String};
    use std::option::{Option};
    
    use sui::transfer;
    use sui::tx_context::{TxContext};
    use sui::url::{Url};
    
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::new_nft;
    use nft_protocol::cap::{Limited, Unlimited};
    use nft_protocol::utils::{to_string_vector};

    struct Data has key, store {
        id: UID,
        index: u64,
        name: String,
        description: String,
        collection_id: ID,
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
        index: u64,
        name: String,
        description: String,
        max_supply: Option<u64>,
        url: Url,
        is_mutable: bool,
        attributes: Attributes,
    }

    struct MintDataEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    // TODO: Must use this event
    struct BurnDataEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    // === Entrypoints ===

    /// Mint one `Nft` with `Data` and send it to `recipient`.
    /// Invokes `mint_and_transfer()`.
    /// Mints an NFT from a `Collection` with `Unlimited` supply.
    /// The only way to mint the NFT for a collection is to give a reference to
    /// [`UID`]. Since this a property, it can be only accessed in the smart 
    /// contract which creates the collection. That contract can then define
    /// their own logic for restriction on minting.
    public entry fun direct_mint_unlimited_collection_nft<MetaColl: store>(
        args: InitArgs,
        max_supply: Option<u64>,
        collection: &Collection<MetaColl, Unlimited>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        mint_and_transfer(
            args,
            collection::id(collection),
            recipient,
            ctx,
        );
    }

    /// Mint one `Nft` with `Data` and send it to `recipient`.
    /// Invokes `mint_and_transfer()`.
    /// Mints an NFT from a `Collection` with `Limited` supply.
    /// The only way to mint the NFT for a collection is to give a reference to
    /// [`UID`]. Since this a property, it can be only accessed in the smart 
    /// contract which creates the collection. That contract can then define
    /// their own logic for restriction on minting.
    public entry fun direct_mint_limited_collection_nft<MetaColl: store>(
        args: InitArgs,
        recipient: address,
        collection: &mut Collection<MetaColl, Limited>,
        ctx: &mut TxContext,
    ) {
        collection::increase_supply(collection, 1);

        mint_and_transfer(
            args,
            collection::id(collection),
            recipient,
            ctx,
        );
    }

    // === Getter Functions  ===

    /// Get the Nft Data's `id` as reference
    public fun id_ref(
        nft_data: &Data,
    ): &ID {
        object::uid_as_inner(&nft_data.id)
    }

    /// Get the Nft Data's `index`
    public fun index(
        nft_data: &Data,
    ): u64 {
        nft_data.index
    }

    /// Get the Nft Data's `name`
    public fun name(
        nft_data: &Data,
    ): String {
        nft_data.name
    }

    /// Get the Nft Data's `description`
    public fun description(
        nft_data: &Data,
    ): String {
        nft_data.name
    }

    /// Get the Nft Data's `collection_id`
    public fun collection_id(
        nft_data: &Data,
    ): &ID {
        &nft_data.collection_id
    }

    /// Get the Nft Data's `url`
    public fun url(
        nft_data: &Data,
    ): Url {
        nft_data.url
    }

    /// Get the Nft Data's `attributes`
    public fun attributes(
        nft_data: &Data,
    ): &Attributes {
        &nft_data.attributes
    }

    // === Private Functions ===

    fun nft_data_id(nft_data: &Data): ID {
        object::uid_to_inner(&nft_data.id)
    }

    fun mint_and_transfer(
        args: InitArgs,
        collection_id: ID,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let data_id = object::new(ctx);

        event::emit(
            MintDataEvent {
                object_id: object::uid_to_inner(&data_id),
                collection_id: collection_id,
            }
        );

        let nft_data = Data {
            id: data_id,
            index: args.index,
            name: args.name,
            description: args.description,
            collection_id: collection_id,
            url: args.url,
            attributes: args.attributes,
        };

        let nft = new_nft::mint_nft_embedded(
            nft_data_id(&nft_data),
            nft_data,
            ctx
        );

        transfer::transfer(
            nft,
            recipient,
        );
    }

    fun mint_args(
        index: u64,
        name: String,
        description: String,
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
            index,
            name,
            description,
            max_supply,
            url,
            is_mutable,
            attributes,
        }
    }
}