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
    use sui::math;
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, ID , UID};

    use launchpad_v2::certificate::{Self, NftCertificate};

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


    struct Witness has drop {}


    /// `Warehouse` object which stores NFTs
    ///
    /// The reason that the type is limited is to easily support random
    /// withdrawals. If multiple types are allowed then user will not be able
    /// to predict the type of the object they withdraw.
    struct Warehouse<phantom T> has key, store {
        /// `Warehouse` ID
        id: UID,
        /// NFTs that are currently on sale
        nfts: vector<ID>,
        // By subtracting `warehouse.total_deposited` to the length of `warehouse.nfts`
        // one can get total redeemed
        total_deposited: u64,
    }

    /// Create a new `Warehouse`
    public fun new<T: key + store>(ctx: &mut TxContext): Warehouse<T> {
        Warehouse<T> {
            id: object::new(ctx),
            nfts: vector::empty(),
            total_deposited: 0,
        }
    }

    /// Creates a `Warehouse` and transfers to transaction sender
    public entry fun init_warehouse<T: key + store>(ctx: &mut TxContext) {
        transfer::public_transfer(new<T>(ctx), tx_context::sender(ctx));
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
    public fun redeem_nft<T: key + store>(
        warehouse: &mut Warehouse<T>,
        certificate: &mut NftCertificate,
        ctx: &mut TxContext,
    ) {
        certificate::assert_cert_buyer(certificate, ctx);

        let warehouse_id = object::id(warehouse);

        let len = certificate::quantity(certificate);
        let remaining = certificate::quantity_mut(Witness {}, certificate);
        let inventories = certificate::invetories_mut_as_inventory(Witness {}, certificate);
        let nft = certificate::nft_mut_as_inventory(Witness {}, certificate);

        assert!(len > 0, 0);

        while (len > 0) {
            let inv_id = vector::borrow(inventories, len);

            if (*inv_id == warehouse_id) {
                vector::remove(inventories, len);


                let rel_index = vector::remove(nft, len);

                let index = math::divide_and_round_up(
                    warehouse.total_deposited * rel_index,
                    10_000
                );

                redeem_nft_and_transfer<T>(warehouse, index, ctx);
            };

            len = len - 1;
        };
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
    fun redeem_nft_and_transfer<T: key + store>(
        warehouse: &mut Warehouse<T>,
        index: u64,
        ctx: &mut TxContext,
    ) {
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

        let nft = dof::remove<ID, T>(&mut warehouse.id, nft_id);

        transfer::public_transfer(nft, tx_context::sender(ctx));
    }


    // TODO: ONLY CREATOR SHOULD BE ABLE TO DESTROY
    /// Destroys `Warehouse`
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is not empty
    public entry fun destroy<T: key + store>(warehouse: Warehouse<T>) {
        assert_is_empty(&warehouse);
        let Warehouse { id, nfts: _, total_deposited: _ } = warehouse;
        object::delete(id);
    }


    // === Getter Functions ===

    /// Return how many `Nft` there are to sell
    public fun supply<T: key + store>(warehouse: &Warehouse<T>): u64 {
        vector::length(&warehouse.nfts)
    }

    /// Return whether there are any `Nft` in the `Warehouse`
    public fun is_empty<T: key + store>(warehouse: &Warehouse<T>): bool {
        vector::is_empty(&warehouse.nfts)
    }

    /// Returns list of all NFTs stored in `Warehouse`
    public fun nfts<T: key + store>(warehouse: &Warehouse<T>): &vector<ID> {
        &warehouse.nfts
    }

    /// Return cumulated amount of `Nft`s deposited in the `Warehouse`
    public fun total_deposited<T: key + store>(warehouse: &Warehouse<T>): u64 {
        warehouse.total_deposited
    }

    /// Return cumulated amount of `Nft`s redeemed in the `Warehouse`
    public fun total_redeemed<T: key + store>(warehouse: &Warehouse<T>): u64 {
        warehouse.total_deposited - vector::length(&warehouse.nfts)
    }

    // === Assertions ===

    /// Asserts that `Warehouse` is empty
    public fun assert_is_empty<T: key + store>(warehouse: &Warehouse<T>) {
        assert!(is_empty(warehouse), ENOT_EMPTY);
    }

}
