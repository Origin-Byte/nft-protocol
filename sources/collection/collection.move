/// Module of a generic `Collection` type and a `MintAuthority` type.
///
/// It acts as a generic interface for NFT Collections and it allows for
/// the creation of arbitrary domain specific implementations.
///
/// The `MintAuthority` object gives power to the owner to mint objects.
/// There is only one `MintAuthority` per `Collection`.
module nft_protocol::collection {
    use std::type_name::{Self, TypeName};

    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::TxContext;
    use sui::bag::{Self, Bag};

    use nft_protocol::err;
    use nft_protocol::utils::{Self, Marker};

    /// An NFT `Collection` object with a generic `M`etadata.
    ///
    /// The `Metadata` is a type exported by an upstream contract which is
    /// used to store additional information about the NFT.
    struct Collection<phantom T> has key, store {
        id: UID,
        /// Domain storage equivalent to NFT domains which allows collections
        /// to implement custom metadata.
        domains: Bag,
    }

    /// The `MintCapability` object gives power to the owner to mint objects.
    /// There is only one `MintCapability` per `Collection`.
    struct MintCap<phantom T> has key, store {
        id: UID,
        // For discovery purposes
        collection_id: ID,
    }

    /// Event signalling that a `Collection` was minted
    struct CollectionMintEvent has copy, drop {
        collection_id: ID,
        type_name: TypeName,
    }

    /// Initialises a `MintAuthority` and transfers it to `authority` and
    /// initializes a `Collection` object and returns it. The `MintAuthority`
    /// object gives power to the owner to mint objects. There is only one
    /// `MintAuthority` per `Collection`.
    public fun create<C>(
        _witness: &C,
        ctx: &mut TxContext,
    ): (MintCap<C>, Collection<C>) {
        let id = object::new(ctx);

        event::emit(CollectionMintEvent {
            collection_id: object::uid_to_inner(&id),
            type_name: type_name::get<CollectionMintEvent>(),
        });

        let cap = create_mint_cap<C>(object::uid_to_inner(&id), ctx);
        let col = Collection { id, domains: bag::new(ctx) };
        (cap, col)
    }

    // === Domain Functions ===

    public fun has_domain<C, D: store>(collection: &Collection<C>): bool {
        bag::contains_with_type<Marker<D>, D>(
            &collection.domains, utils::marker<D>()
        )
    }

    public fun borrow_domain<C, D: store>(collection: &Collection<C>): &D {
        bag::borrow<Marker<D>, D>(&collection.domains, utils::marker<D>())
    }

    public fun borrow_domain_mut<C, D: store, W: drop>(
        _witness: W,
        collection: &mut Collection<C>,
    ): &mut D {
        utils::assert_same_module_as_witness<D, W>();
        bag::borrow_mut<Marker<D>, D>(
            &mut collection.domains, utils::marker<D>()
        )
    }

    public fun add_domain<C, V: store>(
        collection: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        v: V,
    ) {
        assert_mint_cap(mint_cap, collection);
        bag::add(&mut collection.domains, utils::marker<V>(), v);
    }

    public fun remove_domain<C, W: drop, V: store>(
        _witness: W,
        collection: &mut Collection<C>,
    ): V {
        utils::assert_same_module_as_witness<W, V>();
        bag::remove(&mut collection.domains, utils::marker<V>())
    }

    // === MintCap ===

    fun create_mint_cap<C>(
        collection_id: ID,
        ctx: &mut TxContext,
    ): MintCap<C> {
        MintCap {
            id: object::new(ctx),
            collection_id: collection_id,
        }
    }

    public fun mint_collection_id<C>(
        mint: &MintCap<C>,
    ): ID {
        mint.collection_id
    }

    // === Assertions ===

    public fun assert_mint_cap<C>(
        cap: &MintCap<C>,
        collection: &Collection<C>
    ) {
        assert!(
            cap.collection_id == object::id(collection),
            err::mint_cap_mismatch()
        );
    }

    // === Test only helpers ===

    #[test_only]
    public fun dummy_collection<C>(
        witness: &C,
        creator: address,
        scenario: &mut sui::test_scenario::Scenario,
    ): (MintCap<C>, Collection<C>) {
        sui::test_scenario::next_tx(scenario, creator);

        let (cap, col) = create<C>(
            witness,
            sui::test_scenario::ctx(scenario),
        );

        (cap, col)
    }
}
