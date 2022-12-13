module nft_protocol::flat_fee {

    use sui::balance;
    use sui::tx_context;
    use sui::transfer::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use nft_protocol::err;
    use nft_protocol::proceeds;
    use nft_protocol::object_box;
    use nft_protocol::slot::{Self, Slot};
    use nft_protocol::launchpad::{Self, Launchpad};

    struct FlatFee has key, store {
        id: UID,
        rate_bps: u64,
    }

    public entry fun create(
        rate: u64,
        ctx: &mut TxContext,
    ) {
        transfer(create_(rate, ctx), tx_context::sender(ctx));
    }

    public entry fun collect_fee<FT>(
        launchpad: &Launchpad,
        slot: &mut Slot,
        ctx: &mut TxContext,
    ) {
        slot::assert_slot_launchpad_match(launchpad, slot);
        slot::assert_correct_admin(launchpad, slot, ctx);

        let (proceeds_value, slot_receiver) = {
            let proceeds = slot::proceeds(slot);
            let slot_receiver = slot::receiver(slot);
            let proceeds_value = proceeds::balance<FT>(proceeds);
            (proceeds_value, slot_receiver)
        };

        let fee_policy = if (slot::contains_custom_fee(slot)) {
            slot::custom_fee(slot)
        } else {
            launchpad::default_fee(launchpad)
        };

        assert!(
            object_box::has_object<FlatFee>(fee_policy),
            err::wrong_fee_policy_type(),
        );

        let policy = object_box::borrow<FlatFee>(fee_policy);

        let fee = balance::value(proceeds_value) * policy.rate_bps;

        proceeds::collect<FT>(
            slot::proceeds_mut(slot),
            fee,
            launchpad::receiver(launchpad),
            slot_receiver,
            ctx,
        );
    }

    public fun create_(
        rate_bps: u64,
        ctx: &mut TxContext,
    ): FlatFee {
        FlatFee {
            id: object::new(ctx),
            rate_bps,
        }
    }
}
