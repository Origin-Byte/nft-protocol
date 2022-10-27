//! Module of a collectible NFT `Collectible` data type.
//!
//! It acts as a standard domain-specific implementation of an NFT type with
//! supply, fitting use cases such as Digital Collectibles (e.g. Baseball
//! cards).
module nft_protocol::collectible {
    use sui::event;
    use sui::object::{Self, UID, ID};
    use std::string::{Self, String};
    use sui::transfer;
    use sui::tx_context::{TxContext};
    use sui::url::{Self, Url};

    use nft_protocol::err;
    use nft_protocol::supply_policy;
    use nft_protocol::collection::{Self, Collection, MintAuthority};
    use nft_protocol::utils::{to_string_vector};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::nft::{Self, Nft};

    const U64_MAX: u64 = 18446744073709551615;

    struct Collectible has key, store {
        id: UID,
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
        name: String,
        description: String,
        url: Url,
        attributes: Attributes,
        max_supply: u64,
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
    ///
    /// Mints a Collectible data object for NFT(s) from an unregulated
    /// `Collection`.
    /// The only way to mint the NFT data for a collection is to give a
    /// reference to [`UID`]. One is only allowed to mint `Nft`s for a
    /// given collection if one is the `MintAuthority` owner.
    ///
    /// To be called by the Witness Module deployed by NFT creator.
    public fun mint_unregulated_nft_data<T>(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        max_supply: u64,
        mint: &MintAuthority<T>,
        ctx: &mut TxContext,
    ) {
        // Assert that it has an unregulated supply policy
        assert!(
            !supply_policy::regulated(collection::supply_policy(mint)),
            err::supply_policy_mismatch(),
        );

        let args = mint_args(
            name,
            description,
            url,
            to_string_vector(&mut attribute_keys),
            to_string_vector(&mut attribute_values),
            max_supply,
        );

        mint_and_share_data(
            args,
            collection::mint_collection_id(mint),
            ctx,
        );
    }

    /// Mints loose NFT `Collectible` data and shares it.
    /// Invokes `mint_and_share_data()`.
    ///
    /// Mints a Collectible data object for NFT(s) from a regulated
    /// `Collection`.
    /// The only way to mint the NFT data for a collection is to give a
    /// reference to [`UID`]. One is only allowed to mint `Nft`s for a
    /// given collection if one is the `MintAuthority` owner.
    ///
    /// To be called by the Witness Module deployed by NFT creator.
    ///
    /// To be called by the Witness Module deployed by NFT creator.
    public fun mint_regulated_nft_data<T>(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        max_supply: u64,
        mint: &mut MintAuthority<T>,
        ctx: &mut TxContext,
    ) {
        // Assert that it has a regulated supply policy
        assert!(
            supply_policy::regulated(collection::supply_policy(mint)),
            err::supply_policy_mismatch(),
        );

        let args = mint_args(
            name,
            description,
            url,
            to_string_vector(&mut attribute_keys),
            to_string_vector(&mut attribute_values),
            max_supply,
        );

        collection::increment_supply(mint, 1);

        mint_and_share_data(
            args,
            collection::mint_collection_id(mint),
            ctx,
        );
    }

    /// Mints loose NFT and transfers it to `recipient`
    /// Invokes `mint_nft_loose()`.
    /// This function call comes after the minting of the `Data` object.
    ///
    /// To be called by Launchpad contract
    /// TODO: The flow here needs to be reconsidered
    /// TODO: To be deprecated --> calls should be done to the nft module
    public fun mint_nft<T, M: store>(
        _mint: &MintAuthority<T>,
        nft_data: &mut Collectible,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        // TODO: As it stands, only the collection can call this function,
        // whereas the launchad is directly calling `nft::mint_nft_loose`.
        // This means that it is not increasing supply. This needs to fix
        // with high priority.
        supply::increment_supply(&mut nft_data.supply, 1);

        let nft = nft::mint_nft_loose<T, Collectible>(
            nft_data_id(nft_data),
            recipient,
            nft_data.collection_id,
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
    public entry fun burn_regulated_collection_nft_data<T, M: store>(
        nft_data: Collectible,
        mint: &mut MintAuthority<T>,
        collection: &mut Collection<T, M>,
    ) {
        // Assert that it has a regulated supply policy
        assert!(
            supply_policy::regulated(collection::supply_policy(mint)),
            err::supply_policy_mismatch(),
        );

        assert!(
            nft_data.collection_id == collection::mint_collection_id(mint),
            err::collection_mismatch(),
        );

        assert!(
            collection::is_mutable(collection),
            err::collection_is_not_mutable()
        );

        collection::decrease_supply(mint, 1);

        let Collectible {
            id,
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
                collection_id: collection::mint_collection_id(mint),
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
        assert!(nft::data_id(&nft) == id(nft_data), err::nft_data_mismatch());

        supply::decrement_supply(&mut nft_data.supply, 1);
        nft::burn_loose_nft(nft);
    }

    // === Supply Functions ===

    /// NFT `Collectible` data objects have a `supply.max`.
    /// This Function call adds a value to the supply max.
    public entry fun ceil_supply<T, M: store>(
        collection: &Collection<T, M>,
        nft_data: &mut Collectible,
        value: u64
    ) {
        assert!(
            collection::is_mutable(collection),
            err::collection_is_not_mutable()
        );

        supply::ceil_supply(
            &mut nft_data.supply,
            value
        )
    }

    /// Increases the `supply.max` of the NFT `Collectible`
    /// by the `value` amount.
    public entry fun increase_supply_ceil<T, M: store>(
        collection: &Collection<T, M>,
        nft_data: &mut Collectible,
        value: u64
    ) {
        assert!(
            collection::is_mutable(collection),
            err::collection_is_not_mutable()
        );

        supply::increase_ceil(
            &mut nft_data.supply,
            value
        )
    }

    /// Decreases the `supply.max` of the NFT `Collectible`
    /// by the `value` amount.
    /// This function call fails if one attempts to decrease the supply ceil
    /// to a value below the current supply.
    public entry fun decrease_supply_ceil<T, M: store>(
        collection: &Collection<T, M>,
        nft_data: &mut Collectible,
        value: u64
    ) {
        assert!(
            collection::is_mutable(collection),
            err::collection_is_not_mutable()
        );

        supply::decrease_ceil(
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
        collection: &Collection<T, M>,
        nft_data: &mut Collectible,
    ): &Supply {
        assert!(collection::is_mutable(collection), err::collection_is_not_mutable());

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
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<String>,
        attribute_values: vector<String>,
        max_supply: u64,
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
            max_supply,
        }
    }
}
