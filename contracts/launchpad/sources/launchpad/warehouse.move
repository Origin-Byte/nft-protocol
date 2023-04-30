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
module ob_launchpad::warehouse {
    use std::vector;

    use sui::transfer;
    use sui::dynamic_field as df;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, ID , UID};

    use originmate::pseudorandom;

    /// Limit of NFTs held within each ID chunk
    const LIMIT: u64 = 7998;

    /// `Warehouse` does not have NFTs left to withdraw
    ///
    /// Call `warehouse::deposit_nft` or `listing::add_nft` to add NFTs.
    const EEmpty: u64 = 1;

    /// `Warehouse` still has NFTs left to withdraw
    ///
    /// Call `warehouse::redeem_nft` or a `Listing` market to withdraw remaining
    /// NFTs.
    const ENotEmpty: u64 = 2;

    /// `Warehouse` does not have NFT at specified index
    ///
    /// Call `warehouse::redeem_nft_at_index` with an index that exists.
    const EIndexOutOfBounds: u64 = 3;

    /// `Warehouse` did not contain NFT object with given ID
    ///
    /// Call `warehouse::redeem_nft_with_id` with an ID that exists.
    const EInvalidNftId: u64 = 4;

    /// Attempted to construct a `RedeemCommitment` with a hash length
    /// different than 32 bytes
    const EInvalidCommitmentLength: u64 = 5;

    /// Commitment in `RedeemCommitment` did not match original value committed
    ///
    /// Call `warehouse::random_redeem_nft` with the correct commitment.
    const EInvalidCommitment: u64 = 6;

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

    /// `Warehouse` object which stores NFTs of type `T`
    ///
    /// The reason that the type is limited is to easily support random
    /// withdrawals. If multiple types are allowed then user will not be able
    /// to predict the type of the object they withdraw.
    struct Warehouse<phantom T: key + store> has key, store {
        /// `Warehouse` ID
        id: UID,
        /// Current supply of NFTs within warehouse
        supply: u64,
        // By subtracting `warehouse.total_deposited` to the length of `warehouse.nfts`
        // one can get total redeemed
        total_deposited: u64,
        /// Initial vector of NFT IDs stored within `Warehouse`
        ///
        /// If this vector is overflowed, additional NFT IDs will be stored
        /// within dynamic fields. Avoids overhead of dynamic fields for most
        /// use-cases.
        nfts: vector<ID>,
    }

    /// Create a new `Warehouse`
    public fun new<T: key + store>(ctx: &mut TxContext): Warehouse<T> {
        Warehouse {
            id: object::new(ctx),
            supply: 0,
            total_deposited: 0,
            nfts: vector::empty(),
        }
    }

    /// Creates a `Warehouse` and transfers to transaction sender
    public fun create_warehouse<T: key + store>(ctx: &mut TxContext): ID {
        let warehouse = new<T>(ctx);
        let warehouse_id = object::id(&warehouse);
        transfer::public_transfer(warehouse, tx_context::sender(ctx));
        warehouse_id
    }

    /// Creates a `Warehouse` and transfers to transaction sender
    public entry fun init_warehouse<T: key + store>(ctx: &mut TxContext) {
        create_warehouse<T>(ctx);
    }

    /// Deposits NFT to `Warehouse`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    public entry fun deposit_nft<T: key + store>(
        warehouse: &mut Warehouse<T>,
        nft: T,
    ) {
        let nft_id = object::id(&nft);

        let (chunk_idx, _) = chunk_index(warehouse.supply);
        if (has_chunk(warehouse, chunk_idx)) {
            let chunk = borrow_chunk_mut(warehouse, chunk_idx);
            vector::push_back(chunk, nft_id);
        } else {
            insert_chunk(warehouse, chunk_idx, nft_id);
        };

        warehouse.supply = warehouse.supply + 1;
        warehouse.total_deposited = warehouse.total_deposited + 1;

        df::add(&mut warehouse.id, nft_id, nft);
    }

    /// Redeems NFT from `Warehouse` sequentially
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is empty.
    public fun redeem_nft<T: key + store>(
        warehouse: &mut Warehouse<T>,
    ): T {
        assert!(warehouse.supply > 0, EEmpty);

        let (chunk_idx, idx) = chunk_index(warehouse.supply - 1);
        let nft_id = if (idx > 0) {
            let chunk = borrow_chunk_mut(warehouse, chunk_idx);
            vector::pop_back(chunk)
        } else {
            remove_chunk(warehouse, chunk_idx)
        };

        warehouse.supply = warehouse.supply - 1;

        df::remove(&mut warehouse.id, nft_id)
    }

    /// Redeems NFT from `Warehouse` sequentially and transfers to sender
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
    public entry fun redeem_nft_and_transfer<T: key + store>(
        warehouse: &mut Warehouse<T>,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_nft(warehouse);
        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

    /// Redeems NFT from specific index in `Warehouse`
    ///
    /// Does not retain original order of NFTs in the bookkeeping vector.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    ///
    /// #### Panics
    ///
    /// Panics if index does not exist in `Warehouse`.
    public fun redeem_nft_at_index<T: key + store>(
        warehouse: &mut Warehouse<T>,
        index: u64,
    ): T {
        assert!(warehouse.supply > 0, EEmpty);
        assert!(index < warehouse.supply, EIndexOutOfBounds);

        let (chunk_idx_remove, idx_remove) = chunk_index(index);
        let (chunk_idx_last, idx_last) = chunk_index(warehouse.supply - 1);

        let chunk_last = borrow_chunk_mut(warehouse, chunk_idx_last);

        let nft_id = if (chunk_idx_remove == chunk_idx_last) {
            // If the chunk to remove from is the last chunk
            // - Perform swap remove
            // - Cleanup last chunk if it is now empty
            if (idx_last > 0) {
                vector::swap_remove(chunk_last, idx_remove)
            } else {
                remove_chunk(warehouse, chunk_idx_last)
            }
        } else {
            // If the chunk to remove from is not the last chunk
            // - Perform swap remove in remove chunk
            // - Pop ID from last chunk and push to remove chunk
            // - Cleanup last chunk if now empty
            let id_last = if (idx_last > 0) {
                vector::pop_back(chunk_last)
            } else {
                remove_chunk(warehouse, chunk_idx_last)
            };

            let chunk_remove = borrow_chunk_mut(warehouse, chunk_idx_remove);
            let id_remove = vector::swap_remove(chunk_remove, idx_remove);
            vector::push_back(chunk_remove, id_last);

            id_remove
        };

        warehouse.supply = warehouse.supply - 1;

        df::remove(&mut warehouse.id, nft_id)
    }

    /// Redeems NFT from specific index in `Warehouse` and transfers to sender
    ///
    /// See `redeem_nft_at_index` for more details.
    ///
    /// #### Panics
    ///
    /// Panics if index does not exist in `Warehouse`.
    public entry fun redeem_nft_at_index_and_transfer<T: key + store>(
        warehouse: &mut Warehouse<T>,
        index: u64,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_nft_at_index(warehouse, index);
        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

    /// Redeems NFT with specific ID from `Warehouse`
    ///
    /// Does not retain original order of NFTs in the bookkeeping vector.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    ///
    /// #### Panics
    ///
    /// Panics if NFT with ID does not exist in `Warehouse`.
    public fun redeem_nft_with_id<T: key + store>(
        warehouse: &mut Warehouse<T>,
        nft_id: ID,
    ): T {
        let idx = idx_with_id(warehouse, &nft_id);
        redeem_nft_at_index(warehouse, idx)
    }

    /// Redeems NFT from specific index in `Warehouse` and transfers to sender
    ///
    /// See `redeem_nft_with_id` for more details.
    ///
    /// #### Panics
    ///
    /// Panics if index does not exist in `Warehouse`.
    public entry fun redeem_nft_with_id_and_transfer<T: key + store>(
        warehouse: &mut Warehouse<T>,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_nft_with_id(warehouse, nft_id);
        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

    /// Pseudo-randomly redeems NFT from `Warehouse`
    ///
    /// Endpoint is susceptible to validator prediction of the resulting index,
    /// use `random_redeem_nft` instead.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is empty
    public fun redeem_pseudorandom_nft<T: key + store>(
        warehouse: &mut Warehouse<T>,
        ctx: &mut TxContext,
    ): T {
        let supply = supply(warehouse);
        assert!(supply != 0, EEmpty);

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
    public entry fun redeem_pseudorandom_nft_and_transfer<T: key + store>(
        warehouse: &mut Warehouse<T>,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_pseudorandom_nft(warehouse, ctx);
        transfer::public_transfer(nft, tx_context::sender(ctx));
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
    /// #### Panics
    ///
    /// Panics if `Warehouse` is empty or `user_commitment` does not match the
    /// hashed commitment in `RedeemCommitment`.
    public fun redeem_random_nft<T: key + store>(
        warehouse: &mut Warehouse<T>,
        commitment: RedeemCommitment,
        user_commitment: vector<u8>,
        ctx: &mut TxContext,
    ): T {
        let supply = supply(warehouse);
        assert!(supply != 0, EEmpty);

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
    public entry fun redeem_random_nft_and_transfer<T: key + store>(
        warehouse: &mut Warehouse<T>,
        commitment: RedeemCommitment,
        user_commitment: vector<u8>,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_random_nft(
            warehouse, commitment, user_commitment, ctx,
        );
        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

    /// Destroys `Warehouse`
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is not empty
    public entry fun destroy<T: key + store>(warehouse: Warehouse<T>) {
        assert_is_empty(&warehouse);
        let Warehouse { id, supply: _, total_deposited: _, nfts: _ } = warehouse;
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
    public fun supply<T: key + store>(warehouse: &Warehouse<T>): u64 {
        warehouse.supply
    }

    /// Return whether there are any `Nft` in the `Warehouse`
    public fun is_empty<T: key + store>(warehouse: &Warehouse<T>): bool {
        warehouse.supply == 0
    }

    /// Returns list of NFTs held statically within `Warehouse`
    ///
    /// In order to support depositing large amounts of NFTs within `Warehouse`
    /// the vector of NFTs is dynamically extended when the static vector
    /// overflows. In order to query any NFTs that might be deposited within
    /// dynamic vectors call `borrow_chunk`.
    public fun nfts<T: key + store>(warehouse: &Warehouse<T>): &vector<ID> {
        &warehouse.nfts
    }

    /// Return cumulated amount of `Nft`s deposited in the `Warehouse`
    public fun total_deposited<T: key + store>(warehouse: &Warehouse<T>): u64 {
        warehouse.total_deposited
    }

    /// Return cumulated amount of `Nft`s redeemed in the `Warehouse`
    public fun total_redeemed<T: key + store>(warehouse: &Warehouse<T>): u64 {
        warehouse.total_deposited - supply(warehouse)
    }

    /// Get index of NFT given ID
    ///
    /// #### Panics
    ///
    /// Panics if NFT was not registered in `Warehouse`.
    public fun idx_with_id<T: key + store>(
        warehouse: &mut Warehouse<T>,
        nft_id: &ID,
    ): u64 {
        let supply = warehouse.supply;
        assert!(supply > 0, EEmpty);

        let idx = 0;
        while (idx < supply) {
            let _idx = 0;
            let (chunk_idx, _) = chunk_index(idx);
            let chunk = borrow_chunk(warehouse, chunk_idx);
            let length = vector::length(chunk);
            while (_idx < length) {
                let t_nft_id = vector::borrow(chunk, _idx);

                if (t_nft_id == nft_id) {
                    return idx
                };

                idx = idx + 1;
                _idx = _idx + 1;
            };
        };

        abort(EInvalidNftId)
    }

    // === Assertions ===

    /// Asserts that `Warehouse` is empty
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` has elements.
    public fun assert_is_empty<T: key + store>(warehouse: &Warehouse<T>) {
        assert!(is_empty(warehouse), ENotEmpty);
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

    /// Outputs chunk index and NFT index within that chunk
    fun chunk_index(idx: u64): (u64, u64) {
        let chunk_idx = idx / LIMIT;
        let _idx = idx % LIMIT;

        (chunk_idx, _idx)
    }

    // === Chunks ===

    /// Check whether chunk exists
    public fun has_chunk<T: key + store>(
        warehouse: &Warehouse<T>,
        chunk_idx: u64,
    ): bool {
        if (chunk_idx == 0) {
            true
        } else {
            df::exists_(&warehouse.id, chunk_idx)
        }
    }

    /// Borrow chunk of NFT IDs
    public fun borrow_chunk<T: key + store>(
        warehouse: & Warehouse<T>,
        chunk_idx: u64,
    ): &vector<ID> {
        if (chunk_idx == 0) {
            &warehouse.nfts
        } else {
            df::borrow(&warehouse.id, chunk_idx)
        }
    }

    /// Borrow chunk of NFT IDs
    fun borrow_chunk_mut<T: key + store>(
        warehouse: &mut Warehouse<T>,
        chunk_idx: u64,
    ): &mut vector<ID> {
        if (chunk_idx == 0) {
            &mut warehouse.nfts
        } else {
            df::borrow_mut(&mut warehouse.id, chunk_idx)
        }
    }

    /// Insert new chunk
    fun insert_chunk<T: key + store>(
        warehouse: &mut Warehouse<T>,
        chunk_idx: u64,
        id: ID,
    ) {
        let chunk = vector::singleton(id);
        df::add(&mut warehouse.id, chunk_idx, chunk)
    }

    /// Remove chunk
    ///
    /// #### Panics
    ///
    /// Panics if it had more than one element left
    fun remove_chunk<T: key + store>(
        warehouse: &mut Warehouse<T>,
        chunk_idx: u64,
    ): ID {
        if (chunk_idx == 0) {
            vector::pop_back(&mut warehouse.nfts)
        } else {
            let chunk = df::remove(&mut warehouse.id, chunk_idx);
            let nft_id = vector::pop_back(&mut chunk);
            vector::destroy_empty(chunk);
            nft_id
        }
    }
}
