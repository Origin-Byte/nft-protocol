// TODO: Mint to launchpad functions
module nft_protocol::c_nft {
    use sui::event;
    use sui::object::{Self, UID, ID};
    use std::string::{String};
    use std::option::{Self, Option};
    use std::vector;
    
    use sui::transfer;
    use sui::tx_context::{TxContext};
    use sui::url::{Url};
    
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::new_nft::{Self, Nft};
    use nft_protocol::cap::{Limited, Unlimited};
    use nft_protocol::utils::{to_string_vector};

    struct Data has key, store {
        id: UID,
        index: u64,
        name: String,
        supply: Supply,
        description: String,
        collection_id: ID,
        url: Url,
        attributes: Attributes,
        // TODO: need to add more fields here
    }

    struct ComboData<Data> has key, store {
        id: UID,
        data: vector<Data>,
    }

    struct CombinableData has store {
        data_id: ID,
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

    public entry fun mint_unlimited_collection_nft_data<MetaColl: store>(
        args: InitArgs,
        max_supply: Option<u64>,
        collection: &Collection<MetaColl, Unlimited>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        mint_and_share_data(
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
    public entry fun mint_limited_collection_nft_data<MetaColl: store>(
        args: InitArgs,
        recipient: address,
        collection: &mut Collection<MetaColl, Limited>,
        ctx: &mut TxContext,
    ) {
        collection::increase_supply(collection, 1);

        mint_and_share_data(
            args,
            collection::id(collection),
            recipient,
            ctx,
        );
    }

    public entry fun init_combo_data<MetaColl: store, Cap: store>(
        nft_data_1: &Data,
        nft_data_2: &Data,
        collection: &mut Collection<MetaColl, Cap>,
        ctx: &mut TxContext,
    ): ComboData<CombinableData> {
        // event::emit(
        //     MintDataEvent {
        //         object_id: object::uid_to_inner(&data_id),
        //         collection_id: collection_id,
        //     }
        // );

        let data_1 = CombinableData {
            data_id: nft_data_id(nft_data_1),
            index: nft_data_1.index,
            name: nft_data_1.name,
            description: nft_data_1.description,
            collection_id: nft_data_1.collection_id,
            url: nft_data_1.url,
            attributes: nft_data_1.attributes,
        };

        let data_2 = CombinableData {
            data_id: nft_data_id(nft_data_2),
            index: nft_data_2.index,
            name: nft_data_2.name,
            description: nft_data_2.description,
            collection_id: nft_data_2.collection_id,
            url: nft_data_2.url,
            attributes: nft_data_2.attributes,
        };

        let id = object::new(ctx);

        let data: vector<CombinableData> = vector::empty();
        vector::push_back(&mut data, data_1);
        vector::push_back(&mut data, data_2);

        ComboData {
            id: id,
            data: data,
        }
    }

    public entry fun combine_combo_data<MetaColl: store, Cap: store, CData: store>(
        combo_data_1: ComboData<CData>,
        combo_data_2: ComboData<CData>,
        collection: &mut Collection<MetaColl, Cap>,
        ctx: &mut TxContext,
    ): ComboData<ComboData<CData>> {
        // event::emit(
        //     MintDataEvent {
        //         object_id: object::uid_to_inner(&data_id),
        //         collection_id: collection_id,
        //     }
        // );

        let id = object::new(ctx);

        let data: vector<ComboData<CData>> = vector::empty();
        vector::push_back(&mut data, combo_data_1);
        vector::push_back(&mut data, combo_data_2);

        ComboData {
            id: id,
            data: data,
        }
    }

    // Burn two NFT pointers
    // Loose allows for the creation of many NFTs out of the metadata
    public entry fun mint_combo_2_nft_loose<CData: store>(
        nft_1: Nft<Data>,
        nft_2: Nft<Data>,
        data_1: &Data,
        data_2: &Data,
        combo_data: &ComboData<CData>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        // TODO: Check that only loose NFTs can be combined
        // this is checked when burning nft loose function is called
        assert!(new_nft::data_id(&nft_1) == id_ref(data_1), 0);
        assert!(new_nft::data_id(&nft_2) == id_ref(data_2), 0);

        new_nft::burn_loose_nft(nft_1);
        new_nft::burn_loose_nft(nft_2);

        // TODO: Need to assert that the combo data object is the right object

        let nft = new_nft::mint_nft_loose<Data>(
            object::uid_to_inner(&combo_data.id),
            ctx,
        );

        transfer::transfer(
            nft,
            recipient,
        );
    }

    // Burn two NFT pointers
    // Loose allows for the creation of many NFTs out of the metadata
    public entry fun mint_combo_n_nft_loose<CData: store>(
        nfts: vector<Nft<Data>>,
        nfts_data: vector<Data>, // TODO: Ideally we would pass &Data
        combo_data: &ComboData<CData>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        // TODO: Check that only loose NFTs can be combined
        // this is checked when burning nft loose function is called
        let len = vector::length(&nfts);

        while (len > 0) {
            let nft = vector::pop_back(&mut nfts);
            let data = vector::pop_back(&mut nfts_data);
            assert!(new_nft::data_id(&nft) == id_ref(&data), 0);

            new_nft::burn_loose_nft(nft);
            // TODO: This is really not ideal - ideally we would use a reference
            // to the object
            transfer::share_object(data);
            
            len = len - 1;
        };
        vector::destroy_empty(nfts);
        vector::destroy_empty(nfts_data);

        // TODO: Need to assert that the combo data object is the right object
        let nft = new_nft::mint_nft_loose<Data>(
            object::uid_to_inner(&combo_data.id),
            ctx,
        );

        transfer::transfer(
            nft,
            recipient,
        );
    }

    // Burn two NFT pointers
    // Embedded allows for the creation of just one combinable NFT
    // Currently only supports two nfts
    public entry fun mint_combo_2_nft_emdedded<CData: store>(
        nft_1: Nft<Data>,
        nft_2: Nft<Data>,
        data_1: &Data,
        data_2: &Data,
        combo_data: ComboData<CData>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        // TODO: Check that only loose NFTs can be combined
        // this is checked when burning nft loose function is called
        assert!(new_nft::data_id(&nft_1) == id_ref(data_1), 0);
        assert!(new_nft::data_id(&nft_2) == id_ref(data_2), 0);

        new_nft::burn_loose_nft(nft_1);
        new_nft::burn_loose_nft(nft_2);

        // TODO: Need to assert that the combo data object is the right object

        let nft = new_nft::mint_nft_embedded<ComboData<CData>>(
            object::uid_to_inner(&combo_data.id),
            combo_data,
            ctx,
        );

        transfer::transfer(
            nft,
            recipient,
        );
    }

    // Burn two NFT pointers
    // Loose allows for the creation of many NFTs out of the metadata
    public entry fun mint_combo_n_nft_embedded<CData: store>(
        nfts: vector<Nft<Data>>,
        combo_data: &ComboData<CData>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        // TODO: Check that only loose NFTs can be combined
        // this is checked when burning nft loose function is called
        let len = vector::length(&nfts);

        while (len > 0) {
            let nft = vector::pop_back(&mut nfts);

            let data = option::extract(&mut new_nft::burn_embedded_nft(nft));

            transfer::share_object(data);
            
            len = len - 1;
        };
        vector::destroy_empty(nfts);

        // TODO: Need to assert that the combo data object is the right object
        let nft = new_nft::mint_nft_loose<Data>(
            object::uid_to_inner(&combo_data.id),
            ctx,
        );

        transfer::transfer(
            nft,
            recipient,
        );
    }

    public entry fun mint_nft(
        nft_data: &mut Data,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        // TODO: should we allow for the minting of more than one NFT at 
        // a time?
        supply::increase_supply(&mut nft_data.supply, 1);

        let nft = new_nft::mint_nft_loose<Data>(
            nft_data_id(nft_data),
            ctx,
        );

        transfer::transfer(
            nft,
            recipient,
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

    fun mint_and_share_data(
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

        let data = Data {
            id: data_id,
            index: args.index,
            name: args.name,
            supply: supply::new(args.max_supply, true),
            description: args.description,
            collection_id: collection_id,
            url: args.url,
            attributes: args.attributes,
        };

        transfer::share_object(data);
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