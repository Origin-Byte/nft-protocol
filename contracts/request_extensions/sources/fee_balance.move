module ob_request_extensions::fee_balance {
    use std::option;

    use sui::balance::{Self, Balance};
    use sui::coin;
    use sui::dynamic_field as df;
    use sui::transfer::public_transfer;
    use sui::tx_context::TxContext;

    use ob_request::transfer_request::{Self as tr, TransferRequest, BalanceAccessCap};

    // === Structs ===

    struct Witness has drop {}

    struct FeeBalance<phantom FT> has store {
        balance: Balance<FT>,
        beneficiary: address,
    }

    // Stores inner fee from the trde price. Sometimes the BalanceDfKey will only
    // capture the net price, and in those cases we capture the rest of the gross
    // price here.
    struct FeeBalanceDfKey has copy, store, drop {}

    /// Aborts unless called exactly once.
    public fun set_paid_fee<T, FT>(
        self: &mut TransferRequest<T>,
        fee: Balance<FT>,
        fee_beneficiary: address,
    ) {
        df::add(
            tr::metadata_mut(self),
            FeeBalanceDfKey {},
            FeeBalance {balance: fee, beneficiary: fee_beneficiary},
        );
    }


    public fun distribute_fee_to_intermediary<T, FT>(
        self: &mut TransferRequest<T>, ctx: &mut TxContext,
    ) {
        let metadata = tr::metadata_mut(self);

        let fee_opt = df::remove_if_exists<FeeBalanceDfKey, FeeBalance<FT>>(metadata, FeeBalanceDfKey {});

        if (option::is_none(&fee_opt)) {
            option::destroy_none(fee_opt);
            return
        };

        let fee_balance: FeeBalance<FT> = option::extract(&mut fee_opt);

        let FeeBalance<FT> { balance, beneficiary } = fee_balance;

        if (balance::value(&balance) > 0) {
            public_transfer(coin::from_balance(balance, ctx), beneficiary);
        } else {
            balance::destroy_zero(balance);
        };

        option::destroy_none(fee_opt);
    }

    // === Getters ===

    public fun paid_in_fees<T, FT>(
        self: &TransferRequest<T>,
    ): (&Balance<FT>, address) {
        let fee_balance = df::borrow<FeeBalanceDfKey, FeeBalance<FT>>(tr::metadata(self), FeeBalanceDfKey {});
        (&fee_balance.balance, fee_balance.beneficiary)
    }

    public fun paid_in_fees_mut<T, FT>(
        self: &mut TransferRequest<T>, _cap: &BalanceAccessCap<T>,
    ): (&mut Balance<FT>, address) {
        let fee_balance = df::borrow_mut<FeeBalanceDfKey, FeeBalance<FT>>(tr::metadata_mut(self), FeeBalanceDfKey {});
        (&mut fee_balance.balance, fee_balance.beneficiary)
    }

    public fun has_fees<T>(
        self: &TransferRequest<T>,
    ): bool {
        df::exists_(tr::metadata(self), FeeBalanceDfKey {})
    }

}
