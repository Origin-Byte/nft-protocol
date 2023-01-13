/// Module of NFT domains for gaming standard information
///
/// Current gaming domains are:
///     - MatchInviteDomain (For NFTs)
module nft_protocol::gaming {
    use std::string::String;

    use sui::tx_context::{Self, TxContext};

    use nft_protocol::creators;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::collection::{Self, Collection, MintCap};
	
    struct Witness has drop {}

    struct MatchInviteDomain has store {
        matchId: String,
    }

    /// Gets matchId of `MatchInviteDomain`
    public fun matchId(domain: &MatchInviteDomain): &String {
        &domain.matchId
    }

    /// Creates a new `MatchInviteDomain` with matchId
    public fun new_match_invite_domain(
        matchId: String,
    ): MatchInviteDomain {
        MatchInviteDomain { matchId }
    }

    /// Sets matchId of `MatchInviteDomain`
    ///
    /// Requires that `CreatorsDomain` is defined and sender is a creator
    public fun set_name<C>(
        collection: &mut Collection<C>,
        matchId: String,
        ctx: &mut TxContext,
    ) {
        creators::assert_collection_has_creator(
            collection, tx_context::sender(ctx)
        );

        let domain: &mut MatchInviteDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.matchId = matchId;
    }

    /// ====== Interoperability ===

    public fun match_invite_domain<C>(
        nft: &Nft<C>,
    ): &MatchInviteDomain {
        nft::borrow_domain(nft)
    }
	
	public fun collection_match_invite_domain<C>(
        nft: &Collection<C>,
    ): &MatchInviteDomain {
        collection::borrow_domain(nft)
    }

    public fun add_match_invite_domain<C>(
        nft: &mut Nft<C>,
        matchId: String,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(nft, new_match_invite_domain(matchId), ctx);
    }
	
	public fun add_collection_match_invite_domain<C>(
        col: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        matchId: String,
    ) {
        collection::add_domain(
            col, mint_cap, new_match_invite_domain(matchId)
        );
    }
}
