/// Module of Collection `Creators`
///
/// `Creators` tracks all collection creators.
module nft_protocol::creators {
    use sui::vec_set::{Self, VecSet};
    use sui::object::UID;
    use sui::dynamic_field as df;

    use ob_witness::marker::{Self, Marker};

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
    struct Creators has store {
        /// Creators that have the ability to mutate standard domains
        creators: VecSet<address>,
    }

    /// Creates an empty `Creators` object
    ///
    /// By not attributing any `Creators`, nobody will ever be able to modify
    /// `Collection` domains.
    public fun empty(): Creators {
        Creators {
            creators: vec_set::empty(),
        }
    }

    /// Creates an new `Creators` object
    ///
    /// By not attributing any `Creators`, nobody will ever be able to modify
    /// `Collection` domains.
    public fun new(creators: VecSet<address>): Creators {
        Creators {
            creators,
        }
    }

    // === Field Borrow Functions ===

    /// Returns whether `Creators` has no defined creators
    public fun is_empty(domain: &Creators): bool {
        vec_set::is_empty(&domain.creators)
    }

    /// Returns whether address is a defined creator
    public fun contains_creator(
        creators: &Creators,
        who: &address,
    ): bool {
        vec_set::contains(&creators.creators, who)
    }

    /// Returns the list of creators defined on the `Creators`
    public fun get_Creators(
        domain: &Creators,
    ): &VecSet<address> {
        &domain.creators
    }

    /// Borrows immutably the `Creators` field.
    //
    // TODO: Unsafe to arbitrarily add creator, should check that sender is
    // already a creator
    public fun add_creator(
        creators: &mut Creators,
        who: address,
    ) {
        vec_set::insert(&mut creators.creators, who);
    }

    /// Removes address from `Creators` field in object `T`
    //
    // TODO: Unsafe to arbitrarily add remove, should check that sender is
    // already a creator
    public fun remove_creator(
        creators: &mut Creators,
        who: address,
    ) {
        vec_set::remove(&mut creators.creators, &who);
    }

    // === Interoperability ===

    /// Returns whether `Creators` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<Creators>, Creators>(
            nft, marker::marker(),
        )
    }

    /// Borrows `Creators` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Creators` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &Creators {
        assert_Creators(nft);
        df::borrow(nft, marker::marker<Creators>())
    }

    /// Mutably borrows `Creators` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Creators` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut Creators {
        assert_Creators(nft);
        df::borrow_mut(nft, marker::marker<Creators>())
    }

    /// Adds `Creators` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Creators` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: Creators,
    ) {
        assert_no_Creators(nft);
        df::add(nft, marker::marker<Creators>(), domain);
    }

    /// Remove `Creators` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Creators` domain doesnt exist
    public fun remove_domain(nft: &mut UID): Creators {
        assert_Creators(nft);
        df::remove(nft, marker::marker<Creators>())
    }

    /// Delete a `Creators` object
    public fun delete(creators: Creators) {
        let Creators { creators: _ } = creators;
    }

    // === Assertions ===

    /// Asserts that address is a creator attributed in `Creators`
    ///
    /// #### Panics
    ///
    /// Panics if `Creators` is not defined or address is not an
    /// attributed creator.
    public fun assert_creator(
        domain: &Creators,
        who: &address
    ) {
        assert!(contains_creator(domain, who), EUndefinedAddress);
    }

    /// Asserts that `Creators` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Creators` is not registered
    public fun assert_Creators(nft: &UID) {
        assert!(has_domain(nft), EUndefinedCreators);
    }

    /// Asserts that `Creators` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Creators` is registered
    public fun assert_no_Creators(nft: &UID) {
        assert!(!has_domain(nft), EExistingCreators);
    }
}
