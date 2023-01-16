module nft_protocol::market_whitelist {
    use sui::transfer;
    use sui::object::{Self, ID , UID};
    use sui::tx_context::TxContext;

    use nft_protocol::err;
    use nft_protocol::listing::{Self, Listing};

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
        /// `Inventory` from which this certificate can withdraw an `Nft`
        inventory_id: ID,
        /// Market on `Inventory` from which this certificate can withdraw an
        /// `Nft`
        market_id: ID,
    }

    /// Create a new `Certificate`
    ///
    /// Can be used by owner to participate in the provided market.
    ///
    /// ##### Panics
    ///
    /// Panics if transaction sender is not `Listing` admin
    public fun new(
        listing: &Listing,
        inventory_id: ID,
        market_id: ID,
        ctx: &mut TxContext,
    ): Certificate {
        listing::assert_listing_admin(listing, ctx);

        let certificate = Certificate {
            id: object::new(ctx),
            listing_id: object::id(listing),
            inventory_id,
            market_id,
        };

        certificate
    }

    /// Issue a new `Certificate` to an address
    ///
    /// Can be used by owner to participate in the provided market.
    ///
    /// ##### Panics
    ///
    /// Panics if transaction sender is not `Listing` admin
    public entry fun issue(
        listing: &Listing,
        inventory_id: ID,
        market_id: ID,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let certificate = new(
            listing, inventory_id, market_id, ctx,
        );
        transfer::transfer(certificate, recipient);
    }

    /// Burns a `Certificate`
    public entry fun burn(
        certificate: Certificate,
    ) {
        let Certificate {
            id,
            listing_id: _,
            inventory_id: _,
            market_id: _,
        } = certificate;

        object::delete(id);
    }

    // === Assertions ===

    public fun assert_certificate(
        market_id: ID,
        certificate: &Certificate,
    ) {
        // Infer that whitelist token corresponds to correct sale inventory
        assert!(
            certificate.market_id == market_id,
            err::incorrect_whitelist_certificate()
        );
    }
}
