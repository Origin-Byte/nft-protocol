module nft_protocol::fixed_fees {

    use sui::balance;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use nft_protocol::err;
    use nft_protocol::proceeds;
    use nft_protocol::object_box;
    use nft_protocol::launchpad::{Self, Launchpad, Slot};

    struct FixedFee has key, store {
        id: UID,
        rate: u64,
    }

    public fun create(
        rate: u64,
        ctx: &mut TxContext,
    ): FixedFee {
        FixedFee {
            id: object::new(ctx),
            rate,
        }
    }

    public fun collect_fee<FT>(
        launchpad: &Launchpad,
        slot: &mut Slot,
        ctx: &mut TxContext,
    ) {
        launchpad::assert_slot(launchpad, slot);
        launchpad::assert_launchpad_or_slot_admin(launchpad, slot, ctx);

        let proceeds = launchpad::proceeds_mut<FT>(slot);

        let fee_policy = launchpad::custom_fee(slot);

        assert!(
            object_box::has_object<FixedFee>(fee_policy),
            err::wrong_fee_policy_type(),
        );

        let policy = object_box::borrow<FixedFee>(fee_policy);

        let fee = balance::value(proceeds::balance(proceeds)) * policy.rate;

        proceeds::collect(
            proceeds,
            fee,
            launchpad::launchpad_receiver(launchpad),
            launchpad::slot_receiver(slot),
            ctx,
        );
    }

}
