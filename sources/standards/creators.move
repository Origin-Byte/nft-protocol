/// Module of Collection `Creators`
///
/// `Creators` tracks all collection creators.
module nft_protocol::creators {
    use sui::vec_set::{Self, VecSet};
    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::utils::{
        assert_with_consumable_witness, UidType
    };
    use nft_protocol::consumable_witness::{Self as cw, ConsumableWitness};

    /// No field object `Creators` defined as a dynamic field.
    const EUNDEFINED_CREATORS_DOMAIN: u64 = 1;

    /// Field object `Creators` already defined as dynamic field.
    const ECREATORS_FIELD_ALREADY_EXISTS: u64 = 2;

    /// Address was not attributed as a creator
    const EUNDEFINED_ADDRESS: u64 = 3;

    /// `Creators` tracks collection creators
    ///
    /// #### Usage
    ///
    /// Originbyte Standard domains will authenticate mutable operations for
    /// transaction senders which are creators using
    /// `assert_collection_has_creator`.
    ///
    /// `Creators` can additionally be frozen which will cause
    /// `assert_collection_has_creator` to always fail, therefore, allowing
    /// creators to lock in their NFT collection.
    struct Creators has store {
        /// Creators that have the ability to mutate standard domains
        creators: VecSet<address>,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Key struct used to store Attributes in dynamic fields
    struct CreatorsKey has store, copy, drop {}

    // === Insert with ConsumableWitness ===

    /// Adds `Creators` as a dynamic field with key `CreatorsKey`.
    /// It adds creators from a `VecSet<address>`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Creators`.
    ///
    /// #### Panics
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun add_creators<T: key + store>(
        consumable: ConsumableWitness<T>,
        object_uid: &mut UID,
        object_type: UidType<T>,
        creators: VecSet<address>,
    ) {
        assert_has_not_creators(object_uid);
        assert_with_consumable_witness(object_uid, object_type);

        let creators = from_creators(creators);

        cw::consume<T, Creators>(consumable, &mut creators);
        df::add(object_uid, CreatorsKey {}, creators);
    }

    /// Adds `Creators` as a dynamic field with key `CreatorsKey`.
    /// It adds a single `address` to the creators object.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Creators`.
    ///
    /// #### Panics
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun add_singleton<T: key + store>(
        consumable: ConsumableWitness<T>,
        object_uid: &mut UID,
        object_type: UidType<T>,
        creator: address,
    ) {
        assert_has_not_creators(object_uid);
        assert_with_consumable_witness(object_uid, object_type);

        let creators = singleton(creator);

        cw::consume<T, Creators>(consumable, &mut creators);
        df::add(object_uid, CreatorsKey {}, creators);
    }

    /// Adds empty `Creators` as a dynamic field with key `CreatorsKey`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Creators`.
    ///
    /// #### Panics
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun add_empty<T: key + store>(
        consumable: ConsumableWitness<T>,
        object_uid: &mut UID,
        object_type: UidType<T>,
    ) {
        assert_has_not_creators(object_uid);
        assert_with_consumable_witness(object_uid, object_type);

        let creators = empty();

        cw::consume<T, Creators>(consumable, &mut creators);
        df::add(object_uid, CreatorsKey {}, creators);
    }


    // === Get for call from external Module ===


    /// Creates a `Creators` with multiple creators
    public fun from_creators(
        creators: VecSet<address>,
    ): Creators {
        Creators {
            creators,
        }
    }

    /// Creates a `Creators` object with only one creator
    public fun singleton(
        who: address,
    ): Creators {
        let creators = vec_set::empty();
        vec_set::insert(&mut creators, who);

        from_creators(creators)
    }

    /// Creates an empty `Creators` object
    public fun empty(): Creators {
        from_creators(vec_set::empty())
    }


    // === Field Borrow Functions ===


    /// Borrows immutably the `Creators` field.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `CreatorsKey` does not exist.
    public fun borrow_creators(
        object_uid: &UID,
    ): &Creators {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_creators(object_uid);
        df::borrow(object_uid, CreatorsKey {})
    }

    /// Borrows Mutably the `Creators` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Creators`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `CreatorsKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun borrow_creators_mut<T: key>(
        consumable: ConsumableWitness<T>,
        object_uid: &mut UID,
        object_type: UidType<T>
    ): &mut Creators {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_creators(object_uid);
        assert_with_consumable_witness(object_uid, object_type);

        let creators = df::borrow_mut<CreatorsKey, Creators>(
            object_uid,
            CreatorsKey {}
        );
        cw::consume<T, Creators>(consumable, creators);

        creators
    }


    // === Writer Functions ===

    /// Inserts address to `Creators` field in object `T`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Creators`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `CreatorsKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun insert_creator<T: key>(
        consumable: ConsumableWitness<T>,
        object_uid: &mut UID,
        object_type: UidType<T>,
        who: address,
    ) {
       // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_creators(object_uid);
        assert_with_consumable_witness(object_uid, object_type);

        let creators = borrow_mut_internal(object_uid);
        cw::consume<T, Creators>(consumable, creators);

        vec_set::insert(&mut creators.creators, who);
    }

    /// Removes address from `Creators` field in object `T`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Creators`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `CreatorsKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun remove_creator<T: key>(
        consumable: ConsumableWitness<T>,
        object_uid: &mut UID,
        object_type: UidType<T>,
        who: address,
    ) {
       // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_creators(object_uid);
        assert_with_consumable_witness(object_uid, object_type);

        let creators = borrow_mut_internal(object_uid);
        cw::consume<T, Creators>(consumable, creators);

        vec_set::remove(&mut creators.creators, &who);
    }


    // === Getter Functions & Static Mutability Accessors ===

    /// Returns an immutable reference to the list of creators
    /// defined on the `Creators`.
    public fun get_creators(
        creators: &Creators,
    ): &VecSet<address> {
        &creators.creators
    }

    /// Returns a mutable reference to the list of creators
    /// defined on the `Creators`.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Creators`.
    public fun get_creators_mut(
        creators: &mut Creators,
    ): &mut VecSet<address> {
        &mut creators.creators
    }


    // === Private Functions ===


    /// Borrows Mutably the `Creators` field.
    ///
    /// For internal use only.
    fun borrow_mut_internal(
        object_uid: &mut UID,
    ): &mut Creators {
        df::borrow_mut<CreatorsKey, Creators>(
            object_uid,
            CreatorsKey {}
        )
    }


    // === Assertions & Helpers ===

    /// Checks that a given Object has a dynamic field with `AttributesKey`
    public fun has_creators(
        object_uid: &UID,
    ): bool {
        df::exists_(object_uid, CreatorsKey {})
    }

    /// Returns whether address is a defined creator
    public fun contains_creator(
        creators: &Creators,
        who: &address,
    ): bool {
        vec_set::contains(&creators.creators, who)
    }

    /// Returns whether `Creators` has no defined creators
    public fun is_empty(domain: &Creators): bool {
        vec_set::is_empty(&domain.creators)
    }

    /// Asserts that address is a creator attributed in `Creators`
    ///
    /// #### Panics
    ///
    /// Panics if `Creators` is not defined or address is not an
    /// attributed creator.
    public fun assert_creator(
        domain: &Creators,
        who: &address
    ) {
        assert!(contains_creator(domain, who), EUNDEFINED_ADDRESS);
    }

    public fun assert_has_creators(object_uid: &UID) {
        assert!(has_creators(object_uid), EUNDEFINED_CREATORS_DOMAIN);
    }

    public fun assert_has_not_creators(object_uid: &UID) {
        assert!(!has_creators(object_uid), ECREATORS_FIELD_ALREADY_EXISTS);
    }
}
