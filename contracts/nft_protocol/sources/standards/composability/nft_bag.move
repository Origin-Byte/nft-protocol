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
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, ID , UID};
    use sui::vec_map::{Self, VecMap};
    use sui::dynamic_field as df;
    use sui::transfer;

    use ob_witness::marker::{Self, Marker};

    /// `NftBag` was not defined
    ///
    /// Call `nft_bag::add` to add `NftBag`.
    const EUndefinedNftBag: u64 = 1;

    /// `NftBag` already defined
    ///
    /// Call `nft_bag::borrow` to borrow domain.
    const EExistingNftBag: u64 = 2;

    /// `NftBag` did not compose NFT with given ID
    ///
    /// Call `nft_bag::decompose` with an NFT ID that exists.
    const EUndefinedNft: u64 = 3;

    /// Tried to decompose existing NFT but with incorrect type
    ///
    /// Call `nft_bag::decompose` with an NFT type corresponding to the actual
    /// composed NFT.
    const EInvalidType: u64 = 4;

    /// Tried to decompose NFT with invalid authority, only the same authority
    /// that was used to compose an NFT can be used to decompose it
    ///
    /// Call `nft_bag::decompose` with the correct authority.
    const EInvalidAuthority: u64 = 5;

    /// Tried to delete `NftBag` that still had registered NFTs
    ///
    /// Call `nft_bag::decompose` to decompose the remaining NFTs.
    const ENotEmpty: u64 = 5;

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

    /// Struct to index NFTs in dynamic fields
    struct Key has drop, copy, store { id: ID }

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
    public fun has(nft_bag: &NftBag, nft_id: ID): bool {
        dof::exists_(&nft_bag.id, Key { id: nft_id })
    }

    /// Borrows `Nft` from `NftBag`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft` was not composed within the `NftBag`.
    public fun borrow<T: key + store>(nft_bag: &NftBag, nft_id: ID): &T {
        assert_composed_type<T>(nft_bag, nft_id);
        dof::borrow(&nft_bag.id, Key { id: nft_id })
    }

    /// Mutably borrows `Nft` from `NftBag`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft` was not composed within the `NftBag`.
    public fun borrow_mut<T: key + store>(
        nft_bag: &mut NftBag,
        nft_id: ID,
    ): &mut T {
        assert_composed_type<T>(nft_bag, nft_id);
        dof::borrow_mut(&mut nft_bag.id, Key { id: nft_id })
    }

    /// Borrows composed NFT with given ID from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` is not registered or NFT is not composed.
    public fun borrow_nft<T: key + store>(nft: &UID, child_nft_id: ID): &T {
        let nft_bag = borrow_domain(nft);
        borrow(nft_bag, child_nft_id)
    }

    /// Mutably borrows composed NFT with given ID from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` is not registered or NFT is not composed.
    public fun borrow_nft_mut<T: key + store>(
        nft: &mut UID,
        child_nft_id: ID,
    ): &mut T {
        let nft_bag = borrow_domain_mut(nft);
        borrow_mut(nft_bag, child_nft_id)
    }

    /// Get authorities registered in `NftBag`
    public fun get_authorities(nft_bag: &NftBag): &vector<TypeName> {
        &nft_bag.authorities
    }

    /// Get NFTs composed in `NftBag`
    public fun get_nfts(nft_bag: &NftBag): &VecMap<ID, u64> {
        &nft_bag.nfts
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
        dof::add(&mut domain.id, Key { id: nft_id }, child_nft);
    }

    /// Composes child NFT into parent NFT
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` is not registered on the parent `Nft`
    public fun compose_into_nft<T: key + store, Auth: drop>(
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
        let idx_opt = vec_map::get_idx_opt(&domain.nfts, &child_nft_id);
        assert!(option::is_some(&idx_opt), EUndefinedNft);

        // Get NFT composition authority
        let idx = option::destroy_some(idx_opt);
        let (_, authority_idx) = vec_map::get_entry_by_idx(&domain.nfts, idx);
        let authority = vector::borrow(&domain.authorities, *authority_idx);

        // Validate correct authority
        let authority_type = type_name::get<Auth>();
        assert!(authority == &authority_type, EInvalidAuthority);

        vec_map::remove_entry_by_idx(&mut domain.nfts, idx);

        // Additionally validate correct type
        assert_composed_type<T>(domain, child_nft_id);
        dof::remove(&mut domain.id, Key { id: child_nft_id })
    }

    /// Decomposes NFT with given ID from `NftBag` and transfers to receiver
    ///
    /// #### Panics
    ///
    /// Panics if there is no NFT with given ID composed
    public fun decompose_and_transfer<T: key + store, Auth: drop>(
        authority: Auth,
        domain: &mut NftBag,
        child_nft_id: ID,
        ctx: &mut TxContext,
    ) {
        let nft = decompose<T, Auth>(authority, domain, child_nft_id);
        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

    /// Decomposes child NFT from parent NFT
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` is not registered on the parent `Nft`
    public fun decompose_from_nft<T: key + store, Auth: drop>(
        authority: Auth,
        parent_nft: &mut UID,
        child_nft_id: ID,
    ): T {
        let domain = borrow_domain_mut(parent_nft);
        decompose(authority, domain, child_nft_id)
    }

    /// Decomposes NFT with given ID from `NftBag` and transfers to receiver
    ///
    /// #### Panics
    ///
    /// Panics if there is no NFT with given ID composed
    public fun decompose_from_nft_and_transfer<T: key + store, Auth: drop>(
        authority: Auth,
        parent_nft: &mut UID,
        child_nft_id: ID,
        ctx: &mut TxContext,
    ) {
        let nft = decompose_from_nft<T, Auth>(authority, parent_nft, child_nft_id);
        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

    /// Counts how many NFTs are registered under the given authority
    public fun count<Auth>(domain: &NftBag): u64 {
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

    /// Deconstruct `NftBag`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` has NFTs deposited within.
    public fun delete(nft_bag: NftBag) {
        let NftBag { id, authorities: _, nfts } = nft_bag;

        assert!(vec_map::is_empty(&nfts), ENotEmpty);

        object::delete(id);
    }

    // === Interoperability ===

    /// Returns whether `NftBag` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<NftBag>, NftBag>(
            nft, marker::marker(),
        )
    }

    /// Borrows `NftBag` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &NftBag {
        assert_nft_bag(nft);
        df::borrow(nft, marker::marker<NftBag>())
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
        df::borrow_mut(nft, marker::marker<NftBag>())
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
        df::add(nft, marker::marker<NftBag>(), domain);
    }

    /// Creates a new `NftBag` and inserts it into NFT
    public fun add_new(nft: &mut UID, ctx: &mut TxContext) {
        add_domain(nft, new(ctx));
    }

    /// Remove `NftBag` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `NftBag` domain doesnt exist
    public fun remove_domain(nft: &mut UID): NftBag {
        assert_nft_bag(nft);
        df::remove(nft, marker::marker<NftBag>())
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
        nft_bag: &NftBag,
        nft_id: ID,
    ) {
        assert!(has(nft_bag, nft_id), EUndefinedNft)
    }

    /// Assert that NFT with given ID is composed within the `NftBag`
    ///
    /// #### Panics
    ///
    /// Panics if NFT is not composed.
    public fun assert_composed_type<T: key + store>(
        nft_bag: &NftBag,
        nft_id: ID,
    ) {
        // Use double asserts in order to provide clear error codes to
        // developers
        assert_composed(nft_bag, nft_id);
        assert!(
            dof::exists_with_type<Key, T>(&nft_bag.id, Key { id: nft_id }),
            EInvalidType,
        );
    }
}
