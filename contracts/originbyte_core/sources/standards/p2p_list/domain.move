/// `P2PListDomain` tracks allowlist objects that can be used for
/// transferring a collection's NFT.
///
/// #### Important
/// This domain is used for discovery by off-chain applications.
/// It is not authoritative and it's the responsibility of the collection
/// creator to keep it up to date.
module nft_protocol::p2p_list_domain {
    use sui::object::{Self, UID, ID};
    use sui::vec_set::{Self, VecSet};
    use sui::dynamic_field as df;

    use nft_protocol::collection::{Self, Collection};
    use ob_witness::marker::{Self, Marker};
    use ob_witness::witness::Witness as DelegatedWitness;

    use ob_authlist::authlist::Authlist;

    /// `P2PListDomain` was not registered
    ///
    /// Call `transfer_allowlist_domain::add_domain` to add
    /// `P2PListDomain`.
    const EUndefinedTransferAllowlist: u64 = 1;

    /// `P2PListDomain` already registered
    ///
    /// Call `transfer_allowlist_domain::borrow_domain` to borrow
    /// `P2PListDomain`.
    const EExistingTransferAllowlist: u64 = 1;

    /// `P2PListDomain` tracks allowlists which authorize transfer
    /// of NFTs.
    ///
    /// This information is useful for off chain applications - discovery.
    struct P2PListDomain has store {
        lists: VecSet<ID>,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates an empty `P2PListDomain` object
    public fun empty(): P2PListDomain {
        P2PListDomain {
            lists: vec_set::empty(),
        }
    }

    /// Creates a `P2PListDomain` object with a single allowlist
    public fun from_id(
        id: ID,
    ): P2PListDomain {
        P2PListDomain {
            lists: vec_set::singleton(id),
        }
    }

    /// Adds new allowlist to `P2PListDomain`.
    /// Now, off chain clients can use this information to discover the ID
    /// and use it in relevant txs.
    public fun add_id<T>(
        witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        al: &Authlist,
    ) {
        let domain = borrow_domain_mut(
            collection::borrow_uid_mut(witness, collection),
        );
        vec_set::insert(&mut domain.lists, object::id(al));
    }

    /// Removes existing allowlist from `P2PListDomain`.
    public fun remove_id<T>(
        witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        id: ID,
    ) {
        let domain = borrow_domain_mut(
            collection::borrow_uid_mut(witness, collection),
        );
        vec_set::remove(&mut domain.lists, &id);
    }

    // === Getters ===

    /// Returns the list of IDs defined on the `P2PListDomain`
    public fun borrow_allowlists(
        domain: &P2PListDomain,
    ): &VecSet<ID> {
        &domain.lists
    }

    // === Interoperability ===

    /// Returns whether `P2PListDomain` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<
            Marker<P2PListDomain>,
            P2PListDomain,
        >(
            nft, marker::marker(),
        )
    }

    /// Borrows `P2PListDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `P2PListDomain` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &P2PListDomain {
        assert_transfer_allowlist(nft);
        df::borrow(nft, marker::marker<P2PListDomain>())
    }

    /// Mutably borrows `P2PListDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `P2PListDomain` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut P2PListDomain {
        assert_transfer_allowlist(nft);
        df::borrow_mut(nft, marker::marker<P2PListDomain>())
    }

    /// Adds `P2PListDomain` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `P2PListDomain` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: P2PListDomain,
    ) {
        assert_no_transfer_allowlist(nft);
        df::add(nft, marker::marker<P2PListDomain>(), domain);
    }

    /// Remove `P2PListDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `P2PListDomain` domain doesnt exist
    public fun remove_domain(nft: &mut UID): P2PListDomain {
        assert_transfer_allowlist(nft);
        df::remove(nft, marker::marker<P2PListDomain>())
    }

    /// Delete a `P2PListDomain` object
    public fun delete(allowlists: P2PListDomain) {
        let P2PListDomain { lists: _ } = allowlists;
    }

    // === Assertions ===

    /// Asserts that `P2PListDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `P2PListDomain` is not registered
    public fun assert_transfer_allowlist(nft: &UID) {
        assert!(has_domain(nft), EUndefinedTransferAllowlist);
    }

    /// Asserts that `P2PListDomain` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `P2PListDomain` is registered
    public fun assert_no_transfer_allowlist(nft: &UID) {
        assert!(!has_domain(nft), EExistingTransferAllowlist);
    }
}
