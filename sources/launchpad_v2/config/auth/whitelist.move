module nft_protocol::market_whitelist_2 {
    use sui::transfer;
    use sui::object::{Self, ID , UID};
    use sui::tx_context::TxContext;

    use nft_protocol::launchpad_v2::LaunchCap;
    use nft_protocol::venue_v2::{Self, Venue};
    use nft_protocol::venue_request::{Self, VenueRequest};

    // TODO: There should be a way to create different types of whitelists
    // currently it's only possile to have one type.

    // TODO: Add split/merge function for certificates, actually, we should use
    // the Coin<T> api to do this, no need ot reinvent the wheel

    /// `Certificate` issued for incorrect `Venue` ID
    const EINCORRECT_CERTIFICATE: u64 = 1;

    struct WhiteList has drop {}

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
        /// `Venue` from which this certificate can withdraw an `Nft`
        venue_id: ID,
        quantity: u64,
    }

    /// Create a new `Certificate`
    ///
    /// Can be used by owner to participate in the provided market.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not `Listing` admin
    public fun new(
        launch_cap: &LaunchCap,
        venue: &Venue,
        quantity: u64,
        ctx: &mut TxContext,
    ): Certificate {
        venue_v2::assert_launch_cap(venue, launch_cap);

        let certificate = Certificate {
            id: object::new(ctx),
            venue_id: object::id(venue),
            quantity,
        };

        certificate
    }

    public fun check_whitelist(
        venue: &Venue,
        cert: Certificate,
        request: &mut VenueRequest,
    ) {
        assert_certificate(&cert, object::id(venue));
        venue_v2::assert_venue_request(venue, request);

        cert.quantity = cert.quantity - 1;

        if (cert.quantity == 0) {
            burn(cert)
        };

        venue_request::add_receipt(request, &WhiteList {});
    }

    /// Issue a new `Certificate` to an address
    ///
    /// Can be used by owner to participate in the provided market.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not `Listing` admin
    public entry fun issue(
        launch_cap: &LaunchCap,
        venue: &Venue,
        quantity: u64,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let certificate = new(launch_cap, venue, quantity, ctx);
        transfer::public_transfer(certificate, recipient);
    }

    /// Burns a `Certificate`
    public entry fun burn(
        certificate: Certificate,
    ) {
        let Certificate {
            id,
            venue_id: _,
            quantity: _,
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
