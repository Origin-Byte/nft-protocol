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
    use std::string::String;
    use std::type_name::{Self, TypeName};

    use sui::url::Url;
    use sui::event;
    use sui::dynamic_field as df;
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::witness::{Self, Witness as DelegatedWitness};
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::transfer_allowlist::{Self, Allowlist};
    use nft_protocol::mint_cap::{
        Self, MintCap, RegulatedMintCap, UnregulatedMintCap,
    };

    /// Domain not defined
    ///
    /// Call `collection::add_domain` to add domains
    const EUNDEFINED_DOMAIN: u64 = 1;

    /// Domain already defined
    ///
    /// Call `collection::borrow` to borrow domain
    const EEXISTING_DOMAIN: u64 = 2;

    /// Transaction sender not logical owner
    const EINVALID_SENDER: u64 = 3;

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
        /// `Nft` name
        name: String,
        /// `Nft` URL
        url: Url,
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

    struct ChangeLogicalOwnerEvent has copy, drop {
        /// ID of the `Nft` that had its logical owner changed
        nft_id: ID,
        /// The address of the previous logical owner
        old_logical_owner: address,
        /// The address of the new logical owner
        new_logical_owner: address,
    }

    /// Create a new `Nft`
    fun new_<C>(
        name: String,
        url: Url,
        logical_owner: address,
        ctx: &mut TxContext,
    ): Nft<C> {
        let id = object::new(ctx);

        event::emit(MintNftEvent {
            nft_id: object::uid_to_inner(&id),
            type_name: type_name::get<C>(),
        });

        Nft { id, name, url, logical_owner }
    }

    /// Create a new `Nft` using `MintCap`
    ///
    /// Requires witness of collection contract as this function should only
    /// be used by functions defined within that contract due to the potential
    /// to violate correctness guarantees in other parts of the codebase.
    ///
    /// #### Usage
    ///
    /// ```
    /// struct Witness has drop {}
    /// struct SUIMARINES has drop {}
    ///
    /// fun init(witness: SUIMARINES, ctx: &mut TxContext) {
    ///     let nft = nft::new(&Witness {}, tx_context::sender(ctx), ctx);
    /// }
    /// ```
    public fun new<C, W>(
        _witness: &W,
        name: String,
        url: Url,
        owner: address,
        ctx: &mut TxContext,
    ): Nft<C> {
        utils::assert_same_module_as_witness<C, W>();
        new_(name, url, owner, ctx)
    }

    /// Create a new `Nft` using `MintCap`
    ///
    /// Contrary to minting NFTs using [new](#new), the logical owner is set to
    /// the transaction sender as `MintCap` does not have the ability to add
    /// domains to NFTs not belonging to the transaction sender.
    public fun from_mint_cap<C>(
        _mint_cap: &MintCap<C>,
        name: String,
        url: Url,
        ctx: &mut TxContext,
    ): Nft<C> {
        // See documentation note
        new_(name, url, tx_context::sender(ctx), ctx)
    }

    /// Create a new `Nft` using `RegulatedMintCap`
    ///
    /// `RegulatedMintCap` may only be created by
    /// `supply_domain::delegate_regulated`.
    ///
    /// Contrary to minting NFTs using [new](#new), the logical owner is set to
    /// the transaction sender as `RegulatedMintCap` does not have the ability
    /// to add domains to NFTs not belonging to the transaction sender.
    ///
    /// See [new](#new) for usage information.
    ///
    /// #### Panics
    ///
    /// Panics if supply is exceeded.
    public fun from_regulated<C>(
        mint_cap: &mut RegulatedMintCap<C>,
        name: String,
        url: Url,
        ctx: &mut TxContext,
    ): Nft<C> {
        mint_cap::increment_supply(mint_cap, 1);
        // See documentation note
        new_(name, url, tx_context::sender(ctx), ctx)
    }

    /// Create a new `Nft` using `UnregulatedMintCap`
    ///
    /// `UnregulatedMintCap` may only be created by
    /// `supply_domain::delegate_unregulated`.
    ///
    /// Contrary to minting NFTs using [new](#new), the logical owner is set to
    /// the transaction sender as `RegulatedMintCap` does not have the ability
    /// to add domains to NFTs not belonging to the transaction sender.
    ///
    /// See [new](#new) for usage information.
    public fun from_unregulated<C>(
        _mint_cap: &UnregulatedMintCap<C>,
        name: String,
        url: Url,
        ctx: &mut TxContext,
    ): Nft<C> {
        // See documentation note
        new_(name, url, tx_context::sender(ctx), ctx)
    }

    // === Domain Functions ===

    /// Check whether `Nft` has a domain of type `D`
    public fun has_domain<C, D: store>(nft: &Nft<C>): bool {
        df::exists_with_type<Marker<D>, D>(&nft.id, utils::marker<D>())
    }

    /// Borrow domain of type `D` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain of type `D` is not present on the `Nft`
    public fun borrow_domain<C, D: store>(nft: &Nft<C>): &D {
        assert_domain<C, D>(nft);
        df::borrow(&nft.id, utils::marker<D>())
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
    public fun borrow_domain_mut<C, D: store, W: drop>(
        _witness: W,
        nft: &mut Nft<C>,
    ): &mut D {
        utils::assert_same_module_as_witness<D, W>();
        assert_domain<C, D>(nft);

        df::borrow_mut(&mut nft.id, utils::marker<D>())
    }

    /// Adds domain of type `D` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain `D` already exists.
    fun add_domain_<C, D: store>(
        nft: &mut Nft<C>,
        domain: D,
    ) {
        assert_no_domain<C, D>(nft);
        df::add(&mut nft.id, utils::marker<D>(), domain);
    }

    /// Adds domain of type `D` to `Nft`
    ///
    /// Helper method that can be simply used without knowing what a delegated
    /// witness is.
    ///
    /// #### Panics
    ///
    /// Panics if domain `D` already exists.
    public fun add_domain<C, W, D: store>(
        witness: &W,
        nft: &mut Nft<C>,
        domain: D,
    ) {
        add_domain_delegated(
            witness::from_witness(witness),
            nft,
            domain,
        )
    }

    /// Adds domain of type `D` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain `D` already exists.
    public fun add_domain_delegated<C, D: store>(
        _witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
        domain: D,
    ) {
        add_domain_(nft, domain)
    }

    /// Adds domain of type `D` to `Nft`
    ///
    /// Same as [add_domain](#add_domain) but uses `MintCap` to
    /// authenticate the operation.
    ///
    /// Requires that transaction sender is the logical owner of the NFT.
    /// Prevents entities delegated the sole right ot mint NFTs from
    /// registering arbitrary domains on existing NFTs.
    ///
    /// #### Panics
    ///
    /// Panics transaction sender is not logical owner or if domain `D` already
    /// exists.
    public fun add_domain_with_mint_cap<C, D: store>(
        _mint_cap: &MintCap<C>,
        nft: &mut Nft<C>,
        domain: D,
        ctx: &mut TxContext,
    ) {
        assert_logical_owner(nft, ctx);
        add_domain_(nft, domain)
    }

    /// Adds domain of type `D` to `Nft`
    ///
    /// Same as [add_domain](#add_domain) but uses `RegulatedMintCap` to
    /// authenticate the operation.
    ///
    /// Requires that transaction sender is the logical owner of the NFT.
    /// Prevents entities delegated the sole right ot mint NFTs from
    /// registering arbitrary domains on existing NFTs.
    ///
    /// #### Panics
    ///
    /// Panics transaction sender is not logical owner or if domain `D` already
    /// exists.
    public fun add_domain_with_regulated<C, D: store>(
        _mint_cap: &RegulatedMintCap<C>,
        nft: &mut Nft<C>,
        domain: D,
        ctx: &mut TxContext,
    ) {
        assert_logical_owner(nft, ctx);
        add_domain_(nft, domain)
    }

    /// Adds domain of type `D` to `Nft`
    ///
    /// Same as [add_domain](#add_domain) but uses `UnregulatedMintCap` to
    /// authenticate the operation.
    ///
    /// Requires that transaction sender is the logical owner of the NFT.
    /// Prevents entities delegated the sole right ot mint NFTs from
    /// registering arbitrary domains on existing NFTs.
    ///
    /// #### Panics
    ///
    /// Panics transaction sender is not logical owner or if domain `D` already
    /// exists.
    public fun add_domain_with_unregulated<C, D: store>(
        _mint_cap: &UnregulatedMintCap<C>,
        nft: &mut Nft<C>,
        domain: D,
        ctx: &mut TxContext,
    ) {
        assert_logical_owner(nft, ctx);
        add_domain_(nft, domain)
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
    public fun remove_domain<C, W: drop, D: store>(
        _witness: W,
        nft: &mut Nft<C>,
    ): D {
        utils::assert_same_module_as_witness<W, D>();
        assert_domain<C, D>(nft);

        df::remove(&mut nft.id, utils::marker<D>())
    }

    /// Burns an `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if any domains are still registered on the `Nft`.
    public entry fun burn<C>(nft: Nft<C>) {
        let Nft { id, name: _, url: _, logical_owner: _ } = nft;
        object::delete(id);
    }

    // === Static Properties ===

    /// Returns `Nft` name
    public fun name<C>(nft: &Nft<C>): &String {
        &nft.name
    }

    /// Returns `Nft` name
    public fun url<C>(nft: &Nft<C>): &Url {
        &nft.url
    }

    /// Sets `Nft` static name
    ///
    /// Caution when changing properties of loose NFTs as the changes will
    /// not be propagated to the template.
    public fun set_name<C>(
        _witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
        name: String,
    ) {
        nft.name = name
    }

    /// Sets `Nft` static URL
    ///
    /// Caution when changing properties of loose NFTs as the changes will
    /// not be propagated to the template.
    public fun set_url<C>(
        _witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
        url: Url,
    ) {
        nft.url = url
    }

    // === Ownership Functions ===

    /// Returns the logical owner of the `Nft`
    public fun logical_owner<C>(nft: &Nft<C>): address {
        nft.logical_owner
    }

    /// Transfer the `Nft` to `recipient` while changing the `logical_owner`
    ///
    /// Requires that `Auth` is registered as an authority on `Allowlist`.
    ///
    /// #### Panics
    ///
    /// Panics if authority token, `Auth`, or collection was not defined on
    /// `Allowlist`.
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
    /// Panics if authority token, `Auth`, or collection was not defined on
    /// `Allowlist`.
    public fun change_logical_owner<C, Auth: drop>(
        nft: &mut Nft<C>,
        recipient: address,
        _authority: Auth,
        allowlist: &Allowlist,
    ) {
        transfer_allowlist::assert_collection<C>(allowlist);
        transfer_allowlist::assert_authority<Auth>(allowlist);

        event::emit(ChangeLogicalOwnerEvent {
            nft_id: object::id(nft),
            old_logical_owner: nft.logical_owner,
            new_logical_owner: recipient,
        });

        nft.logical_owner = recipient;
    }

    // === Assertions ===

    /// Assert that domain, `D`, exists on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain, `D`, does not exist on `Nft`.
    public fun assert_domain<C, D: store>(nft: &Nft<C>) {
        assert!(has_domain<C, D>(nft), EUNDEFINED_DOMAIN);
    }

    /// Assert that domain, `D`, does not exist on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain, `D`, exists on `Nft`.
    public fun assert_no_domain<C, D: store>(nft: &Nft<C>) {
        assert!(!has_domain<C, D>(nft), EEXISTING_DOMAIN);
    }

    /// Asserts that transaction sender is the logical owner of the Nft
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not logical owner.
    public fun assert_logical_owner<C>(nft: &Nft<C>, ctx: &mut TxContext) {
        assert!(
            tx_context::sender(ctx) == nft.logical_owner,
            EINVALID_SENDER
        );
    }

    // === Test helpers ===

    #[test_only]
    /// Create `Nft` without access to `MintCap` or derivatives
    public fun test_mint<C>(owner: address, ctx: &mut TxContext): Nft<C> {
        new_(std::string::utf8(b""), sui::url::new_unsafe_from_bytes(b""), owner, ctx)
    }
}
