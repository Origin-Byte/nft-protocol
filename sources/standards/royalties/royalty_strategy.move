module nft_protocol::royalty_strategy_bps {
    use std::fixed_point32;

    use nft_protocol::utils;

    struct BpsRoyaltyStrategy has drop, store {
        /// Royalty charged on trades in basis points
        royalty_fee_bps: u64,
    }

    public fun new(royalty_fee_bps: u64): BpsRoyaltyStrategy {
        BpsRoyaltyStrategy { royalty_fee_bps }
    }

    public fun royalty_fee_bps(domain: &BpsRoyaltyStrategy): u64 {
        domain.royalty_fee_bps
    }

    public fun calculate(domain: &BpsRoyaltyStrategy, amount: u64): u64  {
        // TODO: Need to consider implementing Decimals module for increased
        // precision, or wait for native support
        let royalty_rate = fixed_point32::create_from_rational(
            royalty_fee_bps(domain),
            (utils::bps() as u64)
        );

        fixed_point32::multiply_u64(
            amount,
            royalty_rate,
        )
    }
}

module nft_protocol::royalty_strategy_constant {
    struct ConstantRoyaltyStrategy has drop, store {
        /// Constant royalty charged
        royalty_fee: u64,
    }

    public fun new(royalty_fee: u64): ConstantRoyaltyStrategy {
        ConstantRoyaltyStrategy { royalty_fee}
    }

    public fun royalty_fee(domain: &ConstantRoyaltyStrategy): u64 {
        domain.royalty_fee
    }

    public fun calculate(domain: &ConstantRoyaltyStrategy): u64  {
        royalty_fee(domain)
    }
}
