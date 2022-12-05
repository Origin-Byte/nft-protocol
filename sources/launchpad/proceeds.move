module nft_protocol::proceeds {

    use nft_protocol::utils;
    use std::option::{Self, Option};
    use sui::balance::{Self, Balance};
    use sui::coin;
    use sui::object::{Self, ID, UID};
    use sui::transfer::{transfer, share_object};
    use sui::tx_context::TxContext;

    /// `F`ungible `T`oken
    struct Proceeds<phantom FT> has key, store {
        id: UID,
        amount: Balance<FT>,
        /// The address where the amount should be transferred to.
        /// This could be either the payment for the seller or a marketplace's
        /// commision.
        beneficiary: address,
    }

    public fun create<FT>(
        amount: Balance<FT>,
        beneficiary: address,
        ctx: &mut TxContext,
    ): Proceeds<FT> {
        Proceeds<FT> {
            id: object::new(ctx),
            amount,
            beneficiary,
        }
    }

    public fun balance<FT>(payment: &Proceeds<FT>): &Balance<FT> {
        &payment.amount
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
