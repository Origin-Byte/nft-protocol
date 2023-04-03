/// Module of `Factory` type
module nft_protocol::factory {
    use std::vector;

    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::math;
    use sui::bcs::{Self, BCS};

    use nft_protocol::mint_pass::{Self, MintPass};
    // use nft_protocol::loose_mint_cap::{Self, LooseMintCap};
    use nft_protocol::mint_cap::{MintCap};
    use nft_protocol::venue_v2::{Self, NftCert};

    /// `Warehouse` does not have NFT at specified index
    ///
    /// Call `Warehouse::redeem_nft_at_index` with an index that exists.
    const EINDEX_OUT_OF_BOUNDS: u64 = 3;

    /// `Factory` is an inventory that can mint loose NFTs
    ///
    /// Each `Factory` may only mint NFTs from a single collection.
    struct Factory<phantom T> has key, store {
        /// `Factory` ID
        id: UID,
        // TODO: To convert to table vec, need to add fetch_idx helper
        metadata: vector<BCS>,
        /// `LooseMintCap` responsible for generating `PointerDomain` and
        /// maintianing supply invariants on `Collection` and `Archetype`
        /// levels.
        total_deposited: u64,
        mint_cap: MintCap<T>,
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
    public fun new<T>(
        mint_cap: MintCap<T>,
        ctx: &mut TxContext,
    ): Factory<T> {
        Factory {
            id: object::new(ctx),
            metadata: vector::empty(),
            total_deposited: 0,
            mint_cap,
        }
    }

    // /// Borrow `LooseMintCap`
    // fun borrow_mint_cap<C>(factory: &Factory<C>): &LooseMintCap<C> {
    //     &factory.mint_cap
    // }

    // /// Mutably borrow `LooseMintCap`
    // fun borrow_mint_cap_mut<C>(
    //     factory: &mut Factory<C>,
    // ): &mut LooseMintCap<C> {
    //     &mut factory.mint_cap
    // }

    /// Mints NFT from `Factory`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Factory`.
    ///
    /// #### Panics
    ///
    /// Panics if supply was exceeded.
    public fun redeem_nft<T: key + store>(
        factory: &mut Factory<T>,
        certificate: NftCert,
        ctx: &mut TxContext,
    ): MintPass<T> {
        // TODO: Assert type of NFT
        venue_v2::assert_cert_buyer(&certificate, ctx);
        venue_v2::assert_cert_inventory(&certificate, object::id(factory));

        //
        let index = math::divide_and_round_up(
            factory.total_deposited * venue_v2::get_relative_index(&certificate),
            venue_v2::get_index_scale(&certificate)
        );

        venue_v2::consume_certificate(certificate);

        redeem_mint_pass_at_index<T>(factory, index, ctx)
    }

    /// Redeems NFT from specific index in `Warehouse`
    ///
    /// Does not retain original order of NFTs in the bookkeeping vector.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    ///
    /// `Warehouse` may not change the logical owner of an `Nft` when
    /// redeeming as this would allow royalties to be trivially bypassed.
    ///
    /// #### Panics
    ///
    /// Panics if index does not exist in `Warehouse`.
    fun redeem_mint_pass_at_index<T: key + store>(
        factory: &mut Factory<T>,
        index: u64,
        ctx: &mut TxContext,
    ): MintPass<T> {
        let metadatas = &mut factory.metadata;
        assert!(index < vector::length(metadatas), EINDEX_OUT_OF_BOUNDS);

        let metadata = *vector::borrow(metadatas, index);

        // Swap index to remove with last element avoids shifting entire vector
        // of NFTs.
        //
        // `length - 1` is guaranteed to always resolve correctly
        mint_pass::new_with_metadata(
            &mut factory.mint_cap,
            1, // SUPPLY
            &bcs::to_bytes(&metadata),
            ctx,
        )
    }
}
