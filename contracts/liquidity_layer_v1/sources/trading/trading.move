/// Reusable trading primitives.
module liquidity_layer_v1::trading {
    use std::option::{Self, Option};
    use sui::balance::{Self, Balance};
    use sui::coin;
    use sui::transfer::public_transfer;
    use sui::tx_context::{TxContext};

    /// Enables collection of wallet/marketplace collection for buying NFTs.
    /// 1. user bids via wallet to buy NFT for `p`, wallet wants fee `f`
    /// 2. when executed, `p` goes to seller and `f` goes to wallet
    struct BidCommission<phantom FT> has store {
        /// This is given to the facilitator of the trade.
        cut: Balance<FT>,
        /// A new `Coin` object is created and sent to this address.
        beneficiary: address,
    }

    /// Enables collection of wallet/marketplace collection for listing an NFT.
    /// 1. user lists NFT via wallet for price `p`, wallet requests fee `f`
    /// 2. when executed, `p - f` goes to user and `f` goes to wallet
    struct AskCommission has store, drop {
        /// How many tokens of the transferred amount should go to the party
        /// which holds the private key of `beneficiary` address.
        ///
        /// Always less than ask price.
        cut: u64,
        /// A new `Coin` object is created and sent to this address.
        beneficiary: address,
    }

    public fun new_ask_commission(
        beneficiary: address,
        cut: u64,
    ): AskCommission {
        AskCommission { beneficiary, cut }
    }

    public fun new_bid_commission<FT>(
        beneficiary: address,
        cut: Balance<FT>,
    ): BidCommission<FT> {
        BidCommission { beneficiary, cut }
    }

    public fun destroy_bid_commission<FT>(
        commission: BidCommission<FT>,
    ): (Balance<FT>, address) {
        let BidCommission { cut, beneficiary } = commission;
        (cut, beneficiary)
    }

    public fun transfer_bid_commission<FT>(
        commission: &mut Option<BidCommission<FT>>,
        ctx: &mut TxContext,
    ) {
        if (option::is_some(commission)) {
            let BidCommission { beneficiary, cut } =
                option::extract(commission);

            public_transfer(coin::from_balance(cut, ctx), beneficiary);
        };
    }

    public fun destroy_ask_commission(
        commission: AskCommission,
    ): (u64, address) {
        let AskCommission { cut, beneficiary } = commission;
        (cut, beneficiary)
    }

    public fun transfer_ask_commission<FT>(
        commission: &mut Option<AskCommission>,
        source: &mut Balance<FT>,
        ctx: &mut TxContext,
    ) {
        if (option::is_some(commission)) {
            let AskCommission { beneficiary, cut } =
                option::extract(commission);

            public_transfer(coin::take(source, cut, ctx), beneficiary);
        };
    }

    // === Getters ===

    public fun bid_commission_amount<FT>(bid: &BidCommission<FT>): u64 {
        balance::value(&bid.cut)
    }

    public fun bid_commission_beneficiary<FT>(bid: &BidCommission<FT>): address {
        bid.beneficiary
    }

    public fun ask_commission_amount(ask: &AskCommission): u64 {
        ask.cut
    }

    public fun ask_commission_beneficiary(ask: &AskCommission): address {
        ask.beneficiary
    }
}
