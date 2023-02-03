/// Module defining the OriginByte `Collection` and `MintCap` types
///
/// Conceptually, we can think of NFTs as being organized into collections; a
/// one-to-many relational data model.
///
/// OriginByte collections serve two purposes, to centralise collection level
/// information on one object and thus avoid redundancy, and to provide
/// configuration data to NFTs.
module nft_protocol::collection {
    use std::type_name::{Self, TypeName};

    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::TxContext;
    use sui::dynamic_object_field as dof;

    use nft_protocol::err;
    use nft_protocol::utils::{Self, Marker};

    /// NFT `Collection` object
    ///
    /// OriginByte collections and NFTs have a generic parameter `C` which is a
    /// one-time witness created by the creator's NFT collection module. This
    /// allows `Collection` and `Nft` to be linked via type association, but
    /// also ensures that NFTs can only be minted by the contract that
    /// initially deployed them.
    ///
    /// A `Collection`, like each `Nft`, exclusively owns domains of different
    /// types, which can be dynamically acquired and lost over its lifetime.
    /// OriginByte collections are modelled after
    /// [Entity Component Systems](https://en.wikipedia.org/wiki/Entity_component_system),
    /// where their domains are accessible by type. See
    /// [borrow_domain_mut](#borrow_domain_mut).
    struct Collection<phantom C> has key, store {
        /// `Collection` ID
        id: UID,
    }

    /// `MintCap<C>` delegates the capability to it's owner to mint `Nft<C>`.
    /// There is only one `MintCap` per `Collection<C>`.
    ///
    /// This pattern is useful as `MintCap` can be made shared allowing users
    /// to mint NFTs themselves, such as in a name service application.
    struct MintCap<phantom C> has key, store {
        /// `MintCap` ID
        id: UID,
        /// ID of the `Collection` that `MintCap` controls.
        ///
        /// Intended for discovery.
        collection_id: ID,
    }

    /// Event signalling that a `Collection` was minted
    struct MintCollectionEvent has copy, drop {
        /// ID of the `Collection` that was minted
        collection_id: ID,
        /// Type name of `Collection<C>` one-time witness `C`
        ///
        /// Intended to allow users to filter by collections of interest.
        type_name: TypeName,
    }

    /// Creates a `Collection<C>` and corresponding `MintCap<C>`
    ///
    /// ##### Usage
    ///
    /// ```
    /// struct FOOTBALL has drop {}
    ///
    /// fun init(witness: FOOTBALL, ctx: &mut TxContext) {
    ///     let (mint_cap, collection) = collection::create(&witness, ctx);
    /// }
    /// ```
    public fun create<C>(
        _witness: &C,
        ctx: &mut TxContext,
    ): (MintCap<C>, Collection<C>) {
        let id = object::new(ctx);

        event::emit(MintCollectionEvent {
            collection_id: object::uid_to_inner(&id),
            type_name: type_name::get<C>(),
        });

        let cap = MintCap {
            id: object::new(ctx),
            collection_id: object::uid_to_inner(&id),
        };

        (cap, Collection { id })
    }

    // === Domain Functions ===

    /// Check whether `Collection` has a domain of type `D`
    public fun has_domain<C, D: key + store>(
        collection: &Collection<C>,
    ): bool {
        dof::exists_with_type<Marker<D>, D>(&collection.id, utils::marker<D>())
    }

    /// Borrow domain of type `D` from `Nft`
    ///
    /// ##### Panics
    ///
    /// Panics if domain of type `D` is not present on the `Nft`
    public fun borrow_domain<C, D: key + store>(
        collection: &Collection<C>
    ): &D {
        assert_domain<C, D>(collection);
        dof::borrow(&collection.id, utils::marker<D>())
    }

    /// Mutably borrow domain of type `D` from `Collection`
    ///
    /// Guarantees that domain `D` can only be mutated by the module that
    /// instantiated it. In other words, witness `W` must be defined in the
    /// same module as domain `D`.
    ///
    /// ##### Usage
    ///
    /// ```
    /// module nft_protocol::display {
    ///     struct SUIMARINES has drop {}
    ///     struct Witness has drop {}
    ///
    ///     struct DisplayDomain {
    ///         id: UID,
    ///         name: String,
    ///     } has key, store
    ///
    ///     public fun domain_mut(collection: &mut Collection<C>): &mut DisplayDomain {
    ///         let domain: &mut DisplayDomain =
    ///             collection::borrow_domain_mut(Witness {}, collection);
    ///     }
    /// }
    /// ```
    ///
    /// ##### Panics
    ///
    /// Panics when module attempts to mutably borrow a domain it did not
    /// define itself or if domain of type `D` is not present on the `Nft`. See
    /// [nft::borrow_domain_mut](./nft.html#borrow_domain_mut).
    /// ```
    public fun borrow_domain_mut<C, D: key + store, W: drop>(
        _witness: W,
        collection: &mut Collection<C>,
    ): &mut D {
        utils::assert_same_module_as_witness<D, W>();
        assert_domain<C, D>(collection);

        dof::borrow_mut(&mut collection.id, utils::marker<D>())
    }

    /// Adds domain of type `D` to `Collection`
    ///
    /// ##### Panics
    ///
    /// Panics if `MintCap` does not match `Collection` or domain `D` already
    /// exists.
    ///
    /// ##### Usage
    ///
    /// ```
    /// let display_domain = display::new_display_domain(name, description);
    /// collection::add_domain(&mut nft, mint_cap, display_domain);
    /// ```
    public fun add_domain<C, D: key + store>(
        collection: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        domain: D,
    ) {
        assert_mint_cap(mint_cap, collection);
        assert_no_domain<C, D>(collection);

        dof::add(&mut collection.id, utils::marker<D>(), domain);
    }

    /// Removes domain of type `D` from `Collection`
    ///
    /// ##### Panics
    ///
    /// Panics when module attempts to remove a domain it did not define
    /// itself or if domain of type `D` is not present on the `Collection`. See
    /// [borrow_domain_mut](#borrow_domain_mut).
    ///
    /// ##### Usage
    ///
    /// ```
    /// let display_domain: DisplayDomain = collection::remove_domain(Witness {}, &mut nft);
    /// ```
    public fun remove_domain<C, W: drop, D: key + store>(
        _witness: W,
        collection: &mut Collection<C>,
    ): D {
        utils::assert_same_module_as_witness<W, D>();
        assert_domain<C, D>(collection);

        dof::remove(&mut collection.id, utils::marker<D>())
    }

    // === MintCap ===

    /// Returns ID of `Collection` associated with `MintCap`
    public fun collection_id<C>(mint: &MintCap<C>): ID {
        mint.collection_id
    }

    // === Assertions ===

    /// Assert that domain `D` exists on `Collection`
    ///
    /// ##### Panics
    ///
    /// Panics if domain, `D`, does not exist on `Collection`.
    public fun assert_domain<C, D: key + store>(collection: &Collection<C>) {
        assert!(has_domain<C, D>(collection), err::undefined_domain());
    }

    /// Assert that domain `D` does not exist on `Collection`
    ///
    /// ##### Panics
    ///
    /// Panics if domain, `D`, does exists on `Collection`.
    public fun assert_no_domain<C, D: key + store>(
        collection: &Collection<C>
    ) {
        assert!(!has_domain<C, D>(collection), err::domain_already_defined());
    }

    /// Assert that `MintCap` is associated with `Collection`
    ///
    /// ##### Panics
    ///
    /// Panics if `MintCap` is not associated with the `Collection`.
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
    public fun dummy_collection<C>(
        witness: &C,
        creator: address,
        scenario: &mut sui::test_scenario::Scenario,
    ): (MintCap<C>, Collection<C>) {
        sui::test_scenario::next_tx(scenario, creator);

        let (cap, col) = create<C>(
            witness,
            sui::test_scenario::ctx(scenario),
        );

        (cap, col)
    }
}
