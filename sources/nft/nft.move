/// Module defining the OriginByte `NFT` type
///
/// OriginByte's NFT protocol brings dynamism, composability and extendability
/// to NFTs. The current design allows creators to create NFTs with custom
/// domain-specific fields, with their own bespoke behaviour.
///
/// OriginByte provides a set of standard domains which implement common NFT
/// use-cases such as `DisplayDomain` which allows wallets and marketplaces to
/// easily display your NFT.
module nft_protocol::nft {
    use std::type_name::{Self, TypeName};

    use sui::event;
    use sui::dynamic_object_field as dof;
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::transfer_allowlist::{Self, Allowlist};
    use nft_protocol::mint_cap::{
        Self, MintCap, RegulatedMintCap, UnregulatedMintCap,
    };

    // TODO: Remove this after refactoring NFT permissions to allow
    // DelegatedWitness
    friend nft_protocol::warehouse;
    friend nft_protocol::loose_mint_cap;

    /// Domain not defined
    ///
    /// Call `collection::add_domain` to add domains
    const EUNDEFINED_DOMAIN: u64 = 1;

    /// Domain already defined
    ///
    /// Call `collection::borrow` to borrow domain
    const EEXISTING_DOMAIN: u64 = 2;

    /// `Nft` object
    ///
    /// OriginByte collections and NFTs have a generic parameter `C` which is a
    /// one-time witness created by the creator's NFT collection module. This
    /// allows `Collection` and `Nft` to be linked via type association, but
    /// also ensures that NFTs can only be minted by the contract that
    /// initially deployed them.
    ///
    /// An `Nft` exclusively owns domains of different types, which can be
    /// dynamically acquired and lost over its lifetime. OriginByte NFTs are
    /// modelled after [Entity Component Systems](https://en.wikipedia.org/wiki/Entity_component_system),
    /// where their domains are accessible by type. See
    /// [borrow_domain_mut](#borrow_domain_mut).
    struct Nft<phantom C> has key, store {
        /// `Nft` ID
        id: UID,
        /// Represents the logical owner of an NFT
        ///
        /// It allows for the traceability of the owner of an NFT even when the
        /// NFT is owned by a shared `Safe` object.
        logical_owner: address,
    }

    /// Event signalling that an `Nft` was minted
    struct MintNftEvent has copy, drop {
        /// ID of the `Nft` that was minted
        nft_id: ID,
        /// Type name of `Nft<C>` one-time witness `C`
        ///
        /// Intended to allow users to filter by collections of interest.
        type_name: TypeName,
    }

    /// Create a new `Nft`
    fun new_<C>(
        owner: address,
        ctx: &mut TxContext,
    ): Nft<C> {
        let id = object::new(ctx);

        event::emit(MintNftEvent {
            nft_id: object::uid_to_inner(&id),
            type_name: type_name::get<C>(),
        });

        Nft {
            id,
            logical_owner: owner,
        }
    }

    /// Create a new `Nft`
    ///
    /// #### Usage
    ///
    /// ```
    /// struct SUIMARINES has drop {}
    ///
    /// fun init(witness: SUIMARINES, ctx: &mut TxContext) {
    ///
    ///     let nft = nft::new(&witness, tx_context::sender(ctx), ctx);
    /// }
    /// ```
    public fun new<C>(
        _mint_cap: &MintCap<C>,
        owner: address,
        ctx: &mut TxContext,
    ): Nft<C> {
        new_(owner, ctx)
    }

    /// Create a new `Nft` using `RegulatedMintCap`
    ///
    /// `RegulatedMintCap` may only be created by
    /// `supply_domain::delegate_regulated`.
    ///
    /// See [new](#new) for usage information.
    ///
    /// #### Panics
    ///
    /// Panics if supply is exceeded.
    public fun new_regulated<C>(
        mint_cap: &mut RegulatedMintCap<C>,
        owner: address,
        ctx: &mut TxContext,
    ): Nft<C> {
        mint_cap::increment_supply(mint_cap, 1);
        new_(owner, ctx)
    }

    /// Create a new `Nft` using `UnregulatedMintCap`
    ///
    /// `UnregulatedMintCap` may only be created by
    /// `supply_domain::delegate_unregulated`.
    ///
    /// See [new](#new) for usage information.
    public fun new_unregulated<C>(
        _mint_cap: &UnregulatedMintCap<C>,
        owner: address,
        ctx: &mut TxContext,
    ): Nft<C> {
        new_(owner, ctx)
    }

    // === Domain Functions ===

    /// Check whether `Nft` has a domain of type `D`
    public fun has_domain<C, D: key + store>(nft: &Nft<C>): bool {
        dof::exists_with_type<Marker<D>, D>(&nft.id, utils::marker<D>())
    }

    /// Borrow domain of type `D` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain of type `D` is not present on the `Nft`
    public fun borrow_domain<C, D: key + store>(nft: &Nft<C>): &D {
        assert_domain<C, D>(nft);
        dof::borrow(&nft.id, utils::marker<D>())
    }

    /// Mutably borrow domain of type `D` from `Nft`
    ///
    /// Guarantees that domain `D` can only be mutated by the module that
    /// instantiated it. In other words, witness `W` must be defined in the
    /// same module as domain `D`.
    ///
    /// #### Usage
    ///
    /// ```
    /// module nft_protocol::display {
    ///     struct SUIMARINES has drop {}
    ///     struct Witness has drop {}
    ///
    ///     struct DisplayDomain {
    ///         id: UID,
    ///         name: String,
    ///     } has key, store
    ///
    ///     public fun domain_mut(nft: &mut Nft<C>): &mut DisplayDomain {
    ///         let domain: &mut DisplayDomain =
    ///             collection::borrow_domain_mut(Witness {}, collection);
    ///     }
    /// }
    /// ```
    ///
    /// #### Panics
    ///
    /// Panics when module attempts to mutably borrow a domain it did not
    /// define itself or if domain of type `D` is not present on the `Nft`.
    ///
    /// The module that actually added the domain to the `Nft` is not affected,
    /// in effect, this means that you can register OriginByte standard domains
    /// but OriginByte still controls access through any mutating methods it
    /// exposes.
    ///
    /// ```
    /// module nft_protocol::fake_display {
    ///     use nft_protocol::display::DisplayDomain;
    ///
    ///     struct SUIMARINES has drop {}
    ///     struct Witness has drop {}
    ///
    ///     public fun domain_mut<C>(nft: &mut Nft<C>): &mut DisplayDomain {
    ///         // Call to `borrow_domain_mut` will panic due to `Witness` not originating from `nft_protocol::display`.
    ///         let domain: &mut DisplayDomain =
    ///             collection::borrow_domain_mut(Witness {}, collection);
    ///     }
    /// }
    /// ```
    public fun borrow_domain_mut<C, D: key + store, W: drop>(
        _witness: W,
        nft: &mut Nft<C>,
    ): &mut D {
        utils::assert_same_module_as_witness<D, W>();
        assert_domain<C, D>(nft);

        dof::borrow_mut(&mut nft.id, utils::marker<D>())
    }

    /// Adds domain of type `D` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not logical owner of the `Nft` or
    /// domain `D` already exists.
    ///
    /// #### Usage
    ///
    /// ```
    /// let display_domain = display::new_display_domain(name, description);
    /// nft::add_domain(&mut nft, display_domain, ctx);
    /// ```
    public fun add_domain<C, D: key + store>(
        nft: &mut Nft<C>,
        domain: D,
        ctx: &mut TxContext,
    ) {
        // If NFT was a shared objects then malicious actors could freely add
        // their domains without the owners permission.
        assert!(
            tx_context::sender(ctx) == nft.logical_owner,
            err::not_nft_owner()
        );
        assert_no_domain<C, D>(nft);

        dof::add(&mut nft.id, utils::marker<D>(), domain);
    }

    /// Removes domain of type `D` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics when module attempts to remove a domain it did not define
    /// itself or if domain of type `D` is not present on the `Nft`. See
    /// [borrow_domain_mut](#borrow_domain_mut).
    ///
    /// #### Usage
    ///
    /// ```
    /// let display_domain: DisplayDomain = nft::remove_domain(Witness {}, &mut nft);
    /// ```
    public fun remove_domain<C, W: drop, D: key + store>(
        _witness: W,
        nft: &mut Nft<C>,
    ): D {
        utils::assert_same_module_as_witness<W, D>();
        assert_domain<C, D>(nft);

        dof::remove(&mut nft.id, utils::marker<D>())
    }

    // === Ownership Functions ===

    /// Returns the logical owner of the `Nft`
    public fun logical_owner<C>(
        nft: &Nft<C>,
    ): address {
        nft.logical_owner
    }

    /// Transfer the `Nft` to `recipient` while changing the `logical_owner`
    ///
    /// If the authority was allowlisted by the creator, we transfer
    /// the NFT to the recipient address.
    ///
    /// #### Panics
    ///
    /// Panics if authority token, `Auth`, was not defined on `Allowlist`.
    public fun transfer<C, Auth: drop>(
        nft: Nft<C>,
        recipient: address,
        authority: Auth,
        allowlist: &Allowlist,
    ) {
        change_logical_owner(&mut nft, recipient, authority, allowlist);
        transfer::transfer(nft, recipient);
    }

    /// Change the `logical_owner` of the `Nft` to `recipient`
    ///
    /// Creator can allow certain contracts to change the logical owner of an NFT.
    ///
    /// #### Panics
    ///
    /// Panics if authority token, `Auth`, was not defined on `Allowlist`.
    public fun change_logical_owner<C, Auth: drop>(
        nft: &mut Nft<C>,
        recipient: address,
        authority: Auth,
        allowlist: &Allowlist,
    ) {
        let is_ok = transfer_allowlist::can_be_transferred<C, Auth>(
            authority,
            allowlist,
        );
        assert!(is_ok, err::authority_not_allowlisted());

        nft.logical_owner = recipient;
    }

    // TODO: Remove this after refactoring NFT permissions to allow
    // DelegatedWitness
    //
    // Cannot construct an NFT without being the logical owner :/
    public(friend) fun change_logical_owner_internal<C>(
        nft: &mut Nft<C>,
        recipient: address,
    ) {
        nft.logical_owner = recipient
    }

    // === Assertions ===

    /// Assert that domain, `D`, exists on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain, `D`, does not exist on `Nft`.
    public fun assert_domain<C, D: key + store>(nft: &Nft<C>) {
        assert!(has_domain<C, D>(nft), EUNDEFINED_DOMAIN);
    }

    /// Assert that domain, `D`, does not exist on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain, `D`, exists on `Nft`.
    public fun assert_no_domain<C, D: key + store>(nft: &Nft<C>) {
        assert!(!has_domain<C, D>(nft), EEXISTING_DOMAIN);
    }

    // === Test helpers ===

    #[test_only]
    public fun test_mint<C>(owner: address, ctx: &mut TxContext): Nft<C> {
        new_(owner, ctx)
    }
}
