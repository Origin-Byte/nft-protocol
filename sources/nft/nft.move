//! Module of a generic `Nft` type.
//!
//! It acts as a generic interface for NFTs and it allows for
//! the creation of arbitrary domain specific implementations.
module nft_protocol::nft {
    use nft_protocol::err;
    use nft_protocol::transfer_whitelist::{Self, Whitelist};
    use nft_protocol::utils::{Self, Marker};

    use sui::dynamic_object_field as dof;
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct Nft<phantom C> has key, store {
        id: UID,
        logical_owner: address,
    }

    public fun new<C>(logical_owner: address, ctx: &mut TxContext): Nft<C> {
        Nft {
            id: object::new(ctx),
            logical_owner,
        }
    }

    // === Domain Functions ===

    public fun has_domain<C, D: key + store>(nft: &Nft<C>): bool {
        dof::exists_with_type<Marker<D>, D>(&nft.id, utils::marker<D>())
    }

    public fun borrow_domain<C, D: key + store>(nft: &Nft<C>): &D {
        dof::borrow(&nft.id, utils::marker<D>())
    }

    public fun borrow_domain_mut<C, W: drop, D: key + store>(
        _witness: W,
        nft: &mut Nft<C>,
    ): &mut D {
        utils::assert_same_module_as_witness<W, D>();
        dof::borrow_mut(&mut nft.id, utils::marker<D>())
    }

    public fun add_domain<C, D: key + store>(
        nft: &mut Nft<C>,
        domain: D,
        ctx: &mut TxContext,
    ) {
        // If NFT was a shared objects then malicious actors could freely add
        // their domains without the owners permission.
        assert!(
            tx_context::sender(ctx) == nft.logical_owner,
            err::not_nft_owner()
        );
        dof::add(&mut nft.id, utils::marker<D>(), domain)
    }

    public fun remove_domain<C, W: drop, D: key + store>(
        _witness: W,
        nft: &mut Nft<C>,
    ): D {
        utils::assert_same_module_as_witness<W, D>();
        dof::remove(&mut nft.id, utils::marker<D>())
    }

    // === Transfer Functions ===

    /// If the authority was whitelisted by the creator, we transfer
    /// the NFT to the recipient address.
    public fun transfer<C, Auth: drop>(
        nft: Nft<C>,
        recipient: address,
        authority: Auth,
        whitelist: &Whitelist,
    ) {
        change_logical_owner(&mut nft, recipient, authority, whitelist);
        transfer::transfer(nft, recipient);
    }

    /// Whitelisted contracts (by creator) can change logical owner of an NFT.
    public fun change_logical_owner<C, Auth: drop>(
        nft: &mut Nft<C>,
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
