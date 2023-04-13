module nft_protocol::mint_event {
    // TODO: Add burn function

    use sui::event;
    use sui::object::{Self, ID};

    use nft_protocol::mint_cap::{Self, MintCap};

    /// Event signalling that an object `T` was minted
    struct MintEvent<phantom T> has copy, drop {
        /// ID of the `Collection` that was minted
        collection_id: ID,
        /// ID of the minted object
        object: ID,
    }

    /// Event signalling that an object `T` was burned
    struct BurnEvent<phantom T> has copy, drop {
        /// ID of the `Collection` that was minted
        collection_id: ID,
        /// ID of the burned object
        object: ID,
    }

    /// Emit burn event
    public fun emit_burn<C, T: key>(
        mint_cap: &MintCap<C>,
        object: &T,
    ) {
        event::emit(BurnEvent<T> {
            collection_id: mint_cap::collection_id(mint_cap),
            object: object::id(object),
        });
    }

    /// Emit `MintEvent` for NFT of type `T` and enforce supply guarantees on
    /// `MintCap`
    ///
    /// If your contract allows minting an NFT of type `T` while providing
    /// `MintCap<C>`
    ///
    /// #### Panics
    ///
    /// Panics if `MintCap` has limited supply as it cannot be incremented due
    /// to immutable reference.
    public fun mint_unlimited<C, T: key>(
        mint_cap: &MintCap<C>,
        object: &T,
    ) {
        mint_cap::assert_unlimited(mint_cap);

        event::emit(MintEvent<T> {
            collection_id: mint_cap::collection_id(mint_cap),
            object: object::id(object),
        });
    }

    /// Emit `MintEvent` for NFT of type `T` and enforce supply guarantees on
    /// `MintCap`
    ///
    /// #### Panics
    ///
    /// Panics if `MintCap` has unlimited supply or supply limit is exceeded.
    public fun mint_limited<C, T: key>(
        mint_cap: &mut MintCap<C>,
        object: &T,
    ) {
        mint_cap::assert_limited(mint_cap);
        mint_cap::increment_supply(mint_cap, 1);

        event::emit(MintEvent<T> {
            collection_id: mint_cap::collection_id(mint_cap),
            object: object::id(object),
        });
    }

    /// Emit `MintEvent` for NFT of type `T` and enforce supply guarantees on
    /// `MintCap`
    ///
    /// Function is identical to `mint_limited` or `mint_unlimited` but
    /// provides a fallback if `MintCap` is unlimited.
    ///
    /// #### Panics
    ///
    /// Panics if supply limit is exceeded.
    public fun mint<C, T: key>(
        mint_cap: &mut MintCap<C>,
        object: &T,
    ) {
        if (mint_cap::has_supply(mint_cap)) {
            mint_limited(mint_cap, object)
        } else {
            mint_unlimited(mint_cap, object)
        }
    }
}
