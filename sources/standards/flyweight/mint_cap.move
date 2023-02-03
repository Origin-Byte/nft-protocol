module nft_protocol::flyweight_mint_cap {
    use std::option::{Self, Option};

    use sui::transfer;
    use sui::dynamic_field as df;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::supply;
    use nft_protocol::mint_cap::{Self, RegulatedMintCap, UnregulatedMintCap};

    friend nft_protocol::flyweight_archetype;

    // === PointerDomain ===

    struct PointerDomain has key, store {
        /// `PointerDomain` ID
        id: UID,
        /// `Archetype` ID that this NFT is a loose representation of
        archetype_id: ID,
    }

    /// Creates a new `Pointer` to the given `Archetype`
    fun pointer(archetype_id: ID, ctx: &mut TxContext): PointerDomain {
        PointerDomain {
            id: object::new(ctx),
            archetype_id,
        }
    }

    /// Return `ID` of `Archetype` associated with this pointer
    public fun archetype_id(pointer: &PointerDomain): ID {
        pointer.archetype_id
    }

    // === ArchetypeMintCap ===

    /// `ArchetypeMintCap` object
    ///
    /// `ArchetypeMintCap` ensures that supply policy on `Collection` and
    /// `Archetype` are not violated.
    struct ArchetypeMintCap<phantom C> has key, store {
        /// `ArchetypeMintCap` ID
        id: UID,
        /// `Archetype` ID for which this `ArchetypeMintCap` is allowed to mint
        /// NFTs
        archetype_id: ID,
    }

    /// Create `ArchetypeMintCap` with unregulated supply
    ///
    /// #### Safety
    ///
    /// Neither `Collection` nor `Archetype` have regulated supply.
    public(friend) fun from_unregulated<C>(
        mint_cap: UnregulatedMintCap<C>,
        archetype_id: ID,
        ctx: &mut TxContext,
    ): ArchetypeMintCap<C> {
        let archetype_mint_cap = ArchetypeMintCap {
            id: object::new(ctx),
            archetype_id
        };

        df::add(
            &mut archetype_mint_cap.id,
            utils::marker<UnregulatedMintCap<C>>(),
            mint_cap,
        );

        archetype_mint_cap
    }

    /// Create `ArchetypeMintCap` with unregulated supply
    ///
    /// #### Safety
    ///
    /// Either `Collection` or `Archetype` must have regulated supply, such
    /// that `RegulatedMintCap` does not violate either.
    public(friend) fun from_regulated<C>(
        mint_cap: RegulatedMintCap<C>,
        archetype_id: ID,
        ctx: &mut TxContext,
    ): ArchetypeMintCap<C> {
        let archetype_mint_cap = ArchetypeMintCap {
            id: object::new(ctx),
            archetype_id
        };

        df::add(
            &mut archetype_mint_cap.id,
            utils::marker<RegulatedMintCap<C>>(),
            mint_cap,
        );

        archetype_mint_cap
    }

    // === Getters ===

    /// Borrows `RegulatedMintCap` from `ArchetypeMintCap`
    ///
    /// #### Panics
    ///
    /// Panics if `ArchetypeMintCap` is unregulated
    fun borrow_regulated<C>(
        mint_cap: &ArchetypeMintCap<C>,
    ): &RegulatedMintCap<C> {
        df::borrow(&mint_cap.id, utils::marker<RegulatedMintCap<C>>())
    }

    /// Mutably borrows `RegulatedMintCap` from `ArchetypeMintCap`
    ///
    /// #### Panics
    ///
    /// Panics if `ArchetypeMintCap` is unregulated
    fun borrow_regulated_mut<C>(
        mint_cap: &mut ArchetypeMintCap<C>,
    ): &mut RegulatedMintCap<C> {
        df::borrow_mut(&mut mint_cap.id, utils::marker<RegulatedMintCap<C>>())
    }

    /// Borrows `RegulatedMintCap` from `ArchetypeMintCap`
    ///
    /// #### Panics
    ///
    /// Panics if `ArchetypeMintCap` is regulated
    fun borrow_unregulated<C>(
        mint_cap: &ArchetypeMintCap<C>,
    ): &UnregulatedMintCap<C> {
        df::borrow(&mint_cap.id, utils::marker<UnregulatedMintCap<C>>())
    }

    /// Mutably borrows `RegulatedMintCap` from `ArchetypeMintCap`
    ///
    /// #### Panics
    ///
    /// Panics if `ArchetypeMintCap` is regulated
    fun borrow_unregulated_mut<C>(
        mint_cap: &mut ArchetypeMintCap<C>,
    ): &mut UnregulatedMintCap<C> {
        df::borrow_mut(
            &mut mint_cap.id,
            utils::marker<UnregulatedMintCap<C>>(),
        )
    }

    /// Returns whether `ArchetypeMintCap` is eligible to mint NFTs of the
    /// given type
    public fun is_regulated<C>(mint_cap: &ArchetypeMintCap<C>): bool {
        df::exists_with_type<Marker<RegulatedMintCap<C>>, RegulatedMintCap<C>>(
            &mint_cap.id,
            utils::marker<RegulatedMintCap<C>>(),
        )
    }

    /// Returns the remaining supply available to `ArchetypeMintCap`
    ///
    /// If factory is unregulated then none will be returned.
    public fun supply<C>(mint_cap: &ArchetypeMintCap<C>): Option<u64> {
        if (is_regulated(mint_cap)) {
            let mint_cap = borrow_regulated(mint_cap);
            let supply = mint_cap::borrow_supply(mint_cap);
            option::some(supply::supply(supply))
        } else {
            option::none()
        }
    }

    /// Mints `Nft` from `ArchetypeMintCap`
    ///
    /// #### Panics
    ///
    /// Panics if supply was exceeded.
    public fun mint_nft<C>(
        mint_cap: &mut ArchetypeMintCap<C>,
        owner: address,
        ctx: &mut TxContext,
    ): Nft<C> {
        // Owner must be transaction sender otherwise `nft::add_domain` will
        // panic
        let sender = tx_context::sender(ctx);
        let nft = if (is_regulated(mint_cap)) {
            let mint_cap = borrow_regulated_mut(mint_cap);
            nft::new_regulated(mint_cap, sender, ctx)
        } else {
            let mint_cap = borrow_unregulated(mint_cap);
            nft::new_unregulated(mint_cap, sender, ctx)
        };

        let pointer = pointer(mint_cap.archetype_id, ctx);
        nft::add_domain(&mut nft, pointer, ctx);

        nft::change_logical_owner_internal(&mut nft, owner);

        nft
    }

    /// Mints `Nft` from `ArchetypeMintCap` and transfer to transaction sender
    ///
    /// #### Panics
    ///
    /// Panics if supply was exceeded.
    public entry fun mint_nft_and_transfer<C>(
        mint_cap: &mut ArchetypeMintCap<C>,
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        let nft = mint_nft(mint_cap, sender, ctx);
        transfer::transfer(nft, sender);
    }
}
