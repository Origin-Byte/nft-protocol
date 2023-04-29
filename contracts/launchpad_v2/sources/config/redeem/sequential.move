module ob_launchpad_v2::sequential {
    use std::vector;
    // use std::string::utf8;
    // use std::debug;
    use sui::dynamic_field as df;
    use sui::vec_map;

    use ob_launchpad_v2::launchpad::LaunchCap;
    use ob_launchpad_v2::venue::{Self, Venue};
    use ob_launchpad_v2::certificate::{Self, NftCertificate};

    use ob_utils::sized_vec;

    struct FiFoRedeem has store {}

    struct Witness has drop {}

    struct FiFoInvDfKey has store, copy, drop {}
    struct FiFoNftDfKey has store, copy, drop {}

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
    ): FiFoRedeem {
        venue::assert_launch_cap(venue, launch_cap);

        FiFoRedeem { }
    }

    /// Issue a new `FiFoRedeem` and add it to the Venue as a dynamic field
    /// with field key `FiFoRedeemDfKey`.
    ///
    /// Can be used by owner to participate in the provided market.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not `Listing` admin
    public entry fun add_inventory_method(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
    ) {
        let rand_redeem = new(launch_cap, venue);
        let venue_uid = venue::uid_mut(venue, launch_cap);

        df::add(venue_uid, FiFoInvDfKey {}, rand_redeem);
    }

    /// Issue a new `FiFoRedeem` and add it to the Venue as a dynamic field
    /// with field key `FiFoRedeemDfKey`.
    ///
    /// Can be used by owner to participate in the provided market.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not `Listing` admin
    public entry fun add_nft_method(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
    ) {
        let rand_redeem = new(launch_cap, venue);
        let venue_uid = venue::uid_mut(venue, launch_cap);

        df::add(venue_uid, FiFoNftDfKey {}, rand_redeem);
    }

    public fun assign_inventory(
        venue: &mut Venue,
        certificate: &mut NftCertificate,
    ) {
        // TODO: ASSERT Certificate and Venue match

        // Get NFT map
        let i = certificate::quantity(certificate);
        let nft_map = certificate::get_nft_map_mut_as_stock(Witness {}, venue, certificate);

        // Get inventory selection
        let inventories = venue::get_invetories_mut(Witness {}, venue);

        while (i > 0) {
            // TODO: WE SHOULD ONLY DECREMENT SUPPLY WHEN LIMITED
            let (inv_id, supply) = {
                let (inv_id, supply) = vec_map::get_entry_by_idx_mut(inventories, 0);
                *supply = *supply - 1;
                (*inv_id, *supply)
            };

            if (supply == 0) {
                vec_map::remove(inventories, &inv_id);
            };

            certificate::add_to_nft_map(nft_map, inv_id);

            i = i - 1;
        };
    }

    /// Pseudo-randomly redeems NFT from `Warehouse`
    ///
    /// Endpoint is susceptible to validator prediction of the resulting index,
    /// use `random_redeem_nft` instead.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    ///
    /// `Warehouse` may not change the logical owner of an `Nft` when
    /// redeeming as this would allow royalties to be trivially bypassed.
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is empty
    public fun assign_nft(
        venue: &mut Venue,
        certificate: &mut NftCertificate,
    ) {
        // Get NFT Map and Inventory selection
        let nft_map = certificate::get_nft_map_mut_as_redeem(Witness {}, venue, certificate);

        let inv_ids = vec_map::keys(nft_map);
        let inv_selection = vector::length(&inv_ids);

        while (inv_selection > 0) {
            let inv_id = vector::pop_back(&mut inv_ids);
            let sized_vec = vec_map::get_mut(nft_map, &inv_id);
            let slack = sized_vec::slack(sized_vec);

            let index = 10_000;
            while (slack != 0) {
                let nft_index = index;
                sized_vec::push_back(sized_vec, nft_index);

                index = index - 1;
                slack = slack - 1;
            };

            inv_selection = inv_selection - 1;
        };
    }
}
