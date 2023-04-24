// TODO: Add function to deregister rule
module launchpad_v2::certificate {
    use std::vector;
    use std::type_name::{Self, TypeName};
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID, ID};

    use launchpad_v2::venue::{Self, Venue};

    const ELAUNCHCAP_VENUE_MISMATCH: u64 = 1;

    const EMARKET_WITNESS_MISMATCH: u64 = 2;

    const EREDEEM_WITNESS_MISMATCH: u64 = 3;

    const ESTOCK_WITNESS_MISMATCH: u64 = 4;

    const EINVENTORY_ID_MISMATCH: u64 = 5;

    const EBUYER_CERTIFICATE_MISMATCH: u64 = 6;

    const EINVENTORY_CERTIFICATE_MISMATCH: u64 = 7;

    const ENFT_TYPE_CERTIFICATE_MISMATCH: u64 = 8;

    struct NftCertificate has key, store {
        id: UID,
        venue_id: ID,
        quantity: u64,
        buyer: address,
        // Needs to be here to assert which module has authority to
        // perform operations on the vector fields
        inventories: vector<ID>,
        nft_indices: vector<u64>,
        inventory_type: TypeName,
    }

    // === Instantiators ===

    /// Creates `RedeemReceipt` objects which is allows the owner to redeem
    /// NFTs from in the quantity defined by `nfts_bought`.
    ///
    /// This endpoint is protected and can only be called by the Market Policy module.
    ///
    /// Different sales can have different Redemtion Strategies (i.e NFTs are
    /// chosen at random or via FIFO method). In case where there is certainty
    /// as to what `Inventory` the RedeemReceipt is for, the whole process can
    /// be batched programmatically. Only in cases where the client cannot
    /// know ahead of time what `Inventory` it will have to call in the batch,
    /// it must call the `Inventory` in a separate batch in order to retrieve
    /// the NFTs.
    public fun get_redeem_certificate<MW: drop>(
        _market_witness: MW,
        venue: &mut Venue,
        buyer: address,
        nfts_bought: u64,
        ctx: &mut TxContext,
    ): NftCertificate {
        // TODO: Consider emitting events
        venue::assert_called_from_market<MW>(venue);

        NftCertificate {
            id: object::new(ctx),
            venue_id: object::id(venue),
            quantity: nfts_bought,
            buyer,
            inventories: vector::empty(),
            nft_indices: vector::empty(),
            inventory_type: venue::get_inventory_policy(venue),
        }
    }

    // TODO
    // /// This function consumes the NftCert and signals that we have entered
    // /// the last step in our Launchpad voyage.
    // ///
    // /// This endpoint is protected and can only be called by the Inventory module,
    // /// which is the authority which decides how to redeem the NFTs from the Invetories.
    // ///
    // /// This should be called in conjunction with the action of returning or
    // /// transferring the NFT to the buyer.
    // public fun consume_certificate<IW: drop, INV: key + store>(
    //     _inventory_witness: IW,
    //     inventory: &INV,
    //     cert: NftCert,
    // ) {
    //     assert_called_from_inventory<IW, INV>(inventory, &cert);

    //     let NftCert {
    //         id,
    //         venue_id: _,
    //         nft_type: _,
    //         buyer: _,
    //         inventory: _,
    //         nft_index: _,
    //     } = cert;

    //     object::delete(id);
    // }

    // === Certificates ===

    public fun invetories_mut<SW: drop>(
        _stock_witness: SW, venue: &mut Venue, certificate: &mut NftCertificate
    ): &mut vector<ID> {
        // TODO: Need to assert that certificate and venue are related
        venue::assert_called_from_stock_method<SW>(venue);
        &mut certificate.inventories
    }

    public fun nft_mut<RW: drop>(
        _redeem_witness: RW, venue: &mut Venue, certificate: &mut NftCertificate
    ): &mut vector<u64> {
        venue::assert_called_from_redeem_method<RW>(venue);
        &mut certificate.nft_indices
    }

    // Replace these functions, since they run in a loop there should not be more than one assertion
    public fun invetories_mut_as_inventory<IW: drop>(
        _inventory_witness: IW, certificate: &mut NftCertificate
    ): &mut vector<ID> {
        // TODO: Need to assert that certificate and venue are related
        assert_called_from_inventory<IW>(certificate);
        &mut certificate.inventories
    }

    public fun nft_mut_as_inventory<IW: drop>(
        _inventory_witness: IW, certificate: &mut NftCertificate
    ): &mut vector<u64> {
        assert_called_from_inventory<IW>(certificate);
        &mut certificate.nft_indices
    }

    public fun quantity_mut<IW: drop>(_inventory_witness: IW, certificate: &mut NftCertificate): &mut u64 {
        assert_called_from_inventory<IW>(certificate);
        &mut certificate.quantity
    }


    // === NftCert Getter Functions ===

    public fun venue_id(cert: &NftCertificate): ID {
        cert.venue_id
    }

    public fun quantity(cert: &NftCertificate): u64 {
        cert.quantity
    }

    public fun buyer(cert: &NftCertificate): address {
        cert.buyer
    }

    public fun inventories(cert: &NftCertificate): &vector<ID> {
        &cert.inventories
    }

    public fun nft_indices(cert: &NftCertificate): &vector<u64> {
        &cert.nft_indices
    }

    public fun cert_uid(cert: &NftCertificate): &UID {
        &cert.id
    }

    // TODO: Should this be protected?
    public fun cert_uid_mut(cert: &mut NftCertificate): &mut UID {
        &mut cert.id
    }

    // === Assertions ===

    // public fun assert_request(venue: &Venue, request: &AuthRequest) {
    //     assert!(auth_request::policy_id(request) == object::id(&venue.policies.auth), 0);
    // }

    // // TODO: These assertions are wrong because the Witnesses and Policy Objects are not the same...
    // public fun assert_called_from_market<AW: drop>(venue: &Venue) {
    //     assert!(type_name::get<AW>() == venue.policies.market, EMARKET_WITNESS_MISMATCH);
    // }

    public fun assert_called_from_inventory<IW: drop>(certificate: &NftCertificate) {
        assert!(type_name::get<IW>() == certificate.inventory_type, EINVENTORY_ID_MISMATCH);
    }

    public fun assert_cert_buyer(cert: &NftCertificate, ctx: &TxContext) {
        assert!(cert.buyer == tx_context::sender(ctx), EBUYER_CERTIFICATE_MISMATCH);
    }

    // public fun assert_nft_type<T: key + store>(cert: &NftCert) {
    //     assert!(cert.nft_type == type_name::get<T>(), ENFT_TYPE_CERTIFICATE_MISMATCH);
    // }

    // public fun assert_cert_inventory(cert: &NftCert, inventory_id: ID) {
    //     assert!(cert.inventory == inventory_id, EINVENTORY_CERTIFICATE_MISMATCH);
    // }
}
