//! Module of a generic `NFT` type.
//!
//! It acts as a generic interface for NFTs and it allows for
//! the creation of arbitrary domain specific implementations.
module nft_protocol::nft {
    use nft_protocol::err;
    use nft_protocol::domain::{domain_key, DomainKey};
    use nft_protocol::transfer_whitelist::{Self, Whitelist};
    use nft_protocol::utils;

    use sui::bag::{Self, Bag};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct NFT<phantom C> has key, store {
        id: UID,
        bag: Bag,
        logical_owner: address,
    }

    public fun new<C>(ctx: &mut TxContext): NFT<C> {
        NFT {
            id: object::new(ctx),
            bag: bag::new(ctx),
            logical_owner: tx_context::sender(ctx),
        }
    }

    // === Domain Functions ===

    public fun has_domain<C, D: store>(nft: &NFT<C>): bool {
        bag::contains_with_type<DomainKey, D>(&nft.bag, domain_key<D>())
    }

    public fun borrow_domain<C, D: store>(nft: &NFT<C>): &D {
        bag::borrow<DomainKey, D>(&nft.bag, domain_key<D>())
    }

    public fun borrow_domain_mut<C, D: store, W: drop>(
        _witness: W,
        nft: &mut NFT<C>,
    ): &mut D {
        utils::assert_same_module_as_witness<W, D>();
        bag::borrow_mut<DomainKey, D>(&mut nft.bag, domain_key<D>())
    }

    public fun add_domain<C, V: store>(
        nft: &mut NFT<C>,
        v: V,
        ctx: &mut TxContext,
    ) {
        // If NFT is a shared objects then malicious actors could freely add
        // their domains without the owners permission.
        assert!(
            tx_context::sender(ctx) == nft.logical_owner,
            err::not_nft_owner()
        );

        bag::add(&mut nft.bag, domain_key<V>(), v);
    }

    public fun remove_domain<C, W: drop, V: store>(
        _witness: W,
        nft: &mut NFT<C>,
    ): V {
        utils::assert_same_module_as_witness<W, V>();
        bag::remove(&mut nft.bag, domain_key<V>())
    }

    // === Transfer Functions ===

    /// If the authority was whitelisted by the creator, we transfer
    /// the NFT to the recipient address.
    public fun transfer<C, Auth: drop>(
        nft: NFT<C>,
        recipient: address,
        authority: Auth,
        whitelist: &Whitelist,
    ) {
        change_logical_owner(&mut nft, recipient, authority, whitelist);
        transfer::transfer(nft, recipient);
    }

    /// Whitelisted contracts (by creator) can change logical owner of an NFT.
    public fun change_logical_owner<C, Auth: drop>(
        nft: &mut NFT<C>,
        recipient: address,
        authority: Auth,
        whitelist: &Whitelist,
    ) {
        let is_ok = transfer_whitelist::can_be_transferred<C, Auth>(
            authority,
            whitelist,
        );
        assert!(is_ok, err::authority_not_whitelisted());

        nft.logical_owner = recipient;
    }
}
