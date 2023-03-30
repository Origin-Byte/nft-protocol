/// Module defining the OriginByte `NFT` type
///
/// OriginByte's NFT protocol brings dynamism, composability and extendability
/// to NFTs. The current design allows creators to create DomainBags with custom
/// domain-specific fields, with their own bespoke behavior.
module nft_protocol::domain_bag {
    use sui::dynamic_field as df;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use nft_protocol::witness::{Self, Witness as DelegatedWitness};
    use nft_protocol::utils::{Self, Marker, UidType};

    /// Domain not defined
    ///
    /// Call `collection::add_domain` to add domains
    const EUNDEFINED_DOMAIN: u64 = 1;

    /// Domain already defined
    ///
    /// Call `collection::borrow` to borrow domain
    const EEXISTING_DOMAIN: u64 = 2;

    /// Transaction sender not logical owner
    const EINVALID_SENDER: u64 = 3;

    // TODO: Consider wrapping DomainBag in option in order to use df instead of dof
    // since df is more efficient

    /// `DomainBag` object
    ///
    /// Aa `DomainBag` exclusively owns domains of different types, which can be
    /// dynamically acquired and lost over its lifetime. OriginByte domains are
    /// modelled after [Entity Component Systems](https://en.wikipedia.org/wiki/Entity_component_system),
    /// where their domains are accessible by type. See
    /// [borrow_domain_mut](#borrow_domain_mut).
    struct DomainBag has key, store {
        id: UID,
    }

    struct DomainKey has store, copy, drop {}

    /// Create a new `Nft`
    fun new_(ctx: &mut TxContext): DomainBag {
        let id = object::new(ctx);

        DomainBag { id }
    }

    /// Create a new `Nft` using `MintCap`
    ///
    /// Requires witness of collection contract as this function should only
    /// be used by functions defined within that contract due to the potential
    /// to violate correctness guarantees in other parts of the codebase.
    ///
    /// #### Usage
    ///
    /// ```
    /// struct Witness has drop {}
    /// struct SUIMARINES has drop {}
    ///
    /// fun init(witness: SUIMARINES, ctx: &mut TxContext) {
    ///     let nft = nft::new(&Witness {}, tx_context::sender(ctx), ctx);
    /// }
    /// ```
    public fun new(ctx: &mut TxContext): DomainBag {
        new_(ctx)
    }

    public fun add_domain_bag(
        nft_uid: &mut UID,
        ctx: &mut TxContext,
    ) {
        let domain = new_(ctx);

        df::add(nft_uid, DomainKey {}, domain);
    }

    // To be used in the context of programmable transactions.
    // TODO: The problem now is that all domains will have the same access permission,
    // what if creators want to determine access atomically for each domain?
    // Maybe you can make this specific with a generic parameter Domain..
    public fun get_mut_uid<W, T: key + store>(
        _witness: W,
        nft_uid: &mut UID,
        nft_type: &UidType<T>,
    ): &mut UID {
        utils::assert_same_module_as_witness<T, W>();
        utils::assert_uid_type(nft_uid, nft_type);

        let domain_bag = df::borrow_mut<DomainKey, DomainBag>(nft_uid, DomainKey {});

        &mut domain_bag.id
    }

    // === Domain Functions ===

    // public fun has_domain_bag()
    // public fun borrow_domain_bag()
    // public fun borrow_domain_bag_mut()

    /// Check whether `Nft` has a domain
    public fun has_domain<Domain: store>(nft: &DomainBag): bool {
        df::exists_with_type<Marker<Domain>, Domain>(
            &nft.id, utils::marker<Domain>(),
        )
    }

    /// Borrow domain from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain is not present on the `Nft`
    public fun borrow_domain<Domain: store>(nft: &DomainBag): &Domain {
        assert_domain<Domain>(nft);
        df::borrow(&nft.id, utils::marker<Domain>())
    }

    /// Mutably borrow domain from `Nft`
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
    ///         name: string::String,
    ///     } has key, store
    ///
    ///     public fun domain_mut(nft: &mut DomainBag): &mut DisplayDomain {
    ///         let domain: &mut DisplayDomain =
    ///             collection::borrow_domain_mut(Witness {}, collection);
    ///     }
    /// }
    /// ```
    ///
    /// #### Panics
    ///
    /// Panics when module attempts to mutably borrow a domain it did not
    /// define itself or if domain is not present on the `Nft`.
    ///
    /// The module that actually added the domain to the `Nft` is not affected,
    /// in effect, this means that you can register OriginByte standard domains
    /// but OriginByte still controls access through any mutating methods it
    /// exposes.
    ///
    /// ```
    /// module nft_protocol::fake_display {
    ///     use nft_protocol::display::DisplayDomain;
    ///
    ///     struct SUIMARINES has drop {}
    ///     struct Witness has drop {}
    ///
    ///     public fun domain_mut<C>(nft: &mut DomainBag): &mut DisplayDomain {
    ///         // Call to `borrow_domain_mut` will panic due to `Witness` not originating from `nft_protocol::display`.
    ///         let domain: &mut DisplayDomain =
    ///             collection::borrow_domain_mut(Witness {}, collection);
    ///     }
    /// }
    /// ```
    public fun borrow_domain_mut<Domain: store, W: drop>(
        _witness: W,
        nft: &mut DomainBag,
    ): &mut Domain {
        utils::assert_same_module_as_witness<Domain, W>();
        assert_domain<Domain>(nft);

        df::borrow_mut(&mut nft.id, utils::marker<Domain>())
    }

    /// Adds domain to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain already exists.
    fun add_domain_<Domain: store>(
        nft: &mut DomainBag,
        domain: Domain,
    ) {
        assert_no_domain<Domain>(nft);
        df::add(&mut nft.id, utils::marker<Domain>(), domain);
    }

    /// Adds domain to `Nft`
    ///
    /// Helper method that can be simply used without knowing what a delegated
    /// witness is.
    ///
    /// #### Panics
    ///
    /// Panics if domain already exists.
    public fun add_domain<W, Domain: store>(
        witness: &W,
        nft: &mut DomainBag,
        domain: Domain,
    ) {
        add_domain_delegated(
            witness::from_witness(witness),
            nft,
            domain,
        )
    }

    /// Adds domain to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain already exists.
    public fun add_domain_delegated<Domain: store>(
        _witness: DelegatedWitness<DomainBag>,
        nft: &mut DomainBag,
        domain: Domain,
    ) {
        add_domain_(nft, domain)
    }

    /// Removes domain of type from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics when module attempts to remove a domain it did not define
    /// itself or if domain of type is not present on the `Nft`. See
    /// [borrow_domain_mut](#borrow_domain_mut).
    ///
    /// #### Usage
    ///
    /// ```
    /// let display_domain: DisplayDomain = nft::remove_domain(Witness {}, &mut nft);
    /// ```
    public fun remove_domain<W: drop, Domain: store>(
        _witness: W,
        nft: &mut DomainBag,
    ): Domain {
        utils::assert_same_module_as_witness<W, Domain>();
        assert_domain<Domain>(nft);

        df::remove(&mut nft.id, utils::marker<Domain>())
    }

    /// Burns an `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if any domains are still registered on the `Nft`.
    public entry fun burn<C>(nft: DomainBag) {
        let DomainBag { id } = nft;
        // TODO: Avoid locking child objects in a limbo..
        object::delete(id);
    }

    /// Check whether `Nft` has a domain
    public fun has_domain_via_uid<T: key + store, Domain: store>(nft_uid: &UID): bool {
        let bag = df::borrow<Marker<DomainBag>, DomainBag>(
            nft_uid, utils::marker<DomainBag>(),
        );

        df::exists_with_type<Marker<Domain>, Domain>(
            &bag.id, utils::marker<Domain>(),
        )
    }

    /// Borrow domain from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain is not present on the `Nft`
    public fun borrow_domain_via_uid<T: key + store, Domain: store>(nft_uid: &UID): &Domain {
        let bag = df::borrow<Marker<DomainBag>, DomainBag>(
            nft_uid, utils::marker<DomainBag>(),
        );

        assert_domain<Domain>(bag);
        df::borrow(nft_uid, utils::marker<Domain>())
    }

    // === Assertions ===

    /// Assert that domain exists on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain does not exist on `Nft`.
    public fun assert_domain<Domain: store>(nft: &DomainBag) {
        assert!(has_domain<Domain>(nft), EUNDEFINED_DOMAIN);
    }

    /// Assert that domain does not exist on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain exists on `Nft`.
    public fun assert_no_domain<Domain: store>(nft: &DomainBag) {
        assert!(!has_domain<Domain>(nft), EEXISTING_DOMAIN);
    }

    // === Test helpers ===

    #[test_only]
    /// Create `Nft` without access to `MintCap` or derivatives
    public fun test_mint<C>(ctx: &mut TxContext): DomainBag {
        new_(ctx)
    }
}
