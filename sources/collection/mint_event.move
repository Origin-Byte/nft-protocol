/// Module exposing `MintEvent` and `BurnEvent` for use in creator contracts
///
/// `MintEvent` and `BurnEvent` are free to emit as long as the user can
/// demonstrate ownership of the type of object for which the event is being
/// emitted.
///
/// Mint events are not specially protected as they rely on the good-will of
/// the creator to emit events when they instantiate NFTs. On the other hand
/// Sui does give us the ability to ensure that an arbitrary object is
/// destructed in order to emit the `BurnEvent`.
///
/// `emit_event` does not take `MintCap<T>` in order to leave creators flexible
/// to use their own mint authorities.
module nft_protocol::mint_event {
    use sui::event;
    use sui::object::{Self, UID, ID};

    use nft_protocol::witness::Witness as DelegatedWitness;

    /// Passed `BurnGuard` for object with different ID
    ///
    /// Call `mint_event::emit_burn` with the same object used in
    /// `mint_event::start_burn`.
    const EInvalidBurnGuard: u64 = 1;

    // === Mint Events ===

    /// Event signalling that an object `T` was minted
    struct MintEvent<phantom T> has copy, drop {
        /// ID of the `Collection` that was minted
        collection_id: ID,
        /// ID of the minted object
        object: ID,
    }

    /// Emit `MintEvent` for NFT of type `T`
    ///
    /// #### Panics
    ///
    /// Panics if supply limit is exceeded.
    public fun emit_mint<T: key>(
        _witness: DelegatedWitness<T>,
        collection_id: ID,
        object: &T,
    ) {
        event::emit(MintEvent<T> {
            collection_id,
            object: object::id(object),
        });
    }

    // === Burn Events ===

    /// Event signalling that an object `T` was burned
    struct BurnEvent<phantom T> has copy, drop {
        /// ID of the `Collection` that was minted
        collection_id: ID,
        /// ID of the burned object
        object: ID,
    }

    /// Intermediate type used to ensure that object gets deleted
    ///
    /// #### Usage
    ///
    /// ```
    /// let avatar = Avatar { id: object::new(ctx) };
    ///
    /// let guard = start_burn(&avatar);
    /// let Avatar { id } = avatar;
    ///
    /// emit_burn(collection_id, id, guard);
    /// ```
    struct BurnGuard<phantom T> {
        id: ID,
    }

    /// Start burning object of type `T`
    public fun start_burn<T: key>(
        _witness: DelegatedWitness<T>,
        object: &T,
    ): BurnGuard<T> {
        BurnGuard { id: object::id(object) }
    }

    /// Emit `MintEvent` for NFT of type `T`
    ///
    /// #### Panics
    ///
    /// Panics if supply limit is exceeded.
    public fun emit_burn<T: key>(
        guard: BurnGuard<T>,
        collection_id: ID,
        object: UID,
    ) {
        let BurnGuard<T> { id } = guard;

        assert!(object::uid_to_inner(&object) == id, EInvalidBurnGuard);
        object::delete(object);

        event::emit(BurnEvent<T> {
            collection_id,
            object: id,
        });
    }
}
