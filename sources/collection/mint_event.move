module nft_protocol::mint_event {
    // TODO: Add burn function
    use std::type_name::{Self, TypeName};

    use sui::event;
    use sui::object::{Self, ID};

    use nft_protocol::mint_cap::{Self, MintCap};

    /// Event signalling that an object `T` was minted
    struct MintEvent<phantom T> has copy, drop {
        /// ID of the `Collection` that was minted
        collection_id: ID,
        /// Type name of `Collection<C>` one-time witness `C`
        ///
        /// Intended to allow users to filter by collections of interest.
        type_name: TypeName,
        /// ID of the minted object
        object: ID,
    }

    /// Event signalling that an object `T` was burned
    struct BurnEvent<phantom T> has copy, drop {
        /// ID of the `Collection` that was minted
        collection_id: ID,
        /// Type name of `Collection<C>` one-time witness `C`
        ///
        /// Intended to allow users to filter by collections of interest.
        type_name: TypeName,
        /// ID of the burned object
        object: ID,
    }

    public fun mint_unlimited<T: key>(
        mint_cap: &MintCap<T>,
        object: &T,
    ) {
        mint_cap::assert_unlimited(mint_cap);

        event::emit(MintEvent<T> {
            collection_id: mint_cap::collection_id(mint_cap),
            type_name: type_name::get<T>(),
            object: object::id(object),
        });
    }

    public fun mint_limited<T: key>(
        mint_cap: &mut MintCap<T>,
        object: &T,
    ) {
        mint_cap::assert_limited(mint_cap);
        mint_cap::increment_supply(mint_cap, 1);

        event::emit(MintEvent<T> {
            collection_id: mint_cap::collection_id(mint_cap),
            type_name: *mint_cap::collection_type(mint_cap),
            object: object::id(object),
        });
    }
}
