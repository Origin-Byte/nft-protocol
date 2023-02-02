module nft_protocol::market_whitelist {
    use sui::transfer;
    use sui::object::{Self, ID , UID};
    use sui::tx_context::TxContext;

    use nft_protocol::listing::{Self, Listing};

    /// `Certificate` issued for incorrect `Venue` ID
    const EINCORRECT_CERTIFICATE: u64 = 1;

    /// Grants owner the privilege to participate in an NFT sale in a
    /// whitelisted `Listing`
    ///
    /// Creators can create tiered sales based on the NFT rarity and then
    /// whitelist only the rare NFT sale. Alternatively, they can provide a
    /// lower priced market on an `Inventory` that they can then emit whitelist
    /// tokens and send them to users who have completed a set of defined
    /// actions.
    struct Certificate has key, store {
        id: UID,
        /// `Listing` from which this certificate can withdraw an `Nft`
        listing_id: ID,
        /// `Venue` from which this certificate can withdraw an `Nft`
        venue_id: ID,
    }

    /// Create a new `Certificate`
    ///
    /// Can be used by owner to participate in the provided market.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not `Listing` admin
    public fun new(
        listing: &Listing,
        venue_id: ID,
        ctx: &mut TxContext,
    ): Certificate {
        listing::assert_listing_admin(listing, ctx);

        let certificate = Certificate {
            id: object::new(ctx),
            listing_id: object::id(listing),
            venue_id,
        };

        certificate
    }

    /// Issue a new `Certificate` to an address
    ///
    /// Can be used by owner to participate in the provided market.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not `Listing` admin
    public entry fun issue(
        listing: &Listing,
        venue_id: ID,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let certificate = new(listing, venue_id, ctx);
        transfer::transfer(certificate, recipient);
    }

    /// Burns a `Certificate`
    public entry fun burn(
        certificate: Certificate,
    ) {
        let Certificate {
            id,
            listing_id: _,
            venue_id: _,
        } = certificate;

        object::delete(id);
    }

    // === Assertions ===

    /// Assert `Certificate` parameters
    ///
    /// #### Panics
    ///
    /// Panics if `Certificate` parameters don't match
    public fun assert_certificate(certificate: &Certificate, venue_id: ID) {
        assert!(certificate.venue_id == venue_id, EINCORRECT_CERTIFICATE);
    }
}
