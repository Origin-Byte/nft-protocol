module nft_protocol::royalty_strategy_bps {
    const BPS: u64 = 10_000;

    struct BpsRoyaltyStrategy has store {
        /// Royalty charged on trades in basis points
        royalty_fee_bps: u64,
    }

    public fun name(): vector<u8> {
        b"bps"
    }

    public fun royalty_fee_bps(domain: &BpsRoyaltyStrategy): u64 {
        domain.royalty_fee_bps
    }

    public fun calculate(domain: &BpsRoyaltyStrategy, amount: u64): u64  {
        amount / BPS * royalty_fee_bps(domain)
    }

    public fun new(
        royalty_fee_bps: u64,
    ): BpsRoyaltyStrategy {
        BpsRoyaltyStrategy {
            royalty_fee_bps,
        }
    }
}

module nft_protocol::royalty_strategy_constant {
    struct ConstantRoyaltyStrategy has store {
        /// Constant royalty charged
        royalty_fee: u64,
    }

    public fun name(): vector<u8> {
        b"constant"
    }

    public fun royalty_fee(domain: &ConstantRoyaltyStrategy): u64 {
        domain.royalty_fee
    }

    public fun calculate(domain: &ConstantRoyaltyStrategy): u64  {
        royalty_fee(domain)
    }

    public fun new(
        royalty_fee: u64,
    ): ConstantRoyaltyStrategy {
        ConstantRoyaltyStrategy {
            royalty_fee,
        }
    }
}
