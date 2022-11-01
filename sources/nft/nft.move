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
    use sui::tx_context::TxContext;
    use sui::transfer;

    use nft_protocol::err;
    use nft_protocol::transfer_whitelist::{Self, Whitelist};

    // NFT object with an option to hold `D`ata object
    struct Nft<phantom T, D: store> has key, store {
        id: UID,
        logical_owner: address,
        data_id: ID,
        data: Option<D>,
    }

    struct MintEvent has copy, drop {
        nft_id: ID,
        data_id: ID,
    }

    struct BurnEvent has copy, drop {
        nft_id: ID,
        data_id: ID,
    }

    /// Create a loose `Nft` and returns it.
    public fun mint_nft_loose<T, D: store>(
        data_id: ID,
        logical_owner: address,
        ctx: &mut TxContext,
    ): Nft<T, D> {
        let nft_id = object::new(ctx);

        event::emit(
            MintEvent {
                nft_id: object::uid_to_inner(&nft_id),
                data_id: data_id,
            }
        );

        Nft {
            id: nft_id,
            logical_owner,
            data_id: data_id,
            data: option::none(),
        }
    }

    /// Create a embeded `Nft` and returns it.
    public fun mint_nft_embedded<T, D: store>(
        data_id: ID,
        logical_owner: address,
        data: D,
        ctx: &mut TxContext,
    ): Nft<T, D> {
        let nft_id = object::new(ctx);

        event::emit(
            MintEvent {
                nft_id: object::uid_to_inner(&nft_id),
                data_id: data_id,
            }
        );

        Nft {
            id: nft_id,
            logical_owner,
            data_id: data_id,
            data: option::some(data),
        }
    }

    public fun join_nft_data<T, D: store>(
        nft: &mut Nft<T, D>,
        data: D,
    ) {
        assert!(option::is_none(&nft.data), err::nft_not_loose());

        option::fill(&mut nft.data, data);
    }

    public fun split_nft_data<T, D: store>(
        nft: &mut Nft<T, D>,
    ): D {
        assert!(!option::is_none(&nft.data), err::nft_not_embedded());

        option::extract(&mut nft.data)
    }

    public fun burn_loose_nft<T, D: store>(
        nft: Nft<T, D>,
    ) {
        assert!(is_loose(&nft), err::nft_not_loose());

        event::emit(
            BurnEvent {
                nft_id: id(&nft),
                data_id: nft.data_id,
            }
        );

        let Nft {
            id,
            logical_owner: _,
            data_id: _,
            data,
        } = nft;

        object::delete(id);

        option::destroy_none(data);
    }

    public fun burn_embedded_nft<T, D: store>(
        nft: Nft<T, D>,
    ): Option<D> {
        assert!(!is_loose(&nft), err::nft_not_embedded());

        event::emit(
            BurnEvent {
                nft_id: id(&nft),
                data_id: nft.data_id,
            }
        );

        let Nft {
            id,
            logical_owner: _,
            data_id: _,
            data,
        } = nft;

        object::delete(id);

        data
    }

    public fun is_loose<T, D: store>(
        nft: &Nft<T, D>,
    ): bool {
        option::is_none(&nft.data)
    }

    // === Transfer Functions ===

    /// If the authority was whitelisted by the creator, we transfer
    /// the NFT to the recipient address.
    public fun transfer<T, D: store, WW, Auth: drop>(
        nft: Nft<T, D>,
        recipient: address,
        authority: Auth,
        whitelist: &Whitelist<WW>,
    ) {
        change_logical_owner(&mut nft, recipient, authority, whitelist);
        transfer::transfer(nft, recipient);
    }

    /// Whitelisted contracts (by creator) can change logical owner of an NFT.
    public fun change_logical_owner<T, D: store, WW, Auth: drop>(
        nft: &mut Nft<T, D>,
        recipient: address,
        authority: Auth,
        whitelist: &Whitelist<WW>,
    ) {
        let is_ok = transfer_whitelist::can_be_transferred<WW, T, Auth>(
            authority,
            whitelist,
        );
        assert!(is_ok, err::authority_not_whitelisted());

        nft.logical_owner = recipient;
    }

    /// Clawing back an NFT is always possible.
    public fun transfer_to_owner<T, D: store>(nft: Nft<T, D>) {
        let logical_owner = nft.logical_owner;
        transfer::transfer(nft, logical_owner);
    }

    // === Getter Functions  ===

    public fun id<T, D: store>(
        nft: &Nft<T, D>,
    ): ID {
        object::uid_to_inner(&nft.id)
    }

    public fun id_ref<T, D: store>(
        nft: &Nft<T, D>,
    ): &ID {
        object::uid_as_inner(&nft.id)
    }

    public fun data_id<T, D: store>(
        nft: &Nft<T, D>,
    ): ID {
        nft.data_id
    }

    public fun data_id_ref<T, D: store>(
        nft: &Nft<T, D>,
    ): &ID {
        &nft.data_id
    }

    public fun data_ref<T, D: store>(
        nft: &Nft<T, D>,
    ): &D {
        option::borrow(&nft.data)
    }

    public fun data_ref_mut<T, D: store>(
        nft: &mut Nft<T, D>,
    ): &mut D {
        option::borrow_mut(&mut nft.data)
    }
}
