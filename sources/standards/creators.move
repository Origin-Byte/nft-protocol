/// Module of Collection `CreatorsDomain`
///
/// `CreatorsDomain` tracks all collection creators, used to authenticate
/// mutable operations on other OriginByte standard domains.
module nft_protocol::creators {
    use nft_protocol::collection::{Self, Collection, MintCap};
    use nft_protocol::err;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set::{Self, VecSet};

    /// `CreatorsDomain` tracks collection creators
    ///
    /// ##### Usage
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
    ///     struct SUIMARINES has drop {}
    ///     struct Witness has drop {}
    ///
    ///     struct DisplayDomain {
    ///         id: UID,
    ///         name: String,
    ///     } has key, store
    ///
    ///     public fun set_name<C>(
    ///         collection: &mut Collection<C>,
    ///         name: String,
    ///         ctx: &mut TxContext,
    ///     ) {
    ///         creators::assert_collection_has_creator(
    ///             collection, tx_context::sender(ctx)
    ///         );
    ///
    ///         let domain: &mut DisplayDomain =
    ///             collection::borrow_domain_mut(Witness {}, collection);
    ///
    ///         domain.name = name;
    ///     }
    /// }
    struct CreatorsDomain has copy, drop, store {
        /// Increments every time we mutate the creators map.
        ///
        /// Enables multisig to invalidate itself if the attribution domain
        /// changed.
        version: u64,
        /// Frozen `CreatorsDomain` will no longer authenticate creators
        is_frozen: bool,
        /// Creators that have the ability to mutate standard domains
        creators: VecSet<address>,
    }

    /// Creates an empty `CreatorsDomain` object
    ///
    /// By not attributing any `Creators`, nobody will ever be able to modify
    /// `Collection` domains.
    public fun new_empty(): CreatorsDomain {
        from_creators(vec_set::empty())
    }

    /// Creates a `CreatorsDomain` object with only one creator
    ///
    /// Only the single `Creator` will ever be able to modify `Collection`
    /// domains.
    public fun from_address(who: address): CreatorsDomain {
        let creators = vec_set::empty();
        vec_set::insert(&mut creators, who);

        from_creators(creators)
    }

    /// Creates a `CreatorsDomain` with multiple creators
    ///
    /// Each attributed creator will be able to modify `Collection` domains.
    public fun from_creators(creators: VecSet<address>): CreatorsDomain {
        CreatorsDomain { is_frozen: false, creators, version: 0 }
    }

    // === Getters ===

    /// Returns whether `CreatorsDomain` has no defined creators
    public fun is_empty(domain: &CreatorsDomain): bool {
        vec_set::is_empty(&domain.creators)
    }

    /// Returns whether `CreatorsDomain` is frozen
    public fun is_frozen(domain: &CreatorsDomain): bool {
        domain.is_frozen
    }

    /// Returns the version of the `CreatorsDomain` which increments with every
    /// mutation.
    public fun version(attributions: &CreatorsDomain): u64 {
        attributions.version
    }

    /// Returns whether address is a defined creator
    public fun contains_creator(domain: &CreatorsDomain, who: &address): bool {
        vec_set::contains(&domain.creators, who)
    }

    /// Returns the list of creators defined on the `CreatorsDomain`
    public fun borrow_creators(domain: &CreatorsDomain): &VecSet<address> {
        &domain.creators
    }

    // === Mutability ===

    /// Makes `Collection` domains immutable
    ///
    /// Will cause `assert_collection_has_creator` and `assert_is_creator` to
    /// always fail, thus making all standard domains immutable.
    ///
    /// This is irreversible, use with caution.
    public fun freeze_domains(domain: &mut CreatorsDomain,) {
        // Only creators can obtain `&mut CreatorsDomain`
        domain.is_frozen = true
    }

    // === Utils ===

    /// Asserts that address is a `Creator` attributed in `CreatorsDomain`
    ///
    /// ##### Panics
    ///
    /// Panics if address is not an attribtued creator.
    public fun assert_is_creator(domain: &CreatorsDomain, who: &address) {
        assert!(contains_creator(domain, who), err::address_not_attributed());
    }

    /// Asserts that address is a `Creator` attributed in `CreatorsDomain` of
    /// the `Collection`
    ///
    /// ##### Panics
    ///
    /// Panics if `CreatorsDomain` is not defined or address is not an
    /// attributed creator.
    public fun assert_collection_has_creator<C>(
        collection: &Collection<C>,
        who: &address
    ) {
        assert_is_creator(creators_domain(collection), who);
    }

    // ====== Interoperability ===

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Borrows `CreatorsDomain` from `Collection`
    ///
    /// ##### Panics
    ///
    /// Panics if `CreatorsDomain` is not registered on `Collection`.
    public fun creators_domain<C>(
        collection: &Collection<C>,
    ): &CreatorsDomain {
        collection::borrow_domain(collection)
    }

    /// Mutably borrows `CreatorsDomain` from `Collection`
    ///
    /// `CreatorsDomain` has secured endpoints therefore it is safe to expose
    /// a mutable reference to it.
    ///
    /// ##### Panics
    ///
    /// Panics if `CreatorsDomain` is not registered on `Collection`.
    public fun creators_domain_mut<C>(
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ): &mut CreatorsDomain {
        assert_collection_has_creator(
            collection, &tx_context::sender(ctx)
        );

        collection::borrow_domain_mut(Witness {}, collection)
    }

    /// Adds `CreatorsDomain` to `Collection`
    ///
    /// ##### Panics
    ///
    /// Panics if `MintCap` does not match `Collection` or `CreatorsDomain`
    /// already exists.
    public fun add_creators_domain<C>(
        collection: &mut Collection<C>,
        mint_cap: &mut MintCap<C>,
        domain: CreatorsDomain,
    ) {
        collection::add_domain(collection, mint_cap, domain);
    }
}
