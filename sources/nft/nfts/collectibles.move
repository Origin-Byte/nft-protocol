// TODO: Mint to launchpad functions
// TODO: consider implementing function `burn_unlimited_collection_nft_data`
// but this is dangerous because we don't a way to measure if there are any
// nfts pointing to that data
// TODO: Shall we had rarity field?
module nft_protocol::collectibles {
    use sui::event;
    use sui::object::{Self, UID, ID};
    use std::string::{Self, String};
    use std::option::{Option};
    
    use sui::transfer;
    use sui::tx_context::{TxContext};
    use sui::url::{Self, Url};
    
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::cap::{Limited, Unlimited};
    use nft_protocol::utils::{to_string_vector};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::nft::{Self, Nft};

    struct Data has key, store {
        id: UID,
        index: u64,
        name: String,
        description: String,
        collection_id: ID,
        url: Url,
        attributes: Attributes,
        supply: Supply,
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

    // === Entrypoints ===

    public entry fun mint_unlimited_collection_nft_data<MetaColl: store>(
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
        let args = mint_args(
            index,
            name,
            description,
            url,
            to_string_vector(&mut attribute_keys),
            to_string_vector(&mut attribute_values),
            max_supply,
        );

        mint_and_share_data(
            args,
            collection::id(collection),
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

        mint_and_share_data(
            args,
            collection::id(collection),
            ctx,
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

        let nft = nft::mint_nft_loose<Data>(
            nft_data_id(nft_data),
            ctx,
        );

        transfer::transfer(
            nft,
            recipient,
        );
    }

    public entry fun burn_limited_collection_nft_data<MetaColl: store>(
        nft_data: Data,
        collection: &mut Collection<MetaColl, Limited>,
    ) {
        assert!(
            nft_data.collection_id == collection::id(collection), 0
        );

        assert!(collection::is_mutable(collection), 0);

        collection::decrease_supply(collection, 1);

        let Data {
            id,
            index: _,
            name: _,
            description: _,
            collection_id: _,
            url: _,
            attributes: _,
            supply,
        } = nft_data;

        event::emit(
            BurnDataEvent {
                object_id: object::uid_to_inner(&id),
                collection_id: collection::id(collection),
            }
        );

        supply::destroy(supply);
        object::delete(id);
    }

    public entry fun burn_unlimited_collection_nft<MetaColl: store>(
        nft: Nft<Data>,
    ) {
        // TODO: There should be an assertion that the collection cap
        // is of type Unlimited, but how can we do this is the collecion
        // object is private? In essence we want this function to err for
        // NFTs of limited collections
        burn_nft(nft);
    }

    public entry fun burn_limited_collection_nft<MetaColl: store>(
        nft: Nft<Data>,
        nft_data: &mut Data,
    ) {
        assert!(nft::data_id(&nft) == id(nft_data), 0);

        supply::decrease_supply(&mut nft_data.supply, 1);
        burn_nft(nft);
    }

    // === Getter Functions  ===

    /// Get the Nft Data's `id`
    public fun id(
        nft_data: &Data,
    ): ID {
        object::uid_to_inner(&nft_data.id)
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

    /// Get the Nft Data's `supply` as reference
    public fun supply(
        nft_data: &Data,
    ): &Supply {
        &nft_data.supply
    }

    /// Get the Nft Data's `supply` as reference
    public fun supply_mut<MetaColl: store>(
        collection: &Collection<MetaColl, Limited>,
        nft_data: &mut Data,
    ): &Supply {
        assert!(collection::is_mutable(collection), 0);

        &mut nft_data.supply
    }

    // === Supply Functions ===

    // Explain that this function is for Limited collections
    // Limited collections can still have no supply, there is an opt-in 
    public entry fun cap_supply<MetaColl: store>(
        collection: &Collection<MetaColl, Limited>,
        nft_data: &mut Data,
        value: u64
    ) {
        assert!(collection::is_mutable(collection), 0);

        supply::cap_supply(
            &mut nft_data.supply,
            value
        )
    }

    public entry fun increase_supply_cap<MetaColl: store>(
        collection: &Collection<MetaColl, Limited>,
        nft_data: &mut Data,
        value: u64
    ) {
        assert!(collection::is_mutable(collection), 0);

        supply::increase_cap(
            &mut nft_data.supply,
            value
        )
    }

    public entry fun decrease_supply_cap<MetaColl: store>(
        collection: &Collection<MetaColl, Limited>,
        nft_data: &mut Data,
        value: u64
    ) {
        assert!(collection::is_mutable(collection), 0);

        supply::decrease_cap(
            &mut nft_data.supply,
            value
        )
    }

    // === Private Functions ===

    fun nft_data_id(nft_data: &Data): ID {
        object::uid_to_inner(&nft_data.id)
    }

    fun mint_and_share_data(
        args: MintArgs,
        collection_id: ID,
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

    fun burn_nft(
        nft: Nft<Data>,
    ) {
        nft::burn_loose_nft(nft);
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