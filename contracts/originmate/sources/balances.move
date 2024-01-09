module originmate::balances {
    use std::type_name;
    use sui::balance::{Self, Balance};
    use sui::dynamic_field as df;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    /// Stores balances of various currencies.
    struct Balances has store {
        /// Balances are stored as dynamic fields.
        inner: UID,
        /// How many balances are there associated with this struct.
        /// Can only be destroyed if the number is zero.
        items: u64,
    }

    public fun new(ctx: &mut TxContext): Balances {
        Balances { inner: object::new(ctx), items: 0 }
    }

    public fun destroy_empty(self: Balances) {
        let Balances { inner, items } = self;
        assert!(items == 0, 0);
        object::delete(inner);
    }

    public fun join_with<FT>(self: &mut Balances, with: Balance<FT>) {
        balance::join(borrow_mut<FT>(self), with);
    }

    public fun take_from<FT>(self: &mut Balances, from: &mut Balance<FT>, amount: u64) {
        balance::join(borrow_mut<FT>(self), balance::split(from, amount));
    }

    public fun withdraw_all_from<FT>(self: &mut Balances, from: &mut Balance<FT>) {
        balance::join(borrow_mut<FT>(self), balance::withdraw_all(from));
    }

    public fun withdraw_all<FT>(self: &mut Balances): Balance<FT> {
        self.items = self.items - 1;
        df::remove(&mut self.inner, type_name::get<FT>())
    }

    public fun withdraw_amount<FT>(self: &mut Balances, amount: u64): Balance<FT> {
        balance::split(borrow_mut(self), amount)
    }

    /// If balance does no exist, it is created with zero value.
    public fun borrow_mut<FT>(self: &mut Balances): &mut Balance<FT> {
        let ft = type_name::get<FT>();
        if (!df::exists_(&self.inner, ft)) {
            self.items = self.items + 1;
            df::add(&mut self.inner, ft, balance::zero<FT>());
        };
        df::borrow_mut(&mut self.inner, ft)
    }

    /// Panics if the balance does not exist.
    public fun borrow<FT>(self: &Balances): &Balance<FT> {
        df::borrow(&self.inner, type_name::get<FT>())
    }
}
