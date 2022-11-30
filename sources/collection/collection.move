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
    use sui::bag::{Self, Bag};

    use nft_protocol::err;
    use nft_protocol::utils;
    use nft_protocol::tags::{Self, Tags};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::supply_policy::{Self, SupplyPolicy};
    use nft_protocol::domain::{domain_key, DomainKey};

    /// An NFT `Collection` object with a generic `M`etadata.
    ///
    /// The `Metadata` is a type exported by an upstream contract which is
    /// used to store additional information about the NFT.
    struct Collection<phantom T> has key, store {
        id: UID,
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
        creators: vector<Creator>,
        /// ID of `MintAuthority` object
        mint_authority: ID,
        // TODO(https://github.com/Origin-Byte/nft-protocol/issues/103): Implement RoyaltyDomain
        royalty_fee_bps: u64,
        /// Domain storage equivalent to NFT domains which allows collections
        /// to implement custom metadata.
        //
        // TODO(https://github.com/Origin-Byte/nft-protocol/issues/102): Implement DisplayDomain for NFT and Collection
        domains: Bag,
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

    struct MintEvent has copy, drop {
        collection_id: ID,
    }

    struct BurnEvent has copy, drop {
        collection_id: ID,
    }

    /// Shares `Collection`.
    ///
    /// To be called by the Witness Module deployed by NFT creator.
    public fun share<C>(
        collection: Collection<C>,
    ): ID {
        let collection_id = id(&collection);

        event::emit(
            MintEvent { collection_id }
        );

        transfer::share_object(collection);

        collection_id
    }

    /// Initialises a `MintAuthority` and transfers it to `authority` and
    /// initializes a `Collection` object and returns it. The `MintAuthority`
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
    public fun create<T>(
        // Symbol of the Nft Collection. This parameter is a
        // vector of bytes that should enconde to utf8
        symbol: vector<u8>,
        // Defines the maximum supply of the collection. To create an
        // unregulated supply set `max_supply=0`, otherwise any value above
        // zero will make the supply regulated.
        max_supply: u64,
        receiver: address,
        // TODO: When will we be able to pass vector<String>?
        // https://github.com/MystenLabs/sui/pull/4627
        tags: vector<vector<u8>>,
        royalty_fee_bps: u64,
        is_mutable: bool,
        authority: address,
        ctx: &mut TxContext,
    ): Collection<T> {
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
            symbol: string::utf8(symbol),
            receiver,
            tags: tags::from_vec_string(&mut utils::to_string_vector(&mut tags)),
            is_mutable: is_mutable,
            creators: vector::empty(),
            mint_authority: mint_object_id,
            royalty_fee_bps,
            domains: bag::new(ctx),
        }
    }

    /// Shares the `MintAuthority` object of a given `Collection`. For NFT
    /// collections that require users to be the ones to mint the data, one
    /// requires the `MintAuthority` to be shared, such that they can access the
    /// nft mint functions.
    ///
    /// An example of this could be a Domain Name Service protocol, which
    /// relies on users calling the nft mint function themselses and therefore
    /// minting their domain name.
    public fun share_authority<T, M: store>(
        authority: MintAuthority<T>,
        _collection: &Collection<T>,
    ) {
        transfer::share_object(authority);
    }

    /// Make Collections immutable
    /// WARNING: this is irreversible, use with care
    public entry fun freeze_collection<T>(
        collection: &mut Collection<T>,
    ) {
        // Only modify if collection is mutable
        assert!(
            collection.is_mutable == true,
            err::collection_is_not_mutable()
        );

        collection.is_mutable = false;
    }

    // === Modifier Entry Functions ===

    /// Modify the Collections's `symbol`
    public entry fun change_symbol<T>(
        collection: &mut Collection<T>,
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
    public entry fun change_receiver<T>(
        collection: &mut Collection<T>,
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
    public entry fun push_tag<T>(
        collection: &mut Collection<T>,
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
    public entry fun pop_tag<T>(
        collection: &mut Collection<T>,
        tag_index: u64,
    ) {
        tags::pop_tag(
            &mut collection.tags,
            tag_index,
        );
    }

    /// Add a `Creator` to `Collection`
    public entry fun add_creator<T>(
        collection: &mut Collection<T>,
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
    public entry fun remove_creator<T>(
        collection: &mut Collection<T>,
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

    // === Domain Functions ===

    public fun has_domain<C, D: store>(nft: &Collection<C>): bool {
        bag::contains_with_type<DomainKey, D>(&nft.domains, domain_key<D>())
    }

    public fun borrow_domain<C, D: store>(nft: &Collection<C>): &D {
        bag::borrow<DomainKey, D>(&nft.domains, domain_key<D>())
    }

    public fun borrow_domain_mut<C, D: store, W: drop>(
        _witness: W,
        nft: &mut Collection<C>,
    ): &mut D {
        utils::assert_same_module_as_witness<W, D>();
        bag::borrow_mut<DomainKey, D>(&mut nft.domains, domain_key<D>())

    }

    public fun add_domain<C, V: store>(
        nft: &mut Collection<C>,
        v: V,
    ) {
        bag::add(&mut nft.domains, domain_key<V>(), v);
    }

    public fun remove_domain<C, W: drop, V: store>(
        _witness: W,
        nft: &mut Collection<C>,
    ): V {
        utils::assert_same_module_as_witness<W, V>();
        bag::remove(&mut nft.domains, domain_key<V>())
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
    public fun id<T>(
        collection: &Collection<T>,
    ): ID {
        object::uid_to_inner(&collection.id)
    }

    /// Get the Collections's `id` as reference
    public fun id_ref<T>(
        collection: &Collection<T>,
    ): &ID {
        object::uid_as_inner(&collection.id)
    }

    /// Get the Collections's `symbol`
    public fun symbol<T>(
        collection: &Collection<T>,
    ): &String {
        &collection.symbol
    }

    /// Get the Collections's `receiver`
    public fun receiver<T>(
        collection: &Collection<T>,
    ): address {
        collection.receiver
    }

    /// Get the Collections's `tags`
    public fun tags<T>(
        collection: &Collection<T>,
    ): &Tags {
        &collection.tags
    }

    /// Get the Collection's `is_mutable`
    public fun is_mutable<T>(
        collection: &Collection<T>,
    ): bool {
        collection.is_mutable
    }

    /// Get the Collection's `creators`
    public fun creators<T>(
        collection: &Collection<T>,
    ): &vector<Creator> {
        &collection.creators
    }

    /// Get the Collection's `royalty_fee_bps`
    // TODO(https://github.com/Origin-Byte/nft-protocol/issues/103): Implement RoyaltyDomain
    public fun royalty<T>(
        collection: &Collection<T>,
    ): u64 {
        collection.royalty_fee_bps
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
