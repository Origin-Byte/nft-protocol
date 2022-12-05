module nft_protocol::fixed_fees {

    use nft_protocol::utils;
    use std::option::{Self, Option};
    use sui::balance::{Self, Balance};
    use sui::coin;
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::TxContext;

    use nft_protocol::err;
    use nft_protocol::launchpad::{Self, Launchpad, Slot};
    use nft_protocol::proceeds::{Self, Proceeds};
    use nft_protocol::object_box::{Self, ObjectBox};

    struct FixedFee has key, store {
        id: UID,
        rate: u64,
    }

    public fun create(
        launchpad: &mut Launchpad,
        slot: &mut Slot,
        rate: u64,
        ctx: &mut TxContext,
    ): FixedFee {
        FixedFee {
            id: object::new(ctx),
            rate,
        }
    }

    public fun collect_fee<FT>(
        launchpad: &mut Launchpad,
        slot: &mut Slot,
        ctx: &mut TxContext,
    ) {
        launchpad::assert_slot(launchpad, slot);

        let slot_id = launchpad::slot_id(slot);

        let proceeds = launchpad::proceeds_mut<FT>(
            launchpad,
            launchpad::slot_id(slot),
        );

        let fee_policy = launchpad::fee_policy(launchpad, slot_id);

        assert!(
            object_box::has_object<FixedFee>(fee_policy),
            err::wrong_fee_policy_type(),
        );

        let policy = object_box::borrow_object<FixedFee>(fee_policy);

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
