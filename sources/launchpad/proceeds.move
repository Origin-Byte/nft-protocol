module nft_protocol::proceeds {
    // TODO: Function to destroy Proceeds object
    // TODO: reconsider `Proceeds.total` to acocmodate for multiple FTs
    use std::type_name::{Self, TypeName};

    use sui::coin;
    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::dynamic_field as df;

    struct Proceeds has key, store {
        id: UID,
        // Quantity of NFTs sold
        qt_sold: QtSold,
        // Total FT-amount sold. The reason for storing this info is to allow
        // for custom types of fees that rely on the total FT-amount sold.
        // Marketplaces could then reduce the amount of fees charged based
        // on the bulk-volume of the sale.
        total: u64,
    }

    // Quantity of NFTs Sold
    struct QtSold has copy, drop, store {
        // Bookeeping of all NFT sold whose proceeds have been withdrawn.
        collected: u64,
        // Total number of NFTs sold. The reason for storing this info is to
        // allow for custom types of fees that rely on the total FT-amount sold.
        // Marketplaces could then reduce the amount of fees charged based
        // on the bulk-volume of the sale.
        total: u64,
    }

    public fun empty(
        ctx: &mut TxContext,
    ): Proceeds {
        Proceeds {
            id: object::new(ctx),
            qt_sold: QtSold {collected: 0, total: 0},
            total: 0,
        }
    }

    public fun balance<FT>(proceeds: &Proceeds): &Balance<FT> {
        df::borrow<TypeName, Balance<FT>>(
            &proceeds.id,
            type_name::get<Balance<FT>>(),
        )
    }

    fun balance_mut<FT>(
        proceeds: &mut Proceeds,
    ): &mut Balance<FT> {
        df::borrow_mut<TypeName, Balance<FT>>(
            &mut proceeds.id,
            type_name::get<Balance<FT>>(),
        )
    }

    public fun add<FT>(
        proceeds: &mut Proceeds,
        new_proceeds: Balance<FT>,
        qty_sold: u64,
    ) {
        proceeds.total = proceeds.total + balance::value(&new_proceeds);
        proceeds.qt_sold.total = proceeds.qt_sold.total + qty_sold;

        let missing_df = !df::exists_with_type<TypeName, Balance<FT>>(
            &proceeds.id, type_name::get<Balance<FT>>()
        );

        if (missing_df) {
            df::add<TypeName, Balance<FT>>(
                &mut proceeds.id,
                type_name::get<Balance<FT>>(),
                new_proceeds,
            )
        } else {
            let balance = df::borrow_mut<TypeName, Balance<FT>>(
                &mut proceeds.id,
                type_name::get<Balance<FT>>(),
            );

            balance::join(
                balance,
                new_proceeds
            );
        }
    }

    public fun collect<FT>(
        proceeds: &mut Proceeds,
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

        let balance_value = balance::value(balance);

        // Take the whole balance
        let proceeds_balance = balance::split<FT>(
            balance,
            balance_value,
        );

        let proceeds_coin = coin::from_balance(proceeds_balance, ctx);

        transfer::transfer(
            proceeds_coin,
            slot_receiver,
        );
    }
}
