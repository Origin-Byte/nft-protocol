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

    use nft_protocol::err;
    use nft_protocol::collection::{Self, MintAuthority};
    use nft_protocol::slingshot::{Self, Slingshot};
    use nft_protocol::sale;
    use nft_protocol::supply_policy;
    use nft_protocol::utils::{to_string_vector};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::nft::{Self, Nft};

    /// A Composable `Data` object that can represent a combination of objects
    /// of which themselves can be a combination of other objects.
    struct Composable<C: store + copy> has key, store {
        id: UID,
        /// Composable `Data` objects can have some `Data` struct
        /// attached to it. Currently, only the objects at the leaf nodes
        /// of the composability tree have `Data` whilst the others have
        /// `option::none()`
        data: Option<Data>,
        collection_id: ID,
        /// Each composable has its own supply. This allows for configuration
        /// scarcity. If two objects, both with a supply of 10, merge to produce
        /// a composably of both, this composable object can have its own supply.
        /// This means that even if both leaf node objects have supply of 10, if
        /// the supply of the root node composable object is 5 then the NFTs
        /// can only be merge up to 5 times.
        supply: Supply,
        /// A VecMap storing a list of `C` structs which represent cloned
        /// versions of the constituent objects. These structs do not have key
        /// ability and can be copied for the sake of clonability. It is
        /// structured as VecMap such that we can have the original object `ID`s
        /// as the key for each `C` struct.
        components: VecMap<ID, C>,
    }

    /// A Clonable struct that stores information clones from a Composable
    /// object. It facilitates the intermediate step of copying information
    /// from the constituent objects to the newly minted composable object.
    struct ComposableClone<C: store> has store, copy {
        data: Option<Data>,
        collection_id: ID,
        components: VecMap<ID, C>,
    }

    struct Data has store, copy {
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

    struct MintComboDataEvent has copy, drop {
        data_ids: vector<ID>,
        collection_id: ID,
    }

    // TODO: Must use this event
    struct BurnComboDataEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    // === Functions exposed to Witness Module ===

    /// Creates a `Composable` data object, shares it, and adds it's `ID` to
    /// a dedicated launchpad `sale_outlet`. Composable NFTs have themselves
    /// a supply, and therefore the parameter `max_supply` determines how many
    /// NFTs can be minted from the launchpad.
    ///
    /// Invokes `mint_and_share_data()`.
    ///
    /// Creates a Composable data object for NFT(s) from a `Collection`
    /// with regulated supply. Note that unregulated collections should not use
    /// the launchpad since the minting process would stop taking advangage of
    /// the fast broadcast transactions.
    ///
    /// The only way to mint the NFT data for a collection is to give a
    /// reference to [`UID`]. One is only allowed to mint `Nft`s for a
    /// given collection if one is the `MintAuthority` owner.
    ///
    /// This function call bootstraps the minting of leaf node NFTs in a
    /// Composable collection with regulated supply. This function does
    /// not serve to compose Combo objects, but simply to create the
    /// intial objects that are supposed to give rise to the composability tree.
    ///
    /// For a regulated collection with supply of 100 objects, this function
    /// ought to be called 100 times in total to mint such objects. Once these
    /// objects are brought to existance the collection creator can start
    /// creating composable objects which determine which NFTs can be merged
    /// and what the supply of those configurations are.
    ///
    /// To be called by the Witness Module deployed by NFT creator.
    public fun prepare_launchpad_mint<T, M, C: store + copy>(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
        max_supply: u64,
        mint: &mut MintAuthority<T>,
        sale_outlet: u64,
        launchpad: &mut Slingshot<T, M>,
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

        let data_uid = object::new(ctx);
        let data_id = object::uid_to_inner(&data_uid);

        mint_and_share_data<C>(
            data_uid,
            args,
            collection::mint_collection_id(mint),
            max_supply,
        );

        let sale = slingshot::sale_mut(launchpad, sale_outlet);

        sale::add_nft<T, M>(
            sale,
            data_id,
            max_supply
        );
    }

    /// Creates `Composable` data, shares it, with the intent of preparing for
    /// a direct mint. Composable NFTs have themselves a supply, and therefore
    /// the parameter `max_supply` determines how many NFTs can be minted.
    ///
    /// Invokes `mint_and_share_data()`.
    ///
    /// Creates a Composable data object for NFT(s) from a `Collection`
    /// with regulated supply. Note that unregulated collections should use the
    /// thunder mint instead, in order to take advantage of fast broadcast
    /// transactions.
    ///
    /// The only way to mint the NFT data for a collection is to give a
    /// reference to [`UID`]. One is only allowed to mint `Nft`s for a
    /// given collection if one is the `MintAuthority` owner.
    ///
    /// This function call bootstraps the minting of leaf node NFTs in a
    /// Composable collection with regulated supply. This function does
    /// not serve to compose Combo objects, but simply to create the
    /// intial objects that are supposed to give rise to the composability tree.
    ///
    /// For a regulated collection with supply of 100 objects, this function
    /// ought to be called 100 times in total to mint such objects. Once these
    /// objects are brought to existance the collection creator can start
    /// creating composable objects which determine which NFTs can be merged
    /// and what the supply of those configurations are.
    ///
    /// To be called by the Witness Module deployed by NFT creator.
    public fun prepare_direct_mint<T, C: store + copy>(
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

        let data_uid = object::new(ctx);

        mint_and_share_data<C>(
            data_uid,
            args,
            collection::mint_collection_id(mint),
            max_supply,
        );
    }

    /// Creates `Composable` data, shares it, with the intent of preparing for
    /// a thunder mint. A thunder mint works like a direct mint, except that it
    /// takes full advantage of fast broadcast transactions. Composable NFTs
    /// have themselves a supply, and therefore the parameter `max_supply`
    /// determines how many NFTs can be minted.
    ///
    /// Invokes `mint_and_share_data()`.
    ///
    /// Creates a Composable data object for NFT(s) from a `Collection`
    /// with unregulated supply. Note that regulated collections should use the
    /// direct mint instead, since they won't be able to tap into fast
    /// broadcast transactions.
    ///
    /// The only way to mint the NFT data for a collection is to give a
    /// reference to [`UID`]. One is only allowed to mint `Nft`s for a
    /// given collection if one is the `MintAuthority` owner.
    ///
    /// This function call bootstraps the minting of leaf node NFTs in a
    /// Composable collection with regulated supply. This function does
    /// not serve to compose Combo objects, but simply to create the
    /// intial objects that are supposed to give rise to the composability tree.
    ///
    /// For a unregulates collections with inderterminate supply, this function
    /// ought to be called as many times as the owner of the `MintAuthority`
    /// wants, corresponding to the amount of data objects the Creator wants to
    /// have for the collection. Once these objects are brought to existance
    /// the collection creator can start creating composable objects which
    /// determine which NFTs can be merged and what the supply of those
    /// configurations are.
    ///
    /// To be called by the Witness Module deployed by NFT creator.
    public fun prepare_thunder_mint<T, C: store + copy>(
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

        let data_uid = object::new(ctx);

        mint_and_share_data<C>(
            data_uid,
            args,
            collection::mint_collection_id(mint),
            max_supply,
        );
    }

    /// Mints Composable NFT and transfers it to `recipient`. This is an entry
    /// function to be called by the client code for direct or thunder mints.
    /// For launchpad mints, the launchpad calls `nft::mint_nft_loose()`
    /// directly.
    ///
    /// Invokes `mint_nft_loose()`.
    ///
    /// This function call comes after the minting of the leaf node
    /// `Composable` data object.
    public entry fun mint<T, C: store + copy>(
        nft_data: &mut Composable<C>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        // TODO: should we allow for the minting of more than one NFT at
        // a time?
        supply::increment_supply(&mut nft_data.supply, 1);

        let nft = nft::mint_nft_loose<T, Data>(
            nft_data_id(nft_data),
            tx_context::sender(ctx),
            ctx,
        );

        transfer::transfer(
            nft,
            recipient,
        );
    }

    /// Function that receives and temporarily holds two or more objects,
    /// clones their information and produces a composable object, thus allowing
    /// holders of those NFTs to merge them together to create a cNFT.
    ///
    /// The newly composed object has a its own maximum supply of NFTs.
    public entry fun define_combo_nft
        <T, C: store + copy>
    (
        nfts_data: vector<Composable<C>>,
        mint: &mut MintAuthority<T>,
        max_supply: u64,
        ctx: &mut TxContext,
    ) {
        let data_vec: VecMap<ID, ComposableClone<C>> = vec_map::empty();
        let data_ids: vector<ID> = vector::empty();
        let collection_id = collection::mint_collection_id(mint);

        let len = vector::length(&nfts_data);

        while (len > 0) {
            let nft_data = vector::pop_back(&mut nfts_data);

            assert!(
                nft_data.collection_id == collection_id,
                err::collection_mismatch()
            );

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

    // === Entrypoints ===

    /// Mints a cNFT by "merging" two or more NFTs. The function will
    /// burn the NFTs given by the parameter `nfts` and will mint a cNFT
    /// object pointing to the composable object that representes the merge
    /// of said NFTs.
    ///
    /// When burning the constituent NFTs we do not decrease their supply.
    /// The reason for this is because if we were to decrease their supply,
    /// further NFTs could be minted and reach the maximum supply. When the
    /// cNFT would be split back into its constituent components it could result
    /// in a supply bigger than the maximum supply.
    public entry fun mint_combo_nft<T, C: store + copy>(
        nfts: vector<Nft<T, Composable<C>>>,
        nfts_data: vector<Composable<C>>, // TODO: Ideally we would pass &Data
        combo_data: &mut Composable<C>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let len = vector::length(&nfts);
        assert!(
            len == vec_map::size(&combo_data.components),
            err::not_enough_nfts_to_mint_cnft()
        );

        while (len > 0) {
            let nft = vector::pop_back(&mut nfts);
            let data = vector::pop_back(&mut nfts_data);

            assert!(nft::data_id(&nft) == id(&data), err::nft_data_mismatch());
            assert!(
                vec_map::contains(&combo_data.components, &nft::data_id(&nft)),
                err::wrong_nft_data_provided(),
            );

            // `burn_loose_nft` will fail if the NFT is embedded
            nft::burn_loose_nft(nft);

            // TODO: Aesthetically, we would ideally use a reference
            // to the object and would therefore have no need to share it back
            transfer::share_object(data);

            len = len - 1;
        };
        vector::destroy_empty(nfts);
        vector::destroy_empty(nfts_data);

        supply::increment_supply(&mut combo_data.supply, 1);

        let nft = nft::mint_nft_loose<T, Data>(
            object::uid_to_inner(&combo_data.id),
            recipient,
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
    public entry fun burn_nft<T, MetaColl: store, C: store + copy>(
        nft: Nft<T, Composable<C>>,
        nft_data: &mut Composable<C>,
    ) {
        assert!(nft::data_id(&nft) == id(nft_data), err::nft_data_mismatch());

        supply::decrement_supply(&mut nft_data.supply, 1);
        nft::burn_loose_nft(nft);
    }

    /// This function reverts the merge of the NFTs that occurs in `mint_c_nft`.
    /// The Supply of the composable Composable object decrases, however we
    /// do not increment the supply of its constituent objects. The reason for
    /// this is because we do not decrement the supply of these constituent
    /// objects when we merge them, therefore we maintain consistency.
    public entry fun split_combo_nft<T, MetaColl: store, C: store + copy>(
        nft: Nft<T, Composable<C>>,
        combo_data: &mut Composable<C>,
        nfts_data: vector<Composable<C>>,
        ctx: &mut TxContext,
    ) {
        // Assert that nft pointer corresponds to c_nft_data
        // If so, then burn pointer and mint pointer for each nfts_data
        assert!(nft::data_id(&nft) == id(combo_data), err::nft_data_mismatch());

        supply::decrement_supply(&mut combo_data.supply, 1);
        nft::burn_loose_nft(nft);

        let len = vector::length(&nfts_data);

        while (len > 0) {
            let data = vector::pop_back(&mut nfts_data);

            let nft = nft::mint_nft_loose<T, Composable<C>>(
                id(&data),
                tx_context::sender(ctx),
                ctx,
            );

            transfer::transfer(
                nft,
                tx_context::sender(ctx),
            );

            transfer::share_object(data);

            len = len - 1;
        };

        vector::destroy_empty(nfts_data);
    }

    // === Getter Functions  ===

    /// Get the Nft Data's `id`
    public fun id<C: store + copy>(
        comp: &Composable<C>,
    ): ID {
        object::uid_to_inner(&comp.id)
    }

    /// Get the Nft Data's `id` as reference
    public fun id_ref<C: store + copy>(
        comp: &Composable<C>,
    ): &ID {
        object::uid_as_inner(&comp.id)
    }

    /// Get the Nft Data's `name`
    public fun name<C: store + copy>(
        comp: &Composable<C>,
    ): String {
        let data = option::borrow(&comp.data);
        data.name
    }

    /// Get the Nft Data's `description`
    public fun description<C: store + copy>(
        comp: &Composable<C>,
    ): String {
        let data = option::borrow(&comp.data);
        data.description
    }

    /// Get the Nft Data's `collection_id`
    public fun collection_id<C: store + copy>(
        comp: &Composable<C>,
    ): &ID {
        &comp.collection_id
    }

    /// Get the Nft Data's `url`
    public fun url<C: store + copy>(
        comp: &Composable<C>,
    ): Url {
        let data = option::borrow(&comp.data);
        data.url
    }

    /// Get the Nft Data's `attributes`
    public fun attributes<C: store + copy>(
        comp: &Composable<C>,
    ): &Attributes {
        let data = option::borrow(&comp.data);
        &data.attributes
    }

    /// Get the Nft Composable's `attributes.keys`
    public fun attribute_keys<C: store + copy>(
        comp: &Composable<C>,
    ): &vector<String> {
        let data = option::borrow(&comp.data);
        &data.attributes.keys
    }

    /// Get the Nft Composable's `attributes.values`
    public fun attribute_values<C: store + copy>(
        comp: &Composable<C>,
    ): &vector<String> {
        let data = option::borrow(&comp.data);
        &data.attributes.keys
    }

    /// Get the Nft Data's `supply`
    public fun supply<C: store + copy>(
        nft_data: &Composable<C>,
    ): &Supply {
        &nft_data.supply
    }

    // === Private Functions ===

    fun nft_data_id<C: store + copy>(nft_data: &Composable<C>): ID {
        object::uid_to_inner(&nft_data.id)
    }

    fun mint_and_share_data<C: store + copy>(
        data_id: UID,
        args: MintArgs,
        collection_id: ID,
        max_supply: u64,
    ) {
        event::emit(
            MintDataEvent {
                object_id: object::uid_to_inner(&data_id),
                collection_id: collection_id,
            }
        );

        let data = Data {
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
