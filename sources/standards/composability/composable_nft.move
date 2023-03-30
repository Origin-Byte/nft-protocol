module nft_protocol::composable_nft {
    // TODO: Ideally we would allow for multiple NFTs to be composed together in a single
    // transaction
    // TODO: some endpoint for reorder_children
    // TODO: functions to remove relations, already composed NFTs remain until their decomposed
    // TODO: Add entry funtions for change_composition_limit___
    use std::type_name::{Self, TypeName};

    use sui::transfer;
    use sui::dynamic_field as df;
    use sui::linked_table::{Self, LinkedTable};
    use sui::table::{Self, Table};
    use sui::object::{ID, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::items;
    use nft_protocol::utils::{
        Self, assert_with_witness, assert_with_consumable_witness, UidType
    };
    use nft_protocol::consumable_witness::{Self as cw, ConsumableWitness};

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

    /// No field object `Compositions` defined as a dynamic field.
    const EUNDEFINED_COMPOSITIONS_FIELD: u64 = 5;

    /// Field object `Compositions` already defined as dynamic field.
    const ECOMPOSITIONS_FIELD_ALREADY_EXISTS: u64 = 6;

    // === Compositions ===

    struct Compositions has store {
        rules: Table<TypeName, LinkedTable<TypeName, u64>>
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Key struct used to store Items in dynamic fields
    struct CompositionsKey has store, copy, drop {}


    // === Insert with ConsumableWitness ===


    /// Adds `Compositions` as a dynamic field with key `CompositionsKey`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Compositions`.
    ///
    /// #### Panics
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun init_compositions<T: key>(
        consumable: ConsumableWitness<T>,
        object_uid: &mut UID,
        object_type: UidType<T>,
        ctx: &mut TxContext,
    ) {
        assert_has_not_compositions(object_uid);
        assert_with_consumable_witness(object_uid, object_type);

        let compositions = new(ctx);

        cw::consume<T, Compositions>(consumable, &mut compositions);
        df::add(object_uid, CompositionsKey {}, compositions);
    }


    // === Insert with module specific Witness ===


    /// Adds `Compositions` as a dynamic field with key `CompositionsKey`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun init_compositions_<W: drop, T: key>(
        _witness: W,
        object_uid: &mut UID,
        object_type: UidType<T>,
        ctx: &mut TxContext,
    ) {
        assert_has_not_compositions(object_uid);
        assert_with_witness<W, T>(object_uid, object_type);

        let compositions = new(ctx);
        df::add(object_uid, CompositionsKey {}, compositions);
    }


    // === Get for call from external Module ===


    /// Creates new `Compositions`
    public fun new(ctx: &mut TxContext): Compositions {
        Compositions {
            rules: table::new<TypeName, LinkedTable<TypeName, u64>>(ctx)
        }
    }


    // === Field Borrow Functions ===


    /// Borrows immutably the `Compositions` field.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `CompositionsKey` does not exist.
    public fun borrow_compositions(
        object_uid: &UID,
    ): &Compositions {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_compositions(object_uid);
        df::borrow(object_uid, CompositionsKey {})
    }

    /// Borrows Mutably the `Compositions` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Compositions`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `CompositionsKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun borrow_compositions_mut<T: key>(
        consumable: ConsumableWitness<T>,
        object_uid: &mut UID,
        object_type: UidType<T>
    ): &mut Compositions {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_compositions(object_uid);
        assert_with_consumable_witness(object_uid, object_type);

        let compositions = df::borrow_mut<CompositionsKey, Compositions>(
            object_uid,
            CompositionsKey {}
        );
        cw::consume<T, Compositions>(consumable, compositions);

        compositions
    }

    /// Borrows Mutably the `Compositions` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `CompositionsKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun borrow_compositions_mut_<W: drop, T: key>(
        _witness: W,
        object_uid: &mut UID,
        object_type: UidType<T>
    ): &mut Compositions {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_compositions(object_uid);
        assert_with_witness<W, T>(object_uid, object_type);

        df::borrow_mut(object_uid, CompositionsKey {})
    }

    // /// Borrows Mutably an NFT of type `Child` from the `Items` field.
    // ///
    // /// Endpoint is protected as it relies on safetly obtaining a
    // /// `ConsumableWitness` for the specific type `T` and field `Compositions`.
    // ///
    // /// #### Panics
    // ///
    // /// Panics if dynamic field with `CompositionsKey` does not exist.
    // ///
    // /// Panics if `object_uid` does not correspond to `object_type.id`,
    // /// in other words, it panics if `object_uid` is not of type `T`.
    // public fun borrow_child_mut<Parent: key + store, Child: key + store>(
    //     consumable: ConsumableWitness<Parent>,
    //     object_uid: &mut UID,
    //     object_type: UidType<Parent>
    // ): &mut Child {
    //     // `df::borrow` fails if there is no such dynamic field,
    //     // however asserting it here allows for a more straightforward
    //     // error message
    //     assert_has_compositions(object_uid);
    //     assert_with_consumable_witness(object_uid, object_type);

    //     let compositions = df::borrow_mut<CompositionsKey, Compositions>(
    //         object_uid,
    //         CompositionsKey {}
    //     );

    //     cw::consume<Parent, Compositions>(consumable, compositions);

    //     items::borrow_nft_mut_(Witness {}, )
    // }

    /// Borrows Mutably the `Compositions` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `CompositionsKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun borrow_child_mut_<W: drop, Parent: key + store, Child: key + store>(
        _witness: W,
        parent_uid: &mut UID,
        parent_type: UidType<Parent>,
        child_id: ID,
    ): &mut Child {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_compositions(parent_uid);
        assert_with_witness<W, Parent>(parent_uid, parent_type);

        items::borrow_nft_mut_(Witness {}, parent_uid, parent_type, child_id)
    }


    // === Writer Functions ===


    /// Inserts parent child relationship to `Compositions` object field
    /// in object `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Compositions`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `CompositionsKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    ///
    /// Panics if parent child relationship already exists
    public fun insert_relation<T: key, Parent: key, Child: key>(
        consumable: ConsumableWitness<T>,
        object_uid: &mut UID,
        object_type: UidType<T>,
        limit: u64,
    ) {
        assert_has_compositions(object_uid);
        utils::assert_same_module_<T, Child, Parent>();
        assert_with_consumable_witness(object_uid, object_type);

        let compositions = df::borrow_mut<CompositionsKey, Compositions>(
            object_uid,
            CompositionsKey {}
        );

        let parent_type = type_name::get<Parent>();
        let parent_row = table::borrow_mut(&mut compositions.rules, parent_type);

        assert_new_relationship<Child>(parent_row);

        let child_type = type_name::get<Child>();
        linked_table::push_back(parent_row, child_type, limit);
    }

    /// Inserts parent child relationship to `Compositions` object field
    /// in object `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `CompositionsKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    ///
    /// Panics if parent child relationship already exists
    public fun insert_relation_<W: drop, T: key, Parent: key, Child: key>(
        witness: W,
        object_uid: &mut UID,
        object_type: UidType<T>,
        limit: u64,
    ) {
        assert_has_compositions(object_uid);
        utils::assert_same_module_<T, Child, Parent>();
        assert_with_witness<W, T>(object_uid, object_type);

        let compositions = df::borrow_mut<CompositionsKey, Compositions>(
            object_uid,
            CompositionsKey {}
        );

        let parent_type = type_name::get<Parent>();
        let parent_row = table::borrow_mut(&mut compositions.rules, parent_type);

        assert_new_relationship<Child>(parent_row);

        let child_type = type_name::get<Child>();
        linked_table::push_back(parent_row, child_type, limit);
    }

    /// Compose child NFT into parent NFT.
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
        parent_type: UidType<Parent>,
        child_nft: Child,
        compositions: &Compositions,
    ) {
        // TODO: Assert has item, if not create
        utils::assert_uid_type(parent_uid, &parent_type);

        // Asserts that parent and child are composable
        let child_type = type_name::get<Child>();
        let limit = get_composition_limit<Parent,Child>(compositions);

        let items = items::borrow_items(parent_uid);

        assert!(
            items::count<Child>(items) < *limit,
            EEXCEEDED_TYPE_LIMIT,
        );

        items::add_child(Witness {}, parent_uid, &parent_type, child_nft);
    }

    /// Decomposes NFT with given ID from parent NFT and transfers to
    /// transaction sender
    ///
    /// #### Panics
    ///
    /// Panics if there is no NFT with given ID composed
    public entry fun decompose_and_transfer<C, Parent: key + store, Child: key + store>(
        parent_uid: &mut UID,
        parent_type: UidType<Parent>,
        child_id: ID,
        ctx: &mut TxContext,
    ) {
        let nft = decompose<C, Parent, Child>(parent_uid, parent_type, child_id);
        transfer::transfer(nft, tx_context::sender(ctx));
    }

    /// Decomposes NFT with given ID from parent NFT
    ///
    /// #### Panics
    ///
    /// Panics if there is no NFT with given ID composed
    public fun decompose<C, Parent: key + store, Child: key + store>(
        parent_uid: &mut UID,
        parent_type: UidType<Parent>,
        child_id: ID,
    ): Child {
        // TODO: Assert has item
        utils::assert_uid_type(parent_uid, &parent_type);

        items::remove_child(Witness {}, parent_uid, &parent_type, child_id)
    }


    // === Getter Functions & Static Mutability Accessors ===

    /// Get composability limit for a given `Parent` - `Child` relationship
    /// from `Compositions` object.
    ///
    /// #### Panics
    ///
    /// Panics if parent child relationship was not defined on composability
    /// blueprint.
    public fun get_composition_limit<Parent, Child>(
        compositions: &Compositions,
    ): &u64 {
        // assert_composable<Parent>(blueprint, child_type);
        let parent_type = type_name::get<Parent>();
        let parent_row = table::borrow(&compositions.rules, parent_type);

        let child_type = type_name::get<Child>();
        linked_table::borrow<TypeName, u64>(parent_row, child_type)
    }

    /// Change composability limit for a given `Parent` - `Child` relationship
    /// from `Compositions` object.
    ///
    /// #### Panics
    ///
    /// Panics if parent child relationship was not defined on composability
    /// blueprint.
    public fun change_composition_limit___<Parent: key, Child: key>(
        compositions: &mut Compositions,
        new_limit: u64,
    ) {
        // assert_composable<Parent>(blueprint, child_type);
        let parent_type = type_name::get<Parent>();
        let parent_row = table::borrow_mut(&mut compositions.rules, parent_type);

        let child_type = type_name::get<Child>();
        let limit = linked_table::borrow_mut<TypeName, u64>(parent_row, child_type);

        *limit = new_limit;
    }


    // === Assertions & Helpers ===

    /// Returns whether a parent child relationship exists in the blueprint
    public fun has_child<Child>(
        parent_row: &LinkedTable<TypeName, u64>,
    ): bool {
        let child_type = type_name::get<Child>();

        linked_table::contains<TypeName, u64>(parent_row, child_type)
    }


    public fun assert_new_relationship<Child>(
        parent_row: &LinkedTable<TypeName, u64>,
    ) {
        assert!(
            !has_child<Child>(parent_row),
            ERELATIONSHIP_ALREADY_DEFINED,
        );
    }

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

    /// Checks that a given NFT has a dynamic field with `ItemsKey`
    public fun has_compositions(
        object_uid: &UID,
    ): bool {
        df::exists_(object_uid, CompositionsKey {})
    }

    public fun assert_has_compositions(object_uid: &UID) {
        assert!(has_compositions(object_uid), EUNDEFINED_COMPOSITIONS_FIELD);
    }

    public fun assert_has_not_compositions(object_uid: &UID) {
        assert!(!has_compositions(object_uid), ECOMPOSITIONS_FIELD_ALREADY_EXISTS);
    }
}
