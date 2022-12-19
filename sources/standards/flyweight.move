//! Module of Nft Flyweight domain.
//!
//! The flyweight domain is responsible for the implementation of the
//! loose NFT pattern. Where NFT data live in the `Archetype` object and
//! `Nft`s have a `Pointer` to it.
//!
//! The loose NFT pattern is based on the flyweight pattern, which is a design
//! pattern that achieves storage and memory efficiency by sharing common parts
//! of state between multiple objects instead of keeping all of the data
//! in each object.
//!
//! For more on the design pattern:
//! https://refactoring.guru/design-patterns/flyweight
//!
//! Embedded NFTs, contrary to loose NFTs, hold their own data, and therefore
//! the minting of data and the NFT itself can happen in one single step. With
//! Loose NFTs however, the data Archetype is first minted and only then the
//! NFT(s) associated to that object is(are) minted.
//!
//! Embedded NFTs are nevertheless only useful to represent 1-to-1 relationships
//! between the NFT object and the data. In contrast, loose NFTs can
//! represent 1-to-many relationships. Essentially this allows us to build
//! NFTs which effectively have a supply.
module nft_protocol::flyweight {
    // TODO: Where does it make sense to control supply?
    // TODO: Where does it make sense to control ownership of the shared data object?
    // This should ideally be controlled solely by the NFT Creators..
    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};
    use sui::object_table::{Self, ObjectTable};

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::collection::{Self, Collection, MintCap};

    struct Pointer has key, store {
        id: UID,
        data: ID,
    }

    struct Archetype<phantom C> has key, store {
        id: UID,
        nft: Nft<C>,
        supply: Supply,
        mint_authority: ID,
    }

    struct Registry<phantom C> has key, store {
        id: UID,
        table: ObjectTable<ID, Archetype<C>>,
    }

    struct MintEvent has copy, drop {
        id: ID,
    }

    struct BurnEvent has copy, drop {
        id: ID,
    }

    /// Create a `Archetype` object and shares it.
    public fun new<C>(
        supply: u64,
        mint: &mut MintCap<C>,
        ctx: &mut TxContext,
    ): Archetype<C> {
        let id = object::new(ctx);

        event::emit(
            MintEvent {
                id: object::uid_to_inner(&id),
            }
        );

        let owner = object::id_to_address(&object::id(mint));

        let nft = nft::new<C>(owner, ctx);

        collection::increment_supply(mint, 1);

        Archetype<C> {
            id,
            nft,
            supply: supply::new(supply, false),
            mint_authority: object::id(mint),
        }
    }

    /// Create a `Registry` object
    public fun init_registry<C>(
        ctx: &mut TxContext,
        _mint: &MintCap<C>,
    ): Registry<C> {
        Registry<C> {
            id: object::new(ctx),
            table: object_table::new<ID, Archetype<C>>(ctx),
        }
    }

    public fun add_archetype<C>(
        state: Archetype<C>,
        registry: &mut Registry<C>,
        _mint: &MintCap<C>,
    ) {
        object_table::add<ID, Archetype<C>>(
            &mut registry.table,
            object::id(&state),
            state,
        );
    }

    /// Create a `Pointer` object and adds it to NFT.
    public fun set_archetype<C>(
        ctx: &mut TxContext,
        nft: &mut Nft<C>,
        state: &mut Archetype<C>,
        _mint: &MintCap<C>,
    ) {
        let id = object::new(ctx);

        supply::increment_supply(&mut state.supply, 1);

        let pointer = Pointer {
            id,
            data: object::id(state),
        };

        nft::add_domain(nft, pointer, ctx);
    }

    public fun add_archetypes_domain<C>(
        collection: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        registry: Registry<C>,
    ) {
        collection::add_domain(collection, mint_cap, registry);
    }

    // === Domain Functions ===

    public fun borrow_nft<C>(state: &Archetype<C>): &Nft<C> {
        &state.nft
    }

    public fun borrow_nft_mut<C>(
        state: &mut Archetype<C>,
        _mint: &MintCap<C>,
    ): &mut Nft<C> {
        &mut state.nft
    }
}
