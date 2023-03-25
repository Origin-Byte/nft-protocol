/// Module of `Items` which is shared across all composable domains
/// to store the actual NFT objects.
///
/// `Items` allows easy checking on which NFTs are composed across
/// different composability schemes.
module nft_protocol::items {
    use std::vector;
    use std::option::{Self, Option};
    use std::type_name::{Self, TypeName};

    use sui::dynamic_object_field as dof;
    use sui::dynamic_field as df;
    use sui::tx_context::TxContext;
    use sui::object::{Self, ID , UID};
    use sui::vec_map::{Self, VecMap};
    use nft_protocol::utils;

    /// `Items` was not defined
    ///
    /// Call `container::add` to add `Items`.
    const EUNDEFINED_DOMAIN: u64 = 1;

    /// `Items` already defined
    ///
    /// Call `container::borrow` to borrow domain.
    const EEXISTING_DOMAIN: u64 = 2;

    /// `Items` did not compose NFT with given ID
    ///
    /// Call `container::decompose` with an NFT ID that exists.
    const EUNDEFINED_NFT: u64 = 3;

    /// Tried to decompose NFT with invalid authority, only the same authority
    /// that was used to compose an NFT can be used to decompose it
    ///
    /// Call `container::decompose` with the correct authority.
    const EINVALID_AUTHORITY: u64 = 4;

    /// `Items` object
    struct Items has key, store {
        /// `Items` ID
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

    /// Creates new `Items`
    public fun new(ctx: &mut TxContext): Items {
        Items {
            id: object::new(ctx),
            authorities: vector::empty(),
            nfts: vec_map::empty(),
        }
    }

    /// Creates new `Items`
    public fun create(parent_uid: &mut UID, ctx: &mut TxContext) {
        let items = new(ctx);

        df::add(parent_uid, utils::marker<Items>(), items);
    }

    /// Returns whether NFT with given ID is composed within provided
    /// `Items`
    public fun has(container: &Items, nft_id: ID): bool {
        dof::exists_(&container.id, nft_id)
    }

    /// Borrows `Items` from `T`
    ///
    /// #### Panics
    ///
    /// Panics if `T` was not composed within the `Items`.
    public fun borrow_items(parent_uid: &UID): &Items {
        df::borrow(parent_uid, utils::marker<Items>())
    }

    /// Mutably borrows `Nft` from `Items`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft` was not composed within the `Items`.
    public fun borrow_items_mut(parent_uid: &mut UID): &mut Items {
        df::borrow_mut(parent_uid, utils::marker<Items>())
    }

    /// Borrows `Nft` from `Items`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft` was not composed within the `Items`.
    public fun borrow_nft<T: key + store>(items: &Items, nft_id: ID): &T {
        assert_composed(items, nft_id);
        dof::borrow(&items.id, nft_id)
    }

    /// Mutably borrows `Nft` from `Items`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft` was not composed within the `Items`.
    public fun borrow_nft_mut<T: key + store>(
        items: &mut Items,
        nft_id: ID,
    ): &mut T {
        assert_composed(items, nft_id);
        dof::borrow_mut(&mut items.id, nft_id)
    }

    /// Get index of authority
    fun get_authority_idx(
        authority_type: &TypeName,
        domain: &Items,
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
        items: &mut Items,
    ): u64 {
        let idx_opt = get_authority_idx(&authority_type, items);

        if (option::is_some(&idx_opt)) {
            option::destroy_some(idx_opt)
        } else {
            let idx = vector::length(&items.authorities);
            vector::push_back(&mut items.authorities, authority_type);
            idx
        }
    }

    /// Composes child NFT into `Items`
    public fun compose<T: key + store, Auth: drop>(
        _authority: Auth,
        items: &mut Items,
        child_nft: T,
    ) {
        let authority_type = type_name::get<Auth>();
        let idx = get_or_insert_authority_idx(authority_type, items);

        let nft_id = object::id(&child_nft);
        vec_map::insert(&mut items.nfts, nft_id, idx);
        dof::add(&mut items.id, nft_id, child_nft);
    }

    // TODO: Reassess when domain model is restructured
    // /// Composes child NFT into parent NFT
    // ///
    // /// #### Panics
    // ///
    // /// Panics if `Items` is not registered on the parent `Nft`
    // public fun compose_nft<C, Auth: drop>(
    //     authority: Auth,
    //     parent_nft: &mut Nft<C>,
    //     child_nft: Nft<C>,
    // ) {
    //     let domain = borrow_domain_mut(parent_nft);
    //     compose(authority, domain, child_nft);
    // }

    /// Decomposes child NFT from `Items`
    ///
    /// #### Panics
    ///
    /// Panics if child `Nft` does not exist.
    public fun decompose<T: key + store, Auth: drop>(
        _authority: Auth,
        domain: &mut Items,
        child_nft_id: ID,
    ): T {
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

    // TODO: Reassess when domain model is restructured
    /// Decomposes child NFT from parent NFT
    ///
    /// #### Panics
    ///
    /// Panics if `Items` is not registered on the parent `Nft`
    // public fun decompose_nft<C, Auth: drop>(
    //     authority: Auth,
    //     parent_nft: &mut Nft<C>,
    //     child_nft_id: ID,
    // ): Nft<C> {
    //     let domain = borrow_domain_mut(parent_nft);
    //     decompose(authority, domain, child_nft_id)
    // }

    /// Counts how many NFTs are registered under the given authority
    public fun count<Auth>(domain: &Items): u64 {
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

    // TODO: Reassess when domain model is restructured
    // /// Asserts that `Items` is registered on `Nft`
    // ///
    // /// #### Panics
    // ///
    // /// Panics if `Items` is not registered
    // public fun assert_container<C>(nft: &Nft<C>) {
    //     assert!(has_domain(nft), EUNDEFINED_DOMAIN);
    // }

    /// Assert that NFT with given ID is composed within the `Items`
    ///
    /// #### Panics
    ///
    /// Panics if NFT is not composed.
    public fun assert_composed(container: &Items, nft_id: ID) {
        assert!(has(container, nft_id), EUNDEFINED_NFT)
    }
}
