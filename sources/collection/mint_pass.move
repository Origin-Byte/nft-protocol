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
module nft_protocol::mint_pass {
    use std::option::{Self, Option};

    use sui::tx_context::TxContext;
    use sui::object::{Self, UID, ID};
    use sui::bcs;
    use sui::dynamic_field as df;

    use nft_protocol::collection::Collection;
    use nft_protocol::utils;
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::supply::{Self, Supply};

    /// `MintCap` is unregulated when expected regulated
    const EMINT_CAP_UNREGULATED: u64 = 1;

    /// `MintCap` is regulated when expected unregulated
    const EMINT_CAP_REGULATED: u64 = 2;

    /// `MintCap` is regulated when expected unregulated
    const EMINT_CAP_SUPPLY_FROZEN: u64 = 2;

    // === MintCap ===

    /// `MintCap<T>` delegates the capability to it's owner to mint `T`.
    /// There is only one `MintCap` per `Collection<T>`.
    ///
    /// This pattern is useful as `MintCap` can be made shared allowing users
    /// to mint NFTs themselves, such as in a name service application.
    struct MintPass<phantom T> has key, store {
        /// `MintCap` ID
        id: UID,
        /// Supply that `MintCap` can mint
        supply: Supply,
    }

    struct MetadataDfKey has store, copy, drop {}

    public fun new<T: key>(
        mint_cap: &mut MintCap<T>,
        supply: u64,
        ctx: &mut TxContext,
    ): MintPass<T> {
        mint_cap::assert_regulated(mint_cap);
        mint_cap::increment_supply(mint_cap, supply);

        MintPass {
            id: object::new(ctx),
            // The supply is always set to frozen for safety
            supply: supply::new(supply, true),
        }
    }

    public fun new_<T>(
        mint_cap: &MintCap<T>,
        supply: u64,
        ctx: &mut TxContext,
    ): MintPass<T> {
        mint_cap::assert_unregulated(mint_cap);

        MintPass {
            id: object::new(ctx),
            // The supply is always set to frozen for safety
            supply: supply::new(supply, true),
        }
    }

    /// Create a new `MintCap` by delegating supply from unregulated or
    /// regulated `MintCap`.
    public fun new_with_metadata<T: key>(
        mint_cap: &mut MintCap<T>,
        supply: u64,
        metadata: &vector<u8>,
        ctx: &mut TxContext,
    ): MintPass<T> {
        let bcs_meta = bcs::new(*metadata);
        let mint_pass = new(mint_cap, supply, ctx);

        df::add(&mut mint_pass.id, MetadataDfKey {}, bcs_meta);

        mint_pass
    }

    /// Create a new `MintCap` by delegating supply from unregulated or
    /// regulated `MintCap`.
    public fun new_with_metadata_<T: key>(
        mint_cap: &MintCap<T>,
        supply: u64,
        metadata: &vector<u8>,
        ctx: &mut TxContext,
    ): MintPass<T> {
        let bcs_meta = bcs::new(*metadata);
        let mint_pass = new_(mint_cap, supply, ctx);

        df::add(&mut mint_pass.id, MetadataDfKey {}, bcs_meta);

        mint_pass
    }

    /// Return remaining supply
    ///
    /// #### Panics
    ///
    /// Panics if supply is unregulated.
    public fun supply<T>(mint_pass: &MintPass<T>): u64 {
        supply::get_current(&mint_pass.supply)
    }

    public fun is_frozen<T>(mint_pass: &MintPass<T>): bool {
        let supply = get_supply(mint_pass);
        supply::is_frozen(supply)
    }

    public fun get_supply<T>(mint_pass: &MintPass<T>): &Supply {
        &mint_pass.supply
    }

    /// Returns ID of `Collection` associated with `MintCap`
    public fun borrow_supply<T>(mint_pass: &MintPass<T>): &Supply {
        &mint_pass.supply
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
        mint_pass: &mut MintPass<T>,
        quantity: u64,
    ) {
        supply::increment(&mut mint_pass.supply, quantity);
    }

    /// Create a new `MintCap` by delegating supply from unregulated or
    /// regulated `MintCap`.
    public fun split<T: key>(
        mint_pass: &mut MintPass<T>,
        supply: u64,
        ctx: &mut TxContext,
    ): MintPass<T> {
        increment_supply(mint_pass, supply);

        MintPass {
            id: object::new(ctx),
            supply: supply::new(supply, true),
        }
    }


    /// Merge two `MintCap` together
    public fun merge<T: key>(
        mint_pass: &mut MintPass<T>,
        other: MintPass<T>,
    ) {
        let MintPass { id, supply } = other;

        supply::merge(
            &mut mint_pass.supply,
            supply,
        );

        object::delete(id);
    }

    /// Delete `MintCap`
    public fun delete_mint_pass<T>(mint_pass: MintPass<T>,) {
        // TODO: Should delete Supply object if any, otherwise it becomes
        // a stale object
        let MintPass { id, supply: _ } = mint_pass;

        object::delete(id);
    }
}
