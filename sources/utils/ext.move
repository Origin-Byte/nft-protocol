//! Exports utility functions which depend on the codebase as a whole in order
//! to avoid dependency cycles.
//
// TODO: Move remaining standards to here
module nft_protocol::ext {
    use sui::tx_context::TxContext;

    use nft_protocol::nft::{Self, NFT};
    use nft_protocol::collection::{Self, Collection};

    use nft_protocol::royalty::{Self, RoyaltyDomain};

    /// === RoyaltyDomain ===

    public fun royalty_domain<C, FT>(
        nft: &NFT<C>,
    ): &RoyaltyDomain<FT> {
        nft::borrow_domain(nft)
    }

    public fun collection_royalty_domain<C, FT>(
        nft: &Collection<C>,
    ): &RoyaltyDomain<FT> {
        collection::borrow_domain(nft)
    }

    public fun royalty_domain_mut<C, FT>(
        nft: &mut NFT<C>,
    ): &mut RoyaltyDomain<FT> {
        nft::borrow_domain_mut(royalty::witness(), nft)
    }

    public fun collection_royalty_domain_mut<C, FT>(
        nft: &mut Collection<C>,
    ): &mut RoyaltyDomain<FT> {
        collection::borrow_domain_mut(royalty::witness(), nft)
    }

    public fun add_royalty_domain<C, FT>(
        nft: &mut NFT<C>,
        domain: RoyaltyDomain<FT>,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(nft, domain, ctx);
    }

    public fun add_collection_royalty_domain<C, FT>(
        nft: &mut Collection<C>,
        domain: RoyaltyDomain<FT>,
    ) {
        collection::add_domain(nft, domain);
    }
}
