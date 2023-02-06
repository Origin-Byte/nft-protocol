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
    use sui::tx_context::TxContext;
    use sui::object::{Self, UID, ID};

    use nft_protocol::supply::{Self, Supply};

    friend nft_protocol::collection;
    friend nft_protocol::supply_domain;

    // === MintCap ===

    /// `MintCap<C>` delegates the capability to it's owner to mint `Nft<C>`.
    /// There is only one `MintCap` per `Collection<C>`.
    ///
    /// This pattern is useful as `MintCap` can be made shared allowing users
    /// to mint NFTs themselves, such as in a name service application.
    struct MintCap<phantom C> has key, store {
        /// `MintCap` ID
        id: UID,
        /// ID of the `Collection` that `MintCap` controls.
        ///
        /// Intended for discovery.
        collection_id: ID,
    }

    /// Create a new `MintCap`
    ///
    /// Only one `MintCap` must exist per collection
    public(friend) fun new<C>(
        collection_id: ID,
        ctx: &mut TxContext,
    ): MintCap<C> {
        MintCap { id: object::new(ctx), collection_id }
    }

    /// Returns ID of `Collection` associated with `MintCap`
    public fun collection_id<C>(mint: &MintCap<C>): ID {
        mint.collection_id
    }

    // === UnregulatedMintCap ===

    /// `UnregulatedMintCap` delegates the capability to it's owner to mint
    /// `Nft` from collections with unregulated supply.
    struct UnregulatedMintCap<phantom C> has key, store {
        /// `RegulatedMintCap` ID
        id: UID,
        /// ID of the `Collection` that `RegulatedMintCap` controls
        ///
        /// Intended for discovery.
        collection_id: ID,
    }

    /// Create a new `UnregulatedMintCap`
    ///
    /// `UnregulatedMintCap` may only be created by
    /// `supply_domain::delegate_unregulated`.
    public(friend) fun new_unregulated<C>(
        _mint_cap: &MintCap<C>,
        collection_id: ID,
        ctx: &mut TxContext,
    ): UnregulatedMintCap<C> {
        UnregulatedMintCap {
            id: object::new(ctx),
            collection_id
        }
    }

    /// Delete `UnregulatedMintCap`
    public fun delete_unregulated<C>(mint: UnregulatedMintCap<C>) {
        let UnregulatedMintCap {
            id,
            collection_id: _,
        } = mint;
        object::delete(id);
    }

    /// Returns ID of `Collection` associated with `RegulatedMintCap`
    public fun unregulated_collection_id<C>(mint: &UnregulatedMintCap<C>): ID {
        mint.collection_id
    }

    // === RegulatedMintCap ===

    /// `RegulatedMintCap` delegates the capability to it's owner to mint
    /// `Nft` from collections with regulated supply.
    struct RegulatedMintCap<phantom C> has key, store {
        /// `RegulatedMintCap` ID
        id: UID,
        /// ID of the `Collection` that `RegulatedMintCap` controls
        ///
        /// Intended for discovery.
        collection_id: ID,
        /// Supply that `RegulatedMintCap` is entitled to mint
        supply: Supply,
    }

    /// Create a new `RegulatedMintCap`
    ///
    /// `RegulatedMintCap` may only be created by
    /// `supply_domain::delegate_regulated`.
    public(friend) fun new_regulated<C>(
        _mint_cap: &MintCap<C>,
        collection_id: ID,
        supply: Supply,
        ctx: &mut TxContext,
    ): RegulatedMintCap<C> {
        RegulatedMintCap {
            id: object::new(ctx),
            collection_id,
            supply,
        }
    }

    /// Create a new `RegulatedMintCap` from `UnregulatedMintCap`
    ///
    /// Presence of `UnregulatedMintCap` implies that `Collection` supply is
    /// unregulated, therefore it is safe to create arbitrary
    /// `RegulatedMintCap`.
    public fun from_unregulated<C>(
        mint_cap: UnregulatedMintCap<C>,
        supply: u64,
        ctx: &mut TxContext,
    ): RegulatedMintCap<C> {
        let collection_id = unregulated_collection_id(&mint_cap);
        delete_unregulated(mint_cap);

        RegulatedMintCap {
            id: object::new(ctx),
            collection_id,
            supply: supply::new(supply, true),
        }
    }

    /// Creates a new `RegulatedMintCap` by delegating some supply from an
    /// existing `RegulatedMintCap`.
    ///
    /// #### Panics
    ///
    /// Panics if supply exceeds maximum.
    public fun delegate<C>(
        delegated: &mut RegulatedMintCap<C>,
        value: u64,
        ctx: &mut TxContext,
    ): RegulatedMintCap<C> {
        let supply = supply::extend(borrow_supply_mut(delegated), value);
        RegulatedMintCap {
            id: object::new(ctx),
            collection_id: regulated_collection_id(delegated),
            supply,
        }
    }

    /// Creates a new `RegulatedMintCap` by delegating all remaining supply
    /// from existing `RegulatedMintCap`.
    public fun delegate_all<C>(
        delegated: &mut RegulatedMintCap<C>,
        ctx: &mut TxContext,
    ): RegulatedMintCap<C> {
        let supply = supply::supply(borrow_supply(delegated));
        delegate(delegated, supply, ctx)
    }

    /// Delete `RegulatedMintCap<C>`
    public fun delete_regulated<C>(mint: RegulatedMintCap<C>): Supply {
        let RegulatedMintCap {
            id,
            collection_id: _,
            supply
        } = mint;
        object::delete(id);
        supply
    }

    /// Returns ID of `Collection` associated with `RegulatedMintCap`
    public fun regulated_collection_id<C>(mint: &RegulatedMintCap<C>): ID {
        mint.collection_id
    }

    /// Borrow `RegulatedMintCap` `Supply`
    public fun borrow_supply<C>(delegated: &RegulatedMintCap<C>): &Supply {
        &delegated.supply
    }

    /// Mutably borrow `RegulatedMintCap` `Supply`
    fun borrow_supply_mut<C>(
        delegated: &mut RegulatedMintCap<C>,
    ): &mut Supply {
        &mut delegated.supply
    }

    /// Increments the delegated supply of `Inventory`
    ///
    /// This endpoint must be called before a new `Nft` object is created to
    /// ensure that global supply tracking remains consistent.
    ///
    /// #### Panics
    ///
    /// Panics if delegated supply is exceeded.
    public entry fun increment_supply<C>(
        delegated: &mut RegulatedMintCap<C>,
        value: u64,
    ) {
        supply::increment(&mut delegated.supply, value);
    }
}
