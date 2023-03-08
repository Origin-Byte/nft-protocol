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

    use nft_protocol::nft::{Self, Nft};

    /// `NftBagDomain` was not defined
    ///
    /// Call `container::add` to add `NftBagDomain`.
    const EUNDEFINED_DOMAIN: u64 = 1;

    /// `NftBagDomain` already defined
    ///
    /// Call `container::borrow` to borrow domain.
    const EEXISTING_DOMAIN: u64 = 2;

    /// `NftBagDomain` did not compose NFT with given ID
    ///
    /// Call `container::decompose` with an NFT ID that exists.
    const EUNDEFINED_NFT: u64 = 3;

    /// Tried to decompose NFT with invalid authority, only the same authority
    /// that was used to compose an NFT can be used to decompose it
    ///
    /// Call `container::decompose` with the correct authority.
    const EINVALID_AUTHORITY: u64 = 4;

    /// `NftBagDomain` object
    struct NftBagDomain has store {
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
    public fun new(ctx: &mut TxContext): NftBagDomain {
        NftBagDomain {
            id: object::new(ctx),
            authorities: vector::empty(),
            nfts: vec_map::empty(),
        }
    }

    /// Returns whether NFT with given ID is composed within provided
    /// `NftBagDomain`
    public fun has(container: &NftBagDomain, nft_id: ID): bool {
        dof::exists_(&container.id, nft_id)
    }

    /// Borrows `Nft` from `NftBagDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft` was not composed within the `NftBagDomain`.
    public fun borrow<C>(container: &NftBagDomain, nft_id: ID): &Nft<C> {
        assert_composed(container, nft_id);
        dof::borrow(&container.id, nft_id)
    }

    /// Mutably borrows `Nft` from `NftBagDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft` was not composed within the `NftBagDomain`.
    public fun borrow_mut<C>(
        container: &mut NftBagDomain,
        nft_id: ID,
    ): &mut Nft<C> {
        assert_composed(container, nft_id);
        dof::borrow_mut(&mut container.id, nft_id)
    }

    // === Interoperability ===

    /// Returns whether `NftBagDomain` is registered on `Nft`
    public fun has_domain<C>(nft: &Nft<C>): bool {
        nft::has_domain<C, NftBagDomain>(nft)
    }

    /// Register `NftBagDomain` on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBagDomain` is already registered on the `Nft`.
    public fun add_domain<C, W: drop>(
        witness: &W,
        nft: &mut Nft<C>,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(witness, nft, new(ctx))
    }

    /// Borrows `NftBagDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBagDomain` is not registered on the `Nft`.
    public fun borrow_domain<C>(nft: &Nft<C>): &NftBagDomain {
        assert_container(nft);
        nft::borrow_domain<C, NftBagDomain>(nft)
    }

    /// Mutably borrows `NftBagDomain` from `Nft`
    ///
    /// `NftBagDomain` is a safe to expose a mutable reference to.
    ///
    /// #### Panics
    ///
    /// Panics if `NftBagDomain` is not registered on the `Nft`.
    public fun borrow_domain_mut<C>(nft: &mut Nft<C>): &mut NftBagDomain {
        assert_container(nft);
        nft::borrow_domain_mut(Witness {}, nft)
    }

    /// Borrows composed NFT with given ID from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBagDomain` is not registered or NFT is not composed.
    public fun borrow_nft<C>(nft: &Nft<C>, nft_id: ID): &Nft<C> {
        let container = borrow_domain(nft);
        borrow(container, nft_id)
    }

    /// Mutably borrows composed NFT with given ID from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBagDomain` is not registered or NFT is not composed.
    public fun borrow_nft_mut<C>(nft: &mut Nft<C>, nft_id: ID): &Nft<C> {
        let container = borrow_domain_mut(nft);
        borrow_mut(container, nft_id)
    }

    /// Get index of authority
    fun get_authority_idx(
        authority_type: &TypeName,
        domain: &NftBagDomain,
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
        domain: &mut NftBagDomain,
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
    public fun compose<C, Auth: drop>(
        _authority: Auth,
        domain: &mut NftBagDomain,
        child_nft: Nft<C>,
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
    public fun compose_nft<C, Auth: drop>(
        authority: Auth,
        parent_nft: &mut Nft<C>,
        child_nft: Nft<C>,
    ) {
        let domain = borrow_domain_mut(parent_nft);
        compose(authority, domain, child_nft);
    }

    /// Decomposes child NFT from `NftBagDomain`
    ///
    /// #### Panics
    ///
    /// Panics if child `Nft` does not exist.
    public fun decompose<C, Auth: drop>(
        _authority: Auth,
        domain: &mut NftBagDomain,
        child_nft_id: ID,
    ): Nft<C> {
        // Identify index of authority that this `Nft` should be composed using
        // let authority_type = type_name::get<Auth>();
        let idx_opt =
            vec_map::get_idx_opt(&domain.nfts, &child_nft_id);
        assert!(option::is_some(&idx_opt), EUNDEFINED_NFT);
        let idx = option::destroy_some(idx_opt);

        let authority = vector::borrow(&domain.authorities, idx);
        let authority_type = type_name::get<Auth>();
        assert!(authority == &authority_type, EINVALID_AUTHORITY);

        dof::remove(&mut domain.id, child_nft_id)
    }

    /// Decomposes child NFT from parent NFT
    ///
    /// #### Panics
    ///
    /// Panics if `NftBagDomain` is not registered on the parent `Nft`
    public fun decompose_nft<C, Auth: drop>(
        authority: Auth,
        parent_nft: &mut Nft<C>,
        child_nft_id: ID,
    ): Nft<C> {
        let domain = borrow_domain_mut(parent_nft);
        decompose(authority, domain, child_nft_id)
    }

    /// Counts how many NFTs are registered under the given authority
    public fun count<Auth>(domain: &NftBagDomain): u64 {
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

    // === Assertions ===

    /// Asserts that `NftBagDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBagDomain` is not registered
    public fun assert_container<C>(nft: &Nft<C>) {
        assert!(has_domain(nft), EUNDEFINED_DOMAIN);
    }

    /// Assert that NFT with given ID is composed within the `NftBagDomain`
    ///
    /// #### Panics
    ///
    /// Panics if NFT is not composed.
    public fun assert_composed(container: &NftBagDomain, nft_id: ID) {
        assert!(has(container, nft_id), EUNDEFINED_NFT)
    }
}
