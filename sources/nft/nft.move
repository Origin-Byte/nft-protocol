/// Module defining the OriginByte `NFT` object
///
/// OriginByte's NFT protocol brings dynamism, composability and extendability
/// to NFTs. The current design allows creators to create NFTs with custom
/// domain-specific fields, with their own bespoke behaviour. 
/// 
/// OriginByte provides a set of standard domains which implement common NFT
/// use-cases such as `DisplayDomain` which allows wallets and marketplaces to
/// easily display your NFT.
module nft_protocol::nft {
    use sui::transfer;
    use sui::bag::{Self, Bag};
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::transfer_allowlist::{Self, Allowlist};

    /// `Nft` object
    /// 
    /// `Nft` is generically associated with it's collection's witness type 
    /// `C`.
    /// 
    /// An `Nft` exclusively owns domains of different types, which can be 
    /// dynamically acquired and lost over its lifetime. OriginByte NFTs are 
    /// modelled after [Entity Component Systems](https://en.wikipedia.org/wiki/Entity_component_system),
    /// where their domains are accessible by type. See [borrow_domain](#borrow_domain_mut).
    struct Nft<phantom C> has key, store {
        id: UID,
        /// Main storage object for NFT domains
        bag: Bag,
        /// Represents the logical owner of an NFT
        /// 
        /// It allows for the traceability of the owner of an NFT even when the
        /// NFT is owned by a shared `Safe` object.
        logical_owner: address,
    }

    /// Create a new `Nft`
    ///
    /// ##### Usage
    /// 
    /// ```
    /// struct SUIMARINES has drop {}
    /// 
    /// fun init(witness: SUIMARINES, ctx: &mut TxContext) {
    ///     let nft = nft::new<SUIMARINES>(tx_context::sender(ctx), ctx);
    /// }
    /// ```
    public fun new<C>(owner: address, ctx: &mut TxContext): Nft<C> {
        Nft {
            id: object::new(ctx),
            bag: bag::new(ctx),
            logical_owner: owner,
        }
    }

    // === Domain Functions ===

    /// Check whether `Nft` has a domain of type `D`
    /// 
    /// ##### Usage
    /// 
    /// ```
    /// if (!nft::has_domain<C, DisplayDomain>(&nft)) {
    ///     return option::none()
    /// };
    /// ```
    public fun has_domain<C, D: store>(nft: &Nft<C>): bool {
        bag::contains_with_type<Marker<D>, D>(&nft.bag, utils::marker<D>())
    }

    /// Borrow domain of type `D` from `Nft`
    /// 
    /// ##### Panics
    /// 
    /// Panics if domain of type `D` is not present on the `Nft`
    /// 
    /// ##### Usage
    /// 
    /// ```
    /// let display_domain: DisplayDomain = nft::borrow_domain(&nft)
    /// ```
    //
    // TODO: Add custom error reporting that domain is missing
    public fun borrow_domain<C, D: store>(nft: &Nft<C>): &D {
        bag::borrow<Marker<D>, D>(&nft.bag, utils::marker<D>())
    }

    /// Mutably borrow domain of type `D` from `Nft`
    /// 
    /// Guarantees that domain `D` can only be mutated by the module 
    /// instantiated it. In other words, witness `W` must be defined in the 
    /// module as domain `D`.
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
    /// define itself._witness
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
    //
    // TODO: Add custom error reporting that domain is missing
    public fun borrow_domain_mut<C, D: store, W: drop>(
        _witness: W,
        nft: &mut Nft<C>,
    ): &mut D {
        utils::assert_same_module_as_witness<D, W>();
        bag::borrow_mut<Marker<D>, D>(&mut nft.bag, utils::marker<D>())
    }

    /// Adds domain of type `D` to `Nft`
    /// 
    /// ##### Panics
    /// 
    /// Panics if transaction sender is not logical owner of the `Nft`.
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

        bag::add(&mut nft.bag, utils::marker<D>(), domain);
    }

    /// Adds domain of type `D` to `Nft`
    /// 
    /// ##### Panics
    /// 
    /// Panics when module attempts to remove a domain it did not define
    /// itself. See [borrow_domain_mut](#borrow_domain_mut).
    /// 
    /// ##### Usage
    /// 
    /// ```
    /// let display_domain: DisplayDomain =
    ///     nft::remove_domain(Witness {}, &mut nft);
    /// ```
    public fun remove_domain<C, W: drop, D: store>(
        _witness: W,
        nft: &mut Nft<C>,
    ): D {
        utils::assert_same_module_as_witness<W, D>();
        bag::remove(&mut nft.bag, utils::marker<D>())
    }

    // === Transfer Functions ===

    /// Transfer the `Nft` to `recipient` while changing the `logical_owner`
    /// 
    /// If the authority was allowlisted by the creator, we transfer
    /// the NFT to the recipient address.
    //
    // TODO: Elaborate
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
    //
    // TODO: Elaborate
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

    // === Getter Functions ===

    /// Returns the logical owner of the `Nft`
    public fun logical_owner<C>(
        nft: &Nft<C>,
    ): address {
        nft.logical_owner
    }
}
