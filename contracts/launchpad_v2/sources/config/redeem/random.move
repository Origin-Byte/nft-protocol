module launchpad_v2::redeem_random {
    use std::vector;

    use sui::transfer;
    use sui::vec_map;
    use sui::dynamic_field as df;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use launchpad_v2::launchpad::LaunchCap;
    use launchpad_v2::venue::{Self, Venue, NftCertificate};

    use originmate::pseudorandom;

    const SCALE: u64 = 10_000;

    /// Attempted to construct a `RedeemCommitment` with a hash length
    /// different than 32 bytes
    const EInvalidCommitmentLength: u64 = 5;

    /// Commitment in `RedeemCommitment` did not match original value committed
    ///
    /// Call `warehouse::random_redeem_nft` with the correct commitment.
    const EInvalidCommitment: u64 = 6;

    /// Used for the client to commit a pseudo-random
    struct RedeemCommitment has key, store {
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

    struct RandRedeem has store {
        counter: u64,
    }

    struct Witness has drop {}

    struct RandInvDfKey has store, copy, drop {}
    struct RandNftDfKey has store, copy, drop {}

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
    ): RandRedeem {
        venue::assert_launch_cap(venue, launch_cap);

        RandRedeem { counter: 0 }
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

        df::add(venue_uid, RandInvDfKey {}, rand_redeem);
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

        df::add(venue_uid, RandInvDfKey {}, rand_redeem);
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
    public fun new_commitment(
        hashed_sender_commitment: vector<u8>,
        ctx: &mut TxContext,
    ): RedeemCommitment {
        assert!(
            vector::length(&hashed_sender_commitment) != 32,
            EInvalidCommitmentLength,
        );

        RedeemCommitment {
            id: object::new(ctx),
            hashed_sender_commitment,
            contract_commitment: pseudorandom::rand_with_ctx(ctx),
        }
    }

    /// Creates a new `RedeemCommitment` and transfers it to the transaction
    /// caller.
    ///
    /// Contract commitment must be unfeasible to predict by the transaction
    /// caller. The underlying value of the commitment can be pseudo-random as
    /// long as it is not predictable by the validator.
    ///
    /// #### Panics
    ///
    /// Panics if commitment is not 32 bytes.
    public entry fun init_commitment(
        hashed_sender_commitment: vector<u8>,
        ctx: &mut TxContext,
    ) {
        let commitment = new_commitment(hashed_sender_commitment,  ctx);
        transfer::transfer(commitment, tx_context::sender(ctx));
    }

    /// Consumes `RedeemCommitment`
    ///
    /// #### Panics
    ///
    /// Panics if `user_commitment` does not match the hashed commitment in
    /// `RedeemCommitment`.
    public fun consume_commitment(
        commitment: RedeemCommitment,
        user_commitment: vector<u8>,
    ): (vector<u8>, vector<u8>) {
        // Verify user commitment
        let RedeemCommitment {
            id,
            hashed_sender_commitment,
            contract_commitment
        } = commitment;

        object::delete(id);

        let user_commitment = std::hash::sha3_256(user_commitment);
        assert!(
            user_commitment == hashed_sender_commitment,
            EInvalidCommitment,
        );

        (hashed_sender_commitment, contract_commitment)
    }

    /// Deletes `RedeemCommitment`
    public entry fun delete_commitment(commitment: RedeemCommitment) {
        let RedeemCommitment {
            id,
            hashed_sender_commitment: _,
            contract_commitment: _,
        } = commitment;

        object::delete(id);
    }

    public fun assign_inventory(
        venue: &mut Venue,
        certificate: &mut NftCertificate,
        commitment: RedeemCommitment,
        user_commitment: vector<u8>,
        ctx: &mut TxContext,
    ) {
        // TODO: ASSERT Certificate and Venue match
        let rand_redeem = venue::get_df_mut<RandInvDfKey, RandRedeem>(
            venue, RandInvDfKey {}
        );

        // Construct commitment

        // Verify user commitment
        let RedeemCommitment {
            id,
            hashed_sender_commitment,
            contract_commitment
        } = commitment;

        object::delete(id);

        let user_commitment = std::hash::sha3_256(user_commitment);
        assert!(
            user_commitment == hashed_sender_commitment,
            EInvalidCommitment,
        );

        // Construct randomized index
        vector::append(&mut user_commitment, contract_commitment);

        let i = venue::cert_quantity(certificate);
        let inventories = venue::get_invetories_mut(Witness {}, venue);
        let qty = vec_map::size(inventories);

        while (i > 0) {
            // Use supply of `Warehouse` as a additional nonce factor
            vector::append(&mut user_commitment, sui::bcs::to_bytes(&rand_redeem.counter));

            let contract_commitment = pseudorandom::rand_no_counter(user_commitment, ctx);

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
            venue::push_inventory_id(Witness {}, venue, certificate, *inv_id);

            i = i - 1;
        };
    }

    public fun assign_nft(
        venue: &mut Venue,
        certificate: &mut NftCertificate,
        commitment: RedeemCommitment,
        user_commitment: vector<u8>,
        ctx: &mut TxContext,
    ) {
        // TODO: ASSERT Certificate and Venue match
        let rand_redeem = venue::get_df_mut<RandInvDfKey, RandRedeem>(
            venue, RandInvDfKey {}
        );

        // Construct commitment

        // Verify user commitment
        let RedeemCommitment {
            id,
            hashed_sender_commitment,
            contract_commitment
        } = commitment;

        object::delete(id);

        let user_commitment = std::hash::sha3_256(user_commitment);
        assert!(
            user_commitment == hashed_sender_commitment,
            EInvalidCommitment,
        );

        // Construct randomized index
        vector::append(&mut user_commitment, contract_commitment);

        let i = venue::cert_quantity(certificate);
        let inventories = venue::get_invetories_mut(Witness {}, venue);
        let qty = vec_map::size(inventories);

        while (i > 0) {
            // Use supply of `Warehouse` as a additional nonce factor
            vector::append(&mut user_commitment, sui::bcs::to_bytes(&rand_redeem.counter));

            let contract_commitment = pseudorandom::rand_no_counter(user_commitment, ctx);

            let nft_index = select(SCALE, &contract_commitment);

            increment_counter(rand_redeem);
            venue::push_nft_index(Witness {}, venue, certificate, nft_index);

            i = i - 1;
        };
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

    fun increment_counter(counter: &mut RandRedeem) {
        counter.counter = counter.counter + 1;
    }
}
