// TODO: Mint to launchpad functions
// TODO: Consider which fields Nft should have
// TODO: Discuss if name should be data or metadata
// TODO: Consider renaming functions?
// TODO: Do we want a field for further_data: Option<SomeObject?>
// TODO: Discuss how mutability should work for these NFTs
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

    struct Data has key, store {
        id: UID,
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

    /// Mint one `Nft` with `Data` and send it to `recipient`.
    /// Invokes `mint_and_transfer()`.
    /// Mints an NFT from a `Collection` with `Unlimited` supply.
    /// The only way to mint the NFT for a collection is to give a reference to
    /// [`UID`]. Since this a property, it can be only accessed in the smart 
    /// contract which creates the collection. That contract can then define
    /// their own logic for restriction on minting.
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

    /// Mint one `Nft` with `Data` and send it to `recipient`.
    /// Invokes `mint_and_transfer()`.
    /// Mints an NFT from a `Collection` with `Limited` supply.
    /// The only way to mint the NFT for a collection is to give a reference to
    /// [`UID`]. Since this a property, it can be only accessed in the smart 
    /// contract which creates the collection. That contract can then define
    /// their own logic for restriction on minting.
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

    public entry fun burn_unlimited_collection_nft(
        nft: Nft<Data>,
    ) {
        burn_nft(nft);
    }

    public entry fun burn_limited_collection_nft<M: store>(
        nft: Nft<Data>,
    ) {
        // TODO: We need to reflect that collection supply goes down
        burn_nft(nft);
    }

    // === Getter Functions  ===

    /// Get the Nft Data's `id`
    public fun id(
        nft_data: &Data,
    ): ID {
        *object::uid_as_inner(&nft_data.id)
    }

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

        let nft_data = Data {
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
        nft: Nft<Data>,
    ) {
        let data_option = nft::burn_embedded_nft(nft);

        // TODO: What shall we do with the data?
        // Send it to the sender?
        // Make it shared?
        let data = option::extract(&mut data_option);
        option::destroy_none(data_option);

        event::emit(
            BurnDataEvent {
                object_id: id(&data),
                collection_id: *collection_id(&data),
            }
        );

        let Data {
            id,
            index: _,
            name: _,
            description: _,
            collection_id: _,
            url: _,
            attributes: _,
        } = data;

        // TODO: Consider if we really want to delete the nft data here
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