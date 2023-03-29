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

    use nft_protocol::utils::{
        assert_with_witness, assert_with_consumable_witness, UidType, assert_uid_type
    };
    use nft_protocol::consumable_witness::{Self as cw, ConsumableWitness};

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

    /// No field object `Items` defined as a dynamic field.
    const EUNDEFINED_ITEMS_FIELD: u64 = 5;

    /// Field object `Items` already defined as dynamic field.
    const EITEMS_FIELD_ALREADY_EXISTS: u64 = 6;

    /// `Items` object
    struct Items has key, store {
        /// `Items` ID
        id: UID,
        nfts: ObjectBag,
        quantity: Table<TypeName, u64>,
    }

    struct NftKey<phantom AW, phantom T> has copy, store, drop {
        nft_id: ID,
    }

    /// Key struct used to store Items in dynamic fields
    struct ItemsKey has store, copy, drop {}

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    // === Insert with ConsumableWitness ===


    // TODO: Consider deprecate
    /// Adds `Items` as a dynamic field with key `ItemsKey`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Items`.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun add_items<T: key>(
        consumable: ConsumableWitness<T>,
        parent_uid: &mut UID,
        parent_type: UidType<T>,
        ctx: &mut TxContext,
    ) {
        assert_has_not_items(parent_uid);
        assert_with_consumable_witness(parent_uid, parent_type);

        let items = new(ctx);

        cw::consume<T, Items>(consumable, &mut items);
        df::add(parent_uid, ItemsKey {}, items);
    }


    // === Insert with module specific Witness ===


    /// Adds `Items` as a dynamic field with key `ItemsKey`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun add_items_<W: drop, T: key>(
        _witness: W,
        parent_uid: &mut UID,
        parent_type: UidType<T>,
        ctx: &mut TxContext,
    ) {
        assert_has_not_items(parent_uid);
        assert_with_witness<W, T>(parent_uid, parent_type);

        let items = new(ctx);
        df::add(parent_uid, ItemsKey {}, items);
    }


    // === Get for call from external Module ===


    /// Creates new `Items`
    public fun new(ctx: &mut TxContext): Items {
        Items {
            id: object::new(ctx),
            nfts: object_bag::new(ctx),
            quantity: table::new(ctx),
        }
    }


    // === Field Borrow Functions ===


    /// Borrows immutably the `Items` field.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `ItemsKey` does not exist.
    public fun borrow_items(
        parent_uid: &UID,
    ): &Items {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_items(parent_uid);
        df::borrow(parent_uid, ItemsKey {})
    }

    /// Immutably Borrows `Nft` from `Items`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft` was not composed within the `Items`.
    public fun borrow_nft<T: key + store>(parent_uid: &UID, nft_id: ID): &T {
        let items = df::borrow<ItemsKey, Items>(
            parent_uid, ItemsKey {},
        );

        assert_composed(items, nft_id);
        dof::borrow(&items.id, nft_id)
    }

    /// Mutably borrows `Nft` from `Items`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `ItemsKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if `Nft` was not composed within the `Items`.
    public fun borrow_nft_mut_<CW: drop, AW: drop, Parent: key + store, Child: key + store>(
        auth_witness: AW,
        creator_witness: CW,
        parent_uid: &mut UID,
        parent_type: UidType<Parent>,
        nft_id: ID,
    ): &mut Child {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_items(parent_uid);
        // No need to assert the Child belongs to the same module as the creator's
        // Witness because certain composability models might allow Parents and Childs
        // to be from different collections
        assert_with_witness<CW, Parent>(parent_uid, parent_type);

        let items = df::borrow_mut<ItemsKey, Items>(parent_uid, ItemsKey {});
        borrow_nft_mut_internal<AW, Child>(&auth_witness, items, nft_id)
    }


    // === Writer Functions ===


    /// Composes child NFT into `Items`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Items`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `ItemsKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun add_child<AW: drop, Parent: key + store, Child: key + store>(
        _auth_witness: AW,
        parent_uid: &mut UID,
        parent_type: &UidType<Parent>,
        child_nft: Child,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_items(parent_uid);
        assert_uid_type(parent_uid, parent_type);

        let items = df::borrow_mut<ItemsKey, Items>(parent_uid, ItemsKey {});

        let qty = table::borrow_mut(&mut items.quantity, type_name::get<Child>());
        *qty = *qty + 1;

        let nft_key = NftKey<AW, Child> { nft_id: object::id(&child_nft) };
        object_bag::add(&mut items.nfts, nft_key, child_nft);
    }

    /// Decomposes child NFT from `Items`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Items`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `ItemsKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if child `Nft` does not exist.
    public fun remove_child<AW: drop, Parent: key + store, Child: key + store>(
        _auth_witness: AW,
        parent_uid: &mut UID,
        parent_type: &UidType<Parent>,
        child_id: ID,
    ): Child {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_items(parent_uid);
        assert_uid_type(parent_uid, parent_type);

        let items = df::borrow_mut<ItemsKey, Items>(parent_uid, ItemsKey {});
        let qty = table::borrow_mut(&mut items.quantity, type_name::get<Child>());
        *qty = *qty - 1;

        let nft_key = NftKey<AW, Child> { nft_id: child_id };

        object_bag::remove(&mut items.nfts, nft_key)
    }


    // === Getter Functions & Static Mutability Accessors ===

    /// Immutably Borrows `Nft` from `Items`
    ///
    /// #### Panics
    ///
    /// Panics if `Nft` was not composed within the `Items`.
    public fun get_nft<T: key + store>(items: &Items, nft_id: ID): &T {
        assert_composed(items, nft_id);
        dof::borrow(&items.id, nft_id)
    }

    /// Counts how many NFTs are registered under the given type
    public fun count<T: key + store>(items: &Items): u64 {
        *table::borrow(&items.quantity, type_name::get<T>())
    }

    public fun get_key<AW: drop, T: key + store>(
        _auth_witness: AW,
        nft: &T,
    ): NftKey<AW, T> {
        let nft_id = object::id(nft);

        NftKey { nft_id }
    }

    public fun get_key_by_id<AW: drop, T: key + store>(
        _auth_witness: AW,
        nft_id: ID,
    ): NftKey<AW, T> {
        NftKey { nft_id }
    }


    // === Private Functions ===


    fun borrow_nft_mut_internal<AW: drop, Child: key + store>(
        // Auth witness is just here for extra safety
        _auth_witness: &AW,
        items: &mut Items,
        nft_id: ID
    ): &mut Child {
        let nft_key = NftKey<AW, Child> { nft_id: nft_id };

        object_bag::borrow_mut(&mut items.nfts, nft_key)
    }


    // === Assertions & Helpers ===


    /// Returns whether NFT with given ID is composed within provided
    /// `Items`
    public fun has_nft(parent_uid: &UID, nft_id: ID): bool {
        let items = df::borrow<ItemsKey, Items>(
            parent_uid, ItemsKey {}
        );

        object_bag::contains(&items.nfts, nft_id)
    }

    /// Returns whether NFT with given ID is composed within provided
    /// `Items`
    public fun has_nft_(items: &Items, nft_id: ID): bool {
        object_bag::contains(&items.nfts, nft_id)
    }

    /// Checks that a given NFT has a dynamic field with `ItemsKey`
    public fun has_items(
        nft_uid: &UID,
    ): bool {
        df::exists_(nft_uid, ItemsKey {})
    }

    /// Assert that NFT with given ID is composed within the `Items`
    ///
    /// #### Panics
    ///
    /// Panics if NFT is not composed.
    public fun assert_composed(items: &Items, nft_id: ID) {
        assert!(has_nft_(items, nft_id), EUNDEFINED_NFT)
    }

    public fun assert_has_items(nft_uid: &UID) {
        assert!(has_items(nft_uid), EUNDEFINED_ITEMS_FIELD);
    }

    public fun assert_has_not_items(nft_uid: &UID) {
        assert!(!has_items(nft_uid), EITEMS_FIELD_ALREADY_EXISTS);
    }
}
