module launchpad_v2::pseudorand_redeem {
    // TODO: Assigning Inventory and NFTs Indices should not touch the Venue, otherwise it creates contention...
    use std::vector;
    use sui::tx_context::TxContext;
    use sui::dynamic_field as df;
    use sui::vec_map;

    use launchpad_v2::launchpad::LaunchCap;
    use launchpad_v2::venue::{Self, Venue};
    use launchpad_v2::certificate::{Self, NftCertificate};


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
    public entry fun add_pseudorand_inv(
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
    public entry fun add_pseudorand_nft(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
    ) {
        let rand_redeem = new(launch_cap, venue);
        let venue_uid = venue::uid_mut(venue, launch_cap);

        df::add(venue_uid, PseudoRandInvDfKey {}, rand_redeem);
    }

    public fun assign_inventory(
        venue: &mut Venue,
        certificate: &mut NftCertificate,
        ctx: &mut TxContext,
    ) {
        // TODO: ASSERT Certificate and Venue match
        let rand_redeem = venue::get_df_mut<PseudoRandInvDfKey, PseudoRandRedeem>(
            venue, PseudoRandInvDfKey {}
        );

        let i = certificate::quantity(certificate);

        let inventories = venue::get_invetories_mut(Witness {}, venue);
        let qty = vec_map::size(inventories);

        let cert_inventories = certificate::invetories_mut(Witness {}, venue, certificate);

        while (i > 0) {
            // TODO: Use counter of `PseudoRandRedeem` as an additional nonce factor
            let nonce = vector::empty();
            vector::append(&mut nonce, sui::bcs::to_bytes(&rand_redeem.counter));

            let contract_commitment = pseudorandom::rand_no_counter(nonce, ctx);

            let inv_index = select(qty, &contract_commitment);

            // TODO: WE SHOULD ONLY DECREMENT SUPPLY WHEN LIMITED
            let (inv_id, supply) = vec_map::get_entry_by_idx_mut(inventories, inv_index);

            if (*supply == 1) {
                // Remove inventory form the list since supply is exhausted
                vec_map::remove(inventories, inv_id);
            } else {
                // Decrement supply
                *supply = *supply - 1;
            };

            increment_counter(rand_redeem);
            vector::push_back(cert_inventories, *inv_id);

            i = i - 1;
        }
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
        ctx: &mut TxContext,
    ) {

        let rand_redeem = venue::get_df_mut<PseudoRandNftDfKey, PseudoRandRedeem>(
            venue, PseudoRandNftDfKey {}
        );

        let i = certificate::quantity(certificate);
        let inventories = venue::get_invetories_mut(Witness {}, venue);

        let cert_nft_indices = certificate::nft_mut(Witness {}, venue, certificate);

        while (i > 0) {
            // Use supply of `Warehouse` as an additional nonce factor
            let nonce = vector::empty();
            vector::append(&mut nonce, sui::bcs::to_bytes(&rand_redeem.counter));

            let contract_commitment = pseudorandom::rand_no_counter(nonce, ctx);

            let nft_index = select(SCALE, &contract_commitment);

            increment_counter(rand_redeem);
            vector::push_back(cert_nft_indices, nft_index);

            i = i - 1;
        }
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

    fun increment_counter(counter: &mut PseudoRandRedeem) {
        counter.counter = counter.counter + 1;
    }

}
