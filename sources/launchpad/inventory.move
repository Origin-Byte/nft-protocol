/// Module of `Inventory` type, a type-erased wrapper around `Warehouse` and
/// `Factory`.
///
/// Additionally, `Inventory` is responsible for providing a safe interface to
/// change the logical owner of NFTs redeemed from it.
module nft_protocol::inventory {
    use std::option::{Self, Option};

    use sui::transfer;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_field as df;

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::warehouse::{Self, Warehouse, RedeemCommitment};

    /// `Inventory` is not a `Warehouse`
    ///
    /// Call `from_warehouse` to create an `Inventory` from `Warehouse`
    const ENOT_WAREHOUSE: u64 = 1;

    /// `Inventory` is not a `Factory`
    ///
    /// Call `from_factory` to create an `Inventory` from `Factory`
    const ENOT_FACTORY: u64 = 2;

    /// A type-erased wrapper around `Warehouse` and `Factory`
    struct Inventory<phantom T> has key, store {
        /// `Inventory` ID
        id: UID,
    }

    /// Create a new `Inventory` from a `Warehouse`
    public fun from_warehouse<T: key + store>(
        warehouse: Warehouse<T>,
        ctx: &mut TxContext,
    ): Inventory<T> {
        let inventory_id = object::new(ctx);
        df::add(&mut inventory_id, utils::marker<Warehouse<T>>(), warehouse);

        Inventory { id: inventory_id }
    }

    /// Deposits NFT to `Inventory`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Inventory`.
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` is not a `Warehouse`.
    public entry fun deposit_nft<T: key + store>(
        inventory: &mut Inventory<T>,
        nft: T,
    ) {
        let warehouse = borrow_warehouse_mut(inventory);
        warehouse::deposit_nft(warehouse, nft);
    }

    /// Redeems NFT from `Inventory` sequentially
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Inventory`.
    ///
    /// #### Panics
    ///
    /// Panics if no supply is available.
    public fun redeem_nft<T: key + store>(inventory: &mut Inventory<T>): T {
        // TODO: This will be restuctured before merge to main
        assert!(is_warehouse(inventory), 0);

        let warehouse = borrow_warehouse_mut(inventory);
        warehouse::redeem_nft(warehouse)
    }

    /// Redeems NFT from `Inventory` sequentially and transfers to owner
    ///
    /// See `redeem_nft` for more details
    ///
    /// #### Panics
    ///
    /// Panics if no supply is available.
    public entry fun redeem_nft_and_transfer<T: key + store>(
        inventory: &mut Inventory<T>,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_nft(inventory);
        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

    /// Redeems NFT from specific index in `Inventory`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Inventory`.
    ///
    /// #### Panics
    ///
    /// Panics if underlying type is not a `Warehouse` and index does not
    /// exist.
    public fun redeem_nft_at_index<T: key + store>(
        inventory: &mut Inventory<T>,
        index: u64,
    ): T {
        // TODO: This will be restuctured before merge to main
        assert!(is_warehouse(inventory), 0);

        let warehouse = borrow_warehouse_mut(inventory);
        warehouse::redeem_nft_at_index(warehouse, index)
    }

    /// Redeems NFT from specific index in `Inventory` and transfers to sender
    ///
    /// See `redeem_nft_at_index` for more details.
    ///
    /// #### Panics
    ///
    /// Panics if underlying type is not a `Warehouse` and index does not
    /// exist.
    public entry fun redeem_nft_at_index_and_transfer<T: key + store>(
        inventory: &mut Inventory<T>,
        index: u64,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_nft_at_index(inventory, index);
        transfer::transfer(nft, tx_context::sender(ctx));
    }

    /// Redeems NFT with specific ID from `Inventory`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Inventory`.
    ///
    /// #### Panics
    ///
    /// Panics if underlying type is not a `Warehouse` and NFT with ID does not
    /// exist.
    public fun redeem_nft_with_id<T: key + store>(
        inventory: &mut Inventory<T>,
        nft_id: ID,
    ): T {
        // TODO: This will be restuctured before merge to main
        assert!(is_warehouse(inventory), 0);

        let warehouse = borrow_warehouse_mut(inventory);
        warehouse::redeem_nft_with_id(warehouse, nft_id)
    }

    /// Redeems NFT from specific index in `Warehouse` and transfers to sender
    ///
    /// See `redeem_nft_with_id` for more details.
    ///
    /// #### Panics
    ///
    /// Panics if index does not exist in `Warehouse`.
    public entry fun redeem_nft_with_id_and_transfer<T: key + store>(
        inventory: &mut Inventory<T>,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_nft_with_id(inventory, nft_id);
        transfer::transfer(nft, tx_context::sender(ctx));
    }

    /// Pseudo-randomly redeems NFT from `Inventory`
    ///
    /// Endpoint is susceptible to validator prediction of the resulting index,
    /// use `random_redeem_nft` instead.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Inventory`.
    ///
    /// If the underlying `Inventory` is a `Factory` then logic will fallback to
    /// using sequential withdraw.
    ///
    /// #### Panics
    ///
    /// Panics if there is no supply left.
    public fun redeem_pseudorandom_nft<T: key + store>(
        inventory: &mut Inventory<T>,
        ctx: &mut TxContext,
    ): T {
        // TODO: This will be restuctured before merge to main
        assert!(is_warehouse(inventory), 0);

        let warehouse = borrow_warehouse_mut(inventory);
        warehouse::redeem_pseudorandom_nft(warehouse, ctx)
    }

    /// Pseudo-randomly redeems NFT from `Inventory` and transfers to owner
    ///
    /// See `redeem_pseudorandom_nft` for more details.
    ///
    /// #### Panics
    ///
    /// Panics if there is no supply left.
    public entry fun redeem_pseudorandom_nft_and_transfer<T: key + store>(
        inventory: &mut Inventory<T>,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_pseudorandom_nft(inventory, ctx);
        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

    /// Randomly redeems NFT from `Inventory`
    ///
    /// Requires a `RedeemCommitment` created by the user in a separate
    /// transaction to ensure that validators may not bias results favorably.
    /// You can obtain a `RedeemCommitment` by calling
    /// `warehouse::init_redeem_commitment`.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Inventory`.
    ///
    /// If the underlying `Inventory` is a `Factory` then logic will fallback to
    /// using sequential withdraw.
    ///
    /// #### Panics
    ///
    /// Panics if there is no supply left or `user_commitment` does not match
    /// the hashed commitment in `RedeemCommitment`.
    public fun redeem_random_nft<T: key + store>(
        inventory: &mut Inventory<T>,
        commitment: RedeemCommitment,
        user_commitment: vector<u8>,
        ctx: &mut TxContext,
    ): T {
        // TODO: This will be restuctured before merge to main
        assert!(is_warehouse(inventory), 0);

        let warehouse = borrow_warehouse_mut(inventory);
        warehouse::redeem_random_nft(
            warehouse, commitment, user_commitment, ctx,
        )
    }

    /// Randomly redeems NFT from `Inventory` and transfers to owner
    ///
    /// See `redeem_random_nft` for more details.
    ///
    /// #### Panics
    ///
    /// Panics if there is no supply left or `user_commitment` does not match
    /// the hashed commitment in `RedeemCommitment`.
    public entry fun redeem_random_nft_and_transfer<T: key + store>(
        inventory: &mut Inventory<T>,
        commitment: RedeemCommitment,
        user_commitment: vector<u8>,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_random_nft(
            inventory, commitment, user_commitment, ctx,
        );
        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

    // === Getters ===

    /// Returns whether `Inventory` has any remaining supply
    public fun is_empty<T: key + store>(inventory: &Inventory<T>): bool {
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
    public fun supply<T: key + store>(inventory: &Inventory<T>): Option<u64> {
        // TODO: This will be restuctured before merge to main
        assert!(is_warehouse(inventory), 0);

        let warehouse = borrow_warehouse(inventory);
        option::some(warehouse::supply(warehouse))
    }

    /// Returns whether `Inventory` is a `Warehouse`
    public fun is_warehouse<T: key + store>(inventory: &Inventory<T>): bool {
        df::exists_with_type<Marker<Warehouse<T>>, Warehouse<T>>(
            &inventory.id, utils::marker<Warehouse<T>>()
        )
    }

    /// Borrows `Inventory` as `Warehouse`
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` is a `Factory`
    public fun borrow_warehouse<T: key + store>(
        inventory: &Inventory<T>,
    ): &Warehouse<T> {
        assert_warehouse(inventory);
        df::borrow(&inventory.id, utils::marker<Warehouse<T>>())
    }

    /// Mutably borrows `Inventory` as `Warehouse`
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` is a `Factory`
    fun borrow_warehouse_mut<T: key + store>(
        inventory: &mut Inventory<T>,
    ): &mut Warehouse<T> {
        assert_warehouse(inventory);
        df::borrow_mut(&mut inventory.id, utils::marker<Warehouse<T>>())
    }

    // === Assertions ===

    /// Asserts that `Inventory` is a `Warehouse`
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` is not a `Warehouse`
    public fun assert_warehouse<T: key + store>(inventory: &Inventory<T>) {
        assert!(is_warehouse(inventory), ENOT_WAREHOUSE);
    }
}
