// TODO: Where does it make sense to control supply?
// TODO: Where does it make sense to control ownership of the shared data object?
// This should ideally be controlled solely by the NFT Creators..
module nft_protocol::class {
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

    struct ClassData has key, store {
        id: UID,
        data: ID,
    }

    struct Class has key, store {
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

    /// Create a `Class` object and shares it.
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

        let class = Class {
            id,
            supply: supply::new(supply, false),
            mint_authority: collection::mint_id(mint),
            bag: bag::new(ctx),
        };

        collection::increment_supply(mint, 1);

        transfer::share_object(class);
    }

    /// Create a `ClassData` object and adds it to NFT.
    public fun mint_instance<C>(
        ctx: &mut TxContext,
        nft: &mut NFT<C>,
        class: &mut Class,
        mint: &MintAuthority<C>,
    ) {
        let id = object::new(ctx);

        supply::increment_supply(&mut class.supply, 1);

        let class_data = ClassData {
            id,
            data: id(class),
        };

        nft::add_domain(nft, class_data, ctx);
    }

    // === Domain Functions ===

    public fun has_domain<C, D: store>(class: &Class): bool {
        bag::contains_with_type<DomainKey, D>(&class.bag, domain_key<D>())
    }

    public fun borrow_domain<C, D: store>(class: &Class): &D {
        bag::borrow<DomainKey, D>(&class.bag, domain_key<D>())
    }

    public fun borrow_domain_mut<C, D: store, W: drop>(
        _witness: W,
        class: &mut Class,
    ): &mut D {
        utils::assert_same_module_as_witness<W, D>();
        bag::borrow_mut<DomainKey, D>(&mut class.bag, domain_key<D>())
    }

    public fun add_domain<C, V: store>(
        class: &mut Class,
        mint: &MintAuthority<C>,
        v: V,
        ctx: &mut TxContext,
    ) {
        assert!(
            collection::mint_id(mint) == class.mint_authority,
            err::mint_authority_mismatch()
        );

        bag::add(&mut class.bag, domain_key<V>(), v);
    }

    public fun remove_domain<C, W: drop, V: store>(
        _witness: W,
        class: &mut Class,
    ): V {
        utils::assert_same_module_as_witness<W, V>();
        bag::remove(&mut class.bag, domain_key<V>())
    }

    // === Getter Functions  ===

    public fun id(
        core: &Class,
    ): ID {
        object::uid_to_inner(&core.id)
    }

    public fun id_ref(
        core: &Class,
    ): &ID {
        object::uid_as_inner(&core.id)
    }
}
