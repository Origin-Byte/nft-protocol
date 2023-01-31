module nft_protocol::flyweight_archetype {
    use sui::transfer;
    use sui::dynamic_field as df;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::utils;
    use nft_protocol::nft::Nft;
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::mint_cap::{Self, RegulatedMintCap, UnregulatedMintCap};

    use nft_protocol::flyweight_mint_cap::{Self, ArchetypeMintCap};

    /// `Archetype` supply is unregulated
    ///
    /// Create an `Archetype` using `flyweight::new_regulated` to create a
    /// regulated `Archetype`.
    const EUNREGULATED_ARCHETYPE: u64 = 1;

    /// `Archetype` supply is regulated
    ///
    /// Create an `Archetype` using `flyweight::new_unregulated` to create an
    /// unregulated `Archetype`.
    const EREGULATED_ARCHETYPE: u64 = 2;

    /// `Archetype` object
    struct Archetype<phantom C> has key, store {
        id: UID,
        archetype: Nft<C>,
    }

    /// Create `Archetype` with unregulated supply
    ///
    /// Does not require that collection itself is unregulated as `Archetype`
    /// supply is independently regulated.
    public fun new_unregulated<C>(
        archetype: Nft<C>,
        ctx: &mut TxContext,
    ): Archetype<C> {
        Archetype<C> {
            id: object::new(ctx),
            archetype,
        }
    }

    /// Create `Archetype` with unregulated supply and transfer to transaction
    /// sender
    ///
    /// Does not require that collection itself is unregulated as `Archetype`
    /// supply is independently regulated.
    public entry fun create_unregulated<C>(
        archetype: Nft<C>,
        ctx: &mut TxContext
    ) {
        let archetype = new_unregulated(archetype, ctx);
        transfer::transfer(archetype, tx_context::sender(ctx));
    }

    /// Create `Archetype` with unregulated supply
    ///
    /// Does not require that collection itself is regulated as `Archetype`
    /// supply is independently regulated.
    public fun new_regulated<C>(
        archetype: Nft<C>,
        supply: u64,
        ctx: &mut TxContext,
    ): Archetype<C> {
        let archetype = new_unregulated(archetype, ctx);

        let supply = supply::new(supply, false);
        df::add(
            &mut archetype.id,
            utils::marker<Supply>(),
            supply,
        );

        archetype
    }

    /// Create `Archetype` with regulated supply and transfer to transaction
    /// sender
    ///
    /// Does not require that collection itself is regulated as `Archetype`
    /// supply is independently regulated.
    public entry fun create_regulated<C>(
        archetype: Nft<C>,
        supply: u64,
        ctx: &mut TxContext,
    ) {
        let archetype = new_regulated(archetype, supply, ctx);
        transfer::transfer(archetype, tx_context::sender(ctx));
    }

    /// Returns whether `Archetype` has a regulated supply
    public fun is_regulated<C>(archetype: &Archetype<C>): bool {
        df::exists_with_type<utils::Marker<Supply>, Supply>(
            &archetype.id, utils::marker<Supply>()
        )
    }

    /// Returns the `Archetype` supply
    ///
    /// #### Panics
    ///
    /// Panics if `Archetype` supply is unregulated
    public fun borrow_supply<C>(archetype: &Archetype<C>): &Supply {
        assert_regulated(archetype);
        df::borrow(
            &archetype.id,
            utils::marker<Supply>(),
        )
    }

    /// Returns the `Archetype` supply
    ///
    /// #### Panics
    ///
    /// Panics if `Archetype` supply is unregulated
    fun borrow_supply_mut<C>(archetype: &mut Archetype<C>): &mut Supply {
        assert_regulated(archetype);
        df::borrow_mut(
            &mut archetype.id,
            utils::marker<Supply>(),
        )
    }

    /// Freeze `Archetype` supply
    public entry fun freeze_supply<C>(archetype: &mut Archetype<C>) {
        let supply = borrow_supply_mut(archetype);
        supply::freeze_supply(supply);
    }

    /// Delegates archetype minting rights while maintaining `Collection` and
    /// `Archetype` level supply invariants.
    ///
    /// The argument of `RegulatedMintCap` implies that supply is at least
    /// controlled at the `Collection` level.
    ///
    /// #### Panics
    ///
    /// Panics if `Archetype` supply is exceeded if `Archetype` is regulated.
    public fun delegate_regulated<C>(
        mint_cap: RegulatedMintCap<C>,
        archetype: &mut Archetype<C>,
        ctx: &mut TxContext,
    ): ArchetypeMintCap<C> {
        if (is_regulated(archetype)) {
            let supply = borrow_supply_mut(archetype);
            supply::increment(
                supply,
                supply::supply(mint_cap::borrow_supply(&mint_cap))
            );
        };

        flyweight_mint_cap::from_regulated(
            mint_cap,
            object::id(archetype),
            ctx,
        )
    }

    /// Delegates archetype minting rights while maintaining `Collection` and
    /// `Archetype` level supply invariants.
    ///
    /// The argument of `RegulatedMintCap` implies that supply is unregulated
    /// at the `Collection` level.
    public fun delegate_unregulated<C>(
        mint_cap: UnregulatedMintCap<C>,
        archetype: &mut Archetype<C>,
        ctx: &mut TxContext,
    ): ArchetypeMintCap<C> {
        let archetype_id = object::id(archetype);
        if (is_regulated(archetype)) {
            let supply = supply::supply(borrow_supply(archetype));
            let mint_cap = mint_cap::from_unregulated(
                mint_cap, supply, ctx,
            );
            flyweight_mint_cap::from_regulated(mint_cap, archetype_id, ctx)
        } else {
            flyweight_mint_cap::from_unregulated(mint_cap, archetype_id, ctx)
        }
    }

    // === Assertions ===

    /// Asserts that `Archetype` has a regulated supply
    public fun assert_regulated<C>(archetype: &Archetype<C>) {
        assert!(is_regulated(archetype), EUNREGULATED_ARCHETYPE);
    }

    /// Asserts that `Archetype` has a regulated supply
    public fun assert_unregulated<C>(archetype: &Archetype<C>) {
        assert!(!is_regulated(archetype), EREGULATED_ARCHETYPE);
    }
}
