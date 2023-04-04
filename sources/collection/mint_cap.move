/// Module defining the multiple `MintCap` used across the OriginByte
/// ecosystem.
///
/// Ownership of `MintCap` is necessary to mint NFTs and can also be used to
/// delegate the permission to mint NFTs (but not modify collections) using
/// `RegulatedMintCap` and `UnregulatedMintCap`.
///
/// Multiple `RegulatedMintCap` and `UnregulatedMintCap` can be created
/// therefore the objects must be securely protected against malicious
/// access.
///
/// An additional restriction placed upon `RegulatedMintCap` and
/// `UnregulatedMintCap` is that they may not be used to further delegate more
/// mint capabilities.
module nft_protocol::mint_cap {
    use std::option::{Self, Option};

    use sui::tx_context::TxContext;
    use sui::object::{Self, UID, ID};

    use nft_protocol::collection::Collection;
    use nft_protocol::witness::Witness as DelegatedWitness;
    use nft_protocol::supply::{Self, Supply};

    /// `MintCap` is unregulated when expected regulated
    const EMintCapUnregulated: u64 = 1;

    /// `MintCap` is regulated when expected unregulated
    const EMintCapRegulated: u64 = 2;

    /// `MintCap<T>` delegates the capability of it's owner to mint `T`
    struct MintCap<phantom T> has key, store {
        /// `MintCap` ID
        id: UID,
        /// ID of the `Collection` that `MintCap` controls.
        ///
        /// Intended for discovery.
        collection_id: ID,
        /// Supply that `MintCap` can mint
        supply: Option<Supply>,
    }

    /// Create a new `MintCap`
    public fun new<T, U>(
        witness: DelegatedWitness<T>,
        collection: &Collection<U>,
        supply: Option<u64>,
        ctx: &mut TxContext,
    ): MintCap<T> {
        if (option::is_some(&supply)) {
            new_regulated(
                witness, collection, option::destroy_some(supply), ctx,
            )
        } else {
            new_unregulated(witness, collection, ctx)
        }
    }

    /// Create a new `MintCap` with unregulated supply
    public fun new_unregulated<T, U>(
        _witness: DelegatedWitness<T>,
        collection: &Collection<U>,
        ctx: &mut TxContext,
    ): MintCap<T> {
        MintCap {
            id: object::new(ctx),
            collection_id: object::id(collection),
            supply: option::none(),
        }
    }

    /// Create a new `MintCap` with regulated supply
    public fun new_regulated<T, U>(
        _witness: DelegatedWitness<T>,
        collection: &Collection<U>,
        supply: u64,
        ctx: &mut TxContext,
    ): MintCap<T> {
        MintCap {
            id: object::new(ctx),
            collection_id: object::id(collection),
            // The supply is always set to frozen for safety
            supply: option::some(supply::new(supply, true)),
        }
    }


    /// Returns ID of `Collection` associated with `MintCap`
    public fun collection_id<T>(mint_cap: &MintCap<T>): ID {
        mint_cap.collection_id
    }

    /// Return remaining supply
    ///
    /// #### Panics
    ///
    /// Panics if supply is unregulated.
    public fun supply<T>(mint_cap: &MintCap<T>): u64 {
        assert_regulated(mint_cap);
        supply::get_current(option::borrow(&mint_cap.supply))
    }

    public fun is_frozen<T>(mint_cap: &MintCap<T>): bool {
        let supply = get_supply(mint_cap);
        supply::is_frozen(supply)
    }

    public fun get_supply<T>(mint_cap: &MintCap<T>): &Supply {
        assert_regulated(mint_cap);
        option::borrow(&mint_cap.supply)
    }

    public fun has_supply<T>(mint_cap: &MintCap<T>): bool {
        option::is_some(&mint_cap.supply)
    }

    /// Returns ID of `Collection` associated with `MintCap`
    public fun borrow_supply<T>(mint_cap: &MintCap<T>): &Option<Supply> {
        &mint_cap.supply
    }

    /// Increment `MintCap` supply
    ///
    /// This function should be called each time `MintCap` is used to authorize
    /// a mint.
    ///
    /// #### Panics
    ///
    /// Panics if supply is execeeded.
    public fun increment_supply<T>(
        mint_cap: &mut MintCap<T>,
        quantity: u64,
    ) {
        // TODO: Should assert that is regulated
        if (option::is_some(&mint_cap.supply)) {
            supply::increment(option::borrow_mut(&mut mint_cap.supply), quantity);
        }
    }

    /// Create a new `MintCap` by delegating supply from unregulated or
    /// regulated `MintCap`.
    public fun split<T: key>(
        mint_cap: &mut MintCap<T>,
        quantity: u64,
        ctx: &mut TxContext,
    ): MintCap<T> {
        let supply = if (option::is_some(&mint_cap.supply)) {
            supply::split(
                option::borrow_mut(&mut mint_cap.supply), quantity)
        } else {
            // New supply object is frozen for safety
            supply::new(quantity, true)
        };

        MintCap {
            id: object::new(ctx),
            collection_id: mint_cap.collection_id,
            supply: option::some(supply),
        }
    }


    /// Merge two `MintCap` together
    public fun merge<T: key>(
        mint_cap: &mut MintCap<T>,
        other: MintCap<T>,
    ) {
        let MintCap { id, collection_id: _, supply } = other;

        if (option::is_some(&supply)) {
            assert_unregulated(mint_cap);
            supply::merge(
                option::borrow_mut(&mut mint_cap.supply),
                option::destroy_some(supply),
            );
        };

        object::delete(id);
    }

    /// Delete `MintCap`
    public fun delete_mint_cap<T>(mint_cap: MintCap<T>) {
        let MintCap { id, collection_id: _, supply: _ } = mint_cap;
        object::delete(id);
    }

    // === Assertions ===

    /// Assert that `MintCap` has regulated supply
    ///
    /// #### Panics
    ///
    /// Panics if `MintCap` is unregulated.
    public fun assert_regulated<T>(mint_cap: &MintCap<T>) {
        assert!(option::is_some(&mint_cap.supply), EMintCapUnregulated)
    }

    /// Assert that `MintCap` has unregulated supply
    ///
    /// #### Panics
    ///
    /// Panics if `MintCap` is regulated.
    public fun assert_unregulated<T>(mint_cap: &MintCap<T>) {
        assert!(option::is_none(&mint_cap.supply), EMintCapRegulated)
    }
}
