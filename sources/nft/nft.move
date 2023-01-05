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
    use sui::transfer;
    use sui::bag::{Self, Bag};
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::transfer_allowlist::{Self, Allowlist};

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
        /// Main storage object for NFT domains
        bag: Bag,
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
    ///
    /// ##### Usage
    ///
    /// ```
    /// struct SUIMARINES has drop {}
    ///
    /// fun init(witness: SUIMARINES, ctx: &mut TxContext) {
    ///     let nft = nft::new(&witness, tx_context::sender(ctx), ctx);
    /// }
    ///
    /// ##### Panics
    ///
    /// Panics when attempting to create an NFT with a witness type originating
    /// from a different module than the one-time collection witness `C`. See
    /// [borrow_domain_mut](#borrow_domain_mut).
    /// ```
    public fun new<C, W>(
        _witness: &W,
        owner: address,
        ctx: &mut TxContext
    ): Nft<C> {
        utils::assert_same_module_as_witness<C, W>();

        let id = object::new(ctx);

        event::emit(MintNftEvent {
            nft_id: object::uid_to_inner(&id),
            type_name: type_name::get<C>(),
        });

        Nft {
            id,
            bag: bag::new(ctx),
            logical_owner: owner,
        }
    }

    // === Domain Functions ===

    /// Check whether `Nft` has a domain of type `D`
    public fun has_domain<C, D: store>(nft: &Nft<C>): bool {
        bag::contains_with_type<Marker<D>, D>(&nft.bag, utils::marker<D>())
    }

    /// Borrow domain of type `D` from `Nft`
    ///
    /// ##### Panics
    ///
    /// Panics if domain of type `D` is not present on the `Nft`
    public fun borrow_domain<C, D: store>(nft: &Nft<C>): &D {
        assert_domain<C, D>(nft);
        bag::borrow<Marker<D>, D>(&nft.bag, utils::marker<D>())
    }

    /// Mutably borrow domain of type `D` from `Nft`
    ///
    /// Guarantees that domain `D` can only be mutated by the module that
    /// instantiated it. In other words, witness `W` must be defined in the
    /// same module as domain `D`.
    ///
    /// ##### Usage
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
    /// ##### Panics
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

        bag::borrow_mut<Marker<D>, D>(&mut nft.bag, utils::marker<D>())
    }

    /// Adds domain of type `D` to `Nft`
    ///
    /// ##### Panics
    ///
    /// Panics if transaction sender is not logical owner of the `Nft` or
    /// domain `D` already exists.
    ///
    /// ##### Usage
    ///
    /// ```
    /// let display_domain = display::new_display_domain(name, description);
    /// nft::add_domain(&mut nft, display_domain, ctx);
    /// ```
    public fun add_domain<C, D: store>(
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

        bag::add(&mut nft.bag, utils::marker<D>(), domain);
    }

    /// Removes domain of type `D` from `Nft`
    ///
    /// ##### Panics
    ///
    /// Panics when module attempts to remove a domain it did not define
    /// itself or if domain of type `D` is not present on the `Nft`. See
    /// [borrow_domain_mut](#borrow_domain_mut).
    ///
    /// ##### Usage
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

        bag::remove(&mut nft.bag, utils::marker<D>())
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
    /// ##### Panics
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
    /// ##### Panics
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

    // === Assertions ===

    /// Assert that domain, `D`, exists on `Nft`
    ///
    /// ##### Panics
    ///
    /// Panics if domain, `D`, does not exist on `Nft`.
    public fun assert_domain<C, D: store>(nft: &Nft<C>) {
        assert!(has_domain<C, D>(nft), err::undefined_domain());
    }

    /// Assert that domain, `D`, does not exist on `Nft`
    ///
    /// ##### Panics
    ///
    /// Panics if domain, `D`, exists on `Nft`.
    public fun assert_no_domain<C, D: store>(nft: &Nft<C>) {
        assert!(!has_domain<C, D>(nft), err::domain_already_defined());
    }
}
