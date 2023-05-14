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
module ob_launchpad_v2::warehouse {
    use std::vector;

    use sui::transfer;
    use sui::math;
    use sui::dynamic_field as df;
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, ID , UID};
    use sui::vec_map::{Self, VecMap};
    use ob_utils::sized_vec;
    use ob_utils::utils::{Self, IsShared};

    use sui::kiosk::Kiosk;
    use ob_kiosk::ob_kiosk;
    use ob_launchpad_v2::venue::{Self, Venue};
    use ob_launchpad_v2::launchpad::{Self, LaunchCap};
    use ob_launchpad_v2::certificate::{Self, NftCertificate};

    use ob_utils::dynamic_vector::{Self as dyn_vector, DynVec};

    // Track the current version of the module
    const VERSION: u64 = 1;

    /// Limit of NFTs held within each ID chunk
    /// The real limitation is at `7998` but we give a slight buffer
    const LIMIT: u64 = 7500;

    /// `Warehouse` does not have NFTs left to withdraw
    ///
    /// Call `Warehouse::deposit_nft` or `Listing::add_nft` to add NFTs.
    const EEmpty: u64 = 1;

    /// `Warehouse` still has NFTs left to withdraw
    ///
    /// Call `Warehouse::redeem_nft` or a `Listing` market to withdraw remaining
    /// NFTs.
    const ENOT_EMPTY: u64 = 2;

    /// `Warehouse` does not have NFT at specified index
    ///
    /// Call `Warehouse::redeem_nft_at_index` with an index that exists.
    const EIndexOutOfBounds: u64 = 3;

    /// Attempted to construct a `RedeemCommitment` with a hash length
    /// different than 32 bytes
    const EINVALID_COMMITMENT_LENGTH: u64 = 4;

    /// Commitment in `RedeemCommitment` did not match original value committed
    ///
    /// Call `Warehosue::random_redeem_nft` with the correct commitment.
    const EINVALID_COMMITMENT: u64 = 5;

    const EINVALID_CERTIFICATE: u64 = 6;

    const EWAREHOUSE_NOT_SHARED: u64 = 7;

    const EWAREHOUSE_IS_PRIVATE: u64 = 8;

    const ELAUNCHCAP_WAREHOUSE_MISMATCH: u64 = 9;

    struct Witness has drop {}

    /// `Warehouse` object which stores NFTs
    ///
    /// The reason that the type is limited is to easily support random
    /// withdrawals. If multiple types are allowed then user will not be able
    /// to predict the type of the object they withdraw.
    struct Warehouse<phantom T> has key, store {
        /// `Warehouse` ID
        id: UID,
        version: u64,
        listing_id: ID,
        /// NFTs that are currently on sale
        nfts: DynVec<ID>,
        // The net amount of NFTs deposited in the Warehouse
        total_deposited: u64,
        // Registers which venues have access to the warehouse and to how many NFTs.
        // Since Warehouses and Venues are loosely linked, this helps ensuring that the
        // bookeeping of NFTs is done consistently on both sides.
        registry: VecMap<ID, u64>,
        warehouse: UID,
    }

    /// Create a new `Warehouse`
    public fun new<T: key + store>(
        launch_cap: &LaunchCap,
        ctx: &mut TxContext
    ): Warehouse<T> {
        Warehouse<T> {
            id: object::new(ctx),
            version: VERSION,
            listing_id: launchpad::listing_id(launch_cap),
            nfts: dyn_vector::empty(LIMIT, ctx),
            total_deposited: 0,
            registry: vec_map::empty(),
            warehouse: object::new(ctx),
        }
    }

    /// Creates a `Warehouse` and transfers to transaction sender
    public fun init_warehouse<T: key + store>(
        launch_cap: &LaunchCap,
        ctx: &mut TxContext
    ): ID {
        let warehouse = new<T>(launch_cap, ctx);
        let warehouse_id = object::id(&warehouse);
        transfer::share_object(warehouse);
        warehouse_id
    }

    public fun share_from_private<T: key + store>(
        warehouse: Warehouse<T>, ctx: &mut TxContext
    ): ID {
        let Warehouse {
            id,
            version: _,
            listing_id,
            nfts,
            total_deposited,
            registry,
            warehouse
        } = warehouse;
        object::delete(id);

        let shared_warehouse = Warehouse<T> {
            id: object::new(ctx),
            version: VERSION,
            listing_id,
            nfts,
            total_deposited,
            registry,
            warehouse,
        };

        // Adding a simple marker to flag that the object is shared
        flag_as_shared(&mut shared_warehouse);

        let new_id = object::id(&shared_warehouse);
        transfer::share_object(shared_warehouse);
        new_id
    }

    public fun share<T: key + store>(
        warehouse: Warehouse<T>,
    ) {
        // Adding a simple marker to flag that the object is shared
        flag_as_shared(&mut warehouse);
        transfer::share_object(warehouse);
    }

    /// Deposits NFT to `Warehouse`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    public entry fun deposit_nft<T: key + store>(
        warehouse: &mut Warehouse<T>,
        nft: T,
    ) {
        assert_is_private(warehouse);
        let nft_id = object::id(&nft);

        dyn_vector::push_back(&mut warehouse.nfts, nft_id);
        warehouse.total_deposited = warehouse.total_deposited + 1;

        dof::add(&mut warehouse.warehouse, nft_id, nft);
    }

    public fun deposit_nfts<T: key + store>(
        warehouse: &mut Warehouse<T>,
        nfts: vector<T>,
    ) {
        assert_is_private(warehouse);

        let len = vector::length(&nfts);
        warehouse.total_deposited = warehouse.total_deposited + len;

        while (len > 0) {
            let nft = vector::pop_back(&mut nfts);
            let nft_id = object::id(&nft);
            dyn_vector::push_back(&mut warehouse.nfts, nft_id);

            dof::add(&mut warehouse.warehouse, nft_id, nft);

            len = len - 1;
        };

        vector::destroy_empty(nfts);
    }

    /// Deposits NFT to `Warehouse`
    public entry fun deposit_nft_as_admin<T: key + store>(
        launch_cap: &LaunchCap,
        warehouse: &mut Warehouse<T>,
        nft: T,
    ) {
        assert_launch_cap(launch_cap, warehouse);

        let nft_id = object::id(&nft);
        dyn_vector::push_back(&mut warehouse.nfts, nft_id);
        warehouse.total_deposited = warehouse.total_deposited + 1;

        dof::add(&mut warehouse.warehouse, nft_id, nft);
    }

    public fun deposit_nfts_as_admin<T: key + store>(
        launch_cap: &LaunchCap,
        warehouse: &mut Warehouse<T>,
        nfts: vector<T>,
    ) {
        assert_launch_cap(launch_cap, warehouse);

        let len = vector::length(&nfts);
        warehouse.total_deposited = warehouse.total_deposited + len;

        while (len > 0) {
            let nft = vector::pop_back(&mut nfts);
            let nft_id = object::id(&nft);
            dyn_vector::push_back(&mut warehouse.nfts, nft_id);

            dof::add(&mut warehouse.warehouse, nft_id, nft);

            len = len - 1;
        };

        vector::destroy_empty(nfts);
    }

    public fun register_supply<T: key + store>(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        self: &mut Warehouse<T>,
        new_supply: u64,
    ) {
        assert_is_shared(self);

        let allocated_supply = utils::sum_vector(utils::vec_map_entries(&self.registry));
        let remaining_supply = self.total_deposited - allocated_supply;

        assert!(new_supply <= remaining_supply, 0);

        venue::register_supply(Witness {}, launch_cap, venue, &self.id, new_supply);
    }

    /// Redeems NFT from `Warehouse`
    ///
    /// `Warehouse` may not change the logical owner of an `Nft` when
    /// redeeming as this would allow royalties to be trivially bypassed.
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is empty.
    public fun redeem_nft_to_kiosk<T: key + store>(
        warehouse: &mut Warehouse<T>,
        certificate: &mut NftCertificate,
        kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ) {
        ob_kiosk::assert_is_ob_kiosk(kiosk);
        ob_kiosk::assert_owner_address(kiosk, tx_context::sender(ctx));
        ob_kiosk::assert_can_deposit_permissionlessly<T>(kiosk);
        certificate::assert_cert_buyer(certificate, ctx);

        let nfts = redeem_nfts(warehouse, certificate);
        ob_kiosk::deposit_batch(kiosk, nfts, ctx);
    }

    /// Redeems NFT from `Warehouse`
    ///
    /// `Warehouse` may not change the logical owner of an `Nft` when
    /// redeeming as this would allow royalties to be trivially bypassed.
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is empty.
    fun redeem_nfts<T: key + store>(
        warehouse: &mut Warehouse<T>,
        certificate: &mut NftCertificate,
    ): vector<T> {
        let warehouse_id = object::id(warehouse);
        let nft_map = certificate::get_nft_map_mut_as_inventory(Witness {}, certificate);

        let nft_idxs = vec_map::get_mut(nft_map, &warehouse_id);
        let i = sized_vec::length(nft_idxs);

        assert!(i > 0, EINVALID_CERTIFICATE);

        let nfts = vector::empty();

        while (i > 0) {
            let rel_index = sized_vec::remove(nft_idxs, i - 1);

            let index = math::divide_and_round_up(
                (warehouse.total_deposited - 1) * rel_index,
                10_000
            );

            let nft = redeem_nft<T>(warehouse, index);
            vector::push_back(&mut nfts, nft);

            i = i - 1;
        };

        // Remove quantity of NFTs that will be redeemed
        let quantity = certificate::quantity_mut(Witness {}, certificate);
        *quantity = *quantity - i;

        nfts
    }

    /// Redeems NFT from specific index in `Warehouse`
    ///
    /// Does not retain original order of NFTs in the bookkeeping vector.
    ///
    /// `Warehouse` may not change the logical owner of an `Nft` when
    /// redeeming as this would allow royalties to be trivially bypassed.
    ///
    /// #### Panics
    ///
    /// Panics if index does not exist in `Warehouse`.
    fun redeem_nft<T: key + store>(
        warehouse: &mut Warehouse<T>,
        index: u64,
    ): T {
        assert!(warehouse.total_deposited > 0, EEmpty);
        assert!(index < warehouse.total_deposited, EIndexOutOfBounds);

        let nft_id = dyn_vector::pop_at_index(&mut warehouse.nfts, index);
        warehouse.total_deposited = warehouse.total_deposited - 1;

        dof::remove(&mut warehouse.warehouse, nft_id)
    }

    /// Destroys `Warehouse`
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` is not empty
    public fun destroy<T: key + store>(
        launch_cap: &LaunchCap,
        warehouse: Warehouse<T>
    ) {
        assert_launch_cap(launch_cap, &warehouse);
        assert_is_empty(&warehouse);

        let Warehouse { id, version: _, listing_id: _, nfts, total_deposited: _, registry: _ , warehouse} = warehouse;

        object::delete(id);
        dyn_vector::delete(nfts);
        object::delete(warehouse);
    }

    fun flag_as_shared<T: key + store>(warehouse: &mut Warehouse<T>) {
        df::add(&mut warehouse.warehouse, utils::marker<IsShared>(), utils::is_shared());
    }

    // === Getter Functions ===

    /// Return whether there are any `Nft` in the `Warehouse`
    public fun is_empty<T: key + store>(warehouse: &Warehouse<T>): bool {
        warehouse.total_deposited == 0
    }

    /// Returns list of all NFTs stored in `Warehouse`
    public fun nfts<T: key + store>(warehouse: &Warehouse<T>): &DynVec<ID> {
        &warehouse.nfts
    }

    /// Return cumulated amount of `Nft`s deposited in the `Warehouse`
    public fun supply<T: key + store>(warehouse: &Warehouse<T>): u64 {
        warehouse.total_deposited
    }

    // === Assertions ===

    /// Asserts that `Warehouse` is empty
    public fun assert_is_empty<T: key + store>(warehouse: &Warehouse<T>) {
        assert!(is_empty(warehouse), ENOT_EMPTY);
    }

    public fun assert_launch_cap<T: key + store>(launch_cap: &LaunchCap, warehouse: &Warehouse<T>) {
        assert!(
            warehouse.listing_id == launchpad::listing_id(launch_cap),
            ELAUNCHCAP_WAREHOUSE_MISMATCH
        );
    }

    public fun assert_is_shared<T: key + store>(warehouse: &Warehouse<T>) {
        assert!(
            df::exists_(&warehouse.warehouse, utils::marker<IsShared>()),
            EWAREHOUSE_NOT_SHARED
        );
    }

    public fun assert_is_private<T: key + store>(warehouse: &Warehouse<T>) {
        assert!(
            !df::exists_(&warehouse.warehouse, utils::marker<IsShared>()),
            EWAREHOUSE_IS_PRIVATE
        );
    }

    #[test_only]
    public fun test_redeem_nft<T: key + store>(
        warehouse: &mut Warehouse<T>,
        certificate: &mut NftCertificate,
        kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ): vector<T> {
        ob_kiosk::assert_is_ob_kiosk(kiosk);
        ob_kiosk::assert_owner_address(kiosk, tx_context::sender(ctx));
        ob_kiosk::assert_can_deposit_permissionlessly<T>(kiosk);
        certificate::assert_cert_buyer(certificate, ctx);

        redeem_nfts(warehouse, certificate)
    }
}
