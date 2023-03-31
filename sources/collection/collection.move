/// Module defining the OriginByte `Collection` and `MintCap` types
///
/// Conceptually, we can think of NFTs as being organized into collections; a
/// one-to-many relational data model.
///
/// OriginByte collections serve two purposes, to centralise collection level
/// information on one object and thus avoid redundancy, and to provide
/// configuration data to NFTs.
module nft_protocol::collection {
    use std::option;
    use std::type_name::{Self, TypeName};

    use sui::event;
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::TxContext;
    use sui::dynamic_field as df;

    use nft_protocol::witness;
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::witness::Witness as DelegatedWitness;

    /// Domain not defined
    ///
    /// Call `collection::add_domain` to add domains
    const EUndefinedDomain: u64 = 1;

    /// Domain already defined
    ///
    /// Call `collection::borrow` to borrow domain
    const EExistingDomain: u64 = 2;

    /// NFT `Collection` object
    ///
    /// OriginByte collections and NFTs have a generic parameter `T` which is a
    /// one-time witness created by the creator's NFT collection module. This
    /// allows `Collection` and `Nft` to be linked via type association, but
    /// also ensures that NFTs can only be minted by the contract that
    /// initially deployed them.
    ///
    /// A `Collection`, like each `Nft`, exclusively owns domains of different
    /// types, which can be dynamically acquired and lost over its lifetime.
    /// OriginByte collections are modelled after
    /// [Entity Component Systems](https://en.wikipedia.org/wiki/Entity_component_system),
    /// where their domains are accessible by type. See
    /// [borrow_domain_mut](#borrow_domain_mut).
    struct Collection<phantom T> has key, store {
        /// `Collection` ID
        id: UID,
    }

    /// Event signalling that a `Collection` was minted
    struct MintCollectionEvent has copy, drop {
        /// ID of the `Collection` that was minted
        collection_id: ID,
        /// Type name of `Collection<T>` one-time witness `T`
        ///
        /// Intended to allow users to filter by collections of interest.
        type_name: TypeName,
    }

    /// Witness used to authorize collection creation
    struct Witness has drop {}

    /// Creates a `Collection<T>` and corresponding `MintCap<T>`
    ///
    /// #### Panics
    ///
    /// Panics if witness is not defined in the same module as `T`.
    ///
    /// #### Usage
    ///
    /// ```
    /// struct FOOTBALL has drop {}
    ///
    /// fun init(witness: FOOTBALL, ctx: &mut TxContext) {
    ///     let (mint_cap, collection) = collection::create(&witness, ctx);
    /// }
    /// ```
    public fun create<W: drop, T>(
        _witness: W,
        ctx: &mut TxContext,
    ): (MintCap<T>, Collection<T>) {
        utils::assert_same_module_as_witness<T, W>();

        let id = object::new(ctx);

        event::emit(MintCollectionEvent {
            collection_id: object::uid_to_inner(&id),
            type_name: type_name::get<T>(),
        });

        let cap = mint_cap::new(object::uid_to_inner(&id), option::none(), ctx);

        (cap, Collection { id })
    }

    /// Creates a shared `Collection<T>` and corresponding `MintCap<T>`
    ///
    /// #### Panics
    ///
    /// Panics if witness is not defined in the same module as `T`.
    public fun init_collection<W: drop, T>(
        witness: W,
        owner: address,
        ctx: &mut TxContext,
    ) {
        let (mint_cap, collection) = create<W, T>(witness, ctx);
        transfer::public_share_object(collection);
        transfer::public_transfer(mint_cap, owner);
    }

    // === Domain Functions ===

    /// Delegates `&UID` for domain specified extensions of `Nft`
    public fun borrow_uid<T>(collection: &Collection<T>): &UID {
        &collection.id
    }

    /// Delegates `&mut UID` for domain specified extensions of `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if witness `W` does not originate from the same module as `T`.
    public fun borrow_uid_mut<T, W: drop>(
        witness: W,
        collection: &mut Collection<T>,
    ): &mut UID {
        borrow_uid_delegated_mut(
            witness::from_witness<T, W>(witness),
            collection,
        )
    }

    /// Delegates `&mut UID` for domain specified extensions of `Nft`
    public fun borrow_uid_delegated_mut<T>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
    ): &mut UID {
        &mut collection.id
    }

    /// Check whether `Collection` has domain
    public fun has_domain<T, Domain: store>(
        collection: &Collection<T>,
    ): bool {
        df::exists_with_type<Marker<Domain>, Domain>(
            &collection.id, utils::marker<Domain>(),
        )
    }

    /// Borrow domain from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if domain is not present on the `Collection`
    public fun borrow_domain<T, Domain: store>(
        collection: &Collection<T>
    ): &Domain {
        assert_domain<T, Domain>(collection);
        df::borrow(&collection.id, utils::marker<Domain>())
    }

    /// Mutably borrow domain from `Nft`
    ///
    /// Guarantees that `Collection<T>` domains can only be mutated by the
    /// module that instantiated it.
    ///
    /// #### Panics
    ///
    /// Panics if domain does not exist or if witness `W` does not originate
    /// from the same module as `T`.
    public fun borrow_domain_mut<T, Domain: store, W: drop>(
        witness: W,
        collection: &mut Collection<T>,
    ): &mut Domain {
        borrow_domain_delegated_mut(
            witness::from_witness<T, W>(witness),
            collection,
        )
    }

    /// Mutably borrow domain from `Collection`
    ///
    /// Guarantees that `Collection<T>` domains can only be mutated by the module that
    /// instantiated it.
    ///
    /// #### Panics
    ///
    /// Panics if domain does not exist or if witness `W` does not originate
    /// from the same module as `T`.
    public fun borrow_domain_delegated_mut<T, Domain: store>(
        witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
    ): &mut Domain {
        assert_domain<T, Domain>(collection);
        df::borrow_mut(
            borrow_uid_delegated_mut(witness, collection),
            utils::marker<Domain>(),
        )
    }

    /// Adds domain to `Collection`
    ///
    /// Helper method that can be simply used without knowing what a delegated
    /// witness is.
    ///
    /// #### Panics
    ///
    /// Panics if domain already exists or if witness `W` does not originate
    /// from the same module as `T`.
    public fun add_domain<T, Domain: store, W: drop>(
        witness: W,
        collection: &mut Collection<T>,
        domain: Domain,
    ) {
        add_domain_delegated(
            witness::from_witness(witness),
            collection,
            domain,
        )
    }

    /// Adds domain to `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if domain already exists or if witness `W` does not originate
    /// from the same module as `T`.
    public fun add_domain_delegated<T, Domain: store>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        domain: Domain,
    ) {
        assert_no_domain<T, Domain>(collection);
        df::add(&mut collection.id, utils::marker<Domain>(), domain);
    }

    /// Removes domain of type from `Nft`
    ///
    /// ##### Panics
    ///
    /// Panics if domain doesnt exist or if witness `W` does not originate from
    /// the same module as `C`.
    public fun remove_domain<T, Domain: store, W: drop>(
        witness: W,
        collection: &mut Collection<T>,
    ): Domain {
        assert_domain<T, Domain>(collection);
        remove_domain_delegated(
            witness::from_witness(witness),
            collection,
        )
    }

    /// Removes domain of type from `Nft`
    ///
    /// ##### Panics
    ///
    /// Panics if domain doesnt exist.
    public fun remove_domain_delegated<T, Domain: store>(
        witness: DelegatedWitness<T>,
        nft: &mut Collection<T>,
    ): Domain {
        assert_domain<T, Domain>(nft);
        df::remove(
            borrow_uid_delegated_mut(witness, nft),
            utils::marker<Domain>(),
        )
    }

    /// Deletes an `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if any domains are still registered on the `Collection`.
    public entry fun delete<T>(collection: Collection<T>) {
        let Collection { id } = collection;
        object::delete(id);
    }

    // === Assertions ===

    /// Assert that domain exists on `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if domain does not exist on `Collection`.
    public fun assert_domain<T, Domain: store>(
        collection: &Collection<T>,
    ) {
        assert!(has_domain<T, Domain>(collection), EUndefinedDomain);
    }

    /// Assert that domain does not exist on `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if domain does exists on `Collection`.
    public fun assert_no_domain<T, Domain: store>(
        collection: &Collection<T>
    ) {
        assert!(!has_domain<T, Domain>(collection), EExistingDomain);
    }
}
