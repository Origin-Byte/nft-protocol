//! Module of a composable NFT `Data` type.
//! 
//! It acts as a standard implementation for composable / combinable NFTs.
//! `Data` objects can be combined to produce `ComboData` objects. Loose NFTs
//! can be minted pointing at a `Data` or `ComboData` object.
//! 
//! To mint a cNFT, there needs to be the following requirements:
//! 
//! - The collection first mint all the ComboData objects, serving as a 
//! blueprint determining which NFTs can be combined.
//! - For a given ComboData (i.e. Weapon + Skin), the user must own one NFT for
//! each Data object represented by the Combo (i.e. Must own the Weapon NFT
//! and the skin NFT). The user then calls `mint_combo_nft_loose` to mint the
//! cNFT (i.e. Weapon with a Skin) and burn the individual NFTs (i.e. the Weapon
//! and the Skin).
module nft_protocol::c_nft {
    use sui::object::{Self, UID, ID};
    use std::string::{Self, String};
    use std::option::{Self, Option};
    use std::vector;
    
    use sui::event;
    use sui::transfer;
    use sui::vec_map::{Self, VecMap};
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self, Url};
    
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::cap::{Limited, Unlimited};
    use nft_protocol::utils::{to_string_vector};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::nft::{Self, Nft};

    struct Composable<C: store + copy> has key, store {
        id: UID,
        data: Option<Data>,
        collection_id: ID,
        supply: Supply,
        components: VecMap<ID, C>,
    }

    struct ComposableClone<C: store> has store, copy {
        data: Option<Data>,
        collection_id: ID,
        components: VecMap<ID, C>,
    }

    struct Data has store, copy {
        index: u64,
        name: String,
        description: String,
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
        max_supply: Option<u64>,
    }

    struct MintDataEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    struct BurnDataEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    struct MintComboDataEvent has copy, drop {
        data_ids: vector<ID>,
        collection_id: ID,
    }

    // TODO: Must use this event
    struct BurnComboDataEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    // === Entrypoints ===

    public entry fun mint_unlimited_collection_nft_data<MetaColl: store, C: store + copy>(
        index: u64,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        max_supply: Option<u64>,
        collection: &Collection<MetaColl, Unlimited>,
        ctx: &mut TxContext,
    ) {
        let collection_id = collection::id(collection);
        let args = mint_args(
            index,
            name,
            description,
            url,
            to_string_vector(&mut attribute_keys),
            to_string_vector(&mut attribute_values),
            option::none(),
        );

        mint_and_share_data<C>(
            args,
            collection::id(collection),
            max_supply,
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
    public entry fun mint_limited_collection_nft_data<MetaColl: store, C: store + copy>(
        index: u64,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        max_supply: Option<u64>,
        collection: &mut Collection<MetaColl, Limited>,
        ctx: &mut TxContext,
    ) {
        let args = mint_args(
            index,
            name,
            description,
            url,
            to_string_vector(&mut attribute_keys),
            to_string_vector(&mut attribute_values),
            max_supply,
        );

        collection::increase_supply(collection, 1);

        mint_and_share_data<C>(
            args,
            collection::id(collection),
            max_supply,
            ctx,
        );
    }

    public entry fun compose_nft_data
        <MetaColl: store, Cap: store, D: store + copy, C: store + copy>
    (
        nfts_data: vector<Composable<C>>,
        collection: &mut Collection<MetaColl, Cap>,
        max_supply: Option<u64>,
        ctx: &mut TxContext,
    ) {
        let data_vec: VecMap<ID, ComposableClone<C>> = vec_map::empty();
        let data_ids: vector<ID> = vector::empty();
        let collection_id = collection::id(collection);

        let len = vector::length(&nfts_data);

        while (len > 0) {
            let nft_data = vector::pop_back(&mut nfts_data);

            assert!(nft_data.collection_id == collection_id, 0);

            let data_id = nft_data_id(&nft_data);
            
            let data = ComposableClone<C> {
                data: nft_data.data,
                collection_id: nft_data.collection_id,
                components: nft_data.components,
            };

            vec_map::insert(&mut data_vec, data_id, data);

            transfer::share_object(nft_data);
            
            len = len - 1;
        };

        event::emit(
            MintComboDataEvent {
                data_ids: data_ids,
                collection_id: collection_id,
            }
        );

        vector::destroy_empty(nfts_data);
        let id = object::new(ctx);

        // TODO: This forces the Data type of the cNFT to be the same Data
        // type of its constituent NFTs. We need to consider if that is the
        // best approach.
        let combo_data: Composable<ComposableClone<C>> = Composable {
            id: id,
            data: option::none(),
            collection_id: collection_id,
            supply: supply::new(max_supply, false),
            components: data_vec,
        };

        transfer::share_object(combo_data);
    }

    // Burn two NFT pointers
    // Loose allows for the creation of many NFTs out of the metadata
    public entry fun mint_c_nft<C: store + copy>(
        nfts: vector<Nft<Composable<C>>>,
        nfts_data: vector<Composable<C>>, // TODO: Ideally we would pass &Data
        combo_data: &Composable<C>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let len = vector::length(&nfts);

        while (len > 0) {
            let nft = vector::pop_back(&mut nfts);
            let data = vector::pop_back(&mut nfts_data);
            assert!(nft::data_id(&nft) == id(&data), 0);

            // `burn_loose_nft` will fail if the NFT is embedded
            nft::burn_loose_nft(nft);

            // TODO: This is really not ideal - ideally we would use a reference
            // to the object
            transfer::share_object(data);
            
            len = len - 1;
        };
        vector::destroy_empty(nfts);
        vector::destroy_empty(nfts_data);

        // TODO: Need to assert that the combo data object is the right object
        let nft = nft::mint_nft_loose<Data>(
            object::uid_to_inner(&combo_data.id),
            ctx,
        );

        transfer::transfer(
            nft,
            recipient,
        );
    }

    public entry fun mint_nft<C: store + copy>(
        nft_data: &mut Composable<C>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        // TODO: should we allow for the minting of more than one NFT at 
        // a time?
        supply::increase_supply(&mut nft_data.supply, 1);

        let nft = nft::mint_nft_loose<Data>(
            nft_data_id(nft_data),
            ctx,
        );

        transfer::transfer(
            nft,
            recipient,
        );
    }

    /// Burns loose `Nft`. Burning a loose `Nft` has no impact
    /// on the `Data` object besides decreasing its current supply.
    /// It invokes `burn_nft()`
    public entry fun burn_nft<MetaColl: store, C: store + copy>(
        nft: Nft<Composable<C>>,
        nft_data: &mut Composable<C>,
    ) {
        assert!(nft::data_id(&nft) == id(nft_data), 0);

        supply::decrease_supply(&mut nft_data.supply, 1);
        nft::burn_loose_nft(nft);
    }

    public entry fun split_c_nft<MetaColl: store, C: store + copy>(
        nft: Nft<Composable<C>>,
        c_nft_data: &mut Composable<C>,
        nfts_data: vector<Composable<C>>,
        ctx: &mut TxContext,
    ) {
        // Asset that nft pointer corresponds to c_nft_data
        // If so, then burn pointer and mint pointer for each nft_datas
        assert!(nft::data_id(&nft) == id(c_nft_data), 0);

        supply::decrease_supply(&mut c_nft_data.supply, 1);
        nft::burn_loose_nft(nft);

        let len = vector::length(&nfts_data);

        while (len > 0) {
            let data = vector::pop_back(&mut nfts_data);

            let nft = nft::mint_nft_loose<Composable<C>>(
                id(&data),
                ctx,
            );

            transfer::transfer(
                nft,
                tx_context::sender(ctx),
            );

            // TODO: This is really not ideal - ideally we would use a reference
            // to the object
            transfer::share_object(data);
            
            len = len - 1;
        };
        
        vector::destroy_empty(nfts_data);
    }

    // === Getter Functions  ===

    /// Get the Nft Data's `id`
    public fun id<C: store + copy>(
        nft_data: &Composable<C>,
    ): ID {
        object::uid_to_inner(&nft_data.id)
    }
    
    /// Get the Nft Data's `id` as reference
    public fun id_ref<C: store + copy>(
        nft_data: &Composable<C>,
    ): &ID {
        object::uid_as_inner(&nft_data.id)
    }

    /// Get the Nft Data's `index`
    // TODO: this should point to the Composable...
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

    // TODO
    // /// Get the Nft Data's `collection_id`
    // public fun collection_id(
    //     nft_data: &Data,
    // ): &ID {
    //     &nft_data.collection_id
    // }

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

    // TODO
    // /// Get the Nft Data's `supply`
    // public fun supply(
    //     nft_data: &Data,
    // ): &Supply {
    //     &nft_data.supply
    // }

    // === Private Functions ===

    fun nft_data_id<C: store + copy>(nft_data: &Composable<C>): ID {
        object::uid_to_inner(&nft_data.id)
    }

    fun mint_and_share_data<C: store + copy>(
        args: MintArgs,
        collection_id: ID,
        max_supply: Option<u64>,
        ctx: &mut TxContext,
    ) {
        let data_id = object::new(ctx);

        event::emit(
            MintDataEvent {
                object_id: object::uid_to_inner(&data_id),
                collection_id: collection_id,
            }
        );

        let data = Data {
            index: args.index,
            name: args.name,
            description: args.description,
            url: args.url,
            attributes: args.attributes,
        };

        let composable: Composable<C> = Composable {
            id: data_id,
            data: option::some(data),
            collection_id: collection_id,
            supply: supply::new(max_supply, false),
            components: vec_map::empty(),
        };

        transfer::share_object(composable);
    }

    fun mint_args(
        index: u64,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<String>,
        attribute_values: vector<String>,
        max_supply: Option<u64>,
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
            max_supply,
        }
    }
}