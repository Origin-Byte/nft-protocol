/// Module of `Items` which is shared across all composable domains
/// to store the actual NFT objects.
///
/// `Items` allows easy checking on which NFTs are composed across
/// different composability schemes.
module nft_protocol::items {
    use std::type_name::{Self, TypeName};

    use sui::dynamic_field as df;
    use sui::table::{Self, Table};
    use sui::tx_context::TxContext;
    use sui::object::{Self, ID , UID};
    use sui::dynamic_object_field as dof;
    use sui::object_bag::{Self, ObjectBag};

    use nft_protocol::utils::{Self, Marker};

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
        nfts: ObjectBag,
        quantity: Table<TypeName, u64>,
    }

    struct Key<phantom W, phantom T> has copy, store, drop {
        nft_id: ID,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates new `Items`
    public fun new(ctx: &mut TxContext): Items {
        Items {
            id: object::new(ctx),
            nfts: object_bag::new(ctx),
            quantity: table::new(ctx),
        }
    }

    /// Creates new `Items`
    public fun empty(parent_uid: &mut UID, ctx: &mut TxContext) {
        let items = new(ctx);

        // TODO: Is it safe here to add it as a marker?
        df::add(parent_uid, utils::marker<Items>(), items);
    }

    /// Returns whether NFT with given ID is composed within provided
    /// `Items`
    public fun has_nft(parent_uid: &UID, nft_id: ID): bool {
        let items = df::borrow<Marker<Items>, Items>(
            parent_uid, utils::marker<Items>()
        );

        object_bag::contains(&items.nfts, nft_id)
    }

    /// Returns whether NFT with given ID is composed within provided
    /// `Items`
    public fun has_nft_(items: &Items, nft_id: ID): bool {
        object_bag::contains(&items.nfts, nft_id)
    }

    /// Borrows `Items` from `T`
    ///
    /// #### Panics
    ///
    /// Panics if `T` was not composed within the `Items`.
    public fun borrow_items(parent_uid: &UID): &Items {
        df::borrow(parent_uid, utils::marker<Items>())
    }

    // TODO: This is unsafe because there is no access control...
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
    public fun borrow_nft<T: key + store>(parent_uid: &mut UID, nft_id: ID): &T {
        let items = df::borrow<Marker<Items>, Items>(
            parent_uid, utils::marker<Items>()
        );
        borrow_nft_(items, nft_id)
    }

    // TODO: This is unsafe because there is no access control...
    /// Mutably borrows `Nft` from `Items`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft` was not composed within the `Items`.
    public fun borrow_nft_mut<T: key + store>(
        parent_uid: &mut UID,
        nft_id: ID,
    ): &mut T {
        let items = df::borrow_mut<Marker<Items>, Items>(
            parent_uid, utils::marker<Items>()
        );

        borrow_nft_mut_(items, nft_id)
    }

    /// Borrows `Nft` from `Items`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft` was not composed within the `Items`.
    public fun borrow_nft_<T: key + store>(items: &Items, nft_id: ID): &T {
        assert_composed(items, nft_id);
        dof::borrow(&items.id, nft_id)
    }

    // TODO: This is unsafe because there is no access control...
    /// Mutably borrows `Nft` from `Items`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft` was not composed within the `Items`.
    public fun borrow_nft_mut_<T: key + store>(
        items: &mut Items,
        nft_id: ID,
    ): &mut T {
        assert_composed(items, nft_id);
        dof::borrow_mut(&mut items.id, nft_id)
    }

    /// Composes child NFT into `Items`
    public fun compose<W: drop, T: key + store>(
        _witness: W,
        key: Key<W, T>,
        items: &mut Items,
        child_nft: T,
    ) {
        let qty = table::borrow_mut(&mut items.quantity, type_name::get<T>());
        *qty = *qty + 1;

        object_bag::add(&mut items.nfts, key, child_nft);
    }

    /// Decomposes child NFT from `Items`
    ///
    /// #### Panics
    ///
    /// Panics if child `Nft` does not exist.
    public fun decompose<W: drop, T: key + store>(
        _witness: W,
        key: Key<W, T>,
        items: &mut Items,
        child_nft_id: ID,
    ): T {
        let qty = table::borrow_mut(&mut items.quantity, type_name::get<T>());
        *qty = *qty - 1;

        object_bag::remove(&mut items.nfts, key)
    }

    /// Counts how many NFTs are registered under the given type
    public fun count<T: key + store>(items: &Items): u64 {
        *table::borrow(&items.quantity, type_name::get<T>())
    }

    public fun get_key<W: drop, T: key + store>(
        _witness: W,
        nft: &T,
    ): Key<W, T> {
        let nft_id = object::id(nft);

        Key { nft_id }
    }

    public fun get_key_by_id<W: drop, T: key + store>(
        _witness: W,
        nft_id: ID,
    ): Key<W, T> {
        Key { nft_id }
    }

    // === Assertions ===

    /// Assert that NFT with given ID is composed within the `Items`
    ///
    /// #### Panics
    ///
    /// Panics if NFT is not composed.
    public fun assert_composed(items: &Items, nft_id: ID) {
        assert!(has_nft_(items, nft_id), EUNDEFINED_NFT)
    }
}
