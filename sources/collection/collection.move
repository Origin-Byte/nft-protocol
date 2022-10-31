//! Module of a generic `Collection` type and a `MintAuthority` type.
//!
//! It acts as a generic interface for NFT Collections and it allows for
//! the creation of arbitrary domain specific implementations.
//!
//! The `MintAuthority` object gives power to the owner to mint objects.
//! There is only one `MintAuthority` per `Collection`.
//! The Mint Authority object contains a `SupplyPolicy` which
//! can be regulated or unregulated.
//! A Collection with unregulated Supply policy is a collection that
//! does not keep track of its current supply objects. This allows for the
//! minting process to be parallelized.
//!
//! A Collection with regulated Supply policy is a collection that
//! keeps track of its current supply objects. This means that whilst the
//! minting can be parallelized on the client side, on the blockchain side
//! nodes will have to lock the `MintAuthority` object in order to mutate
//! it sequentially. Regulated Supply allows for collections to have limited
//! or unlimited supply. The `MintAuthority` owner can modify the
//! `max_supply` a posteriori, as long as the `Supply` is not frozen.
//! After this function call the `Supply` object will not yet be set to
//! frozen, in order to give creators the ability to ammend it prior to
//! the primary sale taking place.
//!
//! TODO: Consider adding a function `destroy_unregulated`?
//! TODO: Consider adding a struct object Collection Proof
//! TODO: Verify creator in function to add creator, and function to post verify
//! TODO: Split field `is_mutable` to `is_mutable` and `frozen` such that
//! `is_mutable` refers to the NFTs and `frozen` refers to the collection
module nft_protocol::collection {
    use std::vector;
    use std::string::{Self, String};

    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};
    use sui::transfer;

    use nft_protocol::err;
    use nft_protocol::tags::{Self, Tags};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::supply_policy::{Self, SupplyPolicy};

    const U64_MAX: u64 = 18446744073709551615;

    /// An NFT `Collection` object with a generic `M`etadata.
    ///
    /// The `Metadata` is a type exported by an upstream contract which is
    /// used to store additional information about the NFT.
    struct Collection<phantom T, M: store> has key, store {
        id: UID,
        name: String,
        description: String,
        // TODO: Should symbol be limited to x number of chars?
        symbol: String,
        /// Address that receives the mint price in Sui
        receiver: address,
        /// Nft Collection Tags is an enumeration of tags, represented
        /// as strings. An NFT Tag is a string that categorises the domain
        /// in which the NFT operates (i.e. Art, Profile Picture, Gaming, etc.)
        /// This allows wallets and marketplaces to organise NFTs by its
        /// domain specificity.
        tags: Tags,
        /// Determines if the collection and its associated NFTs are
        /// mutable. Once turned `false` it cannot be reversed. Collection
        /// owners however will still be able to push and pop tags to the
        /// `tags` field.
        is_mutable: bool,
        /// Field determining the amount of royaly fees in basis points,
        /// charged in market transactions.
        /// TODO: It is likely that this field will change as we design
        /// the royalty enforcement standard
        royalty_fee_bps: u64,
        creators: vector<Creator>,
        /// ID of `MintAuthority` object
        mint_authority: ID,
        /// The `Metadata` is a type exported by an upstream contract which is
        /// used to store additional information about the NFT.
        metadata: M,
    }

    /// The `MintAuthority` object gives power to the owner to mint objects.
    /// There is only one `MintAuthority` per `Collection`.
    struct MintAuthority<phantom T> has key, store {
        id: UID,
        collection_id: ID,
        // Defines supply policy which can be regulated or unregulated.
        // A Collection with unregulated Supply policy is a collection that
        // does not keep track of its current supply objects. This allows for the
        // minting process to be parallelized.
        supply_policy: SupplyPolicy,
    }

    /// Creator struct which holds the addresses of the creators of the NFT
    /// Collection, as well their share of the royalties collected.
    struct Creator has store, copy, drop {
        creator_address: address,
        /// The creator needs to sign a transaction in order to be verified.
        /// Otherwise anyone could just spoof the creator's identity
        verified: bool,
        share_of_royalty: u8,
    }

    struct InitCollection has drop {
        name: String,
        description: String,
        symbol: String,
        receiver: address,
        tags: vector<String>,
        is_mutable: bool,
        royalty_fee_bps: u64,
    }

    struct MintEvent has copy, drop {
        collection_id: ID,
    }

    struct BurnEvent has copy, drop {
        collection_id: ID,
    }


    /// Initialises a `MintAuthority` and transfers it to `authority` and
    /// initialized `Collection` object and returns it. The `MintAuthority`
    /// object gives power to the owner to mint objects. There is only one
    /// `MintAuthority` per `Collection`. The Mint Authority object contains a
    /// `SupplyPolicy` which can be regulated or unregulated.
    ///
    /// A Collection with unregulated Supply policy is a collection that
    /// does not keep track of its current supply objects. This allows for the
    /// minting process to be parallelized.
    ///
    /// To initialise a collection with a unregulated `SupplyPolicy`,
    /// the parameter `max_supply` should be given as `0`.
    ///
    /// A Collection with regulated Supply policy is a collection that
    /// keeps track of its current supply objects. This means that whilst the
    /// minting can be parallelized on the client side, on the blockchain side
    /// nodes will have to lock the `MintAuthority` object in order to mutate
    /// it sequentially. Regulated Supply allows for collections to have limited
    /// or unlimited supply. The `MintAuthority` owner can modify the
    /// `max_supply` a posteriori, as long as the `Supply` is not frozen.
    /// After this function call the `Supply` object will not yet be set to
    /// frozen, in order to give creators the ability to ammend it prior to
    /// the primary sale taking place.
    ///
    /// To initialise a collection with regualred `SupplyPolicy`, the parameter
    /// `max_supply` should be above `0`. To create an unlimited supply the
    /// parameter `max_supply` should be equal to the biggest integer number
    /// that can be stored in a u64, which is `18446744073709551615`.
    public fun mint<T, M: store>(
        args: InitCollection,
        max_supply: u64,
        metadata: M,
        authority: address,
        ctx: &mut TxContext,
    ): Collection<T, M> {
        let id = object::new(ctx);

        event::emit(
            MintEvent {
                collection_id: object::uid_to_inner(&id),
            }
        );

        let mint_object_uid = object::new(ctx);
        let mint_object_id = object::uid_to_inner(&mint_object_uid);

        create_mint_authority<T>(
            mint_object_uid,
            object::uid_to_inner(&id),
            max_supply,
            authority,
        );


        Collection {
            id,
            name: args.name,
            description: args.description,
            symbol: args.symbol,
            receiver: args.receiver,
            tags: tags::from_vec_string(&mut args.tags),
            is_mutable: args.is_mutable,
            royalty_fee_bps: args.royalty_fee_bps,
            creators: vector::empty(),
            mint_authority: mint_object_id,
            metadata: metadata,
        }
    }

    // TODO: Requires fixing
    // /// Burn a Collection with regulated supply object and
    // /// returns the Metadata object
    // public entry fun burn_regulated<T, M: store>(
    //     collection: Collection<T, M>,
    //     mint: MintAuthority<T>,
    // ): M {
    //     assert!(
    //         supply::current(supply_policy::supply(&mint.supply_policy)) == 0,
    //         err::supply_is_not_zero()
    //     );

    //     let MintAuthority {
    //         id,
    //         collection_id: _,
    //         supply_policy,
    //     } = mint;

    //     object::delete(id);

    //     event::emit(
    //         BurnEvent {
    //             collection_id: id(&collection),
    //         }
    //     );

    //     let Collection {
    //         id,
    //         name: _,
    //         description: _,
    //         symbol: _,
    //         receiver: _,
    //         tags: _,
    //         is_mutable: _,
    //         royalty_fee_bps: _,
    //         creators: _,
    //         mint_authority: _,
    //         metadata,
    //     } = collection;

    //     supply_policy::destroy_regulated(supply_policy);

    //     object::delete(id);

    //     metadata
    // }

    /// Make Collections immutable
    /// WARNING: this is irreversible, use with care
    public entry fun freeze_collection<T, M: store>(
        collection: &mut Collection<T, M>,
    ) {
        // Only modify if collection is mutable
        assert!(
            collection.is_mutable == true,
            err::collection_is_not_mutable()
        );

        collection.is_mutable = false;
    }

    public fun init_args(
        name: String,
        description: String,
        symbol: String,
        receiver: address,
        tags: vector<String>,
        is_mutable: bool,
        royalty_fee_bps: u64,
    ): InitCollection {
        InitCollection {
            name,
            description,
            symbol,
            receiver,
            tags,
            is_mutable,
            royalty_fee_bps,
        }
    }

    // === Modifier Entry Functions ===

    /// Modify the Collections's `name`
    public entry fun rename<T, M: store>(
        collection: &mut Collection<T, M>,
        name: vector<u8>,
    ) {
        // Only modify if collection is mutable
        assert!(
            collection.is_mutable == true,
            err::collection_is_not_mutable()
        );

        collection.name = string::utf8(name);
    }

    /// Modify the Collections's `description`
    public entry fun change_description<T, M: store>(
        collection: &mut Collection<T, M>,
        description: vector<u8>,
    ) {
        // Only modify if collection is mutable
        assert!(
            collection.is_mutable == true,
            err::collection_is_not_mutable()
        );

        collection.description = string::utf8(description);
    }

    /// Modify the Collections's `symbol`
    public entry fun change_symbol<T, M: store>(
        collection: &mut Collection<T, M>,
        symbol: vector<u8>,
    ) {
        // Only modify if collection is mutable
        assert!(
            collection.is_mutable == true,
            err::collection_is_not_mutable()
        );

        collection.symbol = string::utf8(symbol);
    }

    /// Modify the Collections's `receiver`
    public entry fun change_receiver<T, M: store>(
        collection: &mut Collection<T, M>,
        receiver: address,
    ) {
        // Only modify if collection is mutable
        assert!(
            collection.is_mutable == true,
            err::collection_is_not_mutable()
        );

        collection.receiver = receiver;
    }

    /// Add a tag to the Collections's `tags`
    /// Contrary to other fields, tags can be always added by
    /// the collection owner, even if the collection is marked
    /// as immutable.
    public entry fun push_tag<T, M: store>(
        collection: &mut Collection<T, M>,
        tag: vector<u8>,
    ) {
        tags::push_tag(
            &mut collection.tags,
            string::utf8(tag),
        );
    }

    /// Removes a tag to the Collections's `tags`
    /// Contrary to other fields, tags can be always removed by
    /// the collection owner, even if the collection is marked
    /// as immutable.
    public entry fun pop_tag<T, M: store>(
        collection: &mut Collection<T, M>,
        tag_index: u64,
    ) {
        tags::pop_tag(
            &mut collection.tags,
            tag_index,
        );
    }

    /// Change field `royalty_fee_bps` in `Collection`
    public entry fun change_royalty<T, M: store>(
        collection: &mut Collection<T, M>,
        royalty_fee_bps: u64,
    ) {
        collection.royalty_fee_bps = royalty_fee_bps;
    }

    /// Add a `Creator` to `Collection`
    public entry fun add_creator<T, M: store>(
        collection: &mut Collection<T, M>,
        creator_address: address,
        share_of_royalty: u8,
    ) {
        // Only modify if collection is mutable
        assert!(
            collection.is_mutable == true,
            err::collection_is_not_mutable()
        );

        // TODO: Need to make sure sum of all Creator's `share_of_royalty` is
        // not above 100%
        let creator = Creator {
            creator_address: creator_address,
            verified: true,
            share_of_royalty: share_of_royalty,
        };

        if (
            !contains_address(&collection.creators, creator_address)
        ) {
            vector::push_back(&mut collection.creators, creator);
        }
    }

    /// Remove a `Creator` from `Collection`
    public entry fun remove_creator<T, M: store>(
        collection: &mut Collection<T, M>,
        creator_address: address,
    ) {
        // Only modify if collection is mutable
        assert!(
            collection.is_mutable == true,
            err::collection_is_not_mutable()
        );

        if (!vector::is_empty(&collection.creators)) {
            remove_address(
                &mut collection.creators,
                creator_address,
            )
        }
    }

    /// This function call ceils the supply of the Collection as long
    /// as the Policy is regulated.
    public entry fun ceil_supply<T>(
        mint: &mut MintAuthority<T>,
        value: u64
    ) {
        supply_policy::ceil_supply(
            &mut mint.supply_policy,
            value
        )
    }

    /// Increases the `supply.max` by the `value` amount for
    /// regulated collections. Invokes `supply_policy::increase_max_supply()`
    public entry fun increase_max_supply<T>(
        mint: &mut MintAuthority<T>,
        value: u64,
    ) {
        supply_policy::increase_max_supply(
            &mut mint.supply_policy,
            value,
        );
    }

    /// Decreases the `supply.max` by the `value` amount for
    /// `Limited` collections. This function call fails if one attempts
    /// to decrease the supply cap to a value below the current supply.
    /// Invokes `supply_policy::decrease_max_supply()`
    public entry fun decrease_max_supply<T>(
        mint: &mut MintAuthority<T>,
        value: u64
    ) {
        supply_policy::decrease_max_supply(
            &mut mint.supply_policy,
            value
        )
    }

    // === Supply Functions ===

    /// Increments current supply for regulated collections.
    public fun increment_supply<T>(
        mint: &mut MintAuthority<T>,
        value: u64
    ) {
        supply_policy::increment_supply(
            &mut mint.supply_policy,
            value
        )
    }

    /// Decrements current supply for regulated collections.
    public fun decrease_supply<T>(
        mint: &mut MintAuthority<T>,
        value: u64
    ) {
        supply_policy::decrement_supply(
            &mut mint.supply_policy,
            value
        )
    }

    /// Returns reference to supply object for regulated collections.
    public fun supply<T>(mint: &mut MintAuthority<T>): &Supply {
        supply_policy::supply(&mint.supply_policy)
    }

    /// Returns max supply for regulated collections.
    public fun supply_max<T>(mint: &MintAuthority<T>): u64 {
        supply::max(
            supply_policy::supply(&mint.supply_policy)
        )
    }

    public fun current_supply<T>(mint: &mut MintAuthority<T>): u64 {
        supply::current(
            supply_policy::supply(&mint.supply_policy)
        )
    }

    // === Getter Functions ===

    /// Get the Collections's `id`
    public fun id<T, M: store>(
        collection: &Collection<T, M>,
    ): ID {
        object::uid_to_inner(&collection.id)
    }

    /// Get the Collections's `id` as reference
    public fun id_ref<T, M: store>(
        collection: &Collection<T, M>,
    ): &ID {
        object::uid_as_inner(&collection.id)
    }

    /// Get the Collections's `name`
    public fun name<T, M: store>(
        collection: &Collection<T, M>,
    ): &String {
        &collection.name
    }

    /// Get the Collections's `description`
    public fun description<T, M: store>(
        collection: &Collection<T, M>,
    ): &String {
        &collection.description
    }

    /// Get the Collections's `symbol`
    public fun symbol<T, M: store>(
        collection: &Collection<T, M>,
    ): &String {
        &collection.symbol
    }

    /// Get the Collections's `receiver`
    public fun receiver<T, M: store>(
        collection: &Collection<T, M>,
    ): address {
        collection.receiver
    }

    /// Get the Collections's `tags`
    public fun tags<T, M: store>(
        collection: &Collection<T, M>,
    ): &Tags {
        &collection.tags
    }

    /// Get the Collection's `is_mutable`
    public fun is_mutable<T, M: store>(
        collection: &Collection<T, M>,
    ): bool {
        collection.is_mutable
    }

    /// Get the Collection's `royalty_fee_bps`
    public fun royalty<T, M: store>(
        collection: &Collection<T, M>,
    ): u64 {
        collection.royalty_fee_bps
    }

    /// Get the Collection's `creators`
    public fun creators<T, M: store>(
        collection: &Collection<T, M>,
    ): &vector<Creator> {
        &collection.creators
    }

    /// Get an immutable reference to Collections's `cap`
    public fun supply_policy<T>(
        mint: &MintAuthority<T>,
    ): &SupplyPolicy {
        &mint.supply_policy
    }

    /// Get a mutable reference to Collections's `cap`
    public fun cap_mut<T>(
        mint: &mut MintAuthority<T>,
    ): &mut SupplyPolicy {
        &mut mint.supply_policy
    }

    /// Get an immutable reference to Collections's `Metadata`
    public fun metadata<T, M: store>(
        collection: &Collection<T, M>,
    ): &M {
        &collection.metadata
    }

    /// Get a mutable reference to Collections's `metadata`
    public fun metadata_mut<T, M: store>(
        collection: &mut Collection<T, M>,
    ): &mut M {
        // Only return mutable reference if collection is mutable
        assert!(
            collection.is_mutable == true,
            err::collection_is_not_mutable()
        );

        &mut collection.metadata
    }

    public fun mint_collection_id<T>(
        mint: &MintAuthority<T>,
    ): ID {
        mint.collection_id
    }

    // === Utility Function ===

    public fun is_creator(
        who: address,
        creators: &vector<Creator>,
    ): bool {
        let i = 0;
        while (i < vector::length(creators)) {
            let creator = vector::borrow(creators, i);
            if (creator.creator_address == who) {
                return true
            };
            i = i + 1;
        };

        false
    }

    // === Private Functions ===

    fun create_mint_authority<T>(
        object_id: UID,
        collection_id: ID,
        max_supply: u64,
        recipient: address,
    ) {
        if (max_supply == 0) {
            let authority: MintAuthority<T> = MintAuthority {
                id: object_id,
                collection_id: collection_id,
                supply_policy: supply_policy::create_unregulated(),
            };

            transfer::transfer(authority, recipient);
        } else {
            let authority: MintAuthority<T> = MintAuthority {
                id: object_id,
                collection_id: collection_id,
                supply_policy: supply_policy::create_regulated(
                    max_supply, false
                ),
            };

            transfer::transfer(authority, recipient);
        }
    }

    fun contains_address(
        v: &vector<Creator>, c_address: address
    ): bool {
        let i = 0;
        let len = vector::length(v);
        while (i < len) {
            let creator = vector::borrow(v, i);
            if (creator.creator_address == c_address) return true;
            i = i +1;
        };
        false
    }

    fun remove_address(
        v: &mut vector<Creator>, c_address: address
    ) {
        let i = 0;
        let len = vector::length(v);
        while (i < len) {
            let creator = vector::borrow(v, i);

            if (creator.creator_address == c_address) {
                vector::remove(v, i);
            }
        }
    }
}
