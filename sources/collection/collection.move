//! Module of a generic `Collection` type.
//! 
//! It acts as a generic interface for NFT Collections and it allows for
//! the creation of arbitrary domain specific implementations.
//! 
//! NFT Collections can be of `Limited` or `Unlimited` supply `Cap`. The
//! Collection `Cap` is an object that determines what the constrains are in
//! relation to minting an NFT `Data` object associated to the Collection.
//! 
//! TODO: Consider adding a function `destroy_uncapped`?
//! TODO: Consider adding a struct object Collection Proof
//! TODO: Verify creator in function to add creator, and function to post verify
module nft_protocol::collection {
    use std::vector;
    use std::string::{Self, String};
    use std::option::{Option};

    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};

    use nft_protocol::tags::{Self, Tags};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::cap::{Self, Limited, Unlimited};

    /// An NFT `Collection` object with a generic `M`etadata and `C`ap.
    /// NFT Collections can be instantiated with a `Cap` of type `Limited` or
    /// `Unlimited`. An `Unlimited` collection not only does not have a supply
    /// limit but also does not keep track of the amount of NFT `Data` objects
    /// in existance at any given time.
    /// 
    /// The `Metadata` is a type exported by an upstream contract which is 
    /// used to store additional information about the NFT.
    struct Collection<M: store, C: store> has key, store {
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
        /// NFT Collections can be instantiated with a `Cap` of type `Limited`
        ///  or `Unlimited`. An `Unlimited` collection not only does not have 
        /// a supply limit but also does not keep track of the amount of 
        /// NFT `Data` objects in existance at any given time.
        cap: C,
        /// The `Metadata` is a type exported by an upstream contract which is 
        /// used to store additional information about the NFT.
        metadata: M,
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

    /// Initialises a Capped `Collection` object and returns it. A Capped
    /// Collection is one which has a `Limited` object as its `Cap`.
    /// `Limited` Collections have a fixed supply that can not be changed once
    /// the `Cap` object is set to frozen. In this function call the `Limited`
    /// object is not yet set to frozen, in order to give creators the ability
    /// to ammend it prior to the primary sale taking place.
    /// 
    /// Despite its name, `Limited` supplies can still have no maximum supply
    /// constraint, if the field `supply.cap` is set to `option::none`. This
    /// allows us to have a Collection that has no supply contraints whilst 
    /// still being able to track how many NFT `Data` objects are currently
    /// in existance. We can achieve this by setting the parameter
    /// `max_supply` to `option::none`.
    public fun mint_capped<M: store>(
        args: InitCollection,
        max_supply: Option<u64>,
        metadata: M,
        ctx: &mut TxContext,
    ): Collection<M, Limited> {
        let id = object::new(ctx);

        event::emit(
            MintEvent {
                collection_id: object::uid_to_inner(&id),
            }
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
            cap: cap::create_limited(max_supply, false),
            metadata: metadata,
        }
    }

    /// Initialises a Uncapped `Collection` object and returns it. An Uncapped
    /// Collection is one which has a `Unlimited` object as its `Cap`.
    /// `Unlimited` Collections do not have any supply contracints.
    ///
    /// Unlimited collections do not have a counter which incrementes when an
    /// NFT `Data` object is minted, and thus they do not store the current
    /// supply information. This means that the minting of NFT `Data` objects
    /// can be done in parallel without mutating the `Collection` object.
    public fun mint_uncapped<M: store>(
        args: InitCollection,
        metadata: M,
        ctx: &mut TxContext,
    ): Collection<M, Unlimited> {
        let id = object::new(ctx);

        event::emit(
            MintEvent {
                collection_id: object::uid_to_inner(&id),
            }
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
            cap: cap::create_unlimited(),
            metadata: metadata,
        }
    }

    /// Burn a `Capped` Collection object and return the Metadata object
    public fun burn_capped<M: store>(
        collection: Collection<M, Limited>,
    ): M {
        assert!(supply::current(
            cap::supply(&collection.cap)
        ) == 0, 0);

        event::emit(
            BurnEvent {
                collection_id: id(&collection),
            }
        );

        let Collection {
            id,
            name: _,
            description: _,
            symbol: _,
            receiver: _,
            tags: _,
            is_mutable: _,
            royalty_fee_bps: _,
            creators: _,
            cap,
            metadata,
        } = collection;

        cap::destroy_capped(cap);

        object::delete(id);

        metadata
    }

    /// Make Collections immutable
    /// WARNING: this is irreversible, use with care
    public fun freeze_collection<M: store, C: store>(
        collection: &mut Collection<M, C>,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

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
    public entry fun rename<M: store, C: store>(
        collection: &mut Collection<M, C>,
        name: vector<u8>,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.name = string::utf8(name);
    }

    /// Modify the Collections's `description`
    public entry fun change_description<M: store, C: store>(
        collection: &mut Collection<M, C>,
        description: vector<u8>,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.description = string::utf8(description);
    }

    /// Modify the Collections's `symbol`
    public entry fun change_symbol<M: store, C: store>(
        collection: &mut Collection<M, C>,
        symbol: vector<u8>,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.symbol = string::utf8(symbol);
    }

    /// Modify the Collections's `receiver`
    public entry fun change_receiver<M: store, C: store>(
        collection: &mut Collection<M, C>,
        receiver: address,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.receiver = receiver;
    }

    /// Add a tag to the Collections's `tags`
    /// Contrary to other fields, tags can be always added by
    /// the collection owner, even if the collection is marked
    /// as immutable.
    public entry fun push_tag<M: store, C: store>(
        collection: &mut Collection<M, C>,
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
    public entry fun pop_tag<M: store, C: store>(
        collection: &mut Collection<M, C>,
        tag_index: u64,
    ) {
        tags::pop_tag(
            &mut collection.tags,
            tag_index,
        );
    }

    /// Change field `royalty_fee_bps` in `Collection`
    public entry fun change_royalty<M: store, C: store>(
        collection: &mut Collection<M, C>,
        royalty_fee_bps: u64,
    ) {
        collection.royalty_fee_bps = royalty_fee_bps;
    }

    /// Add a `Creator` to `Collection`
    public entry fun add_creator<M: store, C: store>(
        collection: &mut Collection<M, C>,
        creator_address: address,
        share_of_royalty: u8,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

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
    public entry fun remove_creator<M: store, C: store>(
        collection: &mut Collection<M, C>,
        creator_address: address,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        if (!vector::is_empty(&collection.creators)) {
            remove_address(
                &mut collection.creators,
                creator_address,
            )
        }
    }

    /// `Limited` collections can have a cap on the maximum supply, however 
    /// the supply cap can also be `option::none()`. This function call
    /// adds a value to the supply cap.
    public entry fun cap_supply<M: store>(
        collection: &mut Collection<M, Limited>,
        value: u64
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        supply::cap_supply(
            cap::supply_mut(&mut collection.cap),
            value
        )
    }

    /// Increases the `supply.cap` by the `value` amount for 
    /// `Limited` collections. Invokes `supply::increase_cap()`
    public entry fun increase_supply_cap<M: store>(
        collection: &mut Collection<M, Limited>,
        value: u64
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        supply::increase_cap(
            cap::supply_mut(&mut collection.cap),
            value
        )
    }

    /// Decreases the `supply.cap` by the `value` amount for 
    /// `Limited` collections. This function call fails if one attempts
    /// to decrease the supply cap to a value below the current supply.
    /// Invokes `supply::decrease_cap()`
    public entry fun decrease_supply_cap<M: store>(
        collection: &mut Collection<M, Limited>,
        value: u64
    ) {
        supply::decrease_cap(
            cap::supply_mut(&mut collection.cap),
            value
        )
    }

    // === Supply Functions ===

    /// Increase `supply.current` for `Limited`
    public fun increase_supply<M: store>(
        collection: &mut Collection<M, Limited>,
        value: u64
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        supply::increase_supply(
            cap::supply_mut(&mut collection.cap),
            value
        )
    }

    public fun decrease_supply<M: store>(
        collection: &mut Collection<M, Limited>,
        value: u64
    ) {
        supply::decrease_supply(
            cap::supply_mut(&mut collection.cap),
            value
        )
    }

    public fun supply<M: store>(collection: &Collection<M, Limited>): &Supply {
        cap::supply(&collection.cap)
    }

    public fun supply_cap<M: store>(collection: &Collection<M, Limited>): Option<u64> {
        supply::cap(
            cap::supply(&collection.cap)
        )
    }

    public fun current_supply<M: store>(collection: &Collection<M, Limited>): u64 {
        supply::current(
            cap::supply(&collection.cap)
        )
    }

    // === Getter Functions ===

    /// Get the Collections's `id`
    public fun id<M: store, C: store>(
        collection: &Collection<M, C>
    ): ID {
        object::uid_to_inner(&collection.id)
    }

    /// Get the Collections's `id` as reference
    public fun id_ref<M: store, C: store>(
        collection: &Collection<M, C>
    ): &ID {
        object::uid_as_inner(&collection.id)
    }

    /// Get the Collections's `name`
    public fun name<M: store, C: store>(
        collection: &Collection<M, C>
    ): &String {
        &collection.name
    }

    /// Get the Collections's `description`
    public fun description<M: store, C: store>(
        collection: &Collection<M, C>
    ): &String {
        &collection.description
    }

    /// Get the Collections's `symbol`
    public fun symbol<M: store, C: store>(
        collection: &Collection<M, C>
    ): &String {
        &collection.symbol
    }

    /// Get the Collections's `receiver`
    public fun receiver<M: store, C: store>(
        collection: &Collection<M, C>
    ): address {
        collection.receiver
    }

    /// Get the Collections's `tags`
    public fun tags<M: store, C: store>(
        collection: &Collection<M, C>,
    ): Tags {
        collection.tags
    }

    /// Get the Collection's `is_mutable`
    public fun is_mutable<M: store, C: store>(
        collection: &Collection<M, C>,
    ): bool {
        collection.is_mutable
    }

    /// Get the Collection's `royalty_fee_bps`
    public fun royalty<M: store, C: store>(
        collection: &Collection<M, C>,
    ): u64 {
        collection.royalty_fee_bps
    }

    /// Get the Collection's `creators`
    public fun creators<M: store, C: store>(
        collection: &Collection<M, C>,
    ): vector<Creator> {
        collection.creators
    }

    /// Get an immutable reference to Collections's `cap`
    public fun cap<M: store, C: store>(
        collection: &Collection<M, C>,
    ): &C {
        &collection.cap
    }

    /// Get a mutable reference to Collections's `cap`
    public fun cap_mut<M: store, C: store>(
        collection: &mut Collection<M, C>,
    ): &mut C {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        &mut collection.cap
    }

    /// Get an immutable reference to Collections's `Metadata`
    public fun metadata<M: store, C: store>(
        collection: &Collection<M, C>,
    ): &M {
        &collection.metadata
    }

    /// Get a mutable reference to Collections's `metadata`
    public fun metadata_mut<M: store, C: store>(
        collection: &mut Collection<M, C>,
    ): &mut M {
        // Only return mutable reference if collection is mutable
        assert!(collection.is_mutable == true, 0);

        &mut collection.metadata
    }

    // === Private Functions ===

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
