module nft_protocol::metadata {
    use sui::transfer;
    use sui::dynamic_field as df;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::utils;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::mint_cap::{Self, RegulatedMintCap, UnregulatedMintCap};

    use nft_protocol::loose_mint_cap::{Self, LooseMintCap};

    /// `Metadata` supply is unregulated
    ///
    /// Create an `metadata` using `metadata::new_regulated` to create a
    /// regulated `Metadata`.
    const EUNREGULATED_ARCHETYPE: u64 = 1;

    /// `Metadata` supply is regulated
    ///
    /// Create an `metadata` using `metadata::new_unregulated` to create an
    /// unregulated `Metadata`.
    const EREGULATED_ARCHETYPE: u64 = 2;

    /// `Metadata` object
    struct Metadata<phantom C> has key, store {
        id: UID,
        metadata: Nft<C>,
    }

    /// Create `Metadata` with unregulated supply
    ///
    /// Does not require that collection itself is unregulated as `Metadata`
    /// supply is independently regulated.
    public fun new_unregulated<C>(
        metadata: Nft<C>,
        ctx: &mut TxContext,
    ): Metadata<C> {
        Metadata<C> {
            id: object::new(ctx),
            metadata,
        }
    }

    /// Create `Metadata` with unregulated supply and transfer to transaction
    /// sender
    ///
    /// Does not require that collection itself is unregulated as `Metadata`
    /// supply is independently regulated.
    public entry fun create_unregulated<C>(
        metadata: Nft<C>,
        ctx: &mut TxContext
    ) {
        let metadata = new_unregulated(metadata, ctx);
        transfer::transfer(metadata, tx_context::sender(ctx));
    }

    /// Create `Metadata` with unregulated supply
    ///
    /// Does not require that collection itself is regulated as `Metadata`
    /// supply is independently regulated.
    public fun new_regulated<C>(
        metadata: Nft<C>,
        supply: u64,
        ctx: &mut TxContext,
    ): Metadata<C> {
        let metadata = new_unregulated(metadata, ctx);

        let supply = supply::new(supply, false);
        df::add(
            &mut metadata.id,
            utils::marker<Supply>(),
            supply,
        );

        metadata
    }

    /// Create `Metadata` with regulated supply and transfer to transaction
    /// sender
    ///
    /// Does not require that collection itself is regulated as `Metadata`
    /// supply is independently regulated.
    public entry fun create_regulated<C>(
        metadata: Nft<C>,
        supply: u64,
        ctx: &mut TxContext,
    ) {
        let metadata = new_regulated(metadata, supply, ctx);
        transfer::transfer(metadata, tx_context::sender(ctx));
    }

    /// Returns whether `Metadata` has a regulated supply
    public fun is_regulated<C>(metadata: &Metadata<C>): bool {
        df::exists_with_type<utils::Marker<Supply>, Supply>(
            &metadata.id, utils::marker<Supply>()
        )
    }

    /// Returns the `Metadata` `Nft`
    public fun borrow_metadata<C>(metadata: &Metadata<C>): &Nft<C> {
        &metadata.metadata
    }

    /// Returns the `Metadata` supply
    ///
    /// #### Panics
    ///
    /// Panics if `Metadata` supply is unregulated
    public fun borrow_supply<C>(metadata: &Metadata<C>): &Supply {
        assert_regulated(metadata);
        df::borrow(
            &metadata.id,
            utils::marker<Supply>(),
        )
    }

    /// Returns the `Metadata` supply
    ///
    /// #### Panics
    ///
    /// Panics if `Metadata` supply is unregulated
    fun borrow_supply_mut<C>(metadata: &mut Metadata<C>): &mut Supply {
        assert_regulated(metadata);
        df::borrow_mut(
            &mut metadata.id,
            utils::marker<Supply>(),
        )
    }

    /// Freeze `Metadata` supply
    public entry fun freeze_supply<C>(metadata: &mut Metadata<C>) {
        let supply = borrow_supply_mut(metadata);
        supply::freeze_supply(supply);
    }

    /// Delegates metadata minting rights while maintaining `Collection` and
    /// `Metadata` level supply invariants.
    ///
    /// The argument of `RegulatedMintCap` implies that supply is at least
    /// controlled at the `Collection` level.
    ///
    /// #### Panics
    ///
    /// Panics if `Metadata` supply is exceeded if `Metadata` is regulated.
    public fun delegate_regulated<C>(
        mint_cap: RegulatedMintCap<C>,
        metadata: &mut Metadata<C>,
        ctx: &mut TxContext,
    ): LooseMintCap<C> {
        if (is_regulated(metadata)) {
            let supply = borrow_supply_mut(metadata);
            supply::increment(
                supply,
                supply::supply(mint_cap::borrow_supply(&mint_cap))
            );
        };

        let metadata_id = object::id(metadata);
        let nft = borrow_metadata(metadata);

        loose_mint_cap::from_regulated(
            mint_cap,
            metadata_id,
            *nft::name(nft),
            *nft::url(nft),
            ctx,
        )
    }

    /// Delegates metadata minting rights while maintaining `Collection` and
    /// `Metadata` level supply invariants.
    ///
    /// The argument of `RegulatedMintCap` implies that supply is unregulated
    /// at the `Collection` level.
    public fun delegate_unregulated<C>(
        mint_cap: UnregulatedMintCap<C>,
        metadata: &mut Metadata<C>,
        ctx: &mut TxContext,
    ): LooseMintCap<C> {
        let metadata_id = object::id(metadata);
        let nft = borrow_metadata(metadata);
        let name = *nft::name(nft);
        let url = *nft::url(nft);

        if (is_regulated(metadata)) {
            let supply = supply::supply(borrow_supply(metadata));
            let mint_cap = mint_cap::from_unregulated(
                mint_cap, supply, ctx,
            );
            loose_mint_cap::from_regulated(
                mint_cap, metadata_id, name, url, ctx,
            )
        } else {
            loose_mint_cap::from_unregulated(
                mint_cap, metadata_id, name, url, ctx,
            )
        }
    }

    // === Assertions ===

    /// Asserts that `Metadata` has a regulated supply
    public fun assert_regulated<C>(metadata: &Metadata<C>) {
        assert!(is_regulated(metadata), EUNREGULATED_ARCHETYPE);
    }

    /// Asserts that `Metadata` has a regulated supply
    public fun assert_unregulated<C>(metadata: &Metadata<C>) {
        assert!(!is_regulated(metadata), EREGULATED_ARCHETYPE);
    }
}
