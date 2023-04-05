/// Module of collection `GlobalSupply`
///
/// A `Collection` can choose to regulate the supply of multiple NFT types
/// that it defines at the global level, by registering a `GlobalSupply<T>`.
///
/// Collections can have a ceiling on the maximum supply and keep track
/// of the current supply, whilst unregulated policies have no supply
/// constraints nor they keep track of the number of minted objects.
module nft_protocol::global_supply {
    use sui::transfer;
    use sui::object::UID;
    use sui::dynamic_field as df;
    use sui::tx_context::TxContext;

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::supply::{Self, Supply};

    /// `GlobalSupply` was not defined
    ///
    /// Call `global_supply::add_domain` to add `GlobalSupply`.
    const EUndefinedGlobalSupply: u64 = 1;

    /// `GlobalSupply` already defined
    ///
    /// Call `global_supply::borrow_domain` to borrow domain.
    const EExistingGlobalSupply: u64 = 2;

    /// `GlobalSupply` was frozen
    const ESupplyFrozen: u64 = 3;

    /// `GlobalSupply` was not frozen
    const ESupplyNotFrozen: u64 = 4;

    /// `GlobalSupply` provides the source of truth of the total supply and
    /// delegated mint rights.
    struct GlobalSupply<phantom T> has store {
        mint_cap: MintCap<T>,
        supply: Supply,
        frozen: bool,
    }

    /// Creates a `GlobalSupply`
    ///
    /// `MintCap<T>` should be unique for the entire contract.
    ///
    /// Total quantity that can be delegated is bounded by the underlying
    /// `MintCap<T>`, it is recommended to construct `GlobalSupply<T>` using
    /// an unregulated `MintCap<T>`.
    public fun new<T>(
        mint_cap: MintCap<T>,
        supply: u64,
        frozen: bool,
    ): GlobalSupply<T> {
        GlobalSupply { mint_cap, supply: supply::new(supply), frozen }
    }

    /// Return the backing `Supply`
    public fun get_supply<T>(supply: &GlobalSupply<T>): &Supply {
        &supply.supply
    }

    /// Return whether the `GlobalSupply` is frozen
    public fun is_frozen<T>(supply: &GlobalSupply<T>): bool {
        supply.frozen
    }

    /// Delete a `GlobalSupply<T>` recovering the underlying `MintCap<T>`
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated or supply is non-zero or frozen.
    public fun delete<T>(supply: GlobalSupply<T>): MintCap<T> {
        assert_not_frozen(&supply);
        let GlobalSupply<T> { mint_cap, supply: _, frozen: _ } = supply;

        mint_cap
    }

    /// Freeze the supply of `GlobalSupply<T>`
    ///
    /// Will not allow the maximum supply to be increased or decreased, nor
    /// allow `GlobalSupply<T>` to be deconstructed.
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated or supply was already frozen.
    public fun freeze_supply<T>(supply: &mut GlobalSupply<T>) {
        supply.frozen = true;
    }

    /// Delegate a `MintCap<T>` which will be accouted for in the
    /// `GlobalSupply<T>`
    ///
    /// #### Panics
    ///
    /// Panics if maximum supply will be exceeded.
    public fun delegate<T>(
        supply: &mut GlobalSupply<T>,
        quantity: u64,
        ctx: &mut TxContext,
    ): MintCap<T> {
        supply::increment(&mut supply.supply, quantity);
        mint_cap::split(&mut supply.mint_cap, quantity, ctx)
    }

    /// Delegate a `MintCap<T>` which will be accouted for in the
    /// `GlobalSupply<T>` and transfer to receiver.
    ///
    /// #### Panics
    ///
    /// Panics if maximum supply will be exceeded.
    public fun delegate_and_transfer<T>(
        supply: &mut GlobalSupply<T>,
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
        supply: &mut GlobalSupply<T>,
        delegated: MintCap<T>,
    ) {
        supply::decrement(&mut supply.supply, mint_cap::supply(&delegated));
        mint_cap::merge(&mut supply.mint_cap, delegated);
    }

    /// Increases maximum supply
    ///
    /// #### Panics
    ///
    /// Panics if supply is frozen.
    public entry fun increase_max_supply<T>(
        supply: &mut GlobalSupply<T>,
        value: u64,
    ) {
        assert_not_frozen(supply);
        supply::increase_maximum(&mut supply.supply, value)
    }

    /// Decreases maximum supply
    ///
    /// #### Panics
    ///
    /// Panics if supply is frozen or if new maximum supply is smaller than
    /// current supply.
    public entry fun decrease_max_supply<T>(
        supply: &mut GlobalSupply<T>,
        value: u64
    ) {
        assert_not_frozen(supply);
        supply::decrease_maximum(&mut supply.supply, value)
    }

    // === Interoperability ===

    /// Returns whether `GlobalSupply` is registered on `Nft`
    public fun has_domain<T>(nft: &UID): bool {
        df::exists_with_type<Marker<GlobalSupply<T>>, GlobalSupply<T>>(
            nft, utils::marker(),
        )
    }

    /// Borrows `GlobalSupply` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `GlobalSupply` is not registered on the `Nft`
    public fun borrow_domain<T>(nft: &UID): &GlobalSupply<T> {
        assert_regulated<T>(nft);
        df::borrow(nft, utils::marker<GlobalSupply<T>>())
    }

    /// Mutably borrows `GlobalSupply` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `GlobalSupply` is not registered on the `Nft`
    public fun borrow_domain_mut<T>(nft: &mut UID): &mut GlobalSupply<T> {
        assert_regulated<T>(nft);
        df::borrow_mut(nft, utils::marker<GlobalSupply<T>>())
    }

    /// Adds `GlobalSupply` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `GlobalSupply` domain already exists
    public fun add_domain<T>(
        nft: &mut UID,
        domain: GlobalSupply<T>,
    ) {
        assert_unregulated<T>(nft);
        df::add(nft, utils::marker<GlobalSupply<T>>(), domain);
    }

    /// Remove `GlobalSupply` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `GlobalSupply` domain doesnt exist
    public fun remove_domain<T>(nft: &mut UID): GlobalSupply<T> {
        assert_regulated<T>(nft);
        df::remove(nft, utils::marker<GlobalSupply<T>>())
    }

    // === Assertions ===

    /// Asserts that `GlobalSupply` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `GlobalSupply` is not registered
    public fun assert_regulated<T>(nft: &UID) {
        assert!(has_domain<T>(nft), EUndefinedGlobalSupply);
    }

    /// Asserts that `GlobalSupply` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `GlobalSupply` is registered
    public fun assert_unregulated<T>(nft: &UID) {
        assert!(!has_domain<T>(nft), EExistingGlobalSupply);
    }

    /// Assert that `GlobalSupply` is frozen
    public fun assert_frozen<T>(domain: &GlobalSupply<T>) {
        assert!(is_frozen(domain), ESupplyNotFrozen)
    }

    /// Assert that `GlobalSupply` not is frozen
    public fun assert_not_frozen<T>(domain: &GlobalSupply<T>) {
        assert!(!is_frozen(domain), ESupplyFrozen)
    }
}
