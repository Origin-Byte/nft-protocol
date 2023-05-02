/// Module defining the OriginByte `Collection` and `MintCap` types
///
/// Conceptually, we can think of NFTs as being organized into collections; a
/// one-to-many relational data model.
///
/// OriginByte collections serve two purposes, to centralise collection level
/// information on one object and thus avoid redundancy, and to provide
/// configuration data to NFTs.
module nft_protocol::collection {
    use std::type_name::{Self, TypeName};
    use std::option::Option;
    use std::string;

    use sui::event;
    use sui::display::{Self, Display};
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::TxContext;
    use sui::dynamic_field as df;

    use nft_protocol::mint_cap::{Self, MintCap};
    use ob_permissions::witness::Witness as DelegatedWitness;
    use ob_utils::utils::{Self, marker, Marker};
    use ob_permissions::frozen_publisher::{Self, FrozenPublisher};

    // Track the current version of the module
    const VERSION: u64 = 1;

    const ENotUpgrade: u64 = 999;
    const EWrongVersion: u64 = 1000;

    /// Domain not defined
    ///
    /// Call `collection::add_domain` to add domains
    const EUndefinedDomain: u64 = 1;

    /// Domain already defined
    ///
    /// Call `collection::borrow` to borrow domain
    const EExistingDomain: u64 = 2;

    struct Witness has drop {}

    /// NFT `Collection` object
    ///
    /// OriginByte collections have a generic parameter `C` which is a
    /// one-time witness created by the creator's NFT collection module. This
    /// allows `Collection` and `Nft` to be linked via module association, but
    /// also ensures that NFTs can only be minted by the contract that
    /// initially deployed them.
    ///
    /// A `Collection`, exclusively owns domains of different
    /// types, which can be dynamically acquired and lost over its lifetime.
    /// OriginByte collections are modelled after
    /// [Entity Component Systems](https://en.wikipedia.org/wiki/Entity_component_system),
    /// where their domains are accessible by type. See
    /// [borrow_domain_mut](#borrow_domain_mut).
    struct Collection<phantom T> has key, store {
        /// `Collection` ID
        id: UID,
        version: u64,
    }

    /// Event signalling that a `Collection` was minted
    struct MintCollectionEvent has copy, drop {
        /// ID of the `Collection` that was minted
        collection_id: ID,
        /// Type name of `Collection<C>` one-time witness `C`
        ///
        /// Intended to allow users to filter by collections of interest.
        type_name: TypeName,
    }

    /// Creates a `Collection<T>`
    ///
    /// `T` will typically be the one-time witness for the contract and can be
    /// created using the shorthand `create_from_otw`.
    public fun create<T>(
        _witness: DelegatedWitness<T>,
        ctx: &mut TxContext,
    ): Collection<T> {
        create_(ctx)
    }

    /// Creates a `Collection<T>` from the one-time witness of the contract
    ///
    /// #### Panics
    ///
    /// Panics if one-time witness is not defined in the same module as `T`.
    public fun create_from_otw<OTW: drop, T>(
        _witness: &OTW,
        ctx: &mut TxContext,
    ): Collection<T> {
        utils::assert_same_module<OTW, T>();
        create_(ctx)
    }

    /// Creates a `Collection<T>`, and a `MintCap<T>` and returns it.
    ///
    /// #### Panics
    ///
    /// Panics if one-time witness is not defined in the same module as `T`.
    public fun create_with_mint_cap<OTW: drop, T>(
        witness: &OTW,
        supply: Option<u64>,
        ctx: &mut TxContext,
    ): (Collection<T>, MintCap<T>) {
        let collection = create_from_otw(witness, ctx);
        let mint_cap = mint_cap::new(witness, object::id(&collection), supply, ctx);

        (collection, mint_cap)
    }

    /// Create a `Collection<T>`
    fun create_<T>(ctx: &mut TxContext): Collection<T> {
        let id = object::new(ctx);

        event::emit(MintCollectionEvent {
            collection_id: object::uid_to_inner(&id),
            type_name: type_name::get<T>(),
        });

        Collection { id, version: VERSION }
    }

    /// Creates a shared `Collection<C>`, where `C` will typically be the
    /// One-Time Witness of the collection.
    ///
    /// #### Panics
    ///
    /// Panics if witness is not defined in the same module as `C`.
    public fun init_collection<C>(
        witness: DelegatedWitness<C>,
        ctx: &mut TxContext,
    ): ID {
        let collection = create(witness, ctx);
        let collection_id = object::id(&collection);

        transfer::public_share_object(collection);
        collection_id
    }

    // === Domain Functions ===

    /// Delegates `&UID` for domain specified extensions of `Collection`
    public fun borrow_uid<C>(collection: &Collection<C>): &UID {
        &collection.id
    }

    /// Delegates `&mut UID` for domain specified extensions of `Collection`
    public fun borrow_uid_mut<C>(
        _witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
    ): &mut UID {
        &mut collection.id
    }

    /// Check whether `Collection` has domain
    public fun has_domain<C, Domain: store>(
        collection: &Collection<C>,
    ): bool {
        df::exists_with_type<Marker<Domain>, Domain>(
            &collection.id, marker<Domain>(),
        )
    }

    /// Borrow domain from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if domain is not present on the `Collection`
    public fun borrow_domain<C, Domain: store>(
        collection: &Collection<C>
    ): &Domain {
        assert_domain<C, Domain>(collection);
        df::borrow(&collection.id, marker<Domain>())
    }

    /// Mutably borrow domain from `Collection`
    ///
    /// Guarantees that `Collection<C>` domains can only be mutated by the
    /// module that instantiated it. Allows domain contracts to remove the
    /// domains it defined from `Collection`.
    ///
    /// #### Panics
    ///
    /// Panics if domain does not exist.
    public fun borrow_domain_mut<C, Domain: store>(
        _witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
    ): &mut Domain {
        assert_domain<C, Domain>(collection);
        df::borrow_mut(
            &mut collection.id,
            marker<Domain>(),
        )
    }

    /// Adds domain to `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if domain already exists.
    public fun add_domain<C, Domain: store>(
        witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        domain: Domain,
    ) {
        assert_no_domain<C, Domain>(collection);
        df::add(
            borrow_uid_mut(witness, collection),
            marker<Domain>(),
            domain,
        );
    }

    /// Removes domain of type from `Collection`
    ///
    /// ##### Panics
    ///
    /// Panics if domain doesnt exist.
    public fun remove_domain<C, Domain: store>(
        _witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
    ): Domain {
        assert_domain<C, Domain>(collection);
        df::remove(
            &mut collection.id,
            marker<Domain>(),
        )
    }

    /// Deletes an `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if any domains are still registered on the `Collection`.
    public entry fun delete<C>(collection: Collection<C>) {
        let Collection { id, version: _ } = collection;
        object::delete(id);
    }

    // === Assertions ===

    /// Assert that domain exists on `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if domain does not exist on `Collection`.
    public fun assert_domain<C, Domain: store>(
        collection: &Collection<C>,
    ) {
        assert!(has_domain<C, Domain>(collection), EUndefinedDomain);
    }

    /// Assert that domain does not exist on `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if domain does exists on `Collection`.
    public fun assert_no_domain<C, Domain: store>(
        collection: &Collection<C>
    ) {
        assert!(!has_domain<C, Domain>(collection), EExistingDomain);
    }

    // === Display standard ===

    /// Creates a new `Display` with some default settings.
    public fun new_display<T: key + store>(
        _witness: DelegatedWitness<T>,
        pub: &FrozenPublisher,
        ctx: &mut TxContext,
    ): Display<Collection<T>> {
        let display =
            frozen_publisher::new_display<Witness, Collection<T>>(Witness {}, pub, ctx);

        display::add(&mut display, string::utf8(b"type"), string::utf8(b"Collection"));

        display
    }

    // === Upgradeability ===

    fun assert_version<T: key + store>(collection: &Collection<T>) {
        assert!(collection.version == VERSION, EWrongVersion);
    }

    // Only the publisher of type `T` can upgrade
    entry fun migrate_as_creator<T: key + store>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
    ) {
        collection.version = VERSION;
    }


    // === Test-Only ===

    #[test_only]
    public fun test_create_with_mint_cap<OTW: drop, T>(
        supply: Option<u64>,
        ctx: &mut TxContext,
    ): (Collection<T>, MintCap<T>) {
        let collection = create_(ctx);
        let mint_cap = mint_cap::test_create_mint_cap(
            object::id(&collection), supply, ctx
        );

        (collection, mint_cap)
    }
}
