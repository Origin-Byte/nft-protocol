/// Module of Collection `CreatorsDomain`
///
/// `CreatorsDomain` tracks all collection creators, used to authenticate
/// mutable operations on other OriginByte standard domains.
module nft_protocol::creators {
    use sui::object::{Self, UID};
    use sui::vec_set::{Self, VecSet};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::witness::{
        Self, WitnessGenerator, Witness as DelegatedWitness
    };

    /// `CreatorsDomain` was not defined on `Collection`
    ///
    /// Call `collection::add_domain` to add `CreatorsDomain`.
    const EUNDEFINED_CREATORS_DOMAIN: u64 = 1;

    /// Address was not attributed as a creator
    ///
    /// Call `add_creator` or `add_creator_external` to attribute the creator.
    const EUNDEFINED_ADDRESS: u64 = 2;

    /// `CreatorsDomain` tracks collection creators
    ///
    /// #### Usage
    ///
    /// Originbyte Standard domains will authenticate mutable operations for
    /// transaction senders which are creators using
    /// `assert_collection_has_creator`.
    ///
    /// `CreatorsDomain` can additionally be frozen which will cause
    /// `assert_collection_has_creator` to always fail, therefore, allowing
    /// creators to lock in their NFT collection.
    ///
    /// ```
    /// module nft_protocol::display {
    ///     use nft_protocol::witness::Witness as DelegatedWitness;
    ///
    ///     struct SUIMARINES has drop {}
    ///     struct Witness has drop {}
    ///
    ///     struct DisplayDomain {
    ///         id: UID,
    ///         name: String,
    ///     } has key, store
    ///
    ///     public fun set_name<C>(
    ///         _witness: DelegatedWitness<C>,
    ///         collection: &mut Collection<C>,
    ///         name: String,
    ///     ) {
    ///         let domain: &mut DisplayDomain =
    ///             collection::borrow_domain_mut(Witness {}, collection);
    ///
    ///         domain.name = name;
    ///     }
    /// }
    struct CreatorsDomain<phantom C> has key, store {
        /// `CreatorsDomain` ID
        id: UID,
        /// Generator responsible for issuing delegated witnesses
        generator: WitnessGenerator<C>,
        /// Creators that have the ability to mutate standard domains
        creators: VecSet<address>,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates an empty `CreatorsDomain` object
    ///
    /// By not attributing any `Creators`, nobody will ever be able to modify
    /// `Collection` domains.
    public fun empty<C>(witness: &C, ctx: &mut TxContext): CreatorsDomain<C> {
        from_creators(witness, vec_set::empty(), ctx)
    }

    /// Creates a `CreatorsDomain` object with only one creator
    ///
    /// Only the single `Creator` will ever be able to modify `Collection`
    /// domains.
    public fun from_address<C>(
        witness: &C,
        who: address,
        ctx: &mut TxContext,
    ): CreatorsDomain<C> {
        let creators = vec_set::empty();
        vec_set::insert(&mut creators, who);

        from_creators(witness, creators, ctx)
    }

    /// Creates a `CreatorsDomain` with multiple creators
    ///
    /// Each attributed creator will be able to modify `Collection` domains.
    public fun from_creators<C>(
        witness: &C,
        creators: VecSet<address>,
        ctx: &mut TxContext,
    ): CreatorsDomain<C> {
        CreatorsDomain {
            id: object::new(ctx),
            generator: witness::generator(witness),
            creators,
        }
    }

    /// Attributes the given address as a creator on the `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if creator was already attributed or `CreatorsDomain` is not
    /// registered on the `Collection`.
    public fun add_creator<C>(
        _witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        who: address,
    ) {
        let domain = creators_domain_mut(collection);
        vec_set::insert(&mut domain.creators, who);
    }

    /// Attributes the given address as a creator on the `Collection`
    ///
    /// Same as `add_creator` but as an entry function.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not a creator, if already attributed,
    /// or if `CreatorsDomain` is not registered on the `Collection`.
    public entry fun add_creator_external<C>(
        collection: &mut Collection<C>,
        who: address,
        ctx: &mut TxContext,
    ) {
        add_creator(delegate(collection, ctx), collection, who);
    }

    /// Create a delegated witness
    ///
    /// Delegated witness can be used to authorize mutating operations across
    /// most OriginByte domains.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender was not a creator or `CreatorsDomain` was
    /// not registered on the `Collection`.
    public fun delegate<C>(
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ): DelegatedWitness<C> {
        let domain = creators_domain(collection);
        assert_creator(domain, &tx_context::sender(ctx));
        witness::delegate(&domain.generator)
    }

    // === Getters ===

    /// Returns whether `CreatorsDomain` has no defined creators
    public fun is_empty<C>(domain: &CreatorsDomain<C>): bool {
        vec_set::is_empty(&domain.creators)
    }

    /// Returns whether address is a defined creator
    public fun contains_creator<C>(
        domain: &CreatorsDomain<C>,
        who: &address,
    ): bool {
        vec_set::contains(&domain.creators, who)
    }

    /// Returns the list of creators defined on the `CreatorsDomain`
    public fun borrow_creators<C>(
        domain: &CreatorsDomain<C>,
    ): &VecSet<address> {
        &domain.creators
    }

    // === Interoperability ===

    /// Borrows `CreatorsDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `CreatorsDomain` is not registered on `Collection`.
    public fun creators_domain<C>(
        collection: &Collection<C>,
    ): &CreatorsDomain<C> {
        assert_domain(collection);
        collection::borrow_domain(collection)
    }

    /// Mutably borrows `CreatorsDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `CreatorsDomain` is not registered on `Collection`.
    fun creators_domain_mut<C>(
        collection: &mut Collection<C>,
    ): &mut CreatorsDomain<C> {
        assert_domain(collection);
        collection::borrow_domain_mut(Witness {}, collection)
    }

    // === Assertions ===

    /// Asserts that address is a creator attributed in `CreatorsDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `CreatorsDomain` is not defined or address is not an
    /// attributed creator.
    public fun assert_creator<C>(
        domain: &CreatorsDomain<C>,
        who: &address
    ) {
        assert!(contains_creator(domain, who), EUNDEFINED_ADDRESS);
    }

    /// Asserts that `CreatorsDomain` is defined on the `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `CreatorsDomain` is not defined on the `Collection`.
    public fun assert_domain<C>(collection: &Collection<C>) {
        assert!(
            collection::has_domain<C, CreatorsDomain<C>>(collection),
            EUNDEFINED_CREATORS_DOMAIN,
        )
    }
}
