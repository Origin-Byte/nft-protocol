//! Module of a collectibles NFT `Collectible` data type.
//! 
//! It acts as a standard domain-specific implementation of an NFT type with
//! supply, fitting use cases such as Digital Collectibles (e.g. Baseball
//! cards).
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

    struct Collectible has key, store {
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

    // === Functions exposed to Witness Module ===

    /// Mints loose NFT `Collectible` data and shares it.
    /// Invokes `mint_and_share_data()`.
    /// Mints a Collectible data object for NFT(s) from a `Collection` of `Unlimited` supply.
    /// The only way to mint the NFT for a collection is to give a reference to
    /// [`UID`]. One is only allowed to mint `Nft`s for a given collection
    /// if one is the collection owner, or if it is a shared collection.
    /// 
    /// To be called by the Witness Module deployed by NFT creator.
    public fun mint_unlimited_collection_nft_data<T, M: store>(
        index: u64,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        max_supply: Option<u64>,
        collection: &Collection<T, M, Unlimited>,
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

    /// Mints loose NFT `Collectible` data and shares it.
    /// Invokes `mint_and_share_data()`.
    /// Mints a Collectible data object for NFT(s) from a `Collection` of `Limited` supply.
    /// The only way to mint the NFT for a collection is to give a reference to
    /// [`UID`]. One is only allowed to mint `Nft`s for a given collection
    /// if one is the collection owner, or if it is a shared collection.
    /// 
    /// To be called by the Witness Module deployed by NFT creator.
    public fun mint_limited_collection_nft_data<T, M: store>(
        index: u64,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        max_supply: Option<u64>,
        collection: &mut Collection<T, M, Limited>,
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

    /// Mints loose NFT and transfers it to `recipient`
    /// Invokes `mint_nft_loose()`.
    /// This function call comes after the minting of the `Data` object.
    /// 
    /// To be called by Launchpad contract
    /// TODO: The flow here needs to be reconsidered
    public fun mint_nft<T, M: store, C: store>(
        _collection: &Collection<T, M, C>,
        nft_data: &mut Collectible,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        // TODO: As it stands, only the collection can call this function,
        // whereas the launchad is directly calling `nft::mint_nft_loose`.
        // This means that it is not increasing supply. This needs to fix
        // with high priority.
        supply::increase_supply(&mut nft_data.supply, 1);

        let nft = nft::mint_nft_loose<T, Collectible>(
            nft_data_id(nft_data),
            ctx,
        );

        transfer::transfer(
            nft,
            recipient,
        );
    }

    // === Entrypoints ===

    /// Burns loose NFT `Collectible` data. Burning a loose NFT `Collectible` 
    /// data can only be done once all the underlying `Nft`s pointing to that 
    /// object have been burned (or if none have been minted yet). 
    /// In other words, the `supply.current` must be zero.
    public entry fun burn_limited_collection_nft_data<T, M: store>(
        nft_data: Collectible,
        collection: &mut Collection<T, M, Limited>,
    ) {
        assert!(
            nft_data.collection_id == collection::id(collection), 0
        );

        assert!(collection::is_mutable(collection), 0);

        collection::decrease_supply(collection, 1);

        let Collectible {
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

    /// Burns loose `Nft`. Burning a loose `Nft` has no impact
    /// on the `Collectible` data object besides decreasing its current supply.
    /// It invokes `burn_loose_nft()`
    public entry fun burn_nft<T>(
        nft: Nft<T, Collectible>,
        nft_data: &mut Collectible,
    ) {
        assert!(nft::data_id(&nft) == id(nft_data), 0);

        supply::decrease_supply(&mut nft_data.supply, 1);
        nft::burn_loose_nft(nft);
    }

    // === Supply Functions ===

    /// NFT `Collectible` data objects have an opt-in `supply.cap`.
    /// `Data` objects without supply will have `option::none()` in its value.
    /// This Function call adds a value to the supply cap.
    public entry fun cap_supply<T, M: store, C: store>(
        collection: &Collection<T, M, C>,
        nft_data: &mut Collectible,
        value: u64
    ) {
        assert!(collection::is_mutable(collection), 0);

        supply::cap_supply(
            &mut nft_data.supply,
            value
        )
    }

    /// Increases the `supply.cap` of the NFT `Collectible`
    /// by the `value` amount
    public entry fun increase_supply_cap<T, M: store, C: store>(
        collection: &Collection<T, M, C>,
        nft_data: &mut Collectible,
        value: u64
    ) {
        assert!(collection::is_mutable(collection), 0);

        supply::increase_cap(
            &mut nft_data.supply,
            value
        )
    }

    /// Decreases the `supply.cap` of the NFT `Collectible`
    /// by the `value` amount.
    /// This function call fails if one attempts to decrease the supply cap
    /// to a value below the current supply.
    public entry fun decrease_supply_cap<T, M: store, C: store>(
        collection: &Collection<T, M, C>,
        nft_data: &mut Collectible,
        value: u64
    ) {
        assert!(collection::is_mutable(collection), 0);

        supply::decrease_cap(
            &mut nft_data.supply,
            value
        )
    }

    // === Getter Functions  ===

    /// Get the Nft Collectible's `id`
    public fun id(
        nft_data: &Collectible,
    ): ID {
        object::uid_to_inner(&nft_data.id)
    }

    /// Get the Nft Collectible's `id` as reference
    public fun id_ref(
        nft_data: &Collectible,
    ): &ID {
        object::uid_as_inner(&nft_data.id)
    }

    /// Get the Nft Collectible's `index`
    public fun index(
        nft_data: &Collectible,
    ): u64 {
        nft_data.index
    }

    /// Get the Nft Collectible's `name`
    public fun name(
        nft_data: &Collectible,
    ): String {
        nft_data.name
    }

    /// Get the Nft Collectible's `description`
    public fun description(
        nft_data: &Collectible,
    ): String {
        nft_data.name
    }

    /// Get the Nft Collectible's `collection_id`
    public fun collection_id(
        nft_data: &Collectible,
    ): &ID {
        &nft_data.collection_id
    }

    /// Get the Nft Collectible's `url`
    public fun url(
        nft_data: &Collectible,
    ): Url {
        nft_data.url
    }

    /// Get the Nft Collectible's `attributes`
    public fun attributes(
        nft_data: &Collectible,
    ): &Attributes {
        &nft_data.attributes
    }

    /// Get the Nft Collectible's `supply` as reference
    public fun supply(
        nft_data: &Collectible,
    ): &Supply {
        &nft_data.supply
    }

    /// Get the Nft Collectible's `supply` as reference
    public fun supply_mut<T, M: store>(
        collection: &Collection<T, M, Limited>,
        nft_data: &mut Collectible,
    ): &Supply {
        assert!(collection::is_mutable(collection), 0);

        &mut nft_data.supply
    }

    // === Private Functions ===

    fun nft_data_id(nft_data: &Collectible): ID {
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

        let data = Collectible {
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