/// Module containing `Supply` type
///
/// `Supply` tracks the supply of a given object type or an accumualtion of
/// actions. It tracks the current supply and guarantees that it cannot surpass
/// the maximum supply defined. Among others, this is used to keep track of
/// NFT supply for collections.
///
/// A `Collection` with a defined `Supply` has a regulated supply.
/// Collections can have a ceiling on the maximum supply and keep track
/// of the current supply, whilst unregulated policies have no supply
/// constraints nor they keep track of the number of minted objects.
module nft_protocol::supply {
    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::utils_supply;

    /// `Supply` was not defined
    ///
    /// Call `supply::add_domain` to add `Supply`.
    const EUndefinedSupply: u64 = 1;

    /// `Supply` already defined
    ///
    /// Call `Supply::borrow_domain` to borrow domain.
    const EExistingSupply: u64 = 2;

    /// `Supply` was frozen
    const ESupplyFrozen: u64 = 3;

    /// `Supply` provides the source of truth of the total supply and
    /// delegated mint rights.
    struct Supply<phantom T> has store {
        mint_cap: MintCap<T>,
        supply: utils_supply::Supply,
        frozen: bool,
    }

    /// Creates a `Supply`
    ///
    /// #### Panics
    ///
    /// Panics if `MintCap` is regulated as we expect the root `MintCap`
    /// created at `Collection` initialization to be provided. This will
    /// be the only `MintCap` with unregulated supply.
    public fun new<T>(
        mint_cap: MintCap<T>,
        supply: u64,
        frozen: bool,
    ): Supply<T> {
        mint_cap::assert_unregulated(&mint_cap);
        Supply { mint_cap, supply: utils_supply::new(supply), frozen }
    }

    /// Deregulate the supply of `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated or supply is non-zero or frozen.
    public fun delete<T>(domain: Supply<T>): MintCap<T> {
        assert_not_frozen(&domain);
        let Supply<T> { mint_cap, supply: _, frozen: _ } = domain;

        mint_cap
    }

    /// Borrows Mutably the `Supply` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated or supply was already frozen.
    public fun freeze_supply<T>(domain: &mut Supply<T>) {
        domain.frozen = true;
    }

    /// Increases maximum supply in `Supply` field in the object of type `T`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated, supply is not frozen, or if there
    /// is no excess supply to delegate a supply of `value`.
    public fun delegate<T>(
        domain: &mut Supply<T>,
        quantity: u64,
        ctx: &mut TxContext,
    ): MintCap<T> {
        utils_supply::increment(&mut domain.supply, quantity);
        mint_cap::delegate(&mut domain.mint_cap, quantity, ctx)
    }

    /// Decreases maximum supply in `Supply` field in the object of type `T`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated, supply is not frozen, or if there
    /// is no excess supply to delegate a supply of `value`.
    public fun delegate_and_transfer<T>(
        domain: &mut Supply<T>,
        quantity: u64,
        receiver: address,
        ctx: &mut TxContext,
    ) {
        let delegated = delegate(domain, quantity, ctx);
        transfer::public_transfer(delegated, receiver);
    }

    /// Freezes supply in `Supply` field in the object of type `T`
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated.
    public fun merge_delegated<T>(
        domain: &mut Supply<T>,
        delegated: MintCap<T>,
    ) {
        utils_supply::decrement(
            &mut domain.supply, mint_cap::supply(&delegated),
        );
        mint_cap::merge(&mut domain.mint_cap, delegated);
    }

    /// Increases maximum supply
    ///
    /// Endpoint is unprotected as it relies on safetly obtaining a mutable
    /// reference to `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated or supply is frozen.
    public fun increase_max_supply<T>(
        domain: &mut Supply<T>,
        value: u64,
    ) {
        assert_not_frozen(domain);
        utils_supply::increase_maximum(&mut domain.supply, value)
    }

    /// Decreases maximum supply
    ///
    /// #### Panics
    ///
    /// Panics if collection is unregulated, supply is frozen, or if new
    /// maximum supply is smaller than current supply.
    public fun decrease_max_supply<T>(
        domain: &mut Supply<T>,
        value: u64
    ) {
        assert_not_frozen(domain);
        utils_supply::decrease_maximum(&mut domain.supply, value)
    }

    // === Interoperability ===

    /// Returns whether `Supply` is registered on `Nft`
    public fun has_domain<T>(nft: &UID): bool {
        df::exists_with_type<Marker<Supply<T>>, Supply<T>>(
            nft, utils::marker(),
        )
    }

    /// Borrows `Supply` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` is not registered on the `Nft`
    public fun borrow_domain<T>(nft: &UID): &Supply<T> {
        assert_supply<T>(nft);
        df::borrow(nft, utils::marker<Supply<T>>())
    }

    /// Mutably borrows `Supply` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` is not registered on the `Nft`
    public fun borrow_domain_mut<T>(nft: &mut UID): &mut Supply<T> {
        assert_supply<T>(nft);
        df::borrow_mut(nft, utils::marker<Supply<T>>())
    }

    /// Adds `Supply` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` domain already exists
    public fun add_domain<T>(
        nft: &mut UID,
        domain: Supply<T>,
    ) {
        assert_no_supply<T>(nft);
        df::add(nft, utils::marker<Supply<T>>(), domain);
    }

    /// Remove `Supply` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` domain doesnt exist
    public fun remove_domain<T>(nft: &mut UID): Supply<T> {
        assert_supply<T>(nft);
        df::remove(nft, utils::marker<Supply<T>>())
    }

    // === Assertions ===

    /// Assert that `Supply` is frozen
    public fun assert_not_frozen<T>(domain: &Supply<T>) {
        assert!(!domain.frozen, ESupplyFrozen)
    }

    /// Asserts that `Supply` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` is not registered
    public fun assert_supply<T>(nft: &UID) {
        assert!(has_domain<T>(nft), EUndefinedSupply);
    }

    /// Asserts that `Supply` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Supply` is registered
    public fun assert_no_supply<T>(nft: &UID) {
        assert!(!has_domain<T>(nft), EExistingSupply);
    }
}
