/// `TransferAllowlistDomain` tracks allowlist objects which can be used for
/// transferring a collection's NFT.
///
/// #### Important
/// This domain is used for discovery by off-chain applications.
/// It is not authoritative and it's the responsibility of the collection
/// creator to keep it up to date.
module nft_protocol::transfer_allowlist_domain {
    use sui::vec_set::{Self, VecSet};
    use sui::object::{Self, ID};

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::witness::Witness as DelegatedWitness;
    use nft_protocol::transfer_allowlist::{Allowlist, CollectionControlCap};

    /// `TransferAllowlistDomain` was not defined on `Collection`
    ///
    /// Call `collection::add_domain` to add `TransferAllowlistDomain`.
    const EUNDEFINED_TRANSFER_ALLOWLIST_DOMAIN: u64 = 1;

    /// `TransferAllowlistDomain` tracks allowlists which authorize transfer
    /// of NFTs.
    ///
    /// This information is useful for off chain applications - discovery.
    struct TransferAllowlistDomain has store {
        allowlists: VecSet<ID>,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates an empty `TransferAllowlistDomain` object
    public fun empty(): TransferAllowlistDomain {
        TransferAllowlistDomain {
            allowlists: vec_set::empty(),
        }
    }

    /// Creates a `TransferAllowlistDomain` object with a single allowlist
    public fun from_id(
        id: ID,
    ): TransferAllowlistDomain {
        TransferAllowlistDomain {
            allowlists: vec_set::singleton(id),
        }
    }

    /// Adds new allowlist to `TransferAllowlistDomain`.
    /// Now, off chain clients can use this information to discover the ID
    /// and use it in relevant txs.
    public fun add_id<T>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        al: &mut Allowlist,
    ) {
        let domain = transfer_allowlist_domain_mut(collection);
        vec_set::insert(&mut domain.allowlists, object::id(al));
    }

    /// Removes existing allowlist from `TransferAllowlistDomain`.
    public fun remove_id<T>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        id: ID,
    ) {
        let domain = transfer_allowlist_domain_mut(collection);
        vec_set::remove(&mut domain.allowlists, &id);
    }

    /// Like [`add_id`] but as an endpoint
    public entry fun add_id_with_cap<T>(
        _cap: &CollectionControlCap<T>,
        collection: &mut Collection<T>,
        al: &mut Allowlist,
    ) {
        let domain = transfer_allowlist_domain_mut(collection);
        vec_set::insert(&mut domain.allowlists, object::id(al));
    }

    /// Like [`remove_id`] but as an endpoint
    public entry fun remove_id_with_cap<T>(
        _cap: &CollectionControlCap<T>,
        collection: &mut Collection<T>,
        id: ID,
    ) {
        let domain = transfer_allowlist_domain_mut(collection);
        vec_set::remove(&mut domain.allowlists, &id);
    }

    // === Getters ===

    /// Returns the list of IDs defined on the `TransferAllowlistDomain`
    public fun borrow_allowlists(
        domain: &TransferAllowlistDomain,
    ): &VecSet<ID> {
        &domain.allowlists
    }

    // === Interoperability ===

    /// Borrows `TransferAllowlistDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `TransferAllowlistDomain` is not registered on `Collection`.
    public fun transfer_allowlist_domain<T>(
        collection: &Collection<T>,
    ): &TransferAllowlistDomain {
        assert_domain(collection);
        collection::borrow_domain(collection)
    }

    /// Mutably borrows `TransferAllowlistDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `TransferAllowlistDomain` is not registered on `Collection`.
    fun transfer_allowlist_domain_mut<T>(
        collection: &mut Collection<T>,
    ): &mut TransferAllowlistDomain {
        assert_domain(collection);
        collection::borrow_domain_mut(Witness {}, collection)
    }

    // === Assertions ===

    /// Asserts that `TransferAllowlistDomain` is defined on the `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `TransferAllowlistDomain` is not defined on the `Collection`.
    public fun assert_domain<T>(collection: &Collection<T>) {
        assert!(
            collection::has_domain<T, TransferAllowlistDomain>(collection),
            EUNDEFINED_TRANSFER_ALLOWLIST_DOMAIN,
        )
    }
}
