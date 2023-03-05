module nft_protocol::loose_mint_cap {
    use std::string::String;
    use std::option::{Self, Option};

    use sui::url::Url;
    use sui::transfer;
    use sui::dynamic_field as df;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::supply;
    use nft_protocol::mint_cap::{Self, RegulatedMintCap, UnregulatedMintCap};

    friend nft_protocol::metadata;

    // === PointerDomain ===

    struct PointerDomain has store {
        /// `Metadata` ID that this NFT is a loose representation of
        metadata_id: ID,
    }

    /// Creates a new `Pointer` to the given `Metadata`
    fun pointer(metadata_id: ID): PointerDomain {
        PointerDomain { metadata_id }
    }

    /// Return `ID` of `Metadata` associated with this pointer
    public fun metadata_id(pointer: &PointerDomain): ID {
        pointer.metadata_id
    }

    // === LooseMintCap ===

    /// `LooseMintCap` object
    ///
    /// `LooseMintCap` ensures that supply policy on `Collection` and
    /// `Metadata` are not violated.
    struct LooseMintCap<phantom C> has key, store {
        /// `LooseMintCap` ID
        id: UID,
        /// `Nft` name
        name: String,
        /// `Nft` URL
        url: Url,
        /// `Metadata` ID for which this `LooseMintCap` is allowed to mint
        /// NFTs
        metadata_id: ID,
    }

    /// Create `LooseMintCap` with unregulated supply
    ///
    /// #### Safety
    ///
    /// Neither `Collection` nor `Metadata` have regulated supply.
    public(friend) fun from_unregulated<C>(
        mint_cap: UnregulatedMintCap<C>,
        metadata_id: ID,
        name: String,
        url: Url,
        ctx: &mut TxContext,
    ): LooseMintCap<C> {
        let metadata_mint_cap = LooseMintCap {
            id: object::new(ctx),
            name,
            url,
            metadata_id
        };

        df::add(
            &mut metadata_mint_cap.id,
            utils::marker<UnregulatedMintCap<C>>(),
            mint_cap,
        );

        metadata_mint_cap
    }

    /// Create `LooseMintCap` with unregulated supply
    ///
    /// #### Safety
    ///
    /// Either `Collection` or `Metadata` must have regulated supply, such
    /// that `RegulatedMintCap` does not violate either.
    public(friend) fun from_regulated<C>(
        mint_cap: RegulatedMintCap<C>,
        metadata_id: ID,
        name: String,
        url: Url,
        ctx: &mut TxContext,
    ): LooseMintCap<C> {
        let metadata_mint_cap = LooseMintCap {
            id: object::new(ctx),
            name,
            url,
            metadata_id
        };

        df::add(
            &mut metadata_mint_cap.id,
            utils::marker<RegulatedMintCap<C>>(),
            mint_cap,
        );

        metadata_mint_cap
    }

    // === Getters ===

    /// Get loose `Nft` name
    public fun name<C>(mint_cap: &LooseMintCap<C>): &String {
        &mint_cap.name
    }

    /// Get loose `Nft` URL
    public fun url<C>(mint_cap: &LooseMintCap<C>): &Url {
        &mint_cap.url
    }

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
        let pointer = pointer(mint_cap.metadata_id);
        let name = *name(mint_cap);
        let url = *url(mint_cap);

        if (is_regulated(mint_cap)) {
            let mint_cap = borrow_regulated_mut(mint_cap);
            let nft = nft::from_regulated(mint_cap, name, url, ctx);

            nft::add_domain_with_regulated(mint_cap, &mut nft, pointer, ctx);

            nft
        } else {
            let mint_cap = borrow_unregulated(mint_cap);
            let nft = nft::from_unregulated(mint_cap, name, url, ctx);

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
