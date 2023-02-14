/// Module of `ContainerDomain` which is shared across all composable domains
/// to store the actual NFT objects.
///
/// `ContainerDomain` allows easy checking on which NFTs are composed across
/// different composability schemes.
module nft_protocol::container {
    use std::vector;
    use std::option;
    use std::type_name::{Self, TypeName};

    use sui::dynamic_object_field as dof;
    use sui::tx_context::TxContext;
    use sui::object::{Self, ID , UID};
    use sui::vec_map::{Self, VecMap};

    use nft_protocol::nft::{Self, Nft};

    /// `ContainerDomain` was not defined
    ///
    /// Call `container::add` to add `ContainerDomain`.
    const EUNDEFINED_DOMAIN: u64 = 1;

    /// `ContainerDomain` already defined
    ///
    /// Call `container::borrow` to borrow domain.
    const EEXISTING_DOMAIN: u64 = 2;

    /// `ContainerDomain` did not compose NFT with given ID
    ///
    /// Call `container::decompose` with an NFT ID that exists.
    const EUNDEFINED_NFT: u64 = 3;

    /// Tried to decompose NFT with invalid authority, only the same authority
    /// that was used to compose an NFT can be used to decompose it
    ///
    /// Call `container::decompose` with the correct authority.
    const EINVALID_AUTHORITY: u64 = 4;

    /// `NftRef` allows indexing composed NFTs within `ContainerDomain`
    struct NftRef has store {
        /// Type name of the witness authorized to withdraw the NFT
        witness: TypeName,
        /// ID of the NFT stored as a dynamic object field
        nft_id: ID,
    }

    /// `ContainerDomain` object
    struct ContainerDomain has store {
        /// `ContainerDomain` ID
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

    /// Creates new `ContainerDomain`
    public fun new(ctx: &mut TxContext): ContainerDomain {
        ContainerDomain {
            id: object::new(ctx),
            authorities: vector::empty(),
            nfts: vec_map::empty(),
        }
    }

    // === Interoperability ===

    /// Returns whether `ContainerDomain` is registered on `Nft`
    public fun has<C>(nft: &Nft<C>): bool {
        nft::has_domain<C, ContainerDomain>(nft)
    }

    /// Borrows `ContainerDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ContainerDomain` is not registered on the `Nft`
    public fun borrow<C>(nft: &Nft<C>): &ContainerDomain {
        assert_container(nft);
        nft::borrow_domain<C, ContainerDomain>(nft)
    }

    /// Mutably borrows `ContainerDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ContainerDomain` is not registered on the `Nft`
    fun borrow_mut<C>(nft: &mut Nft<C>): &mut ContainerDomain {
        assert_container(nft);
        nft::borrow_domain_mut(Witness {}, nft)
    }

    /// Composes child NFT into parent NFT
    ///
    /// #### Panics
    ///
    /// Panics if `ContainerDomain` is not registered on the parent `Nft`.
    public entry fun compose<C, Auth: drop>(
        _authority: Auth,
        parent_nft: &mut Nft<C>,
        child_nft: Nft<C>,
    ) {
        let container_domain = borrow_mut(parent_nft);

        // Identify index of authority that this `Nft` should be composed using
        let authority_type = type_name::get<Auth>();
        let (has_authority, idx_opt) =
            vector::index_of(&container_domain.authorities, &authority_type);

        let idx = if (has_authority) {
            idx_opt
        } else {
            let idx = vector::length(&container_domain.authorities);
            vector::push_back(&mut container_domain.authorities, authority_type);
            idx
        };

        let nft_id = object::id(&child_nft);
        vec_map::insert(&mut container_domain.nfts, nft_id, idx);
        dof::add(&mut container_domain.id, nft_id, child_nft);
    }

    /// Deomposes child NFT from parent NFT
    ///
    /// #### Panics
    ///
    /// Panics if `ContainerDomain` is not registered on the parent `Nft` or
    /// child `Nft` does not exist.
    public entry fun decompose<C, Auth: drop>(
        _authority: Auth,
        parent_nft: &mut Nft<C>,
        child_nft_id: ID,
    ): Nft<C> {
        let container_domain = borrow_mut(parent_nft);

        // Identify index of authority that this `Nft` should be composed using
        // let authority_type = type_name::get<Auth>();
        let idx_opt =
            vec_map::get_idx_opt(&container_domain.nfts, &child_nft_id);
        assert!(option::is_some(&idx_opt), EUNDEFINED_NFT);
        let idx = option::destroy_some(idx_opt);

        let authority = vector::borrow(&container_domain.authorities, idx);
        let authority_type = type_name::get<Auth>();
        assert!(authority == &authority_type, EINVALID_AUTHORITY);

        dof::remove(&mut container_domain.id, child_nft_id)
    }

    // === Assertions ===

    /// Asserts that `ContainerDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `ContainerDomain` is not registered
    public fun assert_container<C>(nft: &Nft<C>) {
        assert!(has(nft), EUNDEFINED_DOMAIN);
    }
}
