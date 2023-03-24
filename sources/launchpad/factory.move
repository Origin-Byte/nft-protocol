/// Module of `Factory` type
module nft_protocol::factory {
    use std::option::Option;

    use sui::object::{Self, ID, UID};
    use sui::tx_context::TxContext;

    use nft_protocol::nft::Nft;
    use nft_protocol::collection::Collection;
    use nft_protocol::metadata_bag;
    use nft_protocol::loose_mint_cap::{Self, LooseMintCap};
    use nft_protocol::mint_cap::{RegulatedMintCap, UnregulatedMintCap};

    /// `Factory` is an inventory that can mint loose NFTs
    ///
    /// Each `Factory` may only mint NFTs from a single collection.
    struct Factory<phantom T> has key, store {
        /// `Factory` ID
        id: UID,
        /// `LooseMintCap` responsible for generating `PointerDomain` and
        /// maintianing supply invariants on `Collection` and `Archetype`
        /// levels.
        mint_cap: LooseMintCap<T>,
    }

    /// Creates a new `Factory`
    ///
    /// `Factory` supply is limited by both the supply of the `Collection`
    /// and `Archetype` if either is regulated.
    ///
    /// #### Panics
    ///
    /// - Archetype `RegistryDomain` is not registered
    /// - `Archetype` does not exist
    public fun from_regulated<C>(
        mint_cap: RegulatedMintCap<Nft<C>>,
        collection: &mut Collection<Nft<C>>,
        metadata_id: ID,
        ctx: &mut TxContext,
    ): Factory<Nft<C>> {
        let mint_cap = metadata_bag::delegate_regulated(
            mint_cap, collection, metadata_id, ctx,
        );

        Factory { id: object::new(ctx), mint_cap }
    }

    /// Create `Factory` with unregulated supply
    ///
    /// `UnregulatedMintCap` can be obtained from
    /// `supply_domain::delegate_unregulated`.
    public fun from_unregulated<C>(
        mint_cap: UnregulatedMintCap<Nft<C>>,
        collection: &mut Collection<Nft<C>>,
        metadata_id: ID,
        ctx: &mut TxContext,
    ): Factory<Nft<C>> {
        let mint_cap = metadata_bag::delegate_unregulated(
            mint_cap, collection, metadata_id, ctx,
        );

        Factory { id: object::new(ctx), mint_cap }
    }

    /// Borrow `LooseMintCap`
    fun borrow_mint_cap<T>(factory: &Factory<T>): &LooseMintCap<T> {
        &factory.mint_cap
    }

    /// Mutably borrow `LooseMintCap`
    fun borrow_mint_cap_mut<T>(
        factory: &mut Factory<T>,
    ): &mut LooseMintCap<T> {
        &mut factory.mint_cap
    }

    /// Redeems NFT from `Factory`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Factory`.
    ///
    /// #### Panics
    ///
    /// Panics if supply was exceeded.
    public fun redeem_nft<C>(
        factory: &mut Factory<Nft<C>>,
        ctx: &mut TxContext,
    ): Nft<C> {
        let mint_cap = borrow_mint_cap_mut(factory);
        loose_mint_cap::mint_nft(mint_cap, ctx)
    }

    /// Redeems NFT from `Factory` and transfers
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Factory`.
    ///
    /// #### Panics
    ///
    /// Panics if supply was exceeded.
    public fun redeem_nft_and_transfer<C>(
        factory: &mut Factory<Nft<C>>,
        ctx: &mut TxContext,
    ) {
        let mint_cap = borrow_mint_cap_mut(factory);
        loose_mint_cap::mint_nft_and_transfer(mint_cap, ctx)
    }

    /// Returns the remaining supply available to `Factory`
    ///
    /// If factory is unregulated then none will be returned.
    public fun supply<C>(factory: &Factory<C>): Option<u64> {
        let mint_cap = borrow_mint_cap(factory);
        loose_mint_cap::supply(mint_cap)
    }
}
