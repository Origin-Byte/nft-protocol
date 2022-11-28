module nft_protocol::generic {
    use nft_protocol::err;
    use nft_protocol::domain::{domain_key, DomainKey};
    use nft_protocol::transfer_whitelist::{Self, Whitelist};
    use nft_protocol::utils;

    use sui::object_bag::{Self, ObjectBag};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct Generic has key, store {
        id: UID,
        object: ObjectBag,
    }

    public fun new<C>(ctx: &mut TxContext): NFT<C> {
        NFT {
            id: object::new(ctx),
            object: object_bag::new(ctx),
        }
    }

    // === Domain Functions ===

    public fun has_object<C, D: store>(nft: &NFT<C>): bool {
        bag::contains_with_type<DomainKey, D>(&nft.bag, domain_key<D>())
    }

    public fun borrow_object<C, D: store>(nft: &NFT<C>): &D {
        bag::borrow<DomainKey, D>(&nft.bag, domain_key<D>())
    }

    public fun borrow_object_mut<C, D: store, W: drop>(
        _witness: W,
        nft: &mut NFT<C>,
    ): &mut D {
        utils::assert_same_module_as_witness<W, D>();
        bag::borrow_mut<DomainKey, D>(&mut nft.bag, domain_key<D>())

    }

    public fun add_object<C, V: store>(
        nft: &mut NFT<C>,
        v: V,
    ) {
        object_bag::

        bag::add(&mut nft.bag, domain_key<V>(), v);
    }

    public fun remove_object<C, W: drop, V: store>(
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
