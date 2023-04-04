/// Module of `CollectionID` used to associate a collection ID with NFT
module nft_protocol::collection_id {
    use sui::object::{UID, ID};
    use sui::dynamic_field as df;

    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::utils::{Self, Marker};

    /// `CollectionIdDomain` was not defined
    ///
    /// Call `collection_id::add_domain` to add `CollectionIdDomain`.
    const EUndefinedCollectionId: u64 = 1;

    /// `CollectionIdDomain` already defined
    ///
    /// Call `collection_id::borrow_domain` to borrow domain.
    const EExistingCollectionId: u64 = 2;

    struct CollectionIdDomain has store {
        collection_id: ID,
    }

    /// Gets name of `CollectionIdDomain`
    public fun id(domain: &CollectionIdDomain): &ID {
        &domain.collection_id
    }

    /// Creates a new `CollectionIdDomain` with name
    public fun from_mint_cap<T>(mint_cap: &MintCap<T>): CollectionIdDomain {
        CollectionIdDomain { collection_id: mint_cap::collection_id(mint_cap) }
    }

    // === Interoperability ===

    /// Returns whether `CollectionIdDomain` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<CollectionIdDomain>, CollectionIdDomain>(
            nft, utils::marker(),
        )
    }

    /// Borrows `CollectionIdDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `CollectionIdDomain` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &CollectionIdDomain {
        assert_collection_id(nft);
        df::borrow(nft, utils::marker<CollectionIdDomain>())
    }

    /// Mutably borrows `CollectionIdDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `CollectionIdDomain` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut CollectionIdDomain {
        assert_collection_id(nft);
        df::borrow_mut(nft, utils::marker<CollectionIdDomain>())
    }

    /// Adds `CollectionIdDomain` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `CollectionIdDomain` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: CollectionIdDomain,
    ) {
        assert_no_collection_id(nft);
        df::add(nft, utils::marker<CollectionIdDomain>(), domain);
    }

    /// Remove `CollectionIdDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `CollectionIdDomain` domain doesnt exist
    public fun remove_domain(nft: &mut UID): CollectionIdDomain {
        assert_collection_id(nft);
        df::remove(nft, utils::marker<CollectionIdDomain>())
    }

    // === Assertions ===

    /// Asserts that `CollectionIdDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `CollectionIdDomain` is not registered
    public fun assert_collection_id(nft: &UID) {
        assert!(has_domain(nft), EUndefinedCollectionId);
    }

    /// Asserts that `CollectionIdDomain` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `CollectionIdDomain` is registered
    public fun assert_no_collection_id(nft: &UID) {
        assert!(!has_domain(nft), EExistingCollectionId);
    }
}
