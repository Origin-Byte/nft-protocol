/// Module of Collection `CreatorsDomain`
///
/// `CreatorsDomain` tracks all collection creators, used to authenticate
/// mutable operations on other OriginByte standard domains.
module nft_protocol::creators {
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
    struct CreatorsDomain<phantom T> has store {
        /// Generator responsible for issuing delegated witnesses
        generator: WitnessGenerator<T>,
        /// Creators that have the ability to mutate standard domains
        creators: VecSet<address>,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates an empty `CreatorsDomain` object
    ///
    /// By not attributing any `Creators`, nobody will ever be able to modify
    /// `Collection` domains.
    public fun empty<T, W: drop>(witness: W): CreatorsDomain<T> {
        empty_delegated(witness::from_witness(witness))
    }

    /// Creates an empty `CreatorsDomain` object
    ///
    /// By not attributing any `Creators`, nobody will ever be able to modify
    /// `Collection` domains.
    public fun empty_delegated<T>(
        witness: DelegatedWitness<T>,
    ): CreatorsDomain<T> {
        from_creators_delegated(witness, vec_set::empty())
    }

    /// Creates a `CreatorsDomain` object with only one creator
    ///
    /// Only the single `Creator` will ever be able to modify `Collection`
    /// domains.
    public fun from_address<T, W: drop>(
        witness: W,
        who: address,
    ): CreatorsDomain<T> {
        from_address_delegated(witness::from_witness(witness), who)
    }

    /// Creates a `CreatorsDomain` object with only one creator
    ///
    /// Only the single `Creator` will ever be able to modify `Collection`
    /// domains.
    public fun from_address_delegated<T>(
        witness: DelegatedWitness<T>,
        who: address,
    ): CreatorsDomain<T> {
        let creators = vec_set::empty();
        vec_set::insert(&mut creators, who);

        from_creators_delegated(witness, creators)
    }

    /// Creates a `CreatorsDomain` with multiple creators
    ///
    /// Each attributed creator will be able to modify `Collection` domains.
    public fun from_creators<T, W: drop>(
        witness: W,
        creators: VecSet<address>,
    ): CreatorsDomain<T> {
        from_creators_delegated(
            witness::from_witness(witness),
            creators,
        )
    }

    /// Creates a `CreatorsDomain` with multiple creators
    ///
    /// Each attributed creator will be able to modify `Collection` domains.
    public fun from_creators_delegated<T>(
        witness: DelegatedWitness<T>,
        creators: VecSet<address>,
    ): CreatorsDomain<T> {
        CreatorsDomain {
            generator: witness::generator_delegated<T>(witness),
            creators,
        }
    }

    /// Attributes the given address as a creator on the `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if creator was already attributed or `CreatorsDomain` is not
    /// registered on the `Collection`.
    public fun add_creator<T>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
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
    public entry fun add_creator_external<T>(
        collection: &mut Collection<T>,
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
    public fun delegate<T>(
        collection: &Collection<T>,
        ctx: &mut TxContext,
    ): DelegatedWitness<T> {
        let domain = creators_domain(collection);
        assert_creator(domain, &tx_context::sender(ctx));
        witness::delegate(&domain.generator)
    }

    // === Getters ===

    /// Returns whether `CreatorsDomain` has no defined creators
    public fun is_empty<T>(domain: &CreatorsDomain<T>): bool {
        vec_set::is_empty(&domain.creators)
    }

    /// Returns whether address is a defined creator
    public fun contains_creator<T>(
        domain: &CreatorsDomain<T>,
        who: &address,
    ): bool {
        vec_set::contains(&domain.creators, who)
    }

    /// Returns the list of creators defined on the `CreatorsDomain`
    public fun borrow_creators<T>(
        domain: &CreatorsDomain<T>,
    ): &VecSet<address> {
        &domain.creators
    }

    // === Interoperability ===

    /// Borrows `CreatorsDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `CreatorsDomain` is not registered on `Collection`.
    public fun creators_domain<T>(
        collection: &Collection<T>,
    ): &CreatorsDomain<T> {
        assert_domain(collection);
        collection::borrow_domain(collection)
    }

    /// Mutably borrows `CreatorsDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `CreatorsDomain` is not registered on `Collection`.
    fun creators_domain_mut<T>(
        collection: &mut Collection<T>,
    ): &mut CreatorsDomain<T> {
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
    public fun assert_creator<T>(
        domain: &CreatorsDomain<T>,
        who: &address
    ) {
        assert!(contains_creator(domain, who), EUNDEFINED_ADDRESS);
    }

    /// Asserts that `CreatorsDomain` is defined on the `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `CreatorsDomain` is not defined on the `Collection`.
    public fun assert_domain<T>(collection: &Collection<T>) {
        assert!(
            collection::has_domain<T, CreatorsDomain<T>>(collection),
            EUNDEFINED_CREATORS_DOMAIN,
        )
    }
}
