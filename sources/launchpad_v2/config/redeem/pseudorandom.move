module nft_protocol::pseudorand_redeem {
    use std::vector;
    use std::option::{Self, Option};
    use sui::clock::{Self, Clock};
    use sui::transfer;
    use sui::vec_set;
    use std::type_name::{Self, TypeName};
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID, ID};
    use sui::dynamic_field as df;

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::launchpad_v2::{Self, LaunchCap};
    use nft_protocol::venue_request::{Self, VenueRequest, VenuePolicyCap, VenuePolicy};
    use nft_protocol::venue_v2::{Self, Venue};

    use originmate::pseudorandom;

    /// Attempted to construct a `RedeemCommitment` with a hash length
    /// different than 32 bytes
    const EINVALID_COMMITMENT_LENGTH: u64 = 4;

    struct PseudoRandRedeem has store {
        nft_precision: u64,
        safe_precision: u64,
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
        safe_precision: u64,
    ): PseudoRandRedeem {
        venue_v2::assert_launch_cap(venue, launch_cap);

        PseudoRandRedeem { nft_precision, safe_precision }
    }

    /// Issue a new `Pubkey` and add it to the Venue as a dynamic field
    /// with field key `PubkeyDfKey`.
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
        let pubkey = new(launch_cap, venue, nft_precision, safe_precision);
        let venue_uid = venue_v2::uid_mut(venue, launch_cap);

        df::add(venue_uid, PseudoRandRedeemDfKey {}, pubkey);
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
    public fun redeem_pseudorandom_cert<T: key + store>(
        warehouse: &mut Warehouse<T>,
        ctx: &mut TxContext,
    ): T {
        let supply = supply(warehouse);
        assert!(supply != 0, EEMPTY);

        // Use supply of `Warehouse` as an additional nonce factor
        let nonce = vector::empty();
        vector::append(&mut nonce, sui::bcs::to_bytes(&supply));

        let contract_commitment = pseudorandom::rand_no_counter(nonce, ctx);

        let index = select(supply, &contract_commitment);
        redeem_nft_at_index(warehouse, index)
    }

}
