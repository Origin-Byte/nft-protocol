module nft_protocol::mint_event {
    use std::type_name::{Self, TypeName};

    use sui::event;
    use sui::object::{Self, ID};

    use nft_protocol::mint_cap::{Self, MintCap};

    /// Event signalling that an object `T` was minted
    struct MintEvent<phantom T> has copy, drop {
        /// ID of the `Collection` that was minted
        collection_id: ID,
        /// Type name of `Collection<T>` one-time witness `T`
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
        /// Type name of `Collection<T>` one-time witness `T`
        ///
        /// Intended to allow users to filter by collections of interest.
        type_name: TypeName,
        /// ID of the burned object
        object: ID,
    }

    struct MintEventHandle {
        /// ID of the `Collection` of the object `T`
        collection_id: ID,
        /// Type name of `Collection<T>` one-time witness `T`
        ///
        /// Intended to allow users to filter by collections of interest.
        type_name: TypeName,
        /// ID of the minted object
        object: ID,
    }

    struct BurnEventHandle {
        /// ID of the `Collection` of the object `T`
        collection_id: ID,
        /// Type name of `Collection<T>` one-time witness `T`
        ///
        /// Intended to allow users to filter by collections of interest.
        type_name: TypeName,
        /// ID of the burned object
        object: ID,
    }

    public fun mint<T: key>(
        mint_cap: &mut MintCap<T>,
        object: &T,
    ) {
        if (mint_cap::has_supply(mint_cap)) {
            mint_cap::increment_supply(mint_cap, 1);
        };

        let type = type_name::get<T>();
        let object_id = object::id(object);

        event::emit(MintEvent<T> {
            collection_id: mint_cap::collection_id(mint_cap),
            type_name: type,
            object: object_id,
        });
    }
}
