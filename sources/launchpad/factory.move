/// Module of `Factory` type
module nft_protocol::factory {
    use std::option::{Self, Option};

    use sui::object::{Self, ID, UID};
    use sui::tx_context::TxContext;

    use nft_protocol::nft::Nft;
    use nft_protocol::collection::Collection;
    use nft_protocol::metadata_bag;
    use nft_protocol::supply_domain;
    use nft_protocol::mint_cap::MintCap;
    use nft_protocol::loose_mint_cap::{Self, LooseMintCap};
    use nft_protocol::mint_cap::{RegulatedMintCap, UnregulatedMintCap};

    /// `Factory` is an inventory that can mint loose NFTs
    ///
    /// Each `Factory` may only mint NFTs from a single collection.
    struct Factory<phantom C> has key, store {
        /// `Factory` ID
        id: UID,
        /// `LooseMintCap` responsible for generating `PointerDomain` and
        /// maintianing supply invariants on `Collection` and `Template`
        /// levels.
        mint_cap: LooseMintCap<C>,
    }

    /// Create a new `Factory`
    ///
    /// Optional `supply` argument defined if `Factory` supply is limited or
    /// not. `Factory` object exist 1-to-1 with an NFT template and therefore
    /// the collection level supply is limited by both the supply of the
    /// `Collection` and `Template` if either is regulated.
    ///
    /// #### Panics
    ///
    /// - Template `TemplatesDomain` is not registered
    /// - `Template` does not exist
    public fun new<C>(
        mint_cap: &MintCap<C>,
        collection: &mut Collection<C>,
        template_id: ID,
        supply: Option<u64>,
        ctx: &mut TxContext
    ): Factory<C> {
        let factory: Factory<C>;

        if (option::is_none(&supply)) {
            let cap = supply_domain::delegate_unregulated(mint_cap, collection, ctx);

            factory = from_unregulated(cap, collection, template_id, ctx);
        } else {
            // TODO: This should not be the global supply but the template supply
            let cap = supply_domain::delegate(mint_cap, collection, *option::borrow(&supply), ctx);

            factory = from_regulated(cap, collection, template_id, ctx);
        };

        factory
    }

    /// Creates a new `Factory`
    ///
    /// `Factory` supply is limited by both the supply of the `Collection`
    /// and `Template` if either is regulated.
    ///
    /// #### Panics
    ///
    /// - Template `TemplatesDomain` is not registered
    /// - `Template` does not exist
    public fun from_regulated<C>(
        mint_cap: RegulatedMintCap<C>,
        collection: &mut Collection<C>,
        metadata_id: ID,
        ctx: &mut TxContext,
    ): Factory<C> {
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
        mint_cap: UnregulatedMintCap<C>,
        collection: &mut Collection<C>,
        metadata_id: ID,
        ctx: &mut TxContext,
    ): Factory<C> {
        let mint_cap = metadata_bag::delegate_unregulated(
            mint_cap, collection, metadata_id, ctx,
        );

        Factory { id: object::new(ctx), mint_cap }
    }

    /// Borrow `LooseMintCap`
    fun borrow_mint_cap<C>(factory: &Factory<C>): &LooseMintCap<C> {
        &factory.mint_cap
    }

    /// Mutably borrow `LooseMintCap`
    fun borrow_mint_cap_mut<C>(
        factory: &mut Factory<C>,
    ): &mut LooseMintCap<C> {
        &mut factory.mint_cap
    }

    /// Mints NFT from `Factory`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Factory`.
    ///
    /// #### Panics
    ///
    /// Panics if supply was exceeded.
    public fun redeem_nft<C>(
        factory: &mut Factory<C>,
        ctx: &mut TxContext,
    ): Nft<C> {
        let mint_cap = borrow_mint_cap_mut(factory);
        loose_mint_cap::mint_nft(mint_cap, ctx)
    }

    /// Returns the remaining supply available to `Factory`
    ///
    /// If factory is unregulated then none will be returned.
    public fun supply<C>(factory: &Factory<C>): Option<u64> {
        let mint_cap = borrow_mint_cap(factory);
        loose_mint_cap::supply(mint_cap)
    }
}
