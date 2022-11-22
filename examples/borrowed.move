//! Provides a pattern for composing NFTs under a parent NFT.
//!
//! All NFTs must live directly in a [Safe], therefore, we can only refer to
//! allegedly owned NFTs by ID and verify the ownership of the safe.
//!
//! NFTs have an implicit model of ownership, such that, the owner of the
//! [Safe] that an NFT lives in owns the NFT. Therefore, borrowed ownership
//! must introduce a domain-specific ownership concept.
//!
//! For example, consider that the owner of a football player NFT wants to
//! sign them to a team NFT (owned by a different user) but not lose ownership
//! of the player.
//!
//! Alternatively, this exact domain structure can be repurposed to issue
//! license, domain names, and anything with a borrowed ownership concept.
//!
//! In any case, the direct [Safe] ownership is not allowed to be bypassed.

module nft_protocol::borrowed {
    use std::vector;

    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use nft_protocol::nft::{Self, NFT};
    use nft_protocol::safe::Safe;
    use nft_protocol::composable::{Self, assert_ownership};

    struct BorrowedDomain has key, store {
        id: UID,
        /// Address to which the NFT is domain-specificaly borrowed while
        /// retaining ownership in the original [Safe].
        owner: address
    }

    // [BorrowedDomain] can never expose an `owner_mut` endpoint as this would
    // allow the owner of the NFT to change the values of [BorrowedDomain]

    public fun owner(borrowed: &BorrowedDomain): address {
        borrowed.owner
    }

    // === Ownership proofs ===

    /// Prove that the current transaction sender is the owner of the NFT and
    /// the NFTs of it's [ComposableDomain]
    public entry fun assert_composable_ownership<C>(
        nft: &mut NFT<C>,
        // [Safe] where top-level [NFT] lives
        safe: &Safe,
        // Composable NFT child to assert ownership on.
        //
        // [Safe] is not necessary as [BorrowedDomain] can assert ownership.
        // One can use [ID] and [Safe] to obtain the same [NFT] object.
        //
        // The top-level [NFT] is not even required to hold [ComposableDomain],
        // however, it can for on-chain ownership indexing.
        nft_child: &NFT<C>,
        ctx: &mut TxContext
    ) {
        // Prove top-level ownership
        assert_ownership(object::id(nft), safe, ctx);

        let borrowed = nft::borrow_domain<C, BorrowedDomain>(nft);

        assert!(
            tx_context::sender(ctx) == owner(borrowed),
            err::not_nft_owner()
        );

        // Let's assume that our application wants to cache this proof if the
        // NFT implements [ComposableDomain].
        //
        // This is incorrect in the view of [assert_composable_ownership] as it
        // requires that the NFT is owned by the same [Safe]. However, notice
        // that while the ownership model is violated, the ownership of the [NFT]
        // remains safe.
        if (!nft::has_domain<C, composable::ComposableDomain>(nft)) {
            return
        };

        // This is an implementation error of [ComposableDomain] as it allows
        // mutable access to ownership proof invariants. Nevertheless this
        // mutable access had to have been made explicit and does not have to
        // be protected against by default.
        let owned_nft = composable::owned_mut(nft);
        vector::push_back(owned_nft, object::id(nft_child))
    }
}
