//! Module of a generic `NFT` type.
//!
//! It acts as a generic interface for NFTs and it allows for
//! the creation of arbitrary domain specific implementations.
//!
//! The `NFT` type is a hybrid object that can take two shapes: The shape of an
//! NFT that embeds is own data, an Embedded NFT; and the shape of an
//! NFT that does not embed its own data and containst solely a pointer to its
//! data object, a Loose NFT.
//!
//! With this design we can keep only one ultimate type whilst the NFT can be
//! embedded or loose depending on the use case. It is also possible to
//! dynamically join or split the data object from the NFT object, therefore
//! allowing for dynamic behaviour.
//!
//! For embedded NFTs, the `Data` object and the `NFT` object is minted in one
//! step. For loose NFTs the `Data` object is first minted and only then the
//! NFT(s) associated to that object is(are) minted.
//!
//! Embedded NFTs are nevertheless only useful to represent 1-to-1 relationships
//! between the NFT object and the Data object. In contrast, loose NFTs can
//! represent 1-to-many relationships. Essentially this allows us to build
//! NFTs which effectively have a supply.
module nft_protocol::nft {
    use std::option::{Self, Option};

    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::object_bag::{Self, ObjectBag};
    use sui::tx_context::{TxContext};

    use nft_protocol::err;

    // NFT object with phantom type `T`
    struct Nft<phantom T> has key, store {
        id: UID,
        bag: ObjectBag
    }

    struct MintEvent has copy, drop {
        nft_id: ID,
    }

    struct BurnEvent has copy, drop {
        nft_id: ID,
    }

    /// Create a `Nft` and returns it.
    public fun mint_nft<T>(
        ctx: &mut TxContext,
    ): Nft<T> {
        let nft_id = object::new(ctx);

        event::emit(
            MintEvent {
                nft_id: object::uid_to_inner(&nft_id),
            }
        );

        Nft {
            id: nft_id,
            bag: object_bag::new(ctx),
        }
    }

    public fun burn_nft<T>(
        nft: Nft<T>,
    ) {
        assert!(object_bag::is_empty(&nft.bag), err::bag_not_empty());

        event::emit(
            BurnEvent {
                nft_id: id(&nft),
            }
        );

        let Nft {
            id,
            bag,
        } = nft;

        object::delete(id);
        object_bag::destroy_empty(bag);
    }

    // === Getter Functions  ===

    public fun id<T>(
        nft: &Nft<T>,
    ): ID {
        object::uid_to_inner(&nft.id)
    }

    public fun id_ref<T>(
        nft: &Nft<T>,
    ): &ID {
        object::uid_as_inner(&nft.id)
    }

    public fun bag<T>(
        nft: &Nft<T>,
    ): &ObjectBag {
        &nft.bag
    }

    public fun bag_mut<T>(
        nft: &mut Nft<T>,
    ): &mut ObjectBag {
        &mut nft.bag
    }
}
