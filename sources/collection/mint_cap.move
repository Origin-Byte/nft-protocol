/// Module defining the multiple `MintCap` used across the OriginByte
/// ecosystem.
///
/// Ownership of `MintCap` is necessary to mint NFTs and can also be used to
/// delegate the permission to mint NFTs (but not modify collections) using
/// `limitedMintCap` and `unlimitedMintCap`.
///
/// Multiple `limitedMintCap` and `unlimitedMintCap` can be created
/// therefore the objects must be securely protected against malicious
/// access.
///
/// An additional restriction placed upon `limitedMintCap` and
/// `unlimitedMintCap` is that they may not be used to further delegate more
/// mint capabilities.
module nft_protocol::mint_cap {
    use std::option::{Self, Option};

    use sui::types;
    use sui::tx_context::TxContext;
    use sui::object::{Self, UID, ID};

    use nft_protocol::witness;
    use nft_protocol::utils_supply::{Self, Supply};

    /// `MintCap` is unlimited when expected limited
    const EMintCapunlimited: u64 = 1;

    /// `MintCap` is limited when expected unlimited
    const EMintCaplimited: u64 = 2;

    /// Expected one-time witness as `OTW` type paremeter to initialize
    /// `MintCap`
    const ENotOneTimeWitness: u64 = 3;

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
    ///
    /// #### Panics
    ///
    /// Panics if `OTW` is from a different module than `T`.
    public fun new<OTW: drop, T>(
        witness: &OTW,
        collection_id: ID,
        supply: Option<u64>,
        ctx: &mut TxContext,
    ): MintCap<T> {
        if (option::is_some(&supply)) {
            new_limited(
                witness, collection_id, option::destroy_some(supply), ctx,
            )
        } else {
            new_unlimited(witness, collection_id, ctx)
        }
    }

    /// Create a new `MintCap` with unlimited supply
    ///
    /// #### Panics
    ///
    /// Panics if `OTW` is from a different module than `T`.
    public fun new_unlimited<OTW: drop, T>(
        witness: &OTW,
        collection_id: ID,
        ctx: &mut TxContext,
    ): MintCap<T> {
        witness::assert_same_module<OTW, T>();
        assert!(types::is_one_time_witness(witness), ENotOneTimeWitness);

        MintCap {
            id: object::new(ctx),
            collection_id,
            supply: option::none(),
        }
    }

    /// Create a new `MintCap` with limited supply
    ///
    /// #### Panics
    ///
    /// Panics if `OTW` is from a different module than `T`.
    public fun new_limited<OTW: drop, T>(
        witness: &OTW,
        collection_id: ID,
        supply: u64,
        ctx: &mut TxContext,
    ): MintCap<T> {
        witness::assert_same_module<OTW, T>();
        assert!(types::is_one_time_witness(witness), ENotOneTimeWitness);

        MintCap {
            id: object::new(ctx),
            collection_id,
            supply: option::some(utils_supply::new(supply)),
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
    /// Panics if supply is unlimited.
    public fun supply<T>(mint_cap: &MintCap<T>): u64 {
        assert_limited(mint_cap);
        utils_supply::get_current(option::borrow(&mint_cap.supply))
    }

    /// Returns backing `Supply`
    ///
    /// #### Panics
    ///
    /// Panics if suppy is unlimited.
    public fun get_supply<T>(mint_cap: &MintCap<T>): &Supply {
        assert_limited(mint_cap);
        option::borrow(&mint_cap.supply)
    }

    /// Returns whether `MintCap` has limited supply
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
        if (option::is_some(&mint_cap.supply)) {
            utils_supply::increment(
                option::borrow_mut(&mut mint_cap.supply), quantity,
            );
        }
    }

    /// Create a new `MintCap` by delegating supply from unlimited or
    /// limited `MintCap`.
    ///
    /// #### Panics
    ///
    /// Panics if quantity exceeds available supply.
    public fun split<T>(
        mint_cap: &mut MintCap<T>,
        quantity: u64,
        ctx: &mut TxContext,
    ): MintCap<T> {
        let supply = if (has_supply(mint_cap)) {
            utils_supply::split(
                option::borrow_mut(&mut mint_cap.supply), quantity)
        } else {
            utils_supply::new(quantity)
        };

        MintCap {
            id: object::new(ctx),
            collection_id: mint_cap.collection_id,
            supply: option::some(supply),
        }
    }


    /// Merge two `MintCap` together
    public fun merge<T>(
        mint_cap: &mut MintCap<T>,
        other: MintCap<T>,
    ) {
        let MintCap { id, supply, collection_id: _ } = other;

        if (option::is_some(&supply) && option::is_some(&mint_cap.supply)) {
            utils_supply::merge(
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

    /// Assert that `MintCap` has limited supply
    ///
    /// #### Panics
    ///
    /// Panics if `MintCap` is unlimited.
    public fun assert_limited<T>(mint_cap: &MintCap<T>) {
        assert!(option::is_some(&mint_cap.supply), EMintCapunlimited)
    }

    /// Assert that `MintCap` has unlimited supply
    ///
    /// #### Panics
    ///
    /// Panics if `MintCap` is limited.
    public fun assert_unlimited<T>(mint_cap: &MintCap<T>) {
        assert!(option::is_none(&mint_cap.supply), EMintCaplimited)
    }

    // === Test-Only ===

    #[test_only]
    public fun test_create_mint_cap<T>(
        collection_id: ID,
        supply_opt: Option<u64>,
        ctx: &mut TxContext
    ): MintCap<T> {
        let supply = if (option::is_some(&supply_opt)) {
            let amount = option::destroy_some(supply_opt);
            option::some(utils_supply::new(amount))
        } else {
            option::destroy_none(supply_opt);
            option::none()
        };

      MintCap<T> {
        id: object::new(ctx),
        collection_id,
        supply,
      }
    }

    #[test_only]
    public fun test_destroy_mint_cap<T>(cap: MintCap<T>) {
      let MintCap<T> {
        id,
        collection_id: _,
        supply,
      } = cap;

      if (option::is_some(&supply)) {
        option::destroy_some(supply);
      } else {
        option::destroy_none(supply);
      };

      object::delete(id)
    }
}
