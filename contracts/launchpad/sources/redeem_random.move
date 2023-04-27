module ob_launchpad::redeem_random {
    use std::vector;

    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use originmate::pseudorandom;

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
}
