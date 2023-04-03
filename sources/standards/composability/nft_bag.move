/// Module of `NftBagDomain` which is shared across all composable domains
/// to store the actual NFT objects.
///
/// `NftBagDomain` allows easy checking on which NFTs are composed across
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

    /// `NftBagDomain` was not defined
    ///
    /// Call `container::add` to add `NftBagDomain`.
    const EUndefinedNftBag: u64 = 1;

    /// `NftBagDomain` already defined
    ///
    /// Call `container::borrow` to borrow domain.
    const EExistingNftBag: u64 = 2;

    /// `NftBagDomain` did not compose NFT with given ID
    ///
    /// Call `container::decompose` with an NFT ID that exists.
    const EUndefinedNft: u64 = 3;

    /// Tried to decompose NFT with invalid authority, only the same authority
    /// that was used to compose an NFT can be used to decompose it
    ///
    /// Call `container::decompose` with the correct authority.
    const EInvalidAuthority: u64 = 4;

    /// `NftBagDomain` object
    struct NftBagDomain<phantom T: key + store> has store {
        /// `NftBagDomain` ID
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

    /// Creates new `NftBagDomain`
    public fun new<T: key + store>(ctx: &mut TxContext): NftBagDomain<T> {
        NftBagDomain {
            id: object::new(ctx),
            authorities: vector::empty(),
            nfts: vec_map::empty(),
        }
    }

    /// Returns whether NFT with given ID is composed within provided
    /// `NftBagDomain`
    public fun has<T: key + store>(
        container: &NftBagDomain<T>,
        nft_id: ID,
    ): bool {
        dof::exists_(&container.id, nft_id)
    }

    /// Borrows `Nft` from `NftBagDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft` was not composed within the `NftBagDomain`.
    public fun borrow<T: key + store>(
        container: &NftBagDomain<T>,
        nft_id: ID,
    ): &T {
        assert_composed(container, nft_id);
        dof::borrow(&container.id, nft_id)
    }

    /// Mutably borrows `Nft` from `NftBagDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft` was not composed within the `NftBagDomain`.
    public fun borrow_mut<T: key + store>(
        container: &mut NftBagDomain<T>,
        nft_id: ID,
    ): &mut T {
        assert_composed(container, nft_id);
        dof::borrow_mut(&mut container.id, nft_id)
    }

    /// Borrows composed NFT with given ID from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBagDomain` is not registered or NFT is not composed.
    public fun borrow_nft<T: key + store>(nft: &UID, child_nft_id: ID): &T {
        let container = borrow_domain(nft);
        borrow(container, child_nft_id)
    }

    /// Mutably borrows composed NFT with given ID from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBagDomain` is not registered or NFT is not composed.
    public fun borrow_nft_mut<T: key + store>(
        nft: &mut UID,
        child_nft_id: ID,
    ): &T {
        let container = borrow_domain_mut(nft);
        borrow_mut(container, child_nft_id)
    }

    /// Get index of authority
    fun get_authority_idx<T: key + store>(
        authority_type: &TypeName,
        domain: &NftBagDomain<T>,
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
    fun get_or_insert_authority_idx<T: key + store>(
        authority_type: TypeName,
        domain: &mut NftBagDomain<T>,
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

    /// Composes child NFT into `NftBagDomain`
    public fun compose<T: key + store, Auth: drop>(
        _authority: Auth,
        domain: &mut NftBagDomain<T>,
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
    /// Panics if `NftBagDomain` is not registered on the parent `Nft`
    public fun compose_nft<T: key + store, Auth: drop>(
        authority: Auth,
        parent_nft: &mut UID,
        child_nft: T,
    ) {
        let domain = borrow_domain_mut(parent_nft);
        compose(authority, domain, child_nft);
    }

    /// Decomposes child NFT from `NftBagDomain`
    ///
    /// #### Panics
    ///
    /// Panics if child `Nft` does not exist.
    public fun decompose<T: key + store, Auth: drop>(
        _authority: Auth,
        domain: &mut NftBagDomain<T>,
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
    /// Panics if `NftBagDomain` is not registered on the parent `Nft`
    public fun decompose_nft<T: key + store, Auth: drop>(
        authority: Auth,
        parent_nft: &mut UID,
        child_nft_id: ID,
    ): T {
        let domain = borrow_domain_mut(parent_nft);
        decompose(authority, domain, child_nft_id)
    }

    /// Counts how many NFTs are registered under the given authority
    public fun count<T: key + store, Auth>(domain: &NftBagDomain<T>): u64 {
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

    /// Returns whether `NftBagDomain` is registered on `Nft`
    public fun has_domain<T: key + store>(nft: &UID): bool {
        df::exists_with_type<Marker<NftBagDomain<T>>, NftBagDomain<T>>(
            nft, utils::marker(),
        )
    }

    /// Borrows `NftBagDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBagDomain` is not registered on the `Nft`
    public fun borrow_domain<T: key + store>(nft: &UID): &NftBagDomain<T> {
        assert_nft_bag<T>(nft);
        df::borrow(nft, utils::marker<NftBagDomain<T>>())
    }

    /// Mutably borrows `NftBagDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBagDomain` is not registered on the `Nft`
    public fun borrow_domain_mut<T: key + store>(
        nft: &mut UID,
    ): &mut NftBagDomain<T> {
        assert_nft_bag<T>(nft);
        df::borrow_mut(nft, utils::marker<NftBagDomain<T>>())
    }

    /// Adds `NftBagDomain` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBagDomain` domain already exists
    public fun add_domain<T: key + store>(
        nft: &mut UID,
        domain: NftBagDomain<T>,
    ) {
        assert_no_nft_bag<T>(nft);
        df::add(nft, utils::marker<NftBagDomain<T>>(), domain);
    }

    /// Remove `NftBagDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBagDomain` domain doesnt exist
    public fun remove_domain<T: key + store>(nft: &mut UID): NftBagDomain<T> {
        assert_nft_bag<T>(nft);
        df::remove(nft, utils::marker<NftBagDomain<T>>())
    }

    // === Assertions ===

    /// Asserts that `NftBagDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBagDomain` is not registered
    public fun assert_nft_bag<T: key + store>(nft: &UID) {
        assert!(has_domain<T>(nft), EUndefinedNftBag);
    }

    /// Asserts that `NftBagDomain` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBagDomain` is registered
    public fun assert_no_nft_bag<T: key + store>(nft: &UID) {
        assert!(!has_domain<T>(nft), EExistingNftBag);
    }

    /// Assert that NFT with given ID is composed within the `NftBagDomain`
    ///
    /// #### Panics
    ///
    /// Panics if NFT is not composed.
    public fun assert_composed<T: key + store>(
        container: &NftBagDomain<T>,
        nft_id: ID,
    ) {
        assert!(has(container, nft_id), EUndefinedNft)
    }
}
