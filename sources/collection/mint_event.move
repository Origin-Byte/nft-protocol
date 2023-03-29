module nft_protocol::mint_event {
    use std::type_name::{Self, TypeName};
    use std::option::{Self, Option};

    use sui::event;
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::TxContext;
    use sui::dynamic_field as df;

    use nft_protocol::witness;
    use nft_protocol::supply::Supply;
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::witness::Witness as DelegatedWitness;

    /// Event signalling that an object `T` was minted
    struct MintEvent<phantom T> has copy, drop {
        /// ID of the `Collection` that was minted
        collection_id: Option<ID>,
        /// Type name of `Collection<T>` one-time witness `T`
        ///
        /// Intended to allow users to filter by collections of interest.
        type_name: TypeName,
        /// ID of the minted object
        object: ID,
    }

    /// Event signalling that an object `T` was burned
    struct BurnEvent<phantom T> has copy, drop {
        /// ID of the `Collection` that was minted
        collection_id: Option<ID>,
        /// Type name of `Collection<T>` one-time witness `T`
        ///
        /// Intended to allow users to filter by collections of interest.
        type_name: TypeName,
        /// ID of the burned object
        object: ID,
    }

    struct MintEventHandle {
        /// ID of the `Collection` of the object `T`
        collection_id: Option<ID>,
        /// Type name of `Collection<T>` one-time witness `T`
        ///
        /// Intended to allow users to filter by collections of interest.
        type_name: TypeName,
        /// ID of the minted object
        object: ID,
    }

    struct BurnEventHandle {
        /// ID of the `Collection` of the object `T`
        collection_id: Option<ID>,
        /// Type name of `Collection<T>` one-time witness `T`
        ///
        /// Intended to allow users to filter by collections of interest.
        type_name: TypeName,
        /// ID of the burned object
        object: ID,
    }

    public fun mint_with_supply<T: key>(
        mint_cap: &mut MintCap<T>,
        object: &T,
    ): MintEventHandle {
        // Assert that there is a supply in mint cap
        assert!(option::is_some<Supply>(mint_cap::supply&mint_cap), 0);

        let type = type_name::get<T>();
        let object_id = object::id(object);

        event::emit(
            MintEvent<T> {
                collection_id: mint_cap::collection_id(mint_cap),
                type_name: type,
                object: object_id,
        });
    }

    public fun mint_with_supply_frozen<T: key>(
        mint_cap: &mut MintCap<T>,
        object: &T,
    ): MintEventHandle {
        // Assert that there is a supply in mint cap
        assert!(option::is_some<Supply>(mint_cap::supply&mint_cap), 0);
        assert!(Assert that frozen is true);

        let type = type_name::get<T>();
        let object_id = object::id(object);

        event::emit(
            MintEvent<T> {
                collection_id: mint_cap::collection_id(mint_cap),
                type_name: type,
                object: object_id,
        });
    }

    public fun mint<T: key>(
        mint_cap: &MintCap<T>,
        object: &T,
    ) {
        // Assert that there is a supply in mint cap
        assert!(option::is_some<Supply>(mint_cap::supply&mint_cap), 0);

        let type = type_name::get<T>();
        let object_id = object::id(object);

        event::emit(
            MintEvent<T> {
                collection_id: mint_cap::collection_id(mint_cap),
                type_name: type,
                object: object_id,
        });
    }

    /// Creates a shared `Collection<T>` and corresponding `MintCap<T>`
    public fun init_collection<W, T>(
        witness: &W,
        owner: address,
        ctx: &mut TxContext,
    ) {
        let (mint_cap, collection) = create<W, T>(witness, ctx);
        transfer::share_object(collection);
        transfer::transfer(mint_cap, owner);
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
