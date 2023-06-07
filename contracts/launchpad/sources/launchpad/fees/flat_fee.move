module ob_launchpad::flat_fee {
    use sui::balance;
    use sui::tx_context;
    use sui::transfer::public_transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use originmate::object_box;

    use ob_utils::math;
    use ob_utils::utils;
    use ob_launchpad::proceeds;
    use ob_launchpad::listing::{Self, Listing};
    use ob_launchpad::marketplace::{Self as mkt, Marketplace};

    /// `Listing` did not have `FlatFee` policy
    const EInvalidFeePolicy: u64 = 1;

    struct FlatFee has key, store {
        id: UID,
        rate_bps: u64,
    }

    public fun new(rate_bps: u64, ctx: &mut TxContext): FlatFee {
        FlatFee {
            id: object::new(ctx),
            rate_bps,
        }
    }

    public entry fun init_fee(
        rate: u64,
        ctx: &mut TxContext,
    ) {
        public_transfer(new(rate, ctx), tx_context::sender(ctx));
    }

    /// Collect proceeds and fees
    ///
    /// Requires that caller is listing admin in order to protect against
    /// rugpulls.
    ///
    /// #### Panics
    ///
    /// Panics if `Listing` was not attached to the `Marketplace` or
    /// `Marketplace` did not define a flat fee.
    public entry fun collect_proceeds_and_fees<FT>(
        marketplace: &Marketplace,
        listing: &mut Listing,
        ctx: &mut TxContext,
    ) {
        listing::assert_listing_marketplace_match(marketplace, listing);
        listing::assert_correct_admin_or_member(marketplace, listing, ctx);

        let (proceeds_value, listing_receiver) = {
            let proceeds = listing::borrow_proceeds(listing);
            let listing_receiver = listing::receiver(listing);
            let proceeds_value = proceeds::balance<FT>(proceeds);
            (proceeds_value, listing_receiver)
        };

        let fee_policy = if (listing::contains_custom_fee(listing)) {
            listing::custom_fee(listing)
        } else {
            mkt::default_fee(marketplace)
        };

        assert!(
            object_box::has_object<FlatFee>(fee_policy),
            EInvalidFeePolicy,
        );

        let policy = object_box::borrow<FlatFee>(fee_policy);

        let fee = calc_fee(balance::value(proceeds_value), policy.rate_bps);

        proceeds::collect_with_fees<FT>(
            listing::borrow_proceeds_mut(listing),
            fee,
            mkt::receiver(marketplace),
            listing_receiver,
            ctx,
        );
    }

    fun calc_fee(proceeds_value: u64, rate_bps: u64): u64 {
        let (_, div) = math::div_round(rate_bps, (utils::bps() as u64));
        let (_, result) = math::mul_round(div, proceeds_value);
        result
    }

    // === Tests ==

    #[test]
    fun test_calc_fee() {
        let proceeds = 143_534_456;
        let rate_bps = 700; // 5%

        assert!(calc_fee(proceeds, rate_bps) == 10_047_411, 0);
    }

    #[test]
    fun test_precision_() {
        // Round 1
        let trade = 7_777_777_777_777_777_777;

        assert!(calc_fee(trade, 555) == 431_666_666_666_666_666, 0);

        // Round 2
        let trade = 777_777_777_777_777_777;
        assert!(calc_fee(trade, 555) == 431_666_666_666_666_66, 0);

        // Round 3
        let trade = 777_777_777_777_777_77;
        assert!(calc_fee(trade, 555) == 431_666_666_666_666_6, 0);

        // Round 4
        let trade = 777_777_777_777_777_7;
        assert!(calc_fee(trade, 555) == 431_666_666_666_666, 0);

        // Round 5
        let trade = 777_777_777_777;
        assert!(calc_fee(trade, 555) == 431_666_666_66, 0);

        // Round 6
        let trade = 777_777_777;
        assert!(calc_fee(trade, 555) == 431_666_66, 0);

        // Round 7
        let trade = 777_777;
        assert!(calc_fee(trade, 555) == 431_66, 0);
    }
}
