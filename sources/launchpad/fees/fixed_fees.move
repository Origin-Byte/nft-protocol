module nft_protocol::fixed_fees {

    use nft_protocol::utils;
    use std::option::{Self, Option};
    use sui::balance::{Self, Balance};
    use sui::coin;
    use sui::object::{Self, ID, UID};
    use sui::transfer::{transfer, share_object};
    use sui::tx_context::TxContext;

    use nft_protocol::launchpad::{Self, Launchpad, Slot};

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

    public fun unwrap(
        launchpad: &mut Launchpad,
        slot: &mut Slot,
    ) {
        launchpad::assert_slot(launchpad, slot);

        let slot_id = launchpad::slot_id(slot);

        let fee_amount = launchpad::fee(slot) * price;
        let net_price = price - fee_amount;

        // let fee = coin::split<SUI>(
        //     funds,
        //     fee_amount,
        //     ctx,
        // );

        // // Split coin into price and change, then transfer
        // // the price and keep the change
        // pay::split_and_transfer<SUI>(
        //     funds,
        //     net_price,
        //     receiver,
        //     ctx
        // );



    }

    /// `W` is the launchpad's witness (not the one time witness!) which
    /// helps us ensure that the right royalty collection logic is operating
    /// on this receipt.
    ///
    /// Only the designated witness can access the balance.
    ///
    /// Typically, this would be a witness exported from the collection contract
    /// and it would access the balance to calculate the royalty in its custom
    /// implementation.
    public fun balance_mut<FT>(
        // _witness: W,
        payment: &mut Proceeds<FT>,
    ): &mut Balance<FT> {
        // utils::assert_same_module_as_witness<C, W>();
        &mut payment.amount
    }

    public fun beneficiary<FT>(payment: &Proceeds<FT>): address {
        payment.beneficiary
    }

    public fun transfer_remaining_to_beneficiary<C, W: drop, FT>(
        _witness: W,
        payment: &mut Proceeds<FT>,
        ctx: &mut TxContext,
    ) {
        utils::assert_same_module_as_witness<C, W>();

        let amount = balance::value(&payment.amount);
        if (amount > 0) {
            transfer(
                coin::take(
                    &mut payment.amount,
                    amount,
                    ctx,
                ),
                payment.beneficiary
            );
        }
    }

}
