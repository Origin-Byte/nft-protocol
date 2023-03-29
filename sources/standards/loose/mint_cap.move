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

    /// Attempted to redeem an object from `Factory<C>` that wasnt `Nft<C>`
    ///
    /// `LooseMintCap<C>` is only capable of minting `Nft<C>` but erases the
    /// type to `T` in order to be compatible with `Inventory`.
    const ENFT_TYPE_MISMATCH: u64 = 1;

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
    struct LooseMintCap<phantom T> has key, store {
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
    public(friend) fun from_unregulated<T>(
        mint_cap: UnregulatedMintCap<T>,
        metadata_id: ID,
        name: String,
        url: Url,
        ctx: &mut TxContext,
    ): LooseMintCap<T> {
        let metadata_mint_cap = LooseMintCap {
            id: object::new(ctx),
            name,
            url,
            metadata_id
        };

        df::add(
            &mut metadata_mint_cap.id,
            utils::marker<UnregulatedMintCap<T>>(),
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
    public(friend) fun from_regulated<T>(
        mint_cap: RegulatedMintCap<T>,
        metadata_id: ID,
        name: String,
        url: Url,
        ctx: &mut TxContext,
    ): LooseMintCap<T> {
        let metadata_mint_cap = LooseMintCap {
            id: object::new(ctx),
            name,
            url,
            metadata_id
        };

        df::add(
            &mut metadata_mint_cap.id,
            utils::marker<RegulatedMintCap<T>>(),
            mint_cap,
        );

        metadata_mint_cap
    }

    // === Getters ===

    /// Get loose `Nft` name
    public fun name<T>(mint_cap: &LooseMintCap<T>): &String {
        &mint_cap.name
    }

    /// Get loose `Nft` URL
    public fun url<T>(mint_cap: &LooseMintCap<T>): &Url {
        &mint_cap.url
    }

    /// Borrows `RegulatedMintCap` from `LooseMintCap`
    ///
    /// #### Panics
    ///
    /// Panics if `LooseMintCap` is unregulated
    fun borrow_regulated<T>(
        mint_cap: &LooseMintCap<T>,
    ): &RegulatedMintCap<T> {
        df::borrow(&mint_cap.id, utils::marker<RegulatedMintCap<T>>())
    }

    /// Takes `RegulatedMintCap` from `LooseMintCap`
    fun take_regulated<C>(
        mint_cap: &mut LooseMintCap<Nft<C>>,
    ): RegulatedMintCap<Nft<C>> {
        df::remove(
            &mut mint_cap.id,
            utils::marker<RegulatedMintCap<Nft<C>>>(),
        )
    }

    /// Returns `RegulatedMintCap` to `LooseMintCap`
    fun return_regulated<C>(
        mint_cap: &mut LooseMintCap<Nft<C>>,
        regulated_mint_cap: RegulatedMintCap<Nft<C>>,
    ) {
        df::add(
            &mut mint_cap.id,
            utils::marker<RegulatedMintCap<Nft<C>>>(),
            regulated_mint_cap,
        )
    }

    /// Borrows `RegulatedMintCap` from `LooseMintCap`
    ///
    /// Performs potentially dangerous casting between from `T` to `Nft<C>`.
    ///
    /// #### Panics
    ///
    /// Panics if `LooseMintCap` is regulated
    fun borrow_unregulated<T>(
        mint_cap: &LooseMintCap<T>,
    ): &UnregulatedMintCap<T> {
        df::borrow(&mint_cap.id, utils::marker<UnregulatedMintCap<T>>())
    }

    /// Takes `RegulatedMintCap` from `LooseMintCap`
    ///
    /// #### Panics
    ///
    /// Panics if `LooseMintCap<T>` is regulated or is not
    /// `LooseMintCap<Nft<C>>`
    fun take_unregulated<C>(
        mint_cap: &mut LooseMintCap<Nft<C>>,
    ): UnregulatedMintCap<Nft<C>> {
        df::remove(
            &mut mint_cap.id,
            utils::marker<UnregulatedMintCap<Nft<C>>>(),
        )
    }

    /// Returns `UnregulatedMintCap` to `LooseMintCap`
    ///
    /// Performs reverse casting as `take_unregulated_mut`.
    fun return_unregulated<C>(
        mint_cap: &mut LooseMintCap<Nft<C>>,
        unregulated_mint_cap: UnregulatedMintCap<Nft<C>>,
    ) {
        df::add(
            &mut mint_cap.id,
            utils::marker<UnregulatedMintCap<Nft<C>>>(),
            unregulated_mint_cap,
        )
    }

    /// Returns whether `LooseMintCap` is eligible to mint NFTs of the
    /// given type
    public fun is_regulated<T>(mint_cap: &LooseMintCap<T>): bool {
        df::exists_with_type<Marker<RegulatedMintCap<T>>, RegulatedMintCap<T>>(
            &mint_cap.id,
            utils::marker<RegulatedMintCap<T>>(),
        )
    }

    /// Returns the remaining supply available to `LooseMintCap`
    ///
    /// If factory is unregulated then none will be returned.
    public fun supply<T>(mint_cap: &LooseMintCap<T>): Option<u64> {
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
        mint_cap: &mut LooseMintCap<Nft<C>>,
        ctx: &mut TxContext,
    ): Nft<C> {
        let pointer = pointer(mint_cap.metadata_id);
        let name = *name(mint_cap);
        let url = *url(mint_cap);

        if (is_regulated(mint_cap)) {
            let regulated_mint_cap = take_regulated(mint_cap);
            let nft =
                nft::from_regulated(&mut regulated_mint_cap, name, url, ctx);

            nft::add_domain_with_regulated(
                &regulated_mint_cap, &mut nft, pointer,
            );

            return_regulated(mint_cap, regulated_mint_cap);

            nft
        } else {
            let unregulated_mint_cap = take_unregulated(mint_cap);
            let nft =
                nft::from_unregulated(&unregulated_mint_cap, name, url, ctx);

            nft::add_domain_with_unregulated(
                &unregulated_mint_cap, &mut nft, pointer,
            );

            return_unregulated(mint_cap, unregulated_mint_cap);

            nft
        }
    }

    /// Mints `Nft` from `LooseMintCap` and transfer
    ///
    /// #### Panics
    ///
    /// Panics if supply was exceeded
    public fun mint_nft_and_transfer<C>(
        mint_cap: &mut LooseMintCap<Nft<C>>,
        ctx: &mut TxContext,
    ) {
        let nft = mint_nft(mint_cap, ctx);
        transfer::public_transfer(nft, tx_context::sender(ctx))
    }
}
