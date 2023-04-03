module nft_protocol::metadata {
    use std::option::{Self, Option};

    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::utils_supply::{Self, Supply};
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
    struct Metadata<T: key + store> has key, store {
        /// `Metadata` ID
        id: UID,
        /// Backing NFT
        metadata: T,
        /// NFT supply
        supply: Option<Supply>,
    }

    /// Create `Metadata` with unregulated supply
    ///
    /// Does not require that collection itself is unregulated as `Metadata`
    /// supply is independently regulated.
    public fun create<T: key + store>(
        metadata: T,
        supply: Option<u64>,
        ctx: &mut TxContext,
    ): Metadata<T> {
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
    public fun create_unregulated<T: key + store>(
        metadata: T,
        ctx: &mut TxContext,
    ): Metadata<T> {
        Metadata { id: object::new(ctx), metadata, supply: option::none() }
    }

    /// Create `Metadata` with regulated supply
    ///
    /// Does not require that collection itself is unregulated as `Metadata`
    /// supply is independently regulated.
    public fun create_regulated<T: key + store>(
        metadata: T,
        supply: u64,
        ctx: &mut TxContext,
    ): Metadata<T> {
        Metadata {
            id: object::new(ctx),
            metadata,
            supply: option::some(utils_supply::new(supply)),
        }
    }

    /// Create `Metadata` with unregulated supply and transfer to transaction
    /// sender
    ///
    /// Does not require that collection itself is unregulated as `Metadata`
    /// supply is independently regulated.
    public entry fun create_unregulated_and_transfer<T: key + store>(
        metadata: T,
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
    public entry fun create_regulated_and_transfer<T: key + store>(
        metadata: T,
        quantity: u64,
        ctx: &mut TxContext,
    ) {
        let metadata = create(metadata, option::some(quantity), ctx);
        transfer::public_transfer(metadata, tx_context::sender(ctx));
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
    public fun borrow_supply<T: key + store>(
        metadata: &Metadata<T>,
    ): &Option<Supply> {
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
    public fun delegate<T: key + store>(
        mint_cap: &mut MintCap<T>,
        metadata: &mut Metadata<T>,
        quantity: u64,
        ctx: &mut TxContext,
    ): LooseMintCap<T> {
        if (option::is_some(&metadata.supply)) {
            let supply = option::borrow_mut(&mut metadata.supply);
            utils_supply::increment(supply, quantity);
        };

        loose_mint_cap::new(
            mint_cap::delegate(mint_cap, quantity, ctx),
            object::id(metadata),
            ctx,
        )
    }


    // === Assertions ===

    /// Asserts that `Metadata` has a regulated supply
    public fun assert_regulated<T: key + store>(metadata: &Metadata<T>) {
        assert!(option::is_some(&metadata.supply), EUNREGULATED_ARCHETYPE);
    }

    /// Asserts that `Metadata` has a regulated supply
    public fun assert_unregulated<T: key + store>(metadata: &Metadata<T>) {
        assert!(option::is_none(&metadata.supply), EREGULATED_ARCHETYPE);
    }
}
