module nft_protocol::proceeds {

    use std::type_name::{Self, TypeName};

    use sui::coin;
    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::dynamic_field as df;


    /// `F`ungible `T`oken
    struct Proceeds<phantom FT> has key, store {
        id: UID,
        sold: Sold,
        total: u64,
        // amount: Balance<FT>,
    }

    struct Sold has copy, drop, store {
        unwrapped: u64,
        total: u64,
    }

    public fun empty<FT>(
        ctx: &mut TxContext,
    ): Proceeds<FT> {
        Proceeds<FT> {
            id: object::new(ctx),
            sold: Sold {unwrapped: 0, total: 0},
            total: 0,
        }
    }

    public fun balance<FT>(proceeds: &Proceeds<FT>): &Balance<FT> {
        df::borrow<TypeName, Balance<FT>>(
            &proceeds.id,
            type_name::get<Balance<FT>>(),
        )
    }

    fun balance_mut<FT>(
        proceeds: &mut Proceeds<FT>,
    ): &mut Balance<FT> {
        df::borrow_mut<TypeName, Balance<FT>>(
            &mut proceeds.id,
            type_name::get<Balance<FT>>(),
        )
    }

    // public fun destroy_zero<FT>(
    //     proceeds: Proceeds<FT>,
    // ) {
    //     let Proceeds {
    //         id,
    //         sold,
    //         total,
    //         amount: balance,
    //     } = proceeds;

    //     balance::destroy_zero(balance)
    // }

    public fun add<FT>(
        proceeds: &mut Proceeds<FT>,
        new_proceeds: Balance<FT>,
        qty_sold: u64,
        ctx: &mut TxContext,
    ) {
        proceeds.total = proceeds.total + balance::value(&new_proceeds);
        proceeds.sold.total = proceeds.sold.total + qty_sold;

        let balance = df::borrow_mut<TypeName, Balance<FT>>(
            &mut proceeds.id,
            type_name::get<Balance<FT>>(),
        );

        balance::join(
            balance,
            new_proceeds
        );
    }

    public fun collect<FT>(
        proceeds: &mut Proceeds<FT>,
        fees: u64,
        launchpad_receiver: address,
        slot_receiver: address,
        ctx: &mut TxContext,
    ) {
        let balance = df::borrow_mut<TypeName, Balance<FT>>(
            &mut proceeds.id,
            type_name::get<Balance<FT>>(),
        );

        let fee_balance = balance::split<FT>(
            balance,
            fees,
        );

        let fee = coin::from_balance(fee_balance, ctx);

        transfer::transfer(
            fee,
            launchpad_receiver,
        );

        // Take the whole balance
        let proceeds_balance = balance::split<FT>(
            balance,
            balance::value(balance),
        );

        let proceeds_coin = coin::from_balance(proceeds_balance, ctx);

        transfer::transfer(
            fee,
            slot_receiver,
        );
    }
}
