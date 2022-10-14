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
    
    use nft_protocol::collection::{Self, MintAuthority};
    use nft_protocol::utils::{to_string_vector};
    use nft_protocol::supply_policy;
    use nft_protocol::slingshot::{Self, Slingshot};
    use nft_protocol::sale;
    use nft_protocol::nft::{Self, Nft};

    /// An NFT `Unique` data object with standard fields.
    struct Unique has key, store {
        id: UID,
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

    // === Functions exposed to Witness Module ===

    /// Mint one embedded `Nft` with `Unique` data and send it to `Launchpad`.
    /// Invokes `mint_to_launchpad()`.
    /// Mints an NFT from a `Collection` with unregulated supply.
    /// The only way to mint the NFT for a collection is to give a reference to
    /// [`UID`]. One is only allowed to mint `Nft`s for a given collection
    /// if one is the `MintAuthority` owner.
    ///  
    /// To be called by the Witness Module deployed by NFT creator.
    public fun mint_unregulated_nft<T, Market: store>(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        mint: &MintAuthority<T>,
        sale_index: u64,
        // TODO: Ideally we do not take a mutable reference such that 
        // no lock is needed
        launchpad: &mut Slingshot<T, Market>,
        ctx: &mut TxContext,
    ) {
        // Assert that it has an unregulated supply policy
        assert!(
            !supply_policy::regulated(collection::supply_policy(mint)), 0
        );

        let args = mint_args(
            name,
            description,
            url,
            to_string_vector(&mut attribute_keys),
            to_string_vector(&mut attribute_values),
        );

        mint_to_launchpad(
            args,
            collection::mint_collection_id(mint),
            sale_index,
            launchpad,
            ctx,
        );
    }

    /// Mint one embedded `Nft` with `Unique` data and send it to `Launchpad`.
    /// Invokes `mint_to_launchpad()`.
    /// Mints an NFT from a `Collection` with regulated supply.
    /// The only way to mint the NFT for a collection is to give a reference to
    /// [`UID`]. One is only allowed to mint `Nft`s for a given collection
    /// if one is the `MintAuthority` owner.
    /// 
    /// To be called by the Witness Module deployed by NFT creator.
    public fun mint_regulated_nft<T, Market: store>(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        mint: &mut MintAuthority<T>,
        sale_index: u64,
        launchpad: &mut Slingshot<T, Market>,
        ctx: &mut TxContext,
    ) {
        // Assert that it has regulated supply policy
        assert!(
            supply_policy::regulated(collection::supply_policy(mint)), 0
        );

        let args = mint_args(
            name,
            description,
            url,
            to_string_vector(&mut attribute_keys),
            to_string_vector(&mut attribute_values),
        );

        collection::increase_supply(mint, 1);

        mint_to_launchpad(
            args,
            collection::mint_collection_id(mint),
            sale_index,
            launchpad,
            ctx,
        );
    }

    /// Mint one embedded `Nft` with `Unique` data and send it to `recipient`.
    /// Invokes `mint_and_transfer()`.
    /// Mints an NFT from a `Collection` with unregulated supply.
    /// The only way to mint the NFT for a collection is to give a reference to
    /// [`UID`]. One is only allowed to mint `Nft`s for a given collection
    /// if one is the `MintAuthority` owner.
    /// 
    /// To be called by the Witness Module deployed by NFT creator.
    public fun direct_mint_unregulated_nft<T>(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        mint: &MintAuthority<T>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        // Assert that it has an unregulated supply policy
        assert!(
            !supply_policy::regulated(collection::supply_policy(mint)), 0
        );

        let args = mint_args(
            name,
            description,
            url,
            to_string_vector(&mut attribute_keys),
            to_string_vector(&mut attribute_values),
        );

        mint_and_transfer<T>(
            args,
            collection::mint_collection_id(mint),
            recipient,
            ctx,
        );
    }

    /// Mint one embedded `Nft` with `Unique` data and send it to `recipient`.
    /// Invokes `mint_and_transfer()`.
    /// Mints an NFT from a `Collection` with regulated supply.
    /// The only way to mint the NFT for a collection is to give a reference to
    /// [`UID`]. One is only allowed to mint `Nft`s for a given collection
    /// if one is the `MintAuthority` owner.
    /// 
    /// To be called by the Witness Module deployed by NFT creator.
    public fun direct_mint_regulated_nft<T>(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        mint: &mut MintAuthority<T>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        // Assert that it has a regulated supply policy
        assert!(
            supply_policy::regulated(collection::supply_policy(mint)), 0
        );

        let args = mint_args(
            name,
            description,
            url,
            to_string_vector(&mut attribute_keys),
            to_string_vector(&mut attribute_values),
        );
        
        collection::increase_supply(mint, 1);

        mint_and_transfer<T>(
            args,
            collection::mint_collection_id(mint),
            recipient,
            ctx,
        );
    }

    // === Entrypoints ===

    /// Burns embedded `Nft` along with its `Unique`. It invokes `burn_nft()`
    public entry fun burn_nft<T>(
        nft: Nft<T, Unique>,
    ) {
        burn_nft_(nft);
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

    fun mint_and_transfer<T>(
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
            name: args.name,
            description: args.description,
            collection_id: collection_id,
            url: args.url,
            attributes: args.attributes,
        };

        let nft = nft::mint_nft_embedded<T, Unique>(
            nft_data_id(&nft_data),
            nft_data,
            ctx
        );

        transfer::transfer(
            nft,
            recipient,
        );
    }

    fun mint_to_launchpad<T, M: store>(
        args: MintArgs,
        collection_id: ID,
        sale_index: u64,
        launchpad: &mut Slingshot<T, M>,
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
            name: args.name,
            description: args.description,
            collection_id: collection_id,
            url: args.url,
            attributes: args.attributes,
        };

        let nft = nft::mint_nft_embedded<T, Unique>(
            nft_data_id(&nft_data),
            nft_data,
            ctx
        );

        let sale = slingshot::sale_mut(launchpad, sale_index);

        sale::add_nft<T, M>(sale, nft::id(&nft));

        transfer::transfer_to_object(
            nft,
            launchpad,
        );
    }

    fun burn_nft_<T>(
        nft: Nft<T, Unique>,
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
            name: _,
            description: _,
            collection_id: _,
            url: _,
            attributes: _,
        } = data;

        object::delete(id);
    }

    fun mint_args(
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
            name: string::utf8(name),
            description: string::utf8(description),
            url: url::new_unsafe_from_bytes(url),
            attributes,
        }
    }
}