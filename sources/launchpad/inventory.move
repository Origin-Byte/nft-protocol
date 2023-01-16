/// Module representing the NFT bookkeeping `Inventory` type
///
/// `Inventory` allows creator to configure the priamry market through which
/// their collection will be sold. This includes defining multiple primary
/// markets, but also whether the inventory is whitelisted.
///
/// `Inventory` is an unprotected type that composes the inventory structure of
/// `Listing`. In consequence, `Inventory` can be constructed independently
/// before it is published in a `Listing`, allowing `Inventory` to be
/// constructed while avoiding shared consensus transactions on `Listing`.
module nft_protocol::inventory {
    use std::vector;

    use sui::transfer;
    use sui::dynamic_field as df;
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, ID , UID};

    use nft_protocol::err;
    use nft_protocol::nft::Nft;
    use nft_protocol::collection::{Collection, MintCap};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::supply_domain::{Self, DelegatedSupply};
    use nft_protocol::utils;

    friend nft_protocol::listing;

    /// `Inventory` object
    ///
    /// `Inventory` has a generic parameter `C` which is a one-time witness
    /// created by the creator's NFT collection module.
    /// Ensures that any domains restricting the process of minting NFTs such
    /// as `SupplyDomain` are respected.
    /// Requires that all functions that mint NFTs, such as
    /// `suimarines::mint_nft` always mint to an `Inventory`.
    struct Inventory<phantom C> has key, store {
        id: UID,
        // NFTs that are currently on sale. When a `NftCertificate` is sold,
        // its corresponding NFT ID will be flushed from `nfts` and will be
        // added to `queue`.
        nfts: vector<ID>,
    }

    /// Create a new `Inventory`
    ///
    /// Doesn't require the collection witness as `Inventory` doesn't maintain
    /// any safety guarantees.
    ///
    /// #### Panics
    ///
    /// Panics if collection supply is regulated.
    public fun new_unregulated<C>(
        collection: &Collection<C>,
        ctx: &mut TxContext,
    ): Inventory<C> {
        supply_domain::assert_unregulated(collection);

        Inventory {
            id: object::new(ctx),
            nfts: vector::empty(),
        }
    }

    /// Creates a `Inventory` and transfers to transaction sender
    ///
    /// Doesn't require the collection witness as `Inventory` doesn't maintain
    /// any safety guarantees.
    ///
    /// #### Panics
    ///
    /// Panics if collection supply is regulated.
    public entry fun init_unregulated<C>(
        collection: &Collection<C>,
        ctx: &mut TxContext,
    ) {
        let inventory = new_unregulated<C>(collection, ctx);
        transfer::transfer(inventory, tx_context::sender(ctx));
    }

    /// Create a new `Inventory` with regulated supply
    ///
    /// Doesn't require the collection witness as `Inventory` doesn't maintain
    /// any safety guarantees.
    ///
    /// #### Panics
    ///
    /// Panics if collection supply is unregulated.
    public fun new_regulated<C>(
        collection: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        supply: u64,
        ctx: &mut TxContext,
    ): Inventory<C> {
        supply_domain::assert_regulated(collection);

        let inventory = Inventory {
            id: object::new(ctx),
            nfts: vector::empty(),
        };

        let delegated = supply_domain::delegate(collection, mint_cap, supply);
        df::add(
            &mut inventory.id,
            // Use `Supply` instead of `DelegatedSupply<C>` to save on space
            utils::marker<Supply>(),
            delegated,
        );

        inventory
    }

    /// Creates a regulated `Inventory` and transfers to transaction sender
    ///
    /// Doesn't require the collection witness as `Inventory` doesn't maintain
    /// any safety guarantees.
    ///
    /// #### Panics
    ///
    /// Panics if collection supply is unregulated.
    public entry fun init_regulated<C>(
        collection: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        supply: u64,
        ctx: &mut TxContext,
    ) {
        let inventory = new_regulated<C>(collection, mint_cap, supply, ctx);
        transfer::transfer(inventory, tx_context::sender(ctx));
    }

    /// Returns whether `Inventory` has a regulated supply
    public fun is_regulated<C>(
        inventory: &Inventory<C>,
    ): bool {
        df::exists_with_type<utils::Marker<Supply>, DelegatedSupply<C>>(
            &inventory.id, utils::marker<Supply>()
        )
    }

    /// Deposits NFT to `Inventory`
    ///
    /// `Inventory` delegated supply is not updated in order to maintain a
    /// consistent global supply. See [`increment_supply`](#increment_supply).
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Inventory`.
    public entry fun deposit_nft<C>(
        inventory: &mut Inventory<C>,
        nft: Nft<C>,
    ) {
        let nft_id = object::id(&nft);
        vector::push_back(&mut inventory.nfts, nft_id);

        dof::add(&mut inventory.id, nft_id, nft);
    }

    /// Redeems NFT from `Inventory`
    ///
    /// `Inventory` delegated supply is not updated in order to maintain a
    /// consistent global supply. See [`increment_supply`](#increment_supply).
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Inventory`.
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` is empty
    public fun redeem_nft<C>(
        inventory: &mut Inventory<C>,
    ): Nft<C> {
        let nfts = &mut inventory.nfts;
        assert!(!vector::is_empty(nfts), err::no_nfts_left());

        dof::remove(&mut inventory.id, vector::pop_back(nfts))
    }

    /// Redeems specific NFT from `Inventory` and transfers to sender
    ///
    /// `Inventory` delegated supply is not updated in order to maintain a
    /// consistent global supply. See [`increment_supply`](#increment_supply).
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Inventory`.
    ///
    /// #### Usage
    ///
    /// Entry mint functions like `suimarines::mint_nft` take an `Inventory`
    /// object to deposit into. Calling `redeem_nft_transfer` allows one to
    /// withdraw an NFT and own it directly.
    public entry fun redeem_nft_transfer<C>(
        inventory: &mut Inventory<C>,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_nft<C>(inventory);
        transfer::transfer(nft, tx_context::sender(ctx));
    }

    /// Increments the delegated supply of `Inventory`
    ///
    /// This endpoint must be called before a new `Nft` object is created to
    /// ensure that global supply tracking remains consistent.
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` is unregulated.
    public entry fun increment_supply<C>(
        inventory: &mut Inventory<C>,
        value: u64,
    ) {
        assert_regulated(inventory);
        let delegated: &mut DelegatedSupply<C> =
            df::borrow_mut(&mut inventory.id, utils::marker<Supply>());
        let supply = supply_domain::delegated_supply_mut(delegated);
        supply::increment(supply, value);
    }

    /// Destroys `Inventory`
    ///
    /// If `Inventory` was regulated then excess supply is returned to the `Collection`.
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` is not empty
    public entry fun destroy<C>(
        collection: &mut Collection<C>,
        inventory: Inventory<C>,
    ) {
        assert_is_empty(&inventory);
        if (is_regulated(&inventory)) {
            let delegated: DelegatedSupply<C> =
                df::remove(&mut inventory.id, utils::marker<Supply>());
            supply_domain::merge_delegated(collection, delegated);
        };

        let Inventory { id, nfts: _ } = inventory;
        object::delete(id);
    }

    // === Getter Functions ===

    /// Return how many `Nft` there are to sell
    public fun length<C>(inventory: &Inventory<C>): u64 {
        vector::length(&inventory.nfts)
    }

    /// Return whether there are any `Nft` in the `Inventory`
    public fun is_empty<C>(inventory: &Inventory<C>): bool {
        vector::is_empty(&inventory.nfts)
    }

    // === Assertions ===

    /// Asserts that `Inventory` has a regulated supply
    public fun assert_regulated<C>(inventory: &Inventory<C>) {
        assert!(is_regulated(inventory), err::inventory_not_regulated());
    }

    /// Asserts that `Inventory` is empty
    public fun assert_is_empty<C>(inventory: &Inventory<C>) {
        assert!(is_empty(inventory), err::inventory_not_empty());
    }
}
