module nft_protocol::composable_nft {
    // TODO: Ideally we would allow for multiple NFTs to be composed together in a single
    // transaction
    // TODO: some endpoint for reorder_children
    use std::type_name::{Self, TypeName};

    use sui::transfer;
    use sui::linked_table::{Self, LinkedTable};
    use sui::table::{Self, Table};
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::items;
    use nft_protocol::utils::{Self, UidType};

    /// Parent and child types are not composable
    ///
    /// Call `composable_nft::add_relationship` to add parent child
    /// relationship to the composability blueprint.
    const ETYPES_NOT_COMPOSABLE: u64 = 1;

    /// Relationship between provided parent and child types is already defined
    const ERELATIONSHIP_ALREADY_DEFINED: u64 = 2;

    /// Exceeded composed type limit when calling `composable_nft::compose`
    ///
    /// Set a higher type limit in the composability blueprint.
    const EEXCEEDED_TYPE_LIMIT: u64 = 3;

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Internal struct for indexing NFTs in `Items`
    struct Key<phantom T> has drop, store {}

    // === Compositions ===

    struct Compositions has store {
        rules: Table<TypeName, LinkedTable<TypeName, u64>>
    }

    public fun new_compositions<Parent>(ctx: &mut TxContext): Compositions {
        Compositions {
            rules: table::new<TypeName, LinkedTable<TypeName, u64>>(ctx)
        }
    }

    /// Adds parent child relationship to `Blueprint`
    ///
    /// #### Panics
    ///
    /// Panics if parent child relationship already exists
    public fun add_composition<Parent, Child>(
        compositions: &mut Compositions,
        limit: u64,
    ) {
        let parent_type = type_name::get<Parent>();
        let parent_row = table::borrow_mut(&mut compositions.rules, parent_type);

        assert_new_relationship<Child>(parent_row);

        let child_type = type_name::get<Child>();
        linked_table::push_back(parent_row, child_type, limit);
    }

    public fun assert_new_relationship<Child>(
        parent_row: &LinkedTable<TypeName, u64>,
    ) {
        assert!(
            !has_child<Child>(parent_row),
            ERELATIONSHIP_ALREADY_DEFINED,
        );
    }

    /// Returns whether a parent child relationship exists in the blueprint
    public fun has_child<Child>(
        parent_row: &LinkedTable<TypeName, u64>,
    ): bool {
        let child_type = type_name::get<Child>();

        linked_table::contains<TypeName, u64>(parent_row, child_type)
    }

    /// Borrow child node from composability blueprint
    ///
    /// #### Panics
    ///
    /// Panics if parent child relationship was not defined on composability
    /// blueprint.
    public fun borrow_child<Parent, Child>(
        compositions: &Compositions,
    ): &u64 {
        // assert_composable<Parent>(blueprint, child_type);
        let parent_type = type_name::get<Parent>();
        let parent_row = table::borrow(&compositions.rules, parent_type);

        let child_type = type_name::get<Child>();
        linked_table::borrow<TypeName, u64>(parent_row, child_type)
    }

    /// Mutably borrow child node from composability blueprint
    ///
    /// #### Panics
    ///
    /// Panics if parent child relationship was not defined on composability
    /// blueprint.
    fun borrow_child_mut<Parent, Child>(
        compositions: &mut Compositions,
    ): &mut u64 {
        // assert_composable<Parent>(blueprint, child_type);
        let parent_type = type_name::get<Parent>();
        let parent_row = table::borrow_mut(&mut compositions.rules, parent_type);

        let child_type = type_name::get<Child>();
        linked_table::borrow_mut<TypeName, u64>(parent_row, child_type)
    }

    /// Compose child NFT into parent NFT
    ///
    /// #### Panics
    ///
    /// * `Blueprint<Parent>` is not registered as a domain on the parent NFT
    /// * Parent child relationship is not defined on the composability
    /// blueprint
    /// * Parent or child NFT do not have corresponding `Type<Parent>` and
    /// `Type<Child>` domains registered
    /// * Limit of children is exceeded
    public entry fun compose<Parent: key + store, Child: key + store>(
        parent_uid: &mut UID,
        parent_type: &mut UidType<Parent>,
        child_nft: Child,
        compositions: &Compositions,
    ) {
        utils::assert_uid_type(parent_uid, parent_type);

        // Asserts that parent and child are composable
        let child_type = type_name::get<Child>();
        let limit = borrow_child<Parent,Child>(compositions);

        // TODO: Make sure this does not fail if dynamic field for Items is
        // still not created.
        let items = items::borrow_items_mut(parent_uid);

        assert!(
            items::count<Key<Child>>(items) < *limit,
            EEXCEEDED_TYPE_LIMIT,
        );

        items::compose(Key<Child> {}, items, child_nft);
    }

    /// Decomposes NFT with given ID from parent NFT
    ///
    /// #### Panics
    ///
    /// Panics if there is no NFT with given ID composed
    public fun decompose<C, Parent: key + store, Child: key + store>(
        parent_uid: &mut UID,
        parent_type: &mut UidType<Parent>,
        child_nft_id: ID,
    ): Child {
        utils::assert_uid_type(parent_uid, parent_type);

        let items = items::borrow_items_mut(parent_uid);

        items::decompose(Key<Child> {}, items, child_nft_id)
    }

    /// Decomposes NFT with given ID from parent NFT and transfers to
    /// transaction sender
    ///
    /// #### Panics
    ///
    /// Panics if there is no NFT with given ID composed
    public fun decompose_and_transfer<C, Parent: key + store, Child: key + store>(
        parent_uid: &mut UID,
        parent_type: &mut UidType<Parent>,
        child_nft_id: ID,
        ctx: &mut TxContext,
    ) {
        let nft = decompose<C, Parent, Child>(parent_uid, parent_type, child_nft_id);
        transfer::transfer(nft, tx_context::sender(ctx));
    }

    // === Assertions ===

    /// Assert that parent and child types are composable
    ///
    /// #### Panics
    ///
    /// Panics if parent and child types are not composable.
    public fun assert_composable<Child>(
        parent_row: &LinkedTable<TypeName, u64>,
        child_type: &TypeName,
    ) {
        assert!(
            has_child<Child>(parent_row),
            ETYPES_NOT_COMPOSABLE,
        );
    }
}
