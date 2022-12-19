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
module nft_protocol::collection {
    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::TxContext;
    use sui::transfer;
    use sui::bag::{Self, Bag};

    use nft_protocol::err;
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::supply_policy::{Self, SupplyPolicy};

    /// An NFT `Collection` object with a generic `M`etadata.
    ///
    /// The `Metadata` is a type exported by an upstream contract which is
    /// used to store additional information about the NFT.
    struct Collection<phantom T> has key, store {
        id: UID,
        /// Domain storage equivalent to NFT domains which allows collections
        /// to implement custom metadata.
        domains: Bag,
    }

    /// The `MintCapability` object gives power to the owner to mint objects.
    /// There is only one `MintCapability` per `Collection`.
    struct MintCap<phantom T> has key, store {
        id: UID,
        collection_id: ID,
        // Defines supply policy which can be regulated or unregulated.
        // A Collection with unregulated Supply policy is a collection that
        // does not keep track of its current supply objects. This allows for the
        // minting process to be parallelized.
        supply_policy: SupplyPolicy,
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
        let collection_id = object::id(&collection);

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
        _witness: &T,
        // Defines the maximum supply of the collection. To create an
        // unregulated supply set `max_supply=0`, otherwise any value above
        // zero will make the supply regulated.
        max_supply: u64,
        ctx: &mut TxContext,
    ): (MintCap<T>, Collection<T>) {
        let id = object::new(ctx);

        event::emit(
            MintEvent {
                collection_id: object::uid_to_inner(&id),
            }
        );

        let cap = create_mint_cap<T>(
            object::uid_to_inner(&id),
            max_supply,
            ctx,
        );

        let col = Collection {
            id,
            domains: bag::new(ctx),
        };

        (cap, col)
    }

    // === Domain Functions ===

    public fun has_domain<C, D: store>(collection: &Collection<C>): bool {
        bag::contains_with_type<Marker<D>, D>(
            &collection.domains, utils::marker<D>()
        )
    }

    public fun borrow_domain<C, D: store>(collection: &Collection<C>): &D {
        bag::borrow<Marker<D>, D>(&collection.domains, utils::marker<D>())
    }

    public fun borrow_domain_mut<C, D: store, W: drop>(
        _witness: W,
        collection: &mut Collection<C>,
    ): &mut D {
        utils::assert_same_module_as_witness<D, W>();
        bag::borrow_mut<Marker<D>, D>(
            &mut collection.domains, utils::marker<D>()
        )
    }

    public fun add_domain<C, V: store>(
        collection: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        v: V,
    ) {
        assert_mint_cap(mint_cap, collection);
        bag::add(&mut collection.domains, utils::marker<V>(), v);
    }

    public fun remove_domain<C, W: drop, V: store>(
        _witness: W,
        collection: &mut Collection<C>,
    ): V {
        utils::assert_same_module_as_witness<W, V>();
        bag::remove(&mut collection.domains, utils::marker<V>())
    }

    // === MintCap ===

    fun create_mint_cap<T>(
        collection_id: ID,
        max_supply: u64,
        ctx: &mut TxContext,
    ): MintCap<T> {
        MintCap {
            id: object::new(ctx),
            collection_id: collection_id,
            supply_policy: if (max_supply == 0) {
                supply_policy::create_unregulated()
            } else {
                supply_policy::create_regulated(
                    max_supply, false
                )
            },
        }
    }

    /// This function call ceils the supply of the Collection as long
    /// as the Policy is regulated.
    public entry fun ceil_supply<T>(
        mint: &mut MintCap<T>,
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
        mint: &mut MintCap<T>,
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
        mint: &mut MintCap<T>,
        value: u64
    ) {
        supply_policy::decrease_max_supply(
            &mut mint.supply_policy,
            value
        )
    }

    /// Increments current supply for regulated collections.
    public fun increment_supply<T>(
        mint: &mut MintCap<T>,
        value: u64
    ) {
        supply_policy::increment_supply(
            &mut mint.supply_policy,
            value
        )
    }

    /// Decrements current supply for regulated collections.
    public fun decrease_supply<T>(
        mint: &mut MintCap<T>,
        value: u64
    ) {
        supply_policy::decrement_supply(
            &mut mint.supply_policy,
            value
        )
    }

    /// Returns reference to supply object for regulated collections.
    public fun supply<T>(mint: &MintCap<T>): &Supply {
        supply_policy::supply(&mint.supply_policy)
    }

    /// Returns max supply for regulated collections.
    public fun supply_max<T>(mint: &MintCap<T>): u64 {
        supply::max(
            supply_policy::supply(&mint.supply_policy)
        )
    }

    public fun current_supply<T>(mint: &MintCap<T>): u64 {
        supply::current(
            supply_policy::supply(&mint.supply_policy)
        )
    }

    /// Get an immutable reference to Collections's `cap`
    public fun supply_policy<T>(
        mint: &MintCap<T>,
    ): &SupplyPolicy {
        &mint.supply_policy
    }

    /// Get a mutable reference to Collections's `cap`
    public fun cap_mut<T>(
        mint: &mut MintCap<T>,
    ): &mut SupplyPolicy {
        &mut mint.supply_policy
    }

    public fun mint_collection_id<T>(
        mint: &MintCap<T>,
    ): ID {
        mint.collection_id
    }

    // === Assertions ===

    public fun assert_mint_cap<C>(
        cap: &MintCap<C>,
        collection: &Collection<C>
    ) {
        assert!(
            cap.collection_id == object::id(collection),
            err::mint_cap_mismatch()
        );
    }

    // === Test only helpers ===

    #[test_only]
    public fun dummy_collection<T>(
        witness: &T,
        creator: address,
        scenario: &mut sui::test_scenario::Scenario,
    ): (MintCap<T>, Collection<T>) {
        sui::test_scenario::next_tx(scenario, creator);

        let (cap, col) = create<T>(
            witness,
            1,
            sui::test_scenario::ctx(scenario),
        );

        (cap, col)
    }
}
