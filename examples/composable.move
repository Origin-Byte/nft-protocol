//! Provides a pattern for composing NFTs which all live in one [Safe]
//!
//! All NFTs must live directly in a [Safe], therefore, we can only refer to
//! allegedly owned NFTs by ID and verify the ownership of the safe.


module nft_protocol::composable {
    use std::vector;

    use sui::object::{ID, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use nft_protocol::nft::{Self, NFT};
    use nft_protocol::safe::{Self, Safe};

    struct ComposableDomain has key, store {
        id: UID,
        /// Owned NFT IDs
        owned: vector<ID>
    }

    struct Witness has drop {}

    public fun owned<C>(nft: &NFT<C>): &vector<ID> {
        let composable = nft::borrow_domain<C, ComposableDomain>(nft);
        &composable.owned
    }

    /// [ComposableDomain] has full control over the mutable API it exposes.
    ///
    /// Due to the ownership rules enforced by `Safe` and `BorrowedDomain`,
    /// neither ownership model is violated by exposing mutable access to the
    /// ownership vector. A testament to how robust this method is.
    ///
    /// Nevertheless, [assert_composable_ownership] will error out if any NFTs
    /// in this vector do not live in the same [Safe].
    public fun owned_mut<C>(nft: &mut NFT<C>): &mut vector<ID> {
        let composable = nft::borrow_domain_mut<C, ComposableDomain, Witness>(Witness {}, nft);
        &mut composable.owned
    }

    // === Ownership proofs ===

    /// Prove that the current transaction sender is the owner of the NFT
    public entry fun assert_ownership(nft_id: ID, safe: &Safe, ctx: &mut TxContext) {
        assert!(
            tx_context::sender(ctx) == safe::owner(safe),
            err::not_nft_owner()
        );
        assert!(
            safe::contains(safe, nft_id),
            err::nft_doesnt_exist()
        );
    }

    /// Prove that the current transaction sender is the owner of the NFT and
    /// the NFTs of it's [ComposableDomain]
    public entry fun assert_composable_ownership<C>(nft: &NFT<C>, safe: &Safe, ctx: &mut TxContext) {
        // Prove top-level ownership
        assert_ownership(nft::id(nft), safe, ctx);

        if (!nft::has_domain<C, ComposableDomain>(nft)) {
            return
        };

        // [nft::borrow_domain] is publicly accessible, however,
        // [ComposableDomain] can define it's own API
        let owned_nfts = owned(nft);

        let index = 0;
        let length = vector::length(owned_nfts);
        while (length > index) {
            let child = vector::borrow(owned_nfts, index);
            assert_ownership(*child, safe, ctx);
        }
    }
}
