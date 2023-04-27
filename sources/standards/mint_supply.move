/// Module of collection `MintSupply`
///
/// A `Collection` can choose to regulate the supply of multiple NFT types
/// that it defines at the global mint level, by registering a `MintSupply<T>`.
///
/// Collections can have a ceiling on the maximum supply and keep track
/// of the current supply, whilst unregulated policies have no supply
/// constraints nor they keep track of the number of minted objects.
module nft_protocol::mint_supply {
    use sui::transfer;
    use sui::object::UID;
    use sui::dynamic_field as df;
    use sui::tx_context::TxContext;

    use ob_witness::marker::{Self, Marker};
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::utils_supply::{Self, Supply};

    /// `MintSupply` was not defined
    ///
    /// Call `mint_supply::add_domain` to add `MintSupply`.
    const EUndefinedMintSupply: u64 = 1;

    /// `MintSupply` already defined
    ///
    /// Call `mint_supply::borrow_domain` to borrow domain.
    const EExistingMintSupply: u64 = 2;

    /// `MintSupply` was frozen
    const ESupplyFrozen: u64 = 3;

    /// `MintSupply` was not frozen
    const ESupplyNotFrozen: u64 = 4;

    /// `MintSupply` provides the source of truth of the total supply and
    /// delegated mint rights.
    struct MintSupply<phantom T> has store {
        frozen: bool,
        mint_cap: MintCap<T>,
        supply: Supply,
    }

    /// Creates a `MintSupply`
    ///
    /// `MintCap<T>` should be unique for the entire contract.
    ///
    /// Total quantity that can be delegated is bounded by the underlying
    /// `MintCap<T>`, it is recommended to construct `MintSupply<T>` using
    /// an unregulated `MintCap<T>`.
    public fun new<T>(
        mint_cap: MintCap<T>,
        supply: u64,
        frozen: bool,
    ): MintSupply<T> {
        MintSupply {
            frozen,
            mint_cap,
            supply: utils_supply::new(supply),
        }
    }

    /// Return the backing `Supply`
    public fun get_supply<T>(supply: &MintSupply<T>): &Supply {
        &supply.supply
    }

    /// Return whether the `MintSupply` is frozen
    public fun is_frozen<T>(supply: &MintSupply<T>): bool {
        supply.frozen
    }

    /// Delete a `MintSupply<T>` recovering the underlying `MintCap<T>`
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated or supply is non-zero or frozen.
    public fun delete<T>(supply: MintSupply<T>): MintCap<T> {
        assert_not_frozen(&supply);
        let MintSupply<T> { mint_cap, supply: _, frozen: _ } = supply;

        mint_cap
    }

    /// Freeze the supply of `MintSupply<T>`
    ///
    /// Will not allow the maximum supply to be increased or decreased, nor
    /// allow `MintSupply<T>` to be deconstructed.
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated or supply was already frozen.
    public fun freeze_supply<T>(supply: &mut MintSupply<T>) {
        supply.frozen = true;
    }

    /// Delegate a `MintCap<T>` which will be accouted for in the
    /// `MintSupply<T>`
    ///
    /// #### Panics
    ///
    /// Panics if maximum supply will be exceeded.
    public fun delegate<T>(
        supply: &mut MintSupply<T>,
        quantity: u64,
        ctx: &mut TxContext,
    ): MintCap<T> {
        utils_supply::increment(&mut supply.supply, quantity);
        mint_cap::split(&mut supply.mint_cap, quantity, ctx)
    }

    /// Delegate a `MintCap<T>` which will be accouted for in the
    /// `MintSupply<T>` and transfer to receiver.
    ///
    /// #### Panics
    ///
    /// Panics if maximum supply will be exceeded.
    public fun delegate_and_transfer<T>(
        supply: &mut MintSupply<T>,
        quantity: u64,
        receiver: address,
        ctx: &mut TxContext,
    ) {
        let delegated = delegate(supply, quantity, ctx);
        transfer::public_transfer(delegated, receiver);
    }

    /// Merge delegated `RegulatedMintCap`
    ///
    /// Any excess supply on the merged `RegulatedMintCap` will be decremented
    /// from the original `Supply`.
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated.
    public fun merge_delegated<T>(
        supply: &mut MintSupply<T>,
        delegated: MintCap<T>,
    ) {
        utils_supply::decrement(&mut supply.supply, mint_cap::supply(&delegated));
        mint_cap::merge(&mut supply.mint_cap, delegated);
    }

    /// Increases maximum supply
    ///
    /// #### Panics
    ///
    /// Panics if supply is frozen.
    public fun increase_max_supply<T>(
        supply: &mut MintSupply<T>,
        value: u64,
    ) {
        assert_not_frozen(supply);
        utils_supply::increase_maximum(&mut supply.supply, value)
    }

    /// Decreases maximum supply
    ///
    /// #### Panics
    ///
    /// Panics if supply is frozen or if new maximum supply is smaller than
    /// current supply.
    public fun decrease_max_supply<T>(
        supply: &mut MintSupply<T>,
        value: u64
    ) {
        assert_not_frozen(supply);
        utils_supply::decrease_maximum(&mut supply.supply, value)
    }

    // === Interoperability ===

    /// Returns whether `MintSupply` is registered on collection
    public fun has_domain<T>(collection: &UID): bool {
        df::exists_with_type<Marker<MintSupply<T>>, MintSupply<T>>(
            collection, marker::marker(),
        )
    }

    /// Borrows `MintSupply` from collection
    ///
    /// #### Panics
    ///
    /// Panics if `MintSupply` is not registered on the collection
    public fun borrow_domain<T>(collection: &UID): &MintSupply<T> {
        assert_regulated<T>(collection);
        df::borrow(collection, marker::marker<MintSupply<T>>())
    }

    /// Mutably borrows `MintSupply` from collection
    ///
    /// #### Panics
    ///
    /// Panics if `MintSupply` is not registered on the collection
    public fun borrow_domain_mut<T>(
        collection: &mut UID,
    ): &mut MintSupply<T> {
        assert_regulated<T>(collection);
        df::borrow_mut(collection, marker::marker<MintSupply<T>>())
    }

    /// Adds `MintSupply` to collection
    ///
    /// #### Panics
    ///
    /// Panics if `MintSupply` domain already exists
    public fun add_domain<T>(
        collection: &mut UID,
        domain: MintSupply<T>,
    ) {
        assert_unregulated<T>(collection);
        df::add(collection, marker::marker<MintSupply<T>>(), domain);
    }

    /// Remove `MintSupply` from collection
    ///
    /// #### Panics
    ///
    /// Panics if `MintSupply` domain doesnt exist
    public fun remove_domain<T>(collection: &mut UID): MintSupply<T> {
        assert_regulated<T>(collection);
        df::remove(collection, marker::marker<MintSupply<T>>())
    }

    // === Assertions ===

    /// Asserts that `MintSupply` is registered on collection
    ///
    /// #### Panics
    ///
    /// Panics if `MintSupply` is not registered
    public fun assert_regulated<T>(collection: &UID) {
        assert!(has_domain<T>(collection), EUndefinedMintSupply);
    }

    /// Asserts that `MintSupply` is not registered on collection
    ///
    /// #### Panics
    ///
    /// Panics if `MintSupply` is registered
    public fun assert_unregulated<T>(collection: &UID) {
        assert!(!has_domain<T>(collection), EExistingMintSupply);
    }

    /// Assert that `MintSupply` is frozen
    public fun assert_frozen<T>(domain: &MintSupply<T>) {
        assert!(is_frozen(domain), ESupplyNotFrozen)
    }

    /// Assert that `MintSupply` not is frozen
    public fun assert_not_frozen<T>(domain: &MintSupply<T>) {
        assert!(!is_frozen(domain), ESupplyFrozen)
    }
}
