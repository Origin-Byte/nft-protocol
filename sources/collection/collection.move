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
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::TxContext;
    use sui::dynamic_field as df;

    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::witness::Witness as DelegatedWitness;

    /// Domain not defined
    ///
    /// Call `collection::add_domain` to add domains
    const EUNDEFINED_DOMAIN: u64 = 1;

    /// Domain already defined
    ///
    /// Call `collection::borrow` to borrow domain
    const EEXISTING_DOMAIN: u64 = 2;

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
    /// #### Usage
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

        let cap = mint_cap::new(object::uid_to_inner(&id), ctx);

        (cap, Collection { id })
    }

    /// Creates a shared `Collection<C>` and corresponding `MintCap<C>`
    public fun init_collection<C>(
        witness: &C,
        owner: address,
        ctx: &mut TxContext,
    ) {
        let (mint_cap, collection) = create(witness, ctx);
        transfer::share_object(collection);
        transfer::transfer(mint_cap, owner);
    }

    // === Domain Functions ===

    /// Check whether `Collection` has a domain of type `D`
    public fun has_domain<C, D: store>(
        collection: &Collection<C>,
    ): bool {
        df::exists_with_type<Marker<D>, D>(&collection.id, utils::marker<D>())
    }

    /// Borrow domain of type `D` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain of type `D` is not present on the `Nft`
    public fun borrow_domain<C, D: store>(
        collection: &Collection<C>
    ): &D {
        assert_domain<C, D>(collection);
        df::borrow(&collection.id, utils::marker<D>())
    }

    /// Mutably borrow domain of type `D` from `Collection`
    ///
    /// Guarantees that domain `D` can only be mutated by the module that
    /// instantiated it. In other words, witness `W` must be defined in the
    /// same module as domain `D`.
    ///
    /// #### Usage
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
    /// #### Panics
    ///
    /// Panics when module attempts to mutably borrow a domain it did not
    /// define itself or if domain of type `D` is not present on the `Nft`. See
    /// [nft::borrow_domain_mut](./nft.html#borrow_domain_mut).
    /// ```
    public fun borrow_domain_mut<C, D: store, W: drop>(
        _witness: W,
        collection: &mut Collection<C>,
    ): &mut D {
        utils::assert_same_module_as_witness<D, W>();
        assert_domain<C, D>(collection);

        df::borrow_mut(&mut collection.id, utils::marker<D>())
    }

    /// Adds domain of type `D` to `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if domain `D` already exists.
    ///
    /// #### Usage
    ///
    /// ```
    /// let display_domain = display::new_display_domain(name, description);
    /// collection::add_domain(&mut nft, mint_cap, display_domain);
    /// ```
    public fun add_domain<C, D: store>(
        _witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        domain: D,
    ) {
        assert_no_domain<C, D>(collection);
        df::add(&mut collection.id, utils::marker<D>(), domain);
    }

    /// Removes domain of type `D` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics when module attempts to remove a domain it did not define
    /// itself or if domain of type `D` is not present on the `Collection`. See
    /// [borrow_domain_mut](#borrow_domain_mut).
    ///
    /// #### Usage
    ///
    /// ```
    /// let display_domain: DisplayDomain = collection::remove_domain(Witness {}, &mut nft);
    /// ```
    public fun remove_domain<C, W: drop, D: store>(
        _witness: W,
        collection: &mut Collection<C>,
    ): D {
        utils::assert_same_module_as_witness<W, D>();
        assert_domain<C, D>(collection);

        df::remove(&mut collection.id, utils::marker<D>())
    }

    // === Assertions ===

    /// Assert that domain `D` exists on `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if domain, `D`, does not exist on `Collection`.
    public fun assert_domain<C, D: store>(collection: &Collection<C>) {
        assert!(has_domain<C, D>(collection), EUNDEFINED_DOMAIN);
    }

    /// Assert that domain `D` does not exist on `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if domain, `D`, does exists on `Collection`.
    public fun assert_no_domain<C, D: store>(
        collection: &Collection<C>
    ) {
        assert!(!has_domain<C, D>(collection), EEXISTING_DOMAIN);
    }
}
