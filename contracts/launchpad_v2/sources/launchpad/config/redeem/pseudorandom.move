module ob_launchpad_v2::pseudorand_redeem {
    // TODO: Assigning Inventory and NFTs Indices should not touch the Venue, otherwise it creates contention...
    use std::vector;
    use sui::tx_context::TxContext;
    use sui::dynamic_field as df;
    use sui::vec_map;

    use ob_launchpad_v2::launchpad::LaunchCap;
    use ob_launchpad_v2::venue::{Self, Venue};
    use ob_launchpad_v2::certificate::{Self, NftCertificate};

    use ob_utils::sized_vec;

    use originmate::pseudorandom;

    const SCALE: u64 = 10_000;

    /// Attempted to construct a `RedeemCommitment` with a hash length
    /// different than 32 bytes
    const EINVALID_COMMITMENT_LENGTH: u64 = 4;

    struct PseudoRandRedeem has store {
        counter: u64,
    }

    struct Witness has drop {}

    struct PseudoRandInvDfKey has store, copy, drop {}
    struct PseudoRandNftDfKey has store, copy, drop {}

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
    ): PseudoRandRedeem {
        venue::assert_launch_cap(venue, launch_cap);

        PseudoRandRedeem { counter: 0 }
    }

    /// Issue a new `PseudoRandRedeem` and add it to the Venue as a dynamic field
    /// with field key `PseudoRandRedeemDfKey`.
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

        df::add(venue_uid, PseudoRandInvDfKey {}, rand_redeem);
    }

    /// Issue a new `PseudoRandRedeem` and add it to the Venue as a dynamic field
    /// with field key `PseudoRandRedeemDfKey`.
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

        df::add(venue_uid, PseudoRandNftDfKey {}, rand_redeem);
    }

    public fun assign_inventory(
        venue: &mut Venue,
        certificate: &mut NftCertificate,
        ctx: &mut TxContext,
    ) {
        // ASSERT: Type of Redeem policy for better error message
        // TODO: ASSERT Certificate and Venue match
        let rand_redeem = venue::get_df_mut<PseudoRandInvDfKey, PseudoRandRedeem>(
            venue, PseudoRandInvDfKey {}
        );

        // Get counter
        let counter = rand_redeem.counter;

        // Get NFT map
        let i = certificate::quantity(certificate);
        let nft_map = certificate::get_nft_map_mut_as_stock(Witness {}, venue, certificate);

        // Get inventory selection
        let inventories = venue::get_invetories_mut(Witness {}, venue);
        let selection = vec_map::size(inventories);

        while (i > 0) {
            // TODO: Use counter of `PseudoRandRedeem` as an additional nonce factor
            let nonce = vector::empty();
            vector::append(&mut nonce, sui::bcs::to_bytes(&counter));

            let contract_commitment = pseudorandom::rand_no_counter(nonce, ctx);

            let inv_index = select(selection, &contract_commitment);

            // TODO: WE SHOULD ONLY DECREMENT SUPPLY WHEN LIMITED
            let (inv_id, supply) = {
                let (inv_id, supply) = vec_map::get_entry_by_idx_mut(inventories, inv_index);
                *supply = *supply - 1;
                (*inv_id, *supply)
            };

            if (supply == 0) {
                vec_map::remove(inventories, &inv_id);
            };

            certificate::add_to_nft_map(nft_map, inv_id);

            counter = counter + 1;
            i = i - 1;
        };

        new_counter(
            venue::get_df_mut<PseudoRandInvDfKey, PseudoRandRedeem>(
                venue, PseudoRandInvDfKey {}),
            counter
        );
    }

    /// Pseudo-randomly redeems NFT from `Warehouse`
    ///
    /// Endpoint is susceptible to validator prediction of the resulting index,
    /// use `random_redeem_nft` instead.
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
        ctx: &mut TxContext,
    ) {
        let rand_redeem = venue::get_df_mut<PseudoRandNftDfKey, PseudoRandRedeem>(
            venue, PseudoRandNftDfKey {}
        );

        // Get counter
        let counter = rand_redeem.counter;

        // Get NFT Map and Inventory selection
        let nft_map = certificate::get_nft_map_mut_as_redeem(Witness {}, venue, certificate);

        let inv_ids = vec_map::keys(nft_map);
        let inv_selection = vector::length(&inv_ids);

        while (inv_selection > 0) {
            let inv_id = vector::pop_back(&mut inv_ids);
            let sized_vec = vec_map::get_mut(nft_map, &inv_id);
            let slack = sized_vec::slack(sized_vec);

            while (slack != 0) {
                let nonce = vector::empty();
                vector::append(&mut nonce, sui::bcs::to_bytes(&counter));

                let contract_commitment = pseudorandom::rand_no_counter(nonce, ctx);

                let nft_index = select(SCALE, &contract_commitment);
                sized_vec::push_back(sized_vec, nft_index);

                counter = counter + 1;
                slack = slack - 1;
            };

            inv_selection = inv_selection - 1;
        };

        new_counter(
            venue::get_df_mut<PseudoRandNftDfKey, PseudoRandRedeem>(
                venue, PseudoRandNftDfKey {}),
            counter
        );
    }

    // === Utils ===

    /// Outputs modulo of a random `u256` number and a bound
    ///
    /// Due to `random >> bound` we `select` does not exhibit significant
    /// modulo bias.
    fun select(bound: u64, random: &vector<u8>): u64 {
        let random = pseudorandom::u256_from_bytes(random);
        let mod  = random % (bound as u256);
        (mod as u64)
    }

    fun new_counter(counter: &mut PseudoRandRedeem, new_counter: u64) {
        counter.counter = new_counter;
    }
}
