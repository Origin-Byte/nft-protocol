/// Module defining `MintPass` used across the OriginByte ecosystem, for the purpose
/// of one-time mints or many-but-limited-time mints. One core difference between
/// `MintCap<T>` and `MintPass<T>` is that MintCaps are fungible, MintPasses are not
/// as they can have metadata being insert into them.
///
/// OriginByte's protocol uses MintPasses in its LaunchpadV2 `Factory`, which
/// essentially acts as a `MintPass` generator. Creators can then insert metadata
/// templates to it and have the `Factory` generate MintPasses which contain
/// specific NFT metadata.
module nft_protocol::mint_pass {
    use std::string;

    use sui::bcs;
    use sui::dynamic_field as df;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::display::{Self, Display};

    use nft_protocol::mint_cap::{Self, MintCap};
    use ob_utils::utils_supply::{Self, Supply};
    use ob_permissions::witness::Witness as DelegatedWitness;
    use ob_permissions::frozen_publisher::{Self, FrozenPublisher};

    struct Witness has drop {}

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
        mint_cap::assert_limited(mint_cap);
        mint_cap::increment_supply(mint_cap, supply);

        MintPass {
            id: object::new(ctx),
            supply: utils_supply::new(supply),
        }
    }

    public fun new_<T>(
        mint_cap: &MintCap<T>,
        supply: u64,
        ctx: &mut TxContext,
    ): MintPass<T> {
        mint_cap::assert_unlimited(mint_cap);

        MintPass {
            id: object::new(ctx),
            supply: utils_supply::new(supply),
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
        utils_supply::get_current(&mint_pass.supply)
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
        utils_supply::increment(&mut mint_pass.supply, quantity);
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
            supply: utils_supply::new(supply),
        }
    }


    /// Merge two `MintCap` together
    public fun merge<T: key>(
        mint_pass: &mut MintPass<T>,
        other: MintPass<T>,
    ) {
        let MintPass { id, supply } = other;

        utils_supply::merge(
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

    // === Display standard ===

    /// Creates a new `Display` with some default settings.
    public fun new_display<T: key + store>(
        _witness: DelegatedWitness<T>,
        pub: &FrozenPublisher,
        ctx: &mut TxContext,
    ): Display<MintPass<T>> {
        let display =
            frozen_publisher::new_display<Witness, MintPass<T>>(Witness {}, pub, ctx);

        display::add(&mut display, string::utf8(b"type"), string::utf8(b"MintPass"));

        display
    }
}
