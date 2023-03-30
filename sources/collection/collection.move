/// Module defining the OriginByte `Collection` and `MintCap` types
///
/// Conceptually, we can think of NFTs as being organized into collections; a
/// one-to-many relational data model.
///
/// OriginByte collections serve two purposes, to centralise collection level
/// information on one object and thus avoid redundancy, and to provide
/// configuration data to NFTs.
module nft_protocol::collection {
    use std::option;
    use std::type_name::{Self, TypeName};

    use sui::event;
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::TxContext;
    use sui::dynamic_field as df;

    use nft_protocol::witness;
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
    /// OriginByte collections and NFTs have a generic parameter `T` which is a
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
    struct Collection<phantom W> has key, store {
        /// `Collection` ID
        id: UID,
    }

    /// Event signalling that a `Collection` was minted
    struct MintCollectionEvent has copy, drop {
        /// ID of the `Collection` that was minted
        collection_id: ID,
        /// Type name of `Collection<T>` one-time witness `T`
        ///
        /// Intended to allow users to filter by collections of interest.
        type_name: TypeName,
    }

    /// Creates a `Collection<T>` and corresponding `MintCap<T>`
    ///
    /// #### Panics
    ///
    /// Panics if witness is not defined in the same module as `T`.
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
    public fun create<W: drop>(
        _witness: &W,
        ctx: &mut TxContext,
    ): Collection<W> {
        let id = object::new(ctx);

        event::emit(MintCollectionEvent {
            collection_id: object::uid_to_inner(&id),
            type_name: type_name::get<W>(),
        });

        Collection { id }
    }

    /// Creates a shared `Collection<T>` and corresponding `MintCap<T>`
    ///
    /// #### Panics
    ///
    /// Panics if witness is not defined in the same module as `T`.
    public fun init_collection<W: drop>(
        witness: &W,
        ctx: &mut TxContext,
    ) {
        let collection = create<W>(witness, ctx);
        transfer::public_share_object(collection);
    }

    // === Domain Functions ===

    /// Check whether `Collection` has domain
    public fun has_domain<T, Domain: store>(
        collection: &Collection<T>,
    ): bool {
        df::exists_with_type<Marker<Domain>, Domain>(
            &collection.id, utils::marker<Domain>(),
        )
    }

    /// Borrow domain from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain is not present on the `Nft`
    public fun borrow_domain<T, Domain: store>(
        collection: &Collection<T>
    ): &Domain {
        assert_domain<T, Domain>(collection);
        df::borrow(&collection.id, utils::marker<Domain>())
    }

    /// Mutably borrow domain from `Collection`
    ///
    /// Guarantees that domain can only be mutated by the module that
    /// instantiated it. In other words, witness `W` must be defined in the
    /// same module as domain.
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
    ///     public fun domain_mut(collection: &mut Collection<T>): &mut DisplayDomain {
    ///         let domain: &mut DisplayDomain =
    ///             collection::borrow_domain_mut(Witness {}, collection);
    ///     }
    /// }
    /// ```
    ///
    /// #### Panics
    ///
    /// Panics when module attempts to mutably borrow a domain it did not
    /// define itself or if domain is not present on the `Nft`. See
    /// [nft::borrow_domain_mut](./nft.html#borrow_domain_mut).
    /// ```
    public fun borrow_domain_mut<T, Domain: store, W: drop>(
        _witness: W,
        collection: &mut Collection<T>,
    ): &mut Domain {
        utils::assert_same_module_as_witness<Domain, W>();
        assert_domain<T, Domain>(collection);

        df::borrow_mut(&mut collection.id, utils::marker<Domain>())
    }

    /// Adds domain to `Collection`
    ///
    /// Helper method that can be simply used without knowing what a delegated
    /// witness is.
    ///
    /// #### Panics
    ///
    /// Panics if domain already exists.
    public fun add_domain<T, W, Domain: store>(
        witness: &W,
        collection: &mut Collection<T>,
        domain: Domain,
    ) {
        add_domain_delegated(
            witness::from_witness(witness),
            collection,
            domain,
        )
    }

    /// Adds domain to `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if domain already exists.
    public fun add_domain_delegated<T, Domain: store>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        domain: Domain,
    ) {
        assert_no_domain<T, Domain>(collection);
        df::add(&mut collection.id, utils::marker<Domain>(), domain);
    }

    /// Removes domain from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics when module attempts to remove a domain it did not define
    /// itself or if domain is not present on the `Collection`. See
    /// [borrow_domain_mut](#borrow_domain_mut).
    ///
    /// #### Usage
    ///
    /// ```
    /// let display_domain: DisplayDomain = collection::remove_domain(Witness {}, &mut nft);
    /// ```
    public fun remove_domain<T, W: drop, Domain: store>(
        _witness: W,
        collection: &mut Collection<T>,
    ): Domain {
        utils::assert_same_module_as_witness<W, Domain>();
        assert_domain<T, Domain>(collection);

        df::remove(&mut collection.id, utils::marker<Domain>())
    }

    // === Assertions ===

    /// Assert that domain exists on `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if domain does not exist on `Collection`.
    public fun assert_domain<T, Domain: store>(
        collection: &Collection<T>,
    ) {
        assert!(has_domain<T, Domain>(collection), EUNDEFINED_DOMAIN);
    }

    /// Assert that domain does not exist on `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if domain does exists on `Collection`.
    public fun assert_no_domain<T, Domain: store>(
        collection: &Collection<T>
    ) {
        assert!(!has_domain<T, Domain>(collection), EEXISTING_DOMAIN);
    }
}
