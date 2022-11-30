// TODO: Constant Royalty domain
// TODO: Another royalty domain type mechanism could be such that the domain
// has a dynamic objects with relevant Balance<FT> into which these are stored.
module nft_protocol::royalty {
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use nft_protocol::nft::{Self, NFT};
    use nft_protocol::collection::{Self, Collection};

    const BPS: u64 = 10_000;

    struct BpsRoyaltyDomain has store {
        /// Address that receives the mint and trade royalties
        receiver: address,
        /// Royalty charged on trades in basis poitns
        royalty_fee_bps: u64,
    }

    public fun receiver(domain: &BpsRoyaltyDomain): address {
        domain.receiver
    }

    public fun royalty_fee_bps(domain: &BpsRoyaltyDomain): u64 {
        domain.royalty_fee_bps
    }

    public fun calculate(domain: &BpsRoyaltyDomain, amount: u64): u64  {
        amount / BPS * royalty_fee_bps(domain)
    }

    public fun new(
        receiver: address,
        royalty_fee_bps: u64,
    ): BpsRoyaltyDomain {
        BpsRoyaltyDomain {
            receiver,
            royalty_fee_bps,
        }
    }

    /// === Mutability ===

    public fun set_receiver(
        domain: &mut BpsRoyaltyDomain,
        receiver: address,
        ctx: &mut TxContext,
    ) {
        assert!(
            tx_context::sender(ctx) == domain.receiver,
            err::not_nft_owner()
        );

        domain.receiver = receiver;
    }

    public fun set_royalty_fee(
        domain: &mut BpsRoyaltyDomain,
        royalty_fee_bps: u64,
        ctx: &mut TxContext,
    ) {
        assert!(
            tx_context::sender(ctx) == domain.receiver,
            err::not_nft_owner()
        );

        domain.royalty_fee_bps = royalty_fee_bps;
    }

    /// === Interoperability ===

    public fun royalty_domain<C>(
        nft: &NFT<C>,
    ): &BpsRoyaltyDomain {
        nft::borrow_domain(nft)
    }

    public fun collection_royalty_domain<C>(
        nft: &Collection<C>,
    ): &BpsRoyaltyDomain {
        collection::borrow_domain(nft)
    }

    public fun add_royalty_domain<C>(
        nft: &mut NFT<C>,
        receiver: address,
        royalty_fee_bps: u64,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(nft, new(receiver, royalty_fee_bps), ctx);
    }

    public fun add_collection_royalty_domain<C>(
        nft: &mut Collection<C>,
        receiver: address,
        royalty_fee_bps: u64,
    ) {
        collection::add_domain(nft, new(receiver, royalty_fee_bps));
    }
}
