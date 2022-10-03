//! Module of a unique NFT `Unique` data type.
//! 
//! It acts as a standard domain-specific implementation of an NFT type, 
//! fitting use cases such as Art and PFP NFT Collections. It uses the main
//! NFT module to mint embedded NFTs.
module nft_protocol::unique_nft {
    use sui::event;
    use sui::object::{Self, UID, ID};
    use std::string::{Self, String};
    use std::option;
    
    use sui::transfer;
    use sui::tx_context::{TxContext};
    use sui::url::{Self, Url};
    
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::utils::{to_string_vector};
    use nft_protocol::cap::{Limited, Unlimited};
    use nft_protocol::nft::{Self, Nft};

    /// An NFT `Unique` data object with standard fields.
    struct Unique has key, store {
        id: UID,
        /// The index identifier of an NFT
        index: u64,
        name: String,
        description: String,
        collection_id: ID,
        url: Url,
        attributes: Attributes,
    }

    struct Attributes has store, drop, copy {
        keys: vector<String>,
        values: vector<String>,
    }

    struct MintArgs has drop {
        index: u64,
        name: String,
        description: String,
        url: Url,
        attributes: Attributes,
    }

    struct MintDataEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    struct BurnDataEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    // === Entrypoints ===

    /// Mint one embedded `Nft` with `Unique` data and send it to `recipient`.
    /// Invokes `mint_and_transfer()`.
    /// Mints an NFT from a `Collection` with `Unlimited` supply.
    /// The only way to mint the NFT for a collection is to give a reference to
    /// [`UID`]. One is only allowed to mint `Nft`s for a given collection
    /// if one is the collection owner, or if it is a shared collection.
    public entry fun direct_mint_unlimited_collection_nft<M: store>(
        index: u64,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        collection: &Collection<M, Unlimited>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let args = mint_args(
            index,
            name,
            description,
            url,
            to_string_vector(&mut attribute_keys),
            to_string_vector(&mut attribute_values),
        );

        mint_and_transfer(
            args,
            collection::id(collection),
            recipient,
            ctx,
        );
    }

    /// Mint one embedded `Nft` with `Unique` data and send it to `recipient`.
    /// Invokes `mint_and_transfer()`.
    /// Mints an NFT from a `Collection` with `Limited` supply.
    /// The only way to mint the NFT for a collection is to give a reference to
    /// [`UID`]. One is only allowed to mint `Nft`s for a given collection
    /// if one is the collection owner, or if it is a shared collection.
    public entry fun direct_mint_limited_collection_nft<M: store>(
        index: u64,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        collection: &mut Collection<M, Limited>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let args = mint_args(
            index,
            name,
            description,
            url,
            to_string_vector(&mut attribute_keys),
            to_string_vector(&mut attribute_values),
        );
        
        collection::increase_supply(collection, 1);

        mint_and_transfer(
            args,
            collection::id(collection),
            recipient,
            ctx,
        );
    }

    /// Burns embedded `Nft` along with its `Unique`. It invokes `burn_nft()`
    public entry fun burn_collection_nft(
        nft: Nft<Unique>,
    ) {
        burn_nft(nft);
    }

    // === Getter Functions  ===

    /// Get the Nft Unique's `id`
    public fun id(
        nft_data: &Unique,
    ): ID {
        *object::uid_as_inner(&nft_data.id)
    }

    /// Get the Nft Unique's `id` as reference
    public fun id_ref(
        nft_data: &Unique,
    ): &ID {
        object::uid_as_inner(&nft_data.id)
    }

    /// Get the Nft Unique's `index`
    public fun index(
        nft_data: &Unique,
    ): u64 {
        nft_data.index
    }

    /// Get the Nft Unique's `name`
    public fun name(
        nft_data: &Unique,
    ): String {
        nft_data.name
    }

    /// Get the Nft Unique's `description`
    public fun description(
        nft_data: &Unique,
    ): String {
        nft_data.name
    }

    /// Get the Nft Unique's `collection_id`
    public fun collection_id(
        nft_data: &Unique,
    ): &ID {
        &nft_data.collection_id
    }

    /// Get the Nft Unique's `url`
    public fun url(
        nft_data: &Unique,
    ): Url {
        nft_data.url
    }

    /// Get the Nft Unique's `attributes`
    public fun attributes(
        nft_data: &Unique,
    ): &Attributes {
        &nft_data.attributes
    }

    // === Private Functions ===

    fun nft_data_id(nft_data: &Unique): ID {
        object::uid_to_inner(&nft_data.id)
    }

    fun mint_and_transfer(
        args: MintArgs,
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

        let nft_data = Unique {
            id: data_id,
            index: args.index,
            name: args.name,
            description: args.description,
            collection_id: collection_id,
            url: args.url,
            attributes: args.attributes,
        };

        let nft = nft::mint_nft_embedded(
            nft_data_id(&nft_data),
            nft_data,
            ctx
        );

        transfer::transfer(
            nft,
            recipient,
        );
    }

    fun burn_nft(
        nft: Nft<Unique>,
    ) {
        let data_option = nft::burn_embedded_nft(nft);

        // TODO: Consider the best way to handle the data object:
        // Send it to the sender?
        // Make it shared?
        // Delete it?
        let data = option::extract(&mut data_option);
        option::destroy_none(data_option);

        event::emit(
            BurnDataEvent {
                object_id: id(&data),
                collection_id: *collection_id(&data),
            }
        );

        let Unique {
            id,
            index: _,
            name: _,
            description: _,
            collection_id: _,
            url: _,
            attributes: _,
        } = data;

        object::delete(id);
    }

    fun mint_args(
        index: u64,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<String>,
        attribute_values: vector<String>,
    ): MintArgs {
        let attributes = Attributes {
            keys: attribute_keys,
            values: attribute_values,
        };

        MintArgs {
            index,
            name: string::utf8(name),
            description: string::utf8(description),
            url: url::new_unsafe_from_bytes(url),
            attributes,
        }
    }
}