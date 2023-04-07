/// Module of `NftBag` which is shared across all composable domains
/// to store the actual NFT objects.
///
/// `NftBag` allows easy checking on which NFTs are composed across
/// different composability schemes.
module nft_protocol::nft_bag {
    use std::vector;
    use std::option::{Self, Option};
    use std::type_name::{Self, TypeName};

    use sui::dynamic_object_field as dof;
    use sui::tx_context::TxContext;
    use sui::object::{Self, ID , UID};
    use sui::vec_map::{Self, VecMap};
    use sui::dynamic_field as df;

    use nft_protocol::utils::{Self, Marker};

    /// `NftBag` was not defined
    ///
    /// Call `container::add` to add `NftBag`.
    const EUndefinedNftBag: u64 = 1;

    /// `NftBag` already defined
    ///
    /// Call `container::borrow` to borrow domain.
    const EExistingNftBag: u64 = 2;

    /// `NftBag` did not compose NFT with given ID
    ///
    /// Call `container::decompose` with an NFT ID that exists.
    const EUndefinedNft: u64 = 3;

    /// Tried to decompose NFT with invalid authority, only the same authority
    /// that was used to compose an NFT can be used to decompose it
    ///
    /// Call `container::decompose` with the correct authority.
    const EInvalidAuthority: u64 = 4;

    /// `NftBag` object
    struct NftBag has store {
        /// `NftBag` ID
        id: UID,
        /// Authorities which are allowed to withdraw NFTs
        authorities: vector<TypeName>,
        /// NFTs that are currently composed and the index of the authority
        /// permitted to decompose it
        ///
        /// Avoids storage costs of holding `TypeName` strings for each `Nft`.
        nfts: VecMap<ID, u64>,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates new `NftBag`
    public fun new(ctx: &mut TxContext): NftBag {
        NftBag {
            id: object::new(ctx),
            authorities: vector::empty(),
            nfts: vec_map::empty(),
        }
    }

    /// Returns whether NFT with given ID is composed within provided
    /// `NftBag`
    public fun has(
        container: &NftBag,
        nft_id: ID,
    ): bool {
        dof::exists_(&container.id, nft_id)
    }

    /// Borrows `Nft` from `NftBag`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft` was not composed within the `NftBag`.
    public fun borrow<T: key + store>(
        container: &NftBag,
        nft_id: ID,
    ): &T {
        assert_composed(container, nft_id);
        dof::borrow(&container.id, nft_id)
    }

    /// Mutably borrows `Nft` from `NftBag`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft` was not composed within the `NftBag`.
    public fun borrow_mut<T: key + store>(
        container: &mut NftBag,
        nft_id: ID,
    ): &mut T {
        assert_composed(container, nft_id);
        dof::borrow_mut(&mut container.id, nft_id)
    }

    /// Borrows composed NFT with given ID from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` is not registered or NFT is not composed.
    public fun borrow_nft<T: key + store>(nft: &UID, child_nft_id: ID): &T {
        let container = borrow_domain(nft);
        borrow(container, child_nft_id)
    }

    /// Mutably borrows composed NFT with given ID from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` is not registered or NFT is not composed.
    public fun borrow_nft_mut<T: key + store>(
        nft: &mut UID,
        child_nft_id: ID,
    ): &T {
        let container = borrow_domain_mut(nft);
        borrow_mut(container, child_nft_id)
    }

    /// Get index of authority
    fun get_authority_idx(
        authority_type: &TypeName,
        domain: &NftBag,
    ): Option<u64> {
        let (has_authority, idx_opt) =
            vector::index_of(&domain.authorities, authority_type);

        if (has_authority) {
            option::some(idx_opt)
        } else {
            option::none()
        }
    }

    /// Get index of authority or inserts a new one if it did not already exist
    fun get_or_insert_authority_idx(
        authority_type: TypeName,
        domain: &mut NftBag,
    ): u64 {
        let idx_opt = get_authority_idx(&authority_type, domain);

        if (option::is_some(&idx_opt)) {
            option::destroy_some(idx_opt)
        } else {
            let idx = vector::length(&domain.authorities);
            vector::push_back(&mut domain.authorities, authority_type);
            idx
        }
    }

    /// Composes child NFT into `NftBag`
    public fun compose<T: key + store, Auth: drop>(
        _authority: Auth,
        domain: &mut NftBag,
        child_nft: T,
    ) {
        let authority_type = type_name::get<Auth>();
        let idx = get_or_insert_authority_idx(authority_type, domain);

        let nft_id = object::id(&child_nft);
        vec_map::insert(&mut domain.nfts, nft_id, idx);
        dof::add(&mut domain.id, nft_id, child_nft);
    }

    /// Composes child NFT into parent NFT
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` is not registered on the parent `Nft`
    public fun compose_nft<T: key + store, Auth: drop>(
        authority: Auth,
        parent_nft: &mut UID,
        child_nft: T,
    ) {
        let domain = borrow_domain_mut(parent_nft);
        compose(authority, domain, child_nft);
    }

    /// Decomposes child NFT from `NftBag`
    ///
    /// #### Panics
    ///
    /// Panics if child `Nft` does not exist.
    public fun decompose<T: key + store, Auth: drop>(
        _authority: Auth,
        domain: &mut NftBag,
        child_nft_id: ID,
    ): T {
        // Identify index of authority that this `Nft` should be composed using
        // let authority_type = type_name::get<Auth>();
        let idx_opt =
            vec_map::get_idx_opt(&domain.nfts, &child_nft_id);
        assert!(option::is_some(&idx_opt), EUndefinedNft);
        let idx = option::destroy_some(idx_opt);

        let authority = vector::borrow(&domain.authorities, idx);
        let authority_type = type_name::get<Auth>();
        assert!(authority == &authority_type, EInvalidAuthority);

        dof::remove(&mut domain.id, child_nft_id)
    }

    /// Decomposes child NFT from parent NFT
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` is not registered on the parent `Nft`
    public fun decompose_nft<T: key + store, Auth: drop>(
        authority: Auth,
        parent_nft: &mut UID,
        child_nft_id: ID,
    ): T {
        let domain = borrow_domain_mut(parent_nft);
        decompose(authority, domain, child_nft_id)
    }

    /// Counts how many NFTs are registered under the given authority
    public fun count<T: key + store, Auth>(domain: &NftBag): u64 {
        let authority_type = type_name::get<Auth>();

        let authority_idx = get_authority_idx(&authority_type, domain);
        if (option::is_none(&authority_idx)) {
            return 0
        };

        let count = 0;
        let authority_idx = option::destroy_some(authority_idx);

        let idx = 0;
        let size = vec_map::size(&domain.nfts);
        while (idx < size) {
            let (_, nft_authority_idx) =
                vec_map::get_entry_by_idx(&domain.nfts, idx);

            if (nft_authority_idx == &authority_idx) {
                count = count + 1;
            };

            idx = idx + 1;
        };

        count
    }

    // === Interoperability ===

    /// Returns whether `NftBag` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<NftBag>, NftBag>(
            nft, utils::marker(),
        )
    }

    /// Borrows `NftBag` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &NftBag {
        assert_nft_bag(nft);
        df::borrow(nft, utils::marker<NftBag>())
    }

    /// Mutably borrows `NftBag` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` is not registered on the `Nft`
    public fun borrow_domain_mut(
        nft: &mut UID,
    ): &mut NftBag {
        assert_nft_bag(nft);
        df::borrow_mut(nft, utils::marker<NftBag>())
    }

    /// Adds `NftBag` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: NftBag,
    ) {
        assert_no_nft_bag(nft);
        df::add(nft, utils::marker<NftBag>(), domain);
    }

    /// Remove `NftBag` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` domain doesnt exist
    public fun remove_domain(nft: &mut UID): NftBag {
        assert_nft_bag(nft);
        df::remove(nft, utils::marker<NftBag>())
    }

    // === Assertions ===

    /// Asserts that `NftBag` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` is not registered
    public fun assert_nft_bag(nft: &UID) {
        assert!(has_domain(nft), EUndefinedNftBag);
    }

    /// Asserts that `NftBag` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` is registered
    public fun assert_no_nft_bag(nft: &UID) {
        assert!(!has_domain(nft), EExistingNftBag);
    }

    /// Assert that NFT with given ID is composed within the `NftBag`
    ///
    /// #### Panics
    ///
    /// Panics if NFT is not composed.
    public fun assert_composed(
        container: &NftBag,
        nft_id: ID,
    ) {
        assert!(has(container, nft_id), EUndefinedNft)
    }
}
