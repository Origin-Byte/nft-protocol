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
module launchpad_v2::warehouse {
    use std::vector;

    use sui::transfer;
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, ID , UID};

    use nft_protocol::redeem_random::{Self, RedeemCommitment};

    use launchpad_v2::venue::{Self, NftCert};
    use launchpad_v2::redeem_strategy;

    use originmate::pseudorandom;

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
    const EInvalidNft: u64 = 4;

    const EUnsupportedRedeemStrategy: u64 = 5;

    struct Witness has drop {}

    /// `Warehouse` object which stores NFTs of type `T`
    ///
    /// The reason that the type is limited is to easily support random
    /// withdrawals. If multiple types are allowed then user will not be able
    /// to predict the type of the object they withdraw.
    struct Warehouse has key, store {
        /// `Warehouse` ID
        id: UID,
        /// NFTs that are currently on sale
        nfts: vector<ID>,
        // By subtracting `warehouse.total_deposited` to the length of `warehouse.nfts`
        // one can get total redeemed
        total_deposited: u64,
    }

    /// Create a new `Warehouse`
    public fun new(ctx: &mut TxContext): Warehouse {
        Warehouse {
            id: object::new(ctx),
            nfts: vector::empty(),
            total_deposited: 0,
        }
    }

    /// Creates a `Warehouse` and transfers to transaction sender
    public entry fun init_warehouse(ctx: &mut TxContext) {
        transfer::public_transfer(new(ctx), tx_context::sender(ctx));
    }

    /// Deposits NFT to `Warehouse`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    public entry fun deposit_nft<T: key + store>(
        warehouse: &mut Warehouse,
        nft: T,
    ) {
        let nft_id = object::id(&nft);
        vector::push_back(&mut warehouse.nfts, nft_id);
        warehouse.total_deposited = warehouse.total_deposited + 1;

        dof::add(&mut warehouse.id, nft_id, nft);
    }

    public fun redeem_nft<T: key + store>(
        warehouse: &mut Warehouse,
        certificate: NftCert,
        ctx: &mut TxContext,
    ): T {
        venue::assert_nft_type<T>(&certificate);
        venue::assert_cert_buyer(&certificate, ctx);
        venue::assert_cert_inventory(&certificate, object::id(warehouse));

        let strategy = &venue::cert_redeem_strategy(&certificate);

        let nft = if (redeem_strategy::is_sequential(strategy)) {
            redeem_nft_sequential(warehouse)
        } else if (redeem_strategy::is_pseudorandom(strategy)) {
            redeem_pseudorandom_nft(warehouse, ctx)
        } else if (redeem_strategy::is_random(strategy)) {
            let (commitment, user_commitment) = redeem_strategy::extract_parameters_random(
                venue::cert_uid_mut(&mut certificate),
            );
            redeem_random_nft(warehouse, commitment, user_commitment, ctx)
        } else if (redeem_strategy::is_by_index(strategy)) {
            let index = redeem_strategy::extract_parameters_by_index(
                venue::cert_uid_mut(&mut certificate),
            );

            redeem_nft_at_index(warehouse, index)
        } else if (redeem_strategy::is_by_id(strategy)) {
            let id = redeem_strategy::extract_parameters_by_id(
                venue::cert_uid_mut(&mut certificate),
            );

            redeem_nft_with_id(warehouse, id)
        } else {
            abort(EUnsupportedRedeemStrategy)
        };

        venue::consume_certificate(Witness {}, warehouse, certificate);
        nft
    }

    public entry fun redeem_nft_and_transfer<T: key + store>(
        warehouse: &mut Warehouse,
        certificate: NftCert,
        ctx: &mut TxContext,
    ) {
        let nft: T = redeem_nft(warehouse, certificate, ctx);
        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

    /// Redeems NFT from `Warehouse` sequentially
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
    fun redeem_nft_sequential<T: key + store>(
        warehouse: &mut Warehouse,
    ): T {
        let nfts = &mut warehouse.nfts;
        assert!(!vector::is_empty(nfts), EEmpty);

        dof::remove(&mut warehouse.id, vector::pop_back(nfts))
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
    fun redeem_nft_at_index<T: key + store>(
        warehouse: &mut Warehouse,
        index: u64,
    ): T {
        let nfts = &mut warehouse.nfts;
        let length = vector::length(nfts);
        assert!(index < vector::length(nfts), EIndexOutOfBounds);

        let nft_id = *vector::borrow(nfts, index);

        // Swap index to remove with last element avoids shifting entire vector
        // of NFTs.
        //
        // `length - 1` is guaranteed to always resolve correctly
        vector::swap(nfts, index, length - 1);
        vector::pop_back(nfts);

        dof::remove(&mut warehouse.id, nft_id)
    }

    /// Redeems NFT with specific ID from `Warehouse`
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
    /// Panics if NFT with ID does not exist in `Warehouse`.
    fun redeem_nft_with_id<T: key + store>(
        warehouse: &mut Warehouse,
        nft_id: ID,
    ): T {
        let nfts = &mut warehouse.nfts;
        let supply = vector::length(nfts);

        let idx = 0;
        while (idx < supply) {
            let t_nft_id = vector::borrow(nfts, idx);

            if (&nft_id == t_nft_id) {
                return redeem_nft_at_index(warehouse, idx)
            };

            idx = idx + 1;
        };

        assert!(false, EInvalidNft);
        // Provide correct return type signature but will fail eitherway
        redeem_nft_at_index(warehouse, idx)
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
    fun redeem_pseudorandom_nft<T: key + store>(
        warehouse: &mut Warehouse,
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
    fun redeem_random_nft<T: key + store>(
        warehouse: &mut Warehouse,
        commitment: RedeemCommitment,
        user_commitment: vector<u8>,
        ctx: &mut TxContext,
    ): T {
        let (_, contract_commitment) =
            redeem_random::consume_commitment(commitment, user_commitment);

        // Construct randomized index
        let supply = supply(warehouse);
        assert!(supply != 0, EEmpty);

        vector::append(&mut user_commitment, contract_commitment);
        // Use supply of `Warehouse` as a additional nonce factor
        vector::append(&mut user_commitment, sui::bcs::to_bytes(&supply));

        let contract_commitment = pseudorandom::rand_no_counter(user_commitment, ctx);

        let index = select(supply, &contract_commitment);
        redeem_nft_at_index(warehouse, index)
    }

    /// Destroys `Warehouse`
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is not empty
    public entry fun destroy(warehouse: Warehouse) {
        assert_is_empty(&warehouse);
        let Warehouse { id, nfts: _, total_deposited: _ } = warehouse;
        object::delete(id);
    }

    // === Getter Functions ===

    /// Return how many `Nft` there are to sell
    public fun supply(warehouse: &Warehouse): u64 {
        vector::length(&warehouse.nfts)
    }

    /// Return whether there are any `Nft` in the `Warehouse`
    public fun is_empty(warehouse: &Warehouse): bool {
        vector::is_empty(&warehouse.nfts)
    }

    /// Returns list of all NFTs stored in `Warehouse`
    public fun nfts(warehouse: &Warehouse): &vector<ID> {
        &warehouse.nfts
    }

    /// Return cumulated amount of `Nft`s deposited in the `Warehouse`
    public fun total_deposited(warehouse: &Warehouse): u64 {
        warehouse.total_deposited
    }

    /// Return cumulated amount of `Nft`s redeemed in the `Warehouse`
    public fun total_redeemed(warehouse: &Warehouse): u64 {
        warehouse.total_deposited - vector::length(&warehouse.nfts)
    }

    // === Assertions ===

    /// Asserts that `Warehouse` is empty
    public fun assert_is_empty(warehouse: &Warehouse) {
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
}
