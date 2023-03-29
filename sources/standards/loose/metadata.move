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
    struct Metadata<T: key + store> has key, store {
        id: UID,
        metadata: T,
    }

    /// Create `Metadata` with unregulated supply
    ///
    /// Does not require that collection itself is unregulated as `Metadata`
    /// supply is independently regulated.
    public fun new_unregulated<T: key + store>(
        metadata: T,
        ctx: &mut TxContext,
    ): Metadata<T> {
        Metadata {
            id: object::new(ctx),
            metadata,
        }
    }

    /// Create `Metadata` with unregulated supply and transfer to transaction
    /// sender
    ///
    /// Does not require that collection itself is unregulated as `Metadata`
    /// supply is independently regulated.
    public entry fun create_unregulated<T: key + store>(
        metadata: T,
        ctx: &mut TxContext
    ) {
        let metadata = new_unregulated(metadata, ctx);
        transfer::public_transfer(metadata, tx_context::sender(ctx));
    }

    /// Create `Metadata` with unregulated supply
    ///
    /// Does not require that collection itself is regulated as `Metadata`
    /// supply is independently regulated.
    public fun new_regulated<T: key + store>(
        metadata: T,
        supply: u64,
        ctx: &mut TxContext,
    ): Metadata<T> {
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
    public entry fun create_regulated<T: key + store>(
        metadata: T,
        supply: u64,
        ctx: &mut TxContext,
    ) {
        let metadata = new_regulated(metadata, supply, ctx);
        transfer::public_transfer(metadata, tx_context::sender(ctx));
    }

    /// Returns whether `Metadata` has a regulated supply
    public fun is_regulated<T: key + store>(metadata: &Metadata<T>): bool {
        df::exists_with_type<utils::Marker<Supply>, Supply>(
            &metadata.id, utils::marker<Supply>()
        )
    }

    /// Returns the `Metadata` `Nft`
    public fun borrow_metadata<T: key + store>(metadata: &Metadata<T>): &T {
        &metadata.metadata
    }

    /// Returns the `Metadata` supply
    ///
    /// #### Panics
    ///
    /// Panics if `Metadata` supply is unregulated
    public fun borrow_supply<T: key + store>(metadata: &Metadata<T>): &Supply {
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
    fun borrow_supply_mut<T: key + store>(
        metadata: &mut Metadata<T>,
    ): &mut Supply {
        assert_regulated(metadata);
        df::borrow_mut(
            &mut metadata.id,
            utils::marker<Supply>(),
        )
    }

    /// Freeze `Metadata` supply
    public entry fun freeze_supply<T: key + store>(
        metadata: &mut Metadata<T>,
    ) {
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
        mint_cap: RegulatedMintCap<Nft<C>>,
        metadata: &mut Metadata<Nft<C>>,
        ctx: &mut TxContext,
    ): LooseMintCap<Nft<C>> {
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
        mint_cap: UnregulatedMintCap<Nft<C>>,
        metadata: &mut Metadata<Nft<C>>,
        ctx: &mut TxContext,
    ): LooseMintCap<Nft<C>> {
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
    public fun assert_regulated<T: key + store>(metadata: &Metadata<T>) {
        assert!(is_regulated(metadata), EUNREGULATED_ARCHETYPE);
    }

    /// Asserts that `Metadata` has a regulated supply
    public fun assert_unregulated<T: key + store>(metadata: &Metadata<T>) {
        assert!(!is_regulated(metadata), EREGULATED_ARCHETYPE);
    }
}
