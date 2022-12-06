module nft_protocol::flat_fee {

    use sui::balance;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use nft_protocol::err;
    use nft_protocol::proceeds;
    use nft_protocol::object_box::{Self};
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

        let (proceeds_value, slot_receiver) = {
            let proceeds = launchpad::proceeds(slot);
            let slot_receiver = launchpad::slot_receiver(slot);
            let proceeds_value = proceeds::balance<FT>(proceeds);
            (proceeds_value, slot_receiver)
        };

        let fee_policy = if (launchpad::slot_has_custom_fee(slot)) {
            launchpad::custom_fee(slot)
        } else {
            launchpad::default_fee(launchpad)
        };

        assert!(
            object_box::has_object<FlatFee>(fee_policy),
            err::wrong_fee_policy_type(),
        );

        let policy = object_box::borrow<FlatFee>(fee_policy);

        let fee = balance::value(proceeds_value) * policy.rate;

        proceeds::collect<FT>(
            launchpad::proceeds_mut(slot),
            fee,
            launchpad::launchpad_receiver(launchpad),
            slot_receiver,
            ctx,
        );
    }
}
