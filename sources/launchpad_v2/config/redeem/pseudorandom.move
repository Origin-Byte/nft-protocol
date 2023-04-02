module nft_protocol::pseudorand_redeem {
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

    struct PseudoRandRedeem has store {
        nft_precision: u64,
        safe_precision: u64,
    }

    /// Used for the client to commit a pseudo-random
    struct RedeemCommitment has key {
        /// `RedeemCommitment` ID
        id: UID,
        /// Hashed sender commitment
        ///
        /// Sender will have to provide the pre-hashed value to be able to use
        /// this `RedeemCommitment`. This value can be pseudo-random as long
        /// as it is not predictable by the validator.
        hashed_sender_commitment: vector<u8>,
        /// Open commitment made by validator
        contract_commitment: vector<u8>,
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

    /// Create a new `RedeemCommitment`
    ///
    /// Contract commitment must be unfeasible to predict by the transaction
    /// sender. The underlying value of the commitment can be pseudo-random as
    /// long as it is not predictable by the validator.
    ///
    /// #### Panics
    ///
    /// Panics if commitment is not 32 bytes.
    public fun new_redeem_commitment(
        hashed_sender_commitment: vector<u8>,
        ctx: &mut TxContext,
    ): RedeemCommitment {
        assert!(
            vector::length(&hashed_sender_commitment) != 32,
            EINVALID_COMMITMENT_LENGTH,
        );

        RedeemCommitment {
            id: object::new(ctx),
            hashed_sender_commitment,
            contract_commitment: pseudorandom::rand_with_ctx(ctx),
        }
    }
}
