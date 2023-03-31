module nft_protocol::metadata {
    use std::option::{Self, Option};

    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::mint_cap::{Self, MintCap};

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
        supply: Option<Supply>,
    }

    /// Create `Metadata` with unregulated supply
    ///
    /// Does not require that collection itself is unregulated as `Metadata`
    /// supply is independently regulated.
    public fun create<C>(
        metadata: Nft<C>,
        supply: Option<u64>,
        ctx: &mut TxContext,
    ): Metadata<C> {
        if (option::is_some(&supply)) {
            create_regulated(metadata, option::destroy_some(supply), ctx)
        } else {
            create_unregulated(metadata, ctx)
        }
    }

    /// Create `Metadata` with unregulated supply
    ///
    /// Does not require that collection itself is unregulated as `Metadata`
    /// supply is independently regulated.
    public fun create_unregulated<C>(
        metadata: Nft<C>,
        ctx: &mut TxContext,
    ): Metadata<C> {
        Metadata { id: object::new(ctx), metadata, supply: option::none() }
    }

    /// Create `Metadata` with regulated supply
    ///
    /// Does not require that collection itself is unregulated as `Metadata`
    /// supply is independently regulated.
    public fun create_regulated<C>(
        metadata: Nft<C>,
        supply: u64,
        ctx: &mut TxContext,
    ): Metadata<C> {
        Metadata {
            id: object::new(ctx),
            metadata,
            supply: option::some(supply::new(supply)),
        }
    }

    /// Create `Metadata` with unregulated supply and transfer to transaction
    /// sender
    ///
    /// Does not require that collection itself is unregulated as `Metadata`
    /// supply is independently regulated.
    public entry fun create_unregulated_and_transfer<C>(
        metadata: Nft<C>,
        ctx: &mut TxContext
    ) {
        let metadata = create(metadata, option::none(), ctx);
        transfer::public_transfer(metadata, tx_context::sender(ctx));
    }

    /// Create `Metadata` with regulated supply and transfer to transaction
    /// sender
    ///
    /// Does not require that collection itself is regulated as `Metadata`
    /// supply is independently regulated.
    public entry fun create_regulated_and_transfer<C>(
        metadata: Nft<C>,
        quantity: u64,
        ctx: &mut TxContext,
    ) {
        let metadata = create(metadata, option::some(quantity), ctx);
        transfer::public_transfer(metadata, tx_context::sender(ctx));
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
    public fun borrow_supply<C>(metadata: &Metadata<C>): &Option<Supply> {
        &metadata.supply
    }

    /// Delegates metadata minting rights while maintaining `Collection` and
    /// `Metadata` level supply invariants.
    ///
    /// Can only create a regulated `MintCap` from any `MintCap` therefore
    /// quantity must be provided.
    ///
    /// #### Panics
    ///
    /// Panics if supply is exceeded.
    public fun delegate<C>(
        mint_cap: &mut MintCap<Nft<C>>,
        metadata: &mut Metadata<C>,
        quantity: u64,
        ctx: &mut TxContext,
    ): LooseMintCap<Nft<C>> {
        if (option::is_some(&metadata.supply)) {
            let supply = option::borrow_mut(&mut metadata.supply);
            supply::increment(supply, quantity);
        };

        let metadata_id = object::id(metadata);
        let nft = borrow_metadata(metadata);

        loose_mint_cap::new(
            mint_cap::split(mint_cap, quantity, ctx),
            metadata_id,
            *nft::name(nft),
            *nft::url(nft),
            ctx,
        )
    }


    // === Assertions ===

    /// Asserts that `Metadata` has a regulated supply
    public fun assert_regulated<C>(metadata: &Metadata<C>) {
        assert!(option::is_some(&metadata.supply), EUNREGULATED_ARCHETYPE);
    }

    /// Asserts that `Metadata` has a regulated supply
    public fun assert_unregulated<C>(metadata: &Metadata<C>) {
        assert!(option::is_none(&metadata.supply), EREGULATED_ARCHETYPE);
    }
}
