module launchpad_v2::pseudorand_redeem {
    use std::vector;
    use std::type_name::TypeName;
    use sui::tx_context::TxContext;
    use sui::object::ID;
    use sui::dynamic_field as df;

    use launchpad_v2::launchpad::LaunchCap;
    use launchpad_v2::venue::{Self, Venue, RedeemReceipt, NftCert};

    use originmate::pseudorandom;

    /// Attempted to construct a `RedeemCommitment` with a hash length
    /// different than 32 bytes
    const EINVALID_COMMITMENT_LENGTH: u64 = 4;

    struct PseudoRandRedeem has store {
        nft_precision: u64,
        kiosk_precision: u64,
        counter: u64,
    }

    struct PseudoRandRedeemDfKey has store, copy, drop {}

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
        nft_precision: u64,
        kiosk_precision: u64,
    ): PseudoRandRedeem {
        venue::assert_launch_cap(venue, launch_cap);

        PseudoRandRedeem { nft_precision, kiosk_precision, counter: 0 }
    }

    /// Issue a new `PseudoRandRedeem` and add it to the Venue as a dynamic field
    /// with field key `PseudoRandRedeemDfKey`.
    ///
    /// Can be used by owner to participate in the provided market.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not `Listing` admin
    public entry fun add_pseudorand_redeem(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        nft_precision: u64,
        safe_precision: u64,
    ) {
        let rand_redeem = new(launch_cap, venue, nft_precision, safe_precision);
        let venue_uid = venue::uid_mut(venue, launch_cap);

        df::add(venue_uid, PseudoRandRedeemDfKey {}, rand_redeem);
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
    public fun redeem_pseudorandom_cert<T>(
        venue: &mut Venue,
        receipt: RedeemReceipt,
        ctx: &mut TxContext,
    ): NftCert {
        // TODO: Assert Receipt Venue matches Venue
        venue::consume_receipt(receipt);

        let rand_redeem = venue::get_df<PseudoRandRedeemDfKey, PseudoRandRedeem>(
            venue, PseudoRandRedeemDfKey {}
        );
        // TO add back
        // let supply = supply(warehouse);
        // assert!(supply != 0, EEMPTY);

        // Use supply of `Warehouse` as an additional nonce factor
        let nonce = vector::empty();
        vector::append(&mut nonce, sui::bcs::to_bytes(&rand_redeem.counter));

        let contract_commitment = pseudorandom::rand_no_counter(nonce, ctx);

        let inv_index = select(rand_redeem.kiosk_precision, &contract_commitment);
        let nft_rel_index = select(rand_redeem.nft_precision, &contract_commitment);

        let (inv_id, inv_type) = get_inventory_data(venue, inv_index);

        venue::get_certificate(
            venue,
            inv_type,
            inv_id,
            rand_redeem.nft_precision,
            nft_rel_index,
            ctx,
        )
    }

    public fun get_inventory_data(
        venue: &Venue,
        index: u64,
    ): (ID, TypeName) {
        venue::get_inventory_data(venue, index)
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

}
