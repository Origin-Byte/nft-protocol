module nft_protocol::proceeds {

    use sui::coin;
    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};

    /// `F`ungible `T`oken
    struct Proceeds<phantom FT> has key, store {
        id: UID,
        sold: Sold,
        total: u64,
        amount: Balance<FT>,
        /// The address where the amount should be transferred to.
        /// This could be either the payment for the seller or a marketplace's
        /// commision.
        beneficiary: address,
    }

    struct Sold has copy, drop, store {
        unwrapped: u64,
        total: u64,
    }

    public fun empty<FT>(
        beneficiary: address,
        ctx: &mut TxContext,
    ): Proceeds<FT> {
        Proceeds<FT> {
            id: object::new(ctx),
            sold: Sold {unwrapped: 0, total: 0},
            total: 0,
            amount: balance::zero(),
            beneficiary,
        }
    }

    public fun balance<FT>(payment: &Proceeds<FT>): &Balance<FT> {
        &payment.amount
    }

    fun balance_mut<FT>(
        payment: &mut Proceeds<FT>,
    ): &mut Balance<FT> {
        &mut payment.amount
    }

    public fun destroy_zero<FT>(
        proceeds: Proceeds<FT>,
    ) {
        let Proceeds {
            id,
            sold,
            total,
            amount: balance,
            beneficiary: _,
        } = proceeds;

        balance::destroy_zero(balance)
    }

    public fun beneficiary<FT>(payment: &Proceeds<FT>): address {
        payment.beneficiary
    }

    public fun add<FT>(
        proceeds: &mut Proceeds<FT>,
        new_proceeds: Balance<FT>,
        qty_sold: u64,
        ctx: &mut TxContext,
    ) {
        proceeds.total = proceeds.total + balance::value(balance(proceeds));
        proceeds.sold.total = proceeds.sold.total + qty_sold;

        balance::join(balance_mut(proceeds), new_proceeds);
    }

    public fun collect<FT>(
        proceeds: &mut Proceeds<FT>,
        fees: u64,
        launchpad_receiver: address,
        slot_receiver: address,
        ctx: &mut TxContext,
    ) {
        let fee_balance = balance::split<FT>(
            balance_mut(proceeds),
            fees,
        );

        let fee = coin::from_balance(fee_balance, ctx);

        transfer::transfer(
            fee,
            launchpad_receiver,
        );

        let proceeds_balance = balance::split<FT>(
            balance_mut(proceeds),
            balance::value(balance(proceeds)),
        );

        let proceeds_coin = coin::from_balance(proceeds_balance, ctx);

        transfer::transfer(
            fee,
            slot_receiver,
        );
    }
}
