/// Module responsible for the creation and destruction of Whitelist certificates.
module ob_launchpad::market_whitelist {
    use std::vector;

    use sui::transfer;
    use sui::tx_context;
    use sui::vec_set::{Self, VecSet};
    use sui::object::{Self, ID , UID};
    use sui::tx_context::TxContext;

    use ob_launchpad::listing::{Self, Listing};
    use ob_launchpad::venue::{Self, Venue};

    /// `Certificate` issued for incorrect `Venue` ID
    const EINCORRECT_CERTIFICATE: u64 = 1;

    /// User address is not in `Whitelist` object
    const ENOT_WHITELISTED: u64 = 2;

    struct Whitelist has key, store {
        id: UID,
        /// `Listing` from which this certificate can withdraw an `Nft`
        listing_id: ID,
        /// `Venue` from which this certificate can withdraw an `Nft`
        venue_id: ID,
        list: VecSet<address>
    }

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
        listing::assert_listing_admin_or_member(listing, ctx);
        listing::assert_venue(listing, venue_id);

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
        transfer::public_transfer(certificate, recipient);
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

    /// Initiates the `Whitelist` object. It can only
    /// be called by the listing admin or member
    ///
    /// Fails if venue ID does not exist in the Listing.
    /// Fails if caller is not admin or member
    public fun add_whitelist(
        listing: &mut Listing,
        venue_id: ID,
        ctx: &mut TxContext,
    ) {
        listing::assert_listing_admin_or_member(listing, ctx);
        listing::assert_venue(listing, venue_id);

        let venue = listing::borrow_venue(listing, venue_id);

        venue::assert_is_whitelisted(venue);

        let whitelist = Whitelist {
            id: object::new(ctx),
            listing_id: object::id(listing),
            venue_id,
            list: vec_set::empty()
        };

        listing::add_whitelist_internal(listing, venue_id, whitelist);
    }

    /// Adds address to `Whitelist`
    ///
    /// Fails if address already present in the `Whitelist`
    public fun add_addresses(
        listing: &mut Listing,
        venue_id: ID,
        wl_addresses: vector<address>,
        ctx: &mut TxContext,
    ) {
        listing::assert_listing_admin_or_member(listing, ctx);
        listing::assert_venue(listing, venue_id);

        let whitelist = listing::borrow_whitelist_mut<Whitelist>(listing, venue_id);
        let len = vector::length(&wl_addresses);

        while (len > 0) {
            // TODO: Skip duplicates instead of returning err
            let wl_address = vector::pop_back(&mut wl_addresses);
            vec_set::insert(&mut whitelist.list, wl_address);

            len = len - 1;
        }
    }

    /// Removes address from `Whitelist`
    ///
    /// Fails if address not present in the `Whitelist`
    public fun remove_addresses(
        listing: &mut Listing,
        venue_id: ID,
        wl_addresses: vector<address>,
        ctx: &mut TxContext,
    ) {
        listing::assert_listing_admin_or_member(listing, ctx);
        listing::assert_venue(listing, venue_id);

        let whitelist = listing::borrow_whitelist_mut<Whitelist>(listing, venue_id);

        let len = vector::length(&wl_addresses);

        while (len > 0) {
            // TODO: Skip addresses absent in the whitelist instead of returning err
            let wl_address = vector::pop_back(&mut wl_addresses);
            vec_set::remove(&mut whitelist.list, &wl_address);

            len = len - 1;
        }
    }

    /// Checks in address on the whitelist and returns the corresponding
    /// Whitelist certificate.
    ///
    /// This function is unprotected, protection is made implicit by the
    /// ownership of the Whitelist object. In the idiomatic implementation
    /// the Whitelist object is owned by the Venue in a dynamic field.
    ///
    /// Fails if address not present in the `Whitelist`
    public fun check_in_address(
        listing: &mut Listing,
        venue_id: ID,
        ctx: &mut TxContext
    ): Certificate {
        listing::assert_venue(listing, venue_id);

        let wl_address = tx_context::sender(ctx);

        let whitelist = listing::borrow_whitelist_mut<Whitelist>(listing, venue_id);

        assert_wl_address(whitelist, wl_address);

        vec_set::remove(&mut whitelist.list, &wl_address);

        let certificate = Certificate {
            id: object::new(ctx),
            listing_id: whitelist.listing_id,
            venue_id: whitelist.venue_id,
        };

        certificate
    }

    // === Assertions ===

    /// Assert `Certificate` parameters based on `Venue`
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` is not whitelisted or `Certificate` parameters
    /// don't match.
    public fun assert_whitelist(certificate: &Certificate, venue: &Venue) {
        venue::assert_is_whitelisted(venue);
        assert_certificate(certificate, object::id(venue));
    }

    /// Assert that address is whitelisted in `Whitelist` object
    ///
    /// #### Panics
    ///
    /// Panics if not.
    public fun assert_wl_address(whitelist: &Whitelist, wl_address: address) {
        assert!(vec_set::contains(&whitelist.list, &wl_address), ENOT_WHITELISTED);
    }

    /// Assert `Certificate` parameters
    ///
    /// #### Panics
    ///
    /// Panics if `Certificate` parameters don't match
    public fun assert_certificate(certificate: &Certificate, venue_id: ID) {
        assert!(certificate.venue_id == venue_id, EINCORRECT_CERTIFICATE);
    }
}
