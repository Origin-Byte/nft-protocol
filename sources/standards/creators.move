/// Module of Collection `Creators`
///
/// `Creators` tracks all collection creators.
module nft_protocol::creators {
    use sui::vec_set::{Self, VecSet};
    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::utils::{
        assert_with_consumable_witness, assert_with_witness, UidType
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
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun add_creators<T: key + store>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        creators: VecSet<address>,
    ) {
        assert_has_not_creators(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let creators = from_creators(creators);

        cw::consume<T, Creators>(consumable, &mut creators);
        df::add(nft_uid, CreatorsKey {}, creators);
    }

    /// Adds `Creators` as a dynamic field with key `CreatorsKey`.
    /// It adds a single `address` to the creators object.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun add_singleton<T: key + store>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        creator: address,
    ) {
        assert_has_not_creators(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let creators = singleton(creator);

        cw::consume<T, Creators>(consumable, &mut creators);
        df::add(nft_uid, CreatorsKey {}, creators);
    }

    /// Adds empty `Creators` as a dynamic field with key `CreatorsKey`.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun add_empty<T: key + store>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
    ) {
        assert_has_not_creators(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let creators = empty();

        cw::consume<T, Creators>(consumable, &mut creators);
        df::add(nft_uid, CreatorsKey {}, creators);
    }


    // === Insert with module specific Witness ===


    /// Adds `Creators` as a dynamic field with key `CreatorsKey`.
    /// It adds creators from a `VecSet<address>`.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun add_creators_<W: drop, T: key + store>(
        _witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        creators: VecSet<address>,
    ) {
        assert_has_not_creators(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let creators = from_creators(creators);
        df::add(nft_uid, CreatorsKey {}, creators);
    }

    /// Adds `Creators` as a dynamic field with key `CreatorsKey`.
    /// It adds a single `address` to the creators object.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun add_singleton_<W: drop, T: key + store>(
        _witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        creator: address,
    ) {
        assert_has_not_creators(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let creators = singleton(creator);
        df::add(nft_uid, CreatorsKey {}, creators);
    }

    /// Adds empty `Creators` as a dynamic field with key `CreatorsKey`.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun add_empty_<W: drop, T: key + store>(
        _witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
    ) {
        assert_has_not_creators(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let creators = empty();
        df::add(nft_uid, CreatorsKey {}, creators);
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
        nft_uid: &UID,
    ): &Creators {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_creators(nft_uid);
        df::borrow(nft_uid, CreatorsKey {})
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
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun borrow_creators_mut<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>
    ): &mut Creators {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_creators(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let creators = df::borrow_mut<CreatorsKey, Creators>(
            nft_uid,
            CreatorsKey {}
        );
        cw::consume<T, Creators>(consumable, creators);

        creators
    }

    /// Borrows Mutably the `Creators` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `CreatorsKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun borrow_creators_mut_<W: drop, T: key>(
        _witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>
    ): &mut Creators {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_creators(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let creators = df::borrow_mut<CreatorsKey, Creators>(
            nft_uid,
            CreatorsKey {}
        );

        creators
    }


    // === Writer Functions ===

    /// Inserts address to `Creators` field in the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Creators`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `CreatorsKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun insert_creator<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        who: address,
    ) {
       // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_creators(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let creators = borrow_creators_mut(consumable, nft_uid, nft_type);
        cw::consume<T, Creators>(consumable, creators);

        vec_set::insert(&mut creators.creators, who);
    }

    /// Removes address from `Creators` field in the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Creators`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `CreatorsKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun remove_creator<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        who: address,
    ) {
       // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_creators(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let creators = borrow_creators_mut(consumable, nft_uid, nft_type);

        vec_set::remove(&mut creators.creators, &who);
    }

    /// Inserts address to `Creators` field in the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun insert_creator_<W: drop, T: key>(
        witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        who: address,
    ) {
       // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_creators(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let creators = borrow_creators_mut_(witness, nft_uid, nft_type);

        vec_set::insert(&mut creators.creators, who);
    }

    /// Removes address from `Creators` field in the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun remove_creator_<W: drop, T: key>(
        witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        who: address,
    ) {
       // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_creators(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let creators = borrow_creators_mut_(witness, nft_uid, nft_type);

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
    public fun get_creators_mut(
        creators: &mut Creators,
    ): &mut VecSet<address> {
        &mut creators.creators
    }


    // === Assertions & Helpers ===

    /// Checks that a given NFT has a dynamic field with `AttributesKey`
    public fun has_creators(
        nft_uid: &UID,
    ): bool {
        df::exists_(nft_uid, CreatorsKey {})
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

    public fun assert_has_creators(nft_uid: &UID) {
        assert!(has_creators(nft_uid), EUNDEFINED_CREATORS_DOMAIN);
    }

    public fun assert_has_not_creators(nft_uid: &UID) {
        assert!(!has_creators(nft_uid), ECREATORS_FIELD_ALREADY_EXISTS);
    }
}
