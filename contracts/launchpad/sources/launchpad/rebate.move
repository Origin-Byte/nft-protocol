module ob_launchpad::rebate {
    use sui::coin;
    use sui::balance::{Self, Balance};
    use sui::dynamic_field as df;
    use sui::object::UID;
    use sui::tx_context::TxContext;
    use sui::transfer;

    /// Object does not define a rebate for the given type
    const ERebateUndefined: u64 = 1;

    /// `Rebate` container which allows providing a rebate on purchases of a
    /// certain type as long as funds persist.
    struct Rebate<phantom FT> has store {
        funds: Balance<FT>,
        rebate_amount: u64,
    }

    struct RebateDfKey<phantom T, phantom FT> has copy, drop, store {}

    /// Borrows the funds available ot issue further rebates
    public fun borrow_rebate_funds<FT>(rebate: &Rebate<FT>): &Balance<FT> {
        &rebate.funds
    }

    /// Borrows the amount of token, `FT`, that is issued for each purchase
    public fun borrow_rebate_amount<FT>(rebate: &Rebate<FT>): u64 {
        rebate.rebate_amount
    }

    /// Checks whether rebate policy exists
    public fun has_rebate<T: key + store, FT>(object: &UID): bool {
        df::exists_with_type<RebateDfKey<T, FT>, Rebate<FT>>(
            object, RebateDfKey<T, FT> {},
        )
    }

    /// Borrows rebate policy
    ///
    /// #### Panics
    ///
    /// Panics if rebate policy does not exist
    public fun borrow_rebate<T: key + store, FT>(object: &UID): &Rebate<FT> {
        assert!(has_rebate<T, FT>(object), ERebateUndefined);
        df::borrow(object, RebateDfKey<T, FT> {})
    }

    /// Mutably borrows rebate policy
    ///
    /// This function is unprotected and it is the resposibility of the object
    /// to not give public access to its `UID`.
    ///
    /// #### Panics
    ///
    /// Panics if rebate policy does not exist
    public fun borrow_rebate_mut<T: key + store, FT>(object: &mut UID): &mut Rebate<FT> {
        assert!(has_rebate<T, FT>(object), ERebateUndefined);
        df::borrow_mut(object, RebateDfKey<T, FT> {})
    }

    /// Sets rebate policy
    ///
    /// Rebate amount defines the amount of token `FT` that gets transferred
    /// back to the user after purchase.
    public fun set_rebate<T: key + store, FT>(
        object: &mut UID,
        rebate_amount: u64,
    ) {
        // If rebate already exists just update it
        if (has_rebate<T, FT>(object)) {
            let rebate = borrow_rebate_mut<T, FT>(object);
            rebate.rebate_amount = rebate_amount;
        } else {
            let rebate = Rebate<FT> { funds: balance::zero(), rebate_amount };
            df::add(object, RebateDfKey<T, FT> {}, rebate);
        }
    }

    /// Add funds to rebate policy
    ///
    /// #### Panics
    ///
    /// Panics if rebate policy for given type and token, `FT`, was not
    /// previously defined.
    public fun fund_rebate<T: key + store, FT>(
        object: &mut UID,
        balance: &mut Balance<FT>,
        fund_amount: u64,
    ) {
        let rebate = borrow_rebate_mut<T, FT>(object);
        balance::join(&mut rebate.funds, balance::split(balance, fund_amount));
    }

    /// Withdraw rebate funds
    ///
    /// This function is unprotected and it is the resposibility of the object
    /// to not give public access to its `UID`.
    ///
    /// #### Panics
    ///
    /// Panics if rebate for a given type and token, `FT` was not previously
    /// defined.
    public fun withdraw_rebate_funds<T: key + store, FT>(
        object: &mut UID,
        receiver: &mut Balance<FT>,
        amount: u64,
    ) {
        let rebate = borrow_rebate_mut<T, FT>(object);
        let balance = balance::split(&mut rebate.funds, amount);
        balance::join(receiver, balance);
    }

    /// Apply rebate funds
    ///
    /// This function is unprotected and it is the resposibility of the object
    /// to not give public access to its `UID`.
    ///
    /// Never aborts.
    public fun apply_rebate<T: key + store, FT>(
        object: &mut UID,
        wallet: &mut Balance<FT>,
    ) {
        if (has_rebate<T, FT>(object)) {
            let rebate = borrow_rebate_mut<T, FT>(object);

            let balance = balance::value(&rebate.funds);
            if (balance >= rebate.rebate_amount) {
                let funds = balance::split(&mut rebate.funds, rebate.rebate_amount);
                balance::join(wallet, funds);
            }
        }
    }

    /// Send rebate funds
    ///
    /// This function is unprotected and it is the resposibility of the object
    /// to not give public access to its `UID`.
    ///
    /// Never aborts.
    public fun send_rebate<T: key + store, FT>(
        object: &mut UID,
        receiver: address,
        ctx: &mut TxContext,
    ) {
        let balance = balance::zero<FT>();
        apply_rebate<T, FT>(object, &mut balance);
        transfer::public_transfer(coin::from_balance(balance, ctx), receiver);
    }


}