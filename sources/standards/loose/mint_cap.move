module nft_protocol::loose_mint_cap {
    use std::option::{Self, Option};

    use sui::transfer;
    use sui::dynamic_field as df;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::supply;
    use nft_protocol::mint_cap::{Self, RegulatedMintCap, UnregulatedMintCap};

    friend nft_protocol::template;

    // === PointerDomain ===

    struct PointerDomain has key, store {
        /// `PointerDomain` ID
        id: UID,
        /// `Template` ID that this NFT is a loose representation of
        template_id: ID,
    }

    /// Creates a new `Pointer` to the given `Template`
    fun pointer(template_id: ID, ctx: &mut TxContext): PointerDomain {
        PointerDomain {
            id: object::new(ctx),
            template_id,
        }
    }

    /// Return `ID` of `Template` associated with this pointer
    public fun template_id(pointer: &PointerDomain): ID {
        pointer.template_id
    }

    // === LooseMintCap ===

    /// `LooseMintCap` object
    ///
    /// `LooseMintCap` ensures that supply policy on `Collection` and
    /// `Template` are not violated.
    struct LooseMintCap<phantom C> has key, store {
        /// `LooseMintCap` ID
        id: UID,
        /// `Template` ID for which this `LooseMintCap` is allowed to mint
        /// NFTs
        template_id: ID,
    }

    /// Create `LooseMintCap` with unregulated supply
    ///
    /// #### Safety
    ///
    /// Neither `Collection` nor `Template` have regulated supply.
    public(friend) fun from_unregulated<C>(
        mint_cap: UnregulatedMintCap<C>,
        template_id: ID,
        ctx: &mut TxContext,
    ): LooseMintCap<C> {
        let template_mint_cap = LooseMintCap {
            id: object::new(ctx),
            template_id
        };

        df::add(
            &mut template_mint_cap.id,
            utils::marker<UnregulatedMintCap<C>>(),
            mint_cap,
        );

        template_mint_cap
    }

    /// Create `LooseMintCap` with unregulated supply
    ///
    /// #### Safety
    ///
    /// Either `Collection` or `Template` must have regulated supply, such
    /// that `RegulatedMintCap` does not violate either.
    public(friend) fun from_regulated<C>(
        mint_cap: RegulatedMintCap<C>,
        template_id: ID,
        ctx: &mut TxContext,
    ): LooseMintCap<C> {
        let template_mint_cap = LooseMintCap {
            id: object::new(ctx),
            template_id
        };

        df::add(
            &mut template_mint_cap.id,
            utils::marker<RegulatedMintCap<C>>(),
            mint_cap,
        );

        template_mint_cap
    }

    // === Getters ===

    /// Borrows `RegulatedMintCap` from `LooseMintCap`
    ///
    /// #### Panics
    ///
    /// Panics if `LooseMintCap` is unregulated
    fun borrow_regulated<C>(
        mint_cap: &LooseMintCap<C>,
    ): &RegulatedMintCap<C> {
        df::borrow(&mint_cap.id, utils::marker<RegulatedMintCap<C>>())
    }

    /// Mutably borrows `RegulatedMintCap` from `LooseMintCap`
    ///
    /// #### Panics
    ///
    /// Panics if `LooseMintCap` is unregulated
    fun borrow_regulated_mut<C>(
        mint_cap: &mut LooseMintCap<C>,
    ): &mut RegulatedMintCap<C> {
        df::borrow_mut(&mut mint_cap.id, utils::marker<RegulatedMintCap<C>>())
    }

    /// Borrows `RegulatedMintCap` from `LooseMintCap`
    ///
    /// #### Panics
    ///
    /// Panics if `LooseMintCap` is regulated
    fun borrow_unregulated<C>(
        mint_cap: &LooseMintCap<C>,
    ): &UnregulatedMintCap<C> {
        df::borrow(&mint_cap.id, utils::marker<UnregulatedMintCap<C>>())
    }

    /// Mutably borrows `RegulatedMintCap` from `LooseMintCap`
    ///
    /// #### Panics
    ///
    /// Panics if `LooseMintCap` is regulated
    fun borrow_unregulated_mut<C>(
        mint_cap: &mut LooseMintCap<C>,
    ): &mut UnregulatedMintCap<C> {
        df::borrow_mut(
            &mut mint_cap.id,
            utils::marker<UnregulatedMintCap<C>>(),
        )
    }

    /// Returns whether `LooseMintCap` is eligible to mint NFTs of the
    /// given type
    public fun is_regulated<C>(mint_cap: &LooseMintCap<C>): bool {
        df::exists_with_type<Marker<RegulatedMintCap<C>>, RegulatedMintCap<C>>(
            &mint_cap.id,
            utils::marker<RegulatedMintCap<C>>(),
        )
    }

    /// Returns the remaining supply available to `LooseMintCap`
    ///
    /// If factory is unregulated then none will be returned.
    public fun supply<C>(mint_cap: &LooseMintCap<C>): Option<u64> {
        if (is_regulated(mint_cap)) {
            let mint_cap = borrow_regulated(mint_cap);
            let supply = mint_cap::borrow_supply(mint_cap);
            option::some(supply::supply(supply))
        } else {
            option::none()
        }
    }

    /// Mints `Nft` from `LooseMintCap`
    ///
    /// #### Panics
    ///
    /// Panics if supply was exceeded.
    public fun mint_nft<C>(
        mint_cap: &mut LooseMintCap<C>,
        ctx: &mut TxContext,
    ): Nft<C> {
        let pointer = pointer(mint_cap.template_id, ctx);

        if (is_regulated(mint_cap)) {
            let mint_cap = borrow_regulated_mut(mint_cap);
            let nft = nft::new_regulated(mint_cap, ctx);

            nft::add_domain_with_regulated(mint_cap, &mut nft, pointer, ctx);

            nft
        } else {
            let mint_cap = borrow_unregulated(mint_cap);
            let nft = nft::new_unregulated(mint_cap, ctx);

            nft::add_domain_with_unregulated(mint_cap, &mut nft, pointer, ctx);

            nft
        }
    }

    /// Mints `Nft` from `LooseMintCap` and transfer to transaction sender
    ///
    /// #### Panics
    ///
    /// Panics if supply was exceeded.
    public entry fun mint_nft_and_transfer<C>(
        mint_cap: &mut LooseMintCap<C>,
        ctx: &mut TxContext,
    ) {
        let nft = mint_nft(mint_cap, ctx);
        transfer::transfer(nft, tx_context::sender(ctx));
    }
}
