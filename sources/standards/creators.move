/// Module of Collection `Creators`
///
/// `Creators` tracks all collection creators.
module nft_protocol::creators {
    use sui::vec_set::{Self, VecSet};
    use sui::object::UID;
    use sui::dynamic_field as df;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::witness::{
        Self, WitnessGenerator, Witness as DelegatedWitness
    };

    /// `CreatorsDomain` was not defined on `Collection`
    ///
    /// Call `creators::add_domain` to add `Creators`.
    const EUndefinedCreators: u64 = 1;

    /// Address was not attributed as a creator
    ///
    /// Call `add_creator` to attribute the creator
    const EExistingCreators: u64 = 2;

    /// Address was not attributed as a creator
    const EUndefinedAddress: u64 = 3;

    /// `Creators` tracks collection creators
    ///
    /// #### Usage
    ///
    /// Originbyte Standard domains will authenticate mutable operations for
    /// transaction senders which are creators using
    /// `assert_collection_has_creator`.
    ///
    /// `Creators` can additionally be frozen which will cause
    /// `assert_collection_has_creator` to always fail, therefore, allowing
    /// creators to lock in their NFT collection.
    struct Creators<phantom T> has store {
        /// Generator responsible for issuing delegated witnesses
        generator: WitnessGenerator<T>,
        /// Creators that have the ability to mutate standard domains
        creators: VecSet<address>,
    }

    /// Creates an empty `Creators` object
    ///
    /// By not attributing any `Creators`, nobody will ever be able to modify
    /// `Collection` domains.
    public fun empty<T, W: drop>(witness: W): Creators<T> {
        empty_delegated(witness::from_witness(witness))
    }

    /// Creates an empty `Creators` object
    ///
    /// By not attributing any `Creators`, nobody will ever be able to modify
    /// `Collection` domains.
    public fun empty_delegated<T>(
        witness: DelegatedWitness<T>,
    ): Creators<T> {
        from_creators_delegated(witness, vec_set::empty())
    }

    /// Creates a `Creators` object with only one creator
    ///
    /// Only the single `Creator` will ever be able to modify `Collection`
    /// domains.
    public fun from_address<T, W: drop>(
        witness: W,
        who: address,
    ): Creators<T> {
        from_address_delegated(witness::from_witness(witness), who)
    }

    /// Creates a `Creators` object with only one creator
    ///
    /// Only the single `Creator` will ever be able to modify `Collection`
    /// domains.
    public fun from_address_delegated<T>(
        witness: DelegatedWitness<T>,
        who: address,
    ): Creators<T> {
        let creators = vec_set::empty();
        vec_set::insert(&mut creators, who);

        from_creators_delegated(witness, creators)
    }

    /// Creates a `Creators` with multiple creators
    ///
    /// Each attributed creator will be able to modify `Collection` domains.
    public fun from_creators<T, W: drop>(
        witness: W,
        creators: VecSet<address>,
    ): Creators<T> {
        from_creators_delegated(
            witness::from_witness(witness),
            creators,
        )
    }

    /// Creates a `Creators` with multiple creators
    ///
    /// Each attributed creator will be able to modify `Collection` domains.
    public fun from_creators_delegated<T>(
        witness: DelegatedWitness<T>,
        creators: VecSet<address>,
    ): Creators<T> {
        Creators {
            generator: witness::generator_delegated<T>(witness),
            creators,
        }
    }

    // === Field Borrow Functions ===

    /// Returns whether `Creators` has no defined creators
    public fun is_empty<T>(domain: &Creators<T>): bool {
        vec_set::is_empty(&domain.creators)
    }

    /// Returns whether address is a defined creator
    public fun contains_creator<T>(
        creators: &Creators<T>,
        who: &address,
    ): bool {
        vec_set::contains(&creators.creators, who)
    }

    /// Returns the list of creators defined on the `Creators`
    public fun get_creators<T>(
        domain: &Creators<T>,
    ): &VecSet<address> {
        &domain.creators
    }

    /// Borrows immutably the `Creators` field.
    //
    // TODO: Unsafe to arbitrarily add creator, should check that sender is
    // already a creator
    public fun add_creator<T>(
        creators: &mut Creators<T>,
        who: address,
    ) {
        vec_set::insert(&mut creators.creators, who);
    }

    /// Removes address from `Creators` field in object `T`
    //
    // TODO: Unsafe to arbitrarily add remove, should check that sender is
    // already a creator
    public fun remove_creator<T>(
        creators: &mut Creators<T>,
        who: address,
    ) {
        vec_set::remove(&mut creators.creators, &who);
    }

    /// Create a delegated witness
    ///
    /// Delegated witness can be used to authorize mutating operations across
    /// most OriginByte domains.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender was not a creator or `Creators` was
    /// not registered on the `Collection`.
    public fun delegate<T>(
        creators: &Creators<T>,
        ctx: &mut TxContext,
    ): DelegatedWitness<T> {
        assert_creator(creators, &tx_context::sender(ctx));
        witness::delegate(&creators.generator)
    }

    // === Interoperability ===

    /// Returns whether `Creators` is registered on `Nft`
    public fun has_domain<T>(nft: &UID): bool {
        df::exists_with_type<Marker<Creators<T>>, Creators<T>>(
            nft, utils::marker(),
        )
    }

    /// Borrows `Creators` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Creators` is not registered on the `Nft`
    public fun borrow_domain<T>(nft: &UID): &Creators<T> {
        assert_creators<T>(nft);
        df::borrow(nft, utils::marker<Creators<T>>())
    }

    /// Mutably borrows `Creators` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Creators` is not registered on the `Nft`
    public fun borrow_domain_mut<T>(nft: &mut UID): &mut Creators<T> {
        assert_creators<T>(nft);
        df::borrow_mut(nft, utils::marker<Creators<T>>())
    }

    /// Adds `Creators` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Creators` domain already exists
    public fun add_domain<T>(
        nft: &mut UID,
        domain: Creators<T>,
    ) {
        assert_no_creators<T>(nft);
        df::add(nft, utils::marker<Creators<T>>(), domain);
    }

    /// Remove `Creators` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Creators` domain doesnt exist
    public fun remove_domain<T>(nft: &mut UID): Creators<T> {
        assert_creators<T>(nft);
        df::remove(nft, utils::marker<Creators<T>>())
    }

    // === Assertions ===

    /// Asserts that address is a creator attributed in `Creators`
    ///
    /// #### Panics
    ///
    /// Panics if `Creators` is not defined or address is not an
    /// attributed creator.
    public fun assert_creator<T>(
        domain: &Creators<T>,
        who: &address
    ) {
        assert!(contains_creator(domain, who), EUndefinedAddress);
    }

    /// Asserts that `Creators` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Creators` is not registered
    public fun assert_creators<T>(nft: &UID) {
        assert!(has_domain<T>(nft), EUndefinedCreators);
    }

    /// Asserts that `Creators` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Creators` is registered
    public fun assert_no_creators<T>(nft: &UID) {
        assert!(!has_domain<T>(nft), EExistingCreators);
    }
}
