/// Module representing the NFT bookkeeping `Warehouse` type
///
/// `Warehouse` is an unprotected object used to store pre-minted NFTs for
/// later withdrawal in a `Venue`. Additionally, it provides two randomized
/// withdrawal mechanisms, a pseudo-random withdrawal, or a hidden commitment
/// scheme.
///
/// `Warehouse` is an unprotected type that can be constructed independently
/// before it is merged to a `Venue`, allowing `Warehouse` to be constructed
/// while avoiding shared consensus transactions on `Listing`.
module nft_protocol::warehouse {
    use std::vector;

    use sui::transfer;
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, ID , UID};

    use originmate::pseudorandom;

    use nft_protocol::nft::Nft;

    /// `Warehouse` does not have NFTs left to withdraw
    ///
    /// Call `Warehouse::deposit_nft` or `Listing::add_nft` to add NFTs.
    const EEMPTY: u64 = 1;

    /// `Warehouse` still has NFTs left to withdraw
    ///
    /// Call `Warehouse::redeem_nft` or a `Listing` market to withdraw remaining
    /// NFTs.
    const ENOT_EMPTY: u64 = 2;

    /// `Warehouse` does not have NFT at specified index
    ///
    /// Call `Warehouse::redeem_nft_at_index` with an index that exists.
    const EINDEX_OUT_OF_BOUNDS: u64 = 3;

    /// Attempted to construct a `RedeemCommitment` with a hash length
    /// different than 32 bytes
    const EINVALID_COMMITMENT_LENGTH: u64 = 4;

    /// Commitment in `RedeemCommitment` did not match original value committed
    ///
    /// Call `Warehosue::random_redeem_nft` with the correct commitment.
    const EINVALID_COMMITMENT: u64 = 5;

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

    /// `Warehouse` object
    struct Warehouse<phantom C> has key, store {
        /// `Warehouse` ID
        id: UID,
        /// NFTs that are currently on sale
        nfts: vector<ID>,
        // By subtracting `warehouse.total_deposited` to the length of `warehouse.nfts`
        // one can get total redeemed
        total_deposited: u64,
    }

    /// Create a new `Warehouse`
    public fun new<C>(ctx: &mut TxContext): Warehouse<C> {
        Warehouse {
            id: object::new(ctx),
            nfts: vector::empty(),
            total_deposited: 0,
        }
    }

    /// Creates a `Warehouse` and transfers to transaction sender
    public entry fun init_warehouse<C>(ctx: &mut TxContext) {
        transfer::transfer(new<C>(ctx), tx_context::sender(ctx));
    }

    /// Deposits NFT to `Warehouse`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    public entry fun deposit_nft<C>(
        warehouse: &mut Warehouse<C>,
        nft: Nft<C>,
    ) {
        let nft_id = object::id(&nft);
        vector::push_back(&mut warehouse.nfts, nft_id);
        warehouse.total_deposited = warehouse.total_deposited + 1;

        dof::add(&mut warehouse.id, nft_id, nft);
    }

    /// Redeems NFT from `Warehouse`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    ///
    /// `Warehouse` may not change the logical owner of an `Nft` when
    /// redeeming as this would allow royalties to be trivially bypassed.
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is empty.
    public fun redeem_nft<C>(
        warehouse: &mut Warehouse<C>,
    ): Nft<C> {
        let nfts = &mut warehouse.nfts;
        assert!(!vector::is_empty(nfts), EEMPTY);

        dof::remove(&mut warehouse.id, vector::pop_back(nfts))
    }

    /// Redeems NFT from `Warehouse` and transfers to sender
    ///
    /// See `redeem_nft` for more details.
    ///
    /// #### Usage
    ///
    /// Entry mint functions like `suimarines::mint_nft` take an `Warehouse`
    /// object to deposit into. Calling `redeem_nft_and_transfer` allows one to
    /// withdraw an NFT and own it directly.
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is empty.
    public entry fun redeem_nft_and_transfer<C>(
        warehouse: &mut Warehouse<C>,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_nft(warehouse);
        transfer::transfer(nft, tx_context::sender(ctx));
    }

    /// Redeems NFT from specific index in `Warehouse`
    ///
    /// Does not retain original order of NFTs in the bookkeeping vector.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    ///
    /// `Warehouse` may not change the logical owner of an `Nft` when
    /// redeeming as this would allow royalties to be trivially bypassed.
    ///
    /// #### Panics
    ///
    /// Panics if index does not exist in `Warehouse`.
    public fun redeem_nft_at_index<C>(
        warehouse: &mut Warehouse<C>,
        index: u64,
    ): Nft<C> {
        let nfts = &mut warehouse.nfts;
        let length = vector::length(nfts);
        assert!(index < vector::length(nfts), EINDEX_OUT_OF_BOUNDS);

        let nft_id = *vector::borrow(nfts, index);

        // Swap index to remove with last element avoids shifting entire vector
        // of NFTs.
        //
        // `length - 1` is guaranteed to always resolve correctly
        vector::swap(nfts, index, length - 1);
        vector::pop_back(nfts);

        dof::remove(&mut warehouse.id, nft_id)
    }

    /// Redeems NFT from specific index in `Warehouse` and transfers to sender
    ///
    /// See `redeem_nft_at_index` for more details.
    ///
    /// #### Panics
    ///
    /// Panics if index does not exist in `Warehouse`.
    public entry fun redeem_nft_at_index_and_transfer<C>(
        warehouse: &mut Warehouse<C>,
        index: u64,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_nft_at_index(warehouse, index);
        transfer::transfer(nft, tx_context::sender(ctx));
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
    public fun redeem_pseudorandom_nft<C>(
        warehouse: &mut Warehouse<C>,
        ctx: &mut TxContext,
    ): Nft<C> {
        let supply = supply(warehouse);

        // Use supply of `Warehouse` as an additional nonce factor
        let nonce = vector::empty();
        vector::append(&mut nonce, sui::bcs::to_bytes(&supply));

        let contract_commitment = pseudorandom::rand_no_counter(nonce, ctx);

        let index = select(supply, &contract_commitment);
        redeem_nft_at_index(warehouse, index)
    }

    /// Pseudo-randomly redeems specific NFT from `Warehouse` and transfers to
    /// sender
    ///
    /// See `redeem_pseudorandom_nft` for more details.
    ///
    /// #### Usage
    ///
    /// Entry mint functions like `suimarines::mint_nft` take an `Warehouse`
    /// object to deposit into. Calling `redeem_nft_and_transfer` allows one to
    /// withdraw an NFT and own it directly.
    public entry fun redeem_pseudorandom_nft_and_transfer<C>(
        warehouse: &mut Warehouse<C>,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_pseudorandom_nft(warehouse, ctx);
        transfer::transfer(nft, tx_context::sender(ctx));
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
    public entry fun init_redeem_commitment(
        hashed_sender_commitment: vector<u8>,
        ctx: &mut TxContext,
    ) {
        let commitment = new_redeem_commitment(hashed_sender_commitment,  ctx);
        transfer::transfer(commitment, tx_context::sender(ctx));
    }

    /// Randomly redeems NFT from `Warehouse`
    ///
    /// Requires a `RedeemCommitment` created by the user in a separate
    /// transaction to ensure that validators may not bias results favorably.
    /// You can obtain a `RedeemCommitment` by calling
    /// `init_redeem_commitment`.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    ///
    /// `Warehouse` may not change the logical owner of an `Nft` when
    /// redeeming as this would allow royalties to be trivially bypassed.
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is empty or `user_commitment` does not match the
    /// hashed commitment in `RedeemCommitment`.
    public fun redeem_random_nft<C>(
        warehouse: &mut Warehouse<C>,
        commitment: RedeemCommitment,
        user_commitment: vector<u8>,
        ctx: &mut TxContext,
    ): Nft<C> {
        let RedeemCommitment {
            id,
            hashed_sender_commitment,
            contract_commitment
        } = commitment;

        object::delete(id);

        // Verify user commitment
        let user_commitment = std::hash::sha3_256(user_commitment);
        assert!(
            user_commitment == hashed_sender_commitment,
            EINVALID_COMMITMENT,
        );

        // Construct randomized index
        let supply = supply(warehouse);

        vector::append(&mut user_commitment, contract_commitment);
        // Use supply of `Warehouse` as a additional nonce factor
        vector::append(&mut user_commitment, sui::bcs::to_bytes(&supply));

        let contract_commitment = pseudorandom::rand_no_counter(user_commitment, ctx);

        let index = select(supply, &contract_commitment);
        redeem_nft_at_index(warehouse, index)
    }

    /// Randomly redeems NFT from `Warehouse` and transfers to sender
    ///
    /// See `redeem_random_nft` for more details.
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is empty or `user_commitment` does not match the
    /// hashed commitment in `RedeemCommitment`.
    public entry fun redeem_random_nft_and_transfer<C>(
        warehouse: &mut Warehouse<C>,
        commitment: RedeemCommitment,
        user_commitment: vector<u8>,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_random_nft(
            warehouse, commitment, user_commitment, ctx,
        );
        transfer::transfer(nft, tx_context::sender(ctx));
    }

    /// Destroys `Warehouse`
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is not empty
    public entry fun destroy<C>(warehouse: Warehouse<C>) {
        assert_is_empty(&warehouse);
        let Warehouse { id, nfts: _, total_deposited: _ } = warehouse;
        object::delete(id);
    }

    /// Destroyes `RedeemCommitment`
    public entry fun destroy_commitment(commitment: RedeemCommitment) {
        let RedeemCommitment {
            id,
            hashed_sender_commitment: _,
            contract_commitment: _,
        } = commitment;

        object::delete(id);
    }

    // === Getter Functions ===

    /// Return how many `Nft` there are to sell
    public fun supply<C>(warehouse: &Warehouse<C>): u64 {
        vector::length(&warehouse.nfts)
    }

    /// Return whether there are any `Nft` in the `Warehouse`
    public fun is_empty<C>(warehouse: &Warehouse<C>): bool {
        vector::is_empty(&warehouse.nfts)
    }

    /// Returns list of all NFTs stored in `Warehouse`
    public fun nfts<C>(warehouse: &Warehouse<C>): &vector<ID> {
        &warehouse.nfts
    }

    /// Return cumulated amount of `Nft`s deposited in the `Warehouse`
    public fun total_deposited<C>(warehouse: &Warehouse<C>): u64 {
        warehouse.total_deposited
    }

    /// Return cumulated amount of `Nft`s redeemed in the `Warehouse`
    public fun total_redeemed<C>(warehouse: &Warehouse<C>): u64 {
        warehouse.total_deposited - vector::length(&warehouse.nfts)
    }

    // === Assertions ===

    /// Asserts that `Warehouse` is empty
    public fun assert_is_empty<C>(warehouse: &Warehouse<C>) {
        assert!(is_empty(warehouse), ENOT_EMPTY);
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
