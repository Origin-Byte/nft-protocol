module ob_launchpad::flat_fee {
    use sui::balance;
    use sui::tx_context;
    use sui::transfer::public_transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use originmate::object_box;

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

    public entry fun collect_proceeds_and_fees<FT>(
        marketplace: &Marketplace,
        listing: &mut Listing,
        ctx: &mut TxContext,
    ) {
        listing::assert_listing_marketplace_match(marketplace, listing);
        listing::assert_correct_admin(marketplace, listing, ctx);

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

        let fee = balance::value(proceeds_value) * policy.rate_bps / 10_000;

        proceeds::collect_with_fees<FT>(
            listing::borrow_proceeds_mut(listing),
            fee,
            mkt::receiver(marketplace),
            listing_receiver,
            ctx,
        );
    }
}
