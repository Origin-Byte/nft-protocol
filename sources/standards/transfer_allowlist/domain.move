/// `TransferAllowlistDomain` tracks allowlist objects that can be used for
/// transferring a collection's NFT.
///
/// #### Important
/// This domain is used for discovery by off-chain applications.
/// It is not authoritative and it's the responsibility of the collection
/// creator to keep it up to date.
module nft_protocol::transfer_allowlist_domain {
    use sui::object::{Self, UID, ID};
    use sui::vec_set::{Self, VecSet};
    use sui::package::Publisher;
    use sui::dynamic_field as df;

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::transfer_allowlist::Allowlist;
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::witness::{Self, Witness as DelegatedWitness};

    /// `TransferAllowlistDomain` was not registered
    ///
    /// Call `transfer_allowlist_domain::add_domain` to add
    /// `TransferAllowlistDomain`.
    const EUndefinedTransferAllowlist: u64 = 1;

    /// `TransferAllowlistDomain` already registered
    ///
    /// Call `transfer_allowlist_domain::borrow_domain` to borrow
    /// `TransferAllowlistDomain`.
    const EExistingTransferAllowlist: u64 = 1;

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
        witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        al: &mut Allowlist,
    ) {
        let domain = borrow_domain_mut(
            collection::borrow_uid_mut(witness, collection),
        );
        vec_set::insert(&mut domain.allowlists, object::id(al));
    }

    /// Removes existing allowlist from `TransferAllowlistDomain`.
    public fun remove_id<T>(
        witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        id: ID,
    ) {
        let domain = borrow_domain_mut(
            collection::borrow_uid_mut(witness, collection),
        );
        vec_set::remove(&mut domain.allowlists, &id);
    }

    /// Like [`add_id`] but as an endpoint
    //
    // TODO: Should deprecate, use `add_id` directly instead
    public entry fun add_id_with_cap<T>(
        collection_pub: &Publisher,
        collection: &mut Collection<T>,
        al: &mut Allowlist,
    ) {
        add_id(witness::from_publisher<T>(collection_pub), collection, al)
    }

    /// Like [`remove_id`] but as an endpoint
    //
    // TODO: Should deprecate, use `remove_id` directly instead
    public entry fun remove_id_with_cap<T>(
        collection_pub: &Publisher,
        collection: &mut Collection<T>,
        id: ID,
    ) {
        remove_id(witness::from_publisher<T>(collection_pub), collection, id)
    }

    // === Getters ===

    /// Returns the list of IDs defined on the `TransferAllowlistDomain`
    public fun borrow_allowlists(
        domain: &TransferAllowlistDomain,
    ): &VecSet<ID> {
        &domain.allowlists
    }

    // === Interoperability ===

    /// Returns whether `TransferAllowlistDomain` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<
            Marker<TransferAllowlistDomain>,
            TransferAllowlistDomain,
        >(
            nft, utils::marker(),
        )
    }

    /// Borrows `TransferAllowlistDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `TransferAllowlistDomain` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &TransferAllowlistDomain {
        assert_transfer_allowlist(nft);
        df::borrow(nft, utils::marker<TransferAllowlistDomain>())
    }

    /// Mutably borrows `TransferAllowlistDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `TransferAllowlistDomain` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut TransferAllowlistDomain {
        assert_transfer_allowlist(nft);
        df::borrow_mut(nft, utils::marker<TransferAllowlistDomain>())
    }

    /// Adds `TransferAllowlistDomain` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `TransferAllowlistDomain` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: TransferAllowlistDomain,
    ) {
        assert_no_transfer_allowlist(nft);
        df::add(nft, utils::marker<TransferAllowlistDomain>(), domain);
    }

    /// Remove `TransferAllowlistDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `TransferAllowlistDomain` domain doesnt exist
    public fun remove_domain(nft: &mut UID): TransferAllowlistDomain {
        assert_transfer_allowlist(nft);
        df::remove(nft, utils::marker<TransferAllowlistDomain>())
    }

    // === Assertions ===

    /// Asserts that `TransferAllowlistDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `TransferAllowlistDomain` is not registered
    public fun assert_transfer_allowlist(nft: &UID) {
        assert!(has_domain(nft), EUndefinedTransferAllowlist);
    }

    /// Asserts that `TransferAllowlistDomain` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `TransferAllowlistDomain` is registered
    public fun assert_no_transfer_allowlist(nft: &UID) {
        assert!(!has_domain(nft), EExistingTransferAllowlist);
    }
}
