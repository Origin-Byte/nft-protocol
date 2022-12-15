module nft_protocol::trading {
    //! Reusable trading primitives.

    use nft_protocol::royalties;
    use std::option::{Self, Option};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self};
    use sui::object::{Self};
    use sui::transfer::{transfer};
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

            transfer(coin::from_balance(cut, ctx), beneficiary);
        };
    }

    public fun pay_for_nft<C, FT>(
        paid: &mut Balance<FT>,
        buyer: address,
        maybe_commission: &mut Option<AskCommission>,
        ctx: &mut TxContext,
    ) {
        let amount = balance::value(paid);

        if (option::is_some(maybe_commission)) {
            // the `p`aid amount for the NFT and the commission `c`ut

            let AskCommission {
                cut, beneficiary,
            } = option::extract(maybe_commission);

            // associates both payments with each other
            let trade = object::new(ctx);

            // `p` - `c` goes to seller
            royalties::create_with_trade<C, FT>(
                balance::split(paid, amount - cut),
                buyer,
                object::uid_to_inner(&trade),
                ctx,
            );
            // `c` goes to the marketplace
            royalties::create_with_trade<C, FT>(
                balance::split(paid, cut),
                beneficiary,
                object::uid_to_inner(&trade),
                ctx,
            );

            object::delete(trade);
        } else {
            // no commission, all `p` goes to seller

            royalties::create<C, FT>(
                balance::split(paid, amount),
                buyer,
                ctx,
            );
        };
    }
}
