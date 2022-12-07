// TODO: Where does it make sense to control supply?
// TODO: Where does it make sense to control ownership of the shared data object?
// This should ideally be controlled solely by the NFT Creators..
module nft_protocol::flyweight {
    use sui::event;
    use sui::transfer;
    use sui::bag::{Self, Bag};
    use sui::tx_context::{TxContext};
    use sui::object::{Self, UID, ID};

    use nft_protocol::err;
    use nft_protocol::utils;
    use nft_protocol::nft::{Self, NFT};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::collection::{Self, MintAuthority};
    use nft_protocol::domain::{domain_key, DomainKey};

    struct Pointer has key, store {
        id: UID,
        data: ID,
    }

    struct State<phantom C> has key, store {
        id: UID,
        bag: Bag,
        supply: Supply,
        mint_authority: ID,
    }

    struct MintEvent has copy, drop {
        id: ID,
    }

    struct BurnEvent has copy, drop {
        id: ID,
    }

    /// Create a `State` object and shares it.
    public fun create<C>(
        ctx: &mut TxContext,
        supply: u64,
        mint: &mut MintAuthority<C>,
    ) {
        let id = object::new(ctx);

        event::emit(
            MintEvent {
                id: object::uid_to_inner(&id),
            }
        );

        let state = State<C> {
            id,
            supply: supply::new(supply, false),
            mint_authority: collection::mint_id(mint),
            bag: bag::new(ctx),
        };

        collection::increment_supply(mint, 1);

        transfer::share_object(state);
    }

    /// Create a `Pointer` object and adds it to NFT.
    public fun mint_instance<C>(
        ctx: &mut TxContext,
        nft: &mut NFT<C>,
        state: &mut State<C>,
        _mint: &MintAuthority<C>,
    ) {
        let id = object::new(ctx);

        supply::increment_supply(&mut state.supply, 1);

        let pointer = Pointer {
            id,
            data: object::id(state),
        };

        nft::add_domain(nft, pointer, ctx);
    }

    // === Domain Functions ===

    public fun has_domain<C, D: store>(state: &State<C>): bool {
        bag::contains_with_type<DomainKey, D>(&state.bag, domain_key<D>())
    }

    public fun borrow_domain<C, D: store>(state: &State<C>): &D {
        bag::borrow<DomainKey, D>(&state.bag, domain_key<D>())
    }

    public fun borrow_domain_mut<C, D: store, W: drop>(
        _witness: W,
        state: &mut State<C>,
    ): &mut D {
        utils::assert_same_module_as_witness<W, D>();
        bag::borrow_mut<DomainKey, D>(&mut state.bag, domain_key<D>())
    }

    public fun add_domain<C, V: store>(
        state: &mut State<C>,
        mint: &MintAuthority<C>,
        v: V,
    ) {
        assert!(
            collection::mint_id(mint) == state.mint_authority,
            err::mint_authority_mismatch()
        );

        bag::add(&mut state.bag, domain_key<V>(), v);
    }

    public fun remove_domain<C, W: drop, V: store>(
        _witness: W,
        state: &mut State<C>,
    ): V {
        utils::assert_same_module_as_witness<W, V>();
        bag::remove(&mut state.bag, domain_key<V>())
    }
}
