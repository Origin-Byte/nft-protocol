module nft_protocol::flat_fee {

    use sui::balance;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use nft_protocol::err;
    use nft_protocol::proceeds;
    use nft_protocol::object_box::{Self, ObjectBox};
    use nft_protocol::launchpad::{Self, Launchpad, Slot};

    struct FlatFee has key, store {
        id: UID,
        rate: u64,
    }

    public fun create(
        rate: u64,
        ctx: &mut TxContext,
    ): FlatFee {
        FlatFee {
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

        let proceeds = launchpad::proceeds_mut(slot);

        let fee_policy: &ObjectBox;

        if (launchpad::slot_has_custom_fee(slot)) {
            fee_policy = launchpad::custom_fee(slot);
        } else {
            fee_policy = launchpad::default_fee(launchpad);
        };

        assert!(
            object_box::has_object<FlatFee>(fee_policy),
            err::wrong_fee_policy_type(),
        );

        let policy = object_box::borrow<FlatFee>(fee_policy);

        let fee = balance::value(proceeds::balance<FT>(proceeds)) * policy.rate;

        proceeds::collect<FT>(
            proceeds,
            fee,
            launchpad::launchpad_receiver(launchpad),
            launchpad::slot_receiver(slot),
            ctx,
        );
    }
}
