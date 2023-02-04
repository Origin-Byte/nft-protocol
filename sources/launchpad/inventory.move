/// Module of `Inventory` type, a type-erased wrapper around `Warehouse` and
/// `Factory`
module nft_protocol::inventory {
    use std::option::{Self, Option};

    use sui::transfer;
    use sui::tx_context;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::dynamic_field as df;

    use nft_protocol::nft::Nft;
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::factory::{Self, Factory};
    use nft_protocol::warehouse::{Self, Warehouse};

    /// `Inventory` is not a `Warehouse`
    ///
    /// Call `from_warehouse` to create an `Inventory` from `Warehouse`
    const ENOT_WAREHOUSE: u64 = 1;

    /// `Inventory` is not a `Factory`
    ///
    /// Call `from_factory` to create an `Inventory` from `Factory`
    const ENOT_FACTORY: u64 = 2;

    /// A type-erased wrapper around `Warehouse` and `Factory`
    struct Inventory<phantom C> has key, store {
        /// `Inventory` ID
        id: UID,
    }

    /// Create a new `Inventory` from a `Warehouse`
    public fun from_warehouse<C>(
        warehouse: Warehouse<C>,
        ctx: &mut TxContext,
    ): Inventory<C> {
        let inventory_id = object::new(ctx);
        df::add(&mut inventory_id, utils::marker<Warehouse<C>>(), warehouse);

        Inventory { id: inventory_id }
    }

    /// Create a new `Inventory` from a `Warehouse` and transfer to transaction
    /// sender
    public entry fun init_from_warehouse<C>(
        warehouse: Warehouse<C>,
        ctx: &mut TxContext,
    ) {
        let inventory = from_warehouse(warehouse, ctx);
        transfer::transfer(inventory, tx_context::sender(ctx));
    }

    /// Create a new `Inventory` from a `Factory`
    public fun from_factory<C>(
        factory: Factory<C>,
        ctx: &mut TxContext,
    ): Inventory<C> {
        let inventory_id = object::new(ctx);
        df::add(&mut inventory_id, utils::marker<Factory<C>>(), factory);

        Inventory { id: inventory_id }
    }

    /// Create a new `Inventory` from a `Factory` and transfer to transaction
    /// sender
    public entry fun init_from_factory<C>(
        factory: Factory<C>,
        ctx: &mut TxContext,
    ) {
        let inventory = from_factory(factory, ctx);
        transfer::transfer(inventory, tx_context::sender(ctx));
    }

    /// Deposits NFT to `Inventory`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Inventory`.
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` is not a `Warehouse`.
    public entry fun deposit_nft<C>(
        inventory: &mut Inventory<C>,
        nft: Nft<C>,
    ) {
        let warehouse = borrow_warehouse_mut(inventory);
        warehouse::deposit_nft(warehouse, nft);
    }

    /// Redeems NFT from `Inventory`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Inventory`.
    ///
    /// `Inventory` may not change the logical owner of an `Nft` when
    /// redeeming as this would allow royalties to be trivially bypassed.
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is empty or if `Factory` has a regulated supply
    /// whose supply was exceeded.
    public fun redeem_nft<C>(
        inventory: &mut Inventory<C>,
        ctx: &mut TxContext,
    ): Nft<C> {
        if (is_warehouse(inventory)) {
            let warehouse = borrow_warehouse_mut(inventory);
            warehouse::redeem_nft(warehouse)
        } else {
            let factory = borrow_factory_mut(inventory);
            factory::redeem_nft(factory, ctx)
        }

        // TODO: Change owner?
    }

    /// Redeems NFT from `Inventory`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Inventory`.
    ///
    /// `Inventory` may not change the logical owner of an `Nft` when
    /// redeeming as this would allow royalties to be trivially bypassed.
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is empty or if `Factory` has a regulated supply
    /// whose supply was exceeded.
    public entry fun redeem_nft_and_transfer<C>(
        inventory: &mut Inventory<C>,
        owner: address,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_nft(inventory, ctx);
        transfer::transfer(nft, owner);
    }

    // === Getters ===

    /// Returns whether `Inventory` has any remaining supply
    public fun is_empty<C>(inventory: &Inventory<C>): bool {
        let supply = supply(inventory);
        if (option::is_some(&supply)) {
            option::destroy_some(supply) == 0
        } else {
            option::destroy_none(supply);
            // None is only returned for factories with unregulated supplies
            false
        }
    }

    /// Returns the available supply in `Inventory`
    ///
    /// If the `Inventory` is a `Factory` with unregulated supply then none
    /// will be returned.
    ///
    /// #### Panics
    ///
    /// Panics if supply was exceeded.
    public fun supply<C>(inventory: &Inventory<C>): Option<u64> {
        if (is_warehouse(inventory)) {
            let warehouse = borrow_warehouse(inventory);
            option::some(warehouse::supply(warehouse))
        } else {
            let factory = borrow_factory(inventory);
            factory::supply(factory)
        }
    }

    /// Returns whether `Inventory` is a `Warehouse`
    public fun is_warehouse<C>(inventory: &Inventory<C>): bool {
        df::exists_with_type<Marker<Warehouse<C>>, Warehouse<C>>(
            &inventory.id, utils::marker<Warehouse<C>>()
        )
    }

    /// Returns whether `Inventory` is a `Factory`
    public fun is_factory<C>(inventory: &Inventory<C>): bool {
        df::exists_with_type<Marker<Factory<C>>, Factory<C>>(
            &inventory.id, utils::marker<Factory<C>>()
        )
    }

    /// Borrows `Inventory` as `Warehouse`
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` is a `Factory`
    public fun borrow_warehouse<C>(inventory: &Inventory<C>): &Warehouse<C> {
        assert_warehouse(inventory);
        df::borrow(&inventory.id, utils::marker<Warehouse<C>>())
    }

    /// Mutably borrows `Inventory` as `Warehouse`
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` is a `Factory`
    fun borrow_warehouse_mut<C>(
        inventory: &mut Inventory<C>,
    ): &mut Warehouse<C> {
        assert_warehouse(inventory);
        df::borrow_mut(&mut inventory.id, utils::marker<Warehouse<C>>())
    }

    /// Borrows `Inventory` as `Factory`
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` is a `Warehouse`
    public fun borrow_factory<C>(inventory: &Inventory<C>): &Factory<C> {
        assert_factory(inventory);
        df::borrow(&inventory.id, utils::marker<Factory<C>>())
    }

    /// Mutably borrows `Inventory` as `Factory`
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` is a `Warehouse`
    public fun borrow_factory_mut<C>(
        inventory: &mut Inventory<C>,
    ): &mut Factory<C> {
        assert_factory(inventory);
        df::borrow_mut(&mut inventory.id, utils::marker<Factory<C>>())
    }

    // === Assertions ===

    /// Asserts that `Inventory` is a `Warehouse`
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` is not a `Warehouse`
    public fun assert_warehouse<C>(inventory: &Inventory<C>) {
        assert!(is_warehouse(inventory), ENOT_WAREHOUSE);
    }

    /// Asserts that `Inventory` is a `Factory`
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` is not a `Factory`
    public fun assert_factory<C>(inventory: &Inventory<C>) {
        assert!(is_factory(inventory), ENOT_FACTORY);
    }
}
