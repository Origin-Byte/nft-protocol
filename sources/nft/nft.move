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
    use nft_protocol::err;
    use nft_protocol::transfer_whitelist::{Self, Whitelist};
    use nft_protocol::utils;
    use std::option::{Self, Option};
    use std::type_name::{Self, TypeName};
    use sui::bag::{Self, Bag};
    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};

    struct NFT has key, store {
        id: UID,
        bag: Bag,
    }

    struct DomainKey has copy, drop, store {
        type: TypeName,
    }

    public fun new(ctx: &mut TxContext): NFT {
        NFT {
            id: object::new(ctx),
            bag: bag::new(ctx),
        }
    }

    public fun has_domain<D: store>(nft: &NFT): bool {
        bag::contains_with_type<DomainKey, D>(&nft.bag, dkey<D>())
    }

    public fun borrow_domain<D: store>(nft: &NFT): &D {
        bag::borrow<DomainKey, D>(&nft.bag, dkey<D>())
    }

    public fun borrow_domain_mut<D: store, W: drop>(
        _witness: W,
        nft: &mut NFT,
    ): &mut D {
        utils::assert_same_package_as_witness<W, D>();
        bag::borrow_mut<DomainKey, D>(&mut nft.bag, dkey<D>())

    }

    public fun add_domain<V: store>(
        nft: &mut NFT,
        v: V,
    ) {
        bag::add(&mut nft.bag, dkey<V>(), v);
    }

    public fun remove_domain<W: drop, V: store>(
        _witness: W,
        nft: &mut NFT,
    ): V {
        utils::assert_same_package_as_witness<W, V>();
        bag::remove(&mut nft.bag, dkey<V>())
    }

    fun dkey<D>(): DomainKey {
        DomainKey {
            type: type_name::get<D>(),
        }
    }

    struct MintEvent has copy, drop {
        nft_id: ID,
        data_id: ID,
    }

    struct BurnEvent has copy, drop {
        nft_id: ID,
        data_id: ID,
    }

    // === Transfer Functions ===

    /// If the authority was whitelisted by the creator, we transfer
    /// the NFT to the recipient address.
    public fun transfer<WW, Auth: drop>(
        nft: NFT,
        recipient: address,
        authority: Auth,
        whitelist: &Whitelist,
    ) {
        change_logical_owner(&mut nft, recipient, authority, whitelist);
        transfer::transfer(nft, recipient);
    }

    /// Whitelisted contracts (by creator) can change logical owner of an NFT.
    public fun change_logical_owner<WW, Auth: drop>(
        nft: &mut NFT,
        recipient: address,
        authority: Auth,
        whitelist: &Whitelist,
    ) {
        let is_ok = transfer_whitelist::can_be_transferred<T, Auth>(
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
