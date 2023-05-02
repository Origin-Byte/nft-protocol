// TODO: Add function to deregister rule
module ob_launchpad_v2::certificate {
    use sui::vec_map::{Self, VecMap};
    use std::type_name::{Self, TypeName};
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID, ID};

    use ob_utils::sized_vec::{Self, SizedVec};

    use ob_launchpad_v2::venue::{Self, Venue};

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
        // Wrapped under option to avoid conflict with mutable references
        nft_map: VecMap<ID, SizedVec<u64>>,
        // Wrapped under option to avoid conflict with mutable references
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
        market_witness: MW,
        venue: &mut Venue,
        buyer: address,
        nfts_bought: u64,
        ctx: &mut TxContext,
    ): NftCertificate {
        // TODO: Consider emitting events
        venue::assert_called_from_market<MW>(market_witness, venue);

        NftCertificate {
            id: object::new(ctx),
            venue_id: object::id(venue),
            quantity: nfts_bought,
            buyer,
            nft_map: vec_map::empty(),
            inventory_type: venue::get_inventory_policy(venue),
        }
    }

    // /// This function consumes the NftCert and signals that we have entered
    // /// the last step in our Launchpad voyage.
    // ///
    // /// This endpoint is protected and can only be called by the Inventory module,
    // /// which is the authority which decides how to redeem the NFTs from the Invetories.
    // ///
    // /// This should be called in conjunction with the action of returning or
    // /// transferring the NFT to the buyer.
    // public fun consume_certificate(
    //     cert: NftCert,
    // ) {


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

    public fun get_nft_map_mut_as_stock<SW: drop>(
        stock_witness: SW, venue: &Venue, certificate: &mut NftCertificate
    ): &mut VecMap<ID, SizedVec<u64>> {
        // TODO: Need to assert that certificate and venue are related
        venue::assert_called_from_stock_method<SW>(stock_witness, venue);
        &mut certificate.nft_map
    }

    public fun get_nft_map_mut_as_redeem<RW: drop>(
        redeem_witness: RW, venue: &Venue, certificate: &mut NftCertificate
    ): &mut VecMap<ID, SizedVec<u64>> {
        // TODO: Need to assert that certificate and venue are related
        venue::assert_called_from_redeem_method<RW>(redeem_witness, venue);
        &mut certificate.nft_map
    }

    public fun get_nft_map_mut_as_inventory<IW: drop>(
        inventory_witness: IW, certificate: &mut NftCertificate
    ): &mut VecMap<ID, SizedVec<u64>> {
        assert_called_from_inventory<IW>(inventory_witness, certificate);
        &mut certificate.nft_map
    }

    public fun quantity_mut<IW: drop>(inventory_witness: IW, certificate: &mut NftCertificate): &mut u64 {
        assert_called_from_inventory<IW>(inventory_witness, certificate);
        &mut certificate.quantity
    }

    public fun add_to_nft_map(nft_map: &mut VecMap<ID, SizedVec<u64>>, inv_id: ID) {
        if (!vec_map::contains(nft_map, &inv_id)) {
            let vec = sized_vec::empty(1);
            vec_map::insert(nft_map, inv_id, vec);
        } else {
            let vec = vec_map::get_mut(nft_map, &inv_id);
            sized_vec::increase_capacity(vec, 1);
        };
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

    public fun nft_map(cert: &NftCertificate): &VecMap<ID, SizedVec<u64>> {
        &cert.nft_map
    }

    public fun inventory_type(cert: &NftCertificate): TypeName {
        cert.inventory_type
    }

    // TODO: Should this not be protected?
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

    public fun assert_called_from_inventory<IW: drop>(_witness: IW, certificate: &NftCertificate) {
        assert!(type_name::get<IW>() == certificate.inventory_type, EINVENTORY_ID_MISMATCH);
    }

    public fun assert_cert_buyer(cert: &NftCertificate, ctx: &TxContext) {
        assert!(cert.buyer == tx_context::sender(ctx), EBUYER_CERTIFICATE_MISMATCH);
    }

    // public fun assert_nft_type<T: key + store>(cert: &NftCert) {
    //     assert!(cert.nft_type == type_name::get<T>(), ENFT_TYPE_CERTIFICATE_MISMATCH);
    // }

    // === Test-Only Functions ===

    #[test_only]
    public fun consume_for_test(cert: NftCertificate) {
        let NftCertificate {
            id,
            venue_id: _,
            quantity: _,
            buyer: _,
            nft_map: _,
            inventory_type: _,
        } = cert;

        object::delete(id);

    }
}
