/// Module of `Factory` type
module ob_launchpad_v2::factory {
    // TODO: Destroy function
    use std::vector;

    use sui::math;
    use sui::dynamic_field as df;
    use sui::vec_map::VecMap;
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::TxContext;
    use sui::bcs::{Self, BCS};
    use sui::table_vec::{Self, TableVec};
    use sui::vec_map;

    use nft_protocol::mint_pass::{Self, MintPass};
    use nft_protocol::mint_cap::{MintCap};
    use ob_utils::sized_vec;
    use ob_utils::utils::{Self, IsShared};
    use ob_launchpad_v2::venue::{Self, Venue};
    use ob_launchpad_v2::certificate::{Self, NftCertificate};
    use ob_launchpad_v2::launchpad::{Self, LaunchCap};

    // Track the current version of the module
    const VERSION: u64 = 1;


    /// `Warehouse` does not have NFT at specified index
    ///
    /// Call `Warehouse::redeem_nft_at_index` with an index that exists.
    const EINDEX_OUT_OF_BOUNDS: u64 = 1;
    const EINVALID_CERTIFICATE: u64 = 2;
    const EFACTORY_IS_PRIVATE: u64 = 3;
    const ELAUNCHCAP_FACTORY_MISMATCH: u64 = 4;
    const EFACTORY_NOT_SHARED: u64 = 5;

    struct Witness has drop {}

    /// `Factory` is an inventory that can mint loose NFTs
    ///
    /// Each `Factory` may only mint NFTs from a single collection.
    struct Factory<phantom T> has key, store {
        /// `Factory` ID
        id: UID,
        version: u64,
        listing_id: ID,
        // TODO: To convert to table vec, need to add fetch_idx helper
        metadata: TableVec<vector<BCS>>,
        /// `LooseMintCap` responsible for generating `PointerDomain` and
        /// maintianing supply invariants on `Collection` and `Archetype`
        /// levels.
        total_deposited: u64,
        registry: VecMap<ID, u64>,
        mint_cap: MintCap<T>,
    }

    /// Creates a new `Factory`
    ///
    /// `Factory` supply is limited by both the supply of the `Collection`
    /// and `Archetype` if either is regulated.
    ///
    /// #### Panics
    ///
    /// - Archetype `RegistryDomain` is not registered
    /// - `Archetype` does not exist
    public fun new<T>(
        launch_cap: &LaunchCap,
        mint_cap: MintCap<T>,
        ctx: &mut TxContext,
    ): Factory<T> {
        Factory {
            id: object::new(ctx),
            version: VERSION,
            listing_id: launchpad::listing_id(launch_cap),
            metadata: table_vec::empty(ctx),
            total_deposited: 0,
            registry: vec_map::empty(),
            mint_cap,
        }
    }

    /// Creates a `Warehouse` and transfers to transaction sender
    public fun init_factory<T: key + store>(
        launch_cap: &LaunchCap,
        mint_cap: MintCap<T>,
        ctx: &mut TxContext
    ): ID {
        let factory = new<T>(launch_cap, mint_cap, ctx);
        let factory_id = object::id(&factory);
        transfer::share_object(factory);
        factory_id
    }

    public fun share_from_private<T: key + store>(
        factory: Factory<T>, ctx: &mut TxContext
    ): ID {
        let Factory {
            id,
            version: _,
            listing_id,
            metadata,
            total_deposited,
            registry,
            mint_cap,
        } = factory;
        object::delete(id);

        let shared_factory = Factory<T> {
            id: object::new(ctx),
            version: VERSION,
            listing_id,
            metadata,
            total_deposited,
            registry,
            mint_cap,
        };

        // Adding a simple marker to flag that the object is shared
        flag_as_shared(&mut shared_factory);

        let new_id = object::id(&shared_factory);
        transfer::share_object(shared_factory);
        new_id
    }

    public fun share<T: key + store>(
        factory: Factory<T>,
    ) {
        // Adding a simple marker to flag that the object is shared
        flag_as_shared(&mut factory);
        transfer::share_object(factory);
    }

    /// Deposits NFT to `Warehouse`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    public fun deposit_metadata<T: key + store>(
        warehouse: &mut Factory<T>,
        metadata: vector<vector<u8>>,
    ) {
        assert_is_private(warehouse);

        let i = vector::length(&metadata);
        let metadata_bcs = vector::empty();

        // TODO: Test that the order is preserved
        while (i > 0) {
            vector::push_back(
                &mut metadata_bcs,
                bcs::new(vector::pop_back(&mut metadata)),
            );
        };

        vector::reverse(&mut metadata_bcs);

        table_vec::push_back(&mut warehouse.metadata, metadata_bcs);
        warehouse.total_deposited = warehouse.total_deposited + 1;
    }

    /// Deposits NFT to `Warehouse`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    public fun deposit_metadata_as_admin<T: key + store>(
        launch_cap: &LaunchCap,
        warehouse: &mut Factory<T>,
        metadata: vector<vector<u8>>,
    ) {
        assert_launch_cap(launch_cap, warehouse);

        let i = vector::length(&metadata);
        let metadata_bcs = vector::empty();

        // TODO: Test that the order is preserved
        while (i > 0) {
            vector::push_back(
                &mut metadata_bcs,
                bcs::new(vector::pop_back(&mut metadata)),
            );
        };

        vector::reverse(&mut metadata_bcs);

        table_vec::push_back(&mut warehouse.metadata, metadata_bcs);
        warehouse.total_deposited = warehouse.total_deposited + 1;
    }

    public fun register_supply<T: key + store>(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        self: &mut Factory<T>,
        new_supply: u64,
    ) {
        assert_is_shared(self);

        let allocated_supply = utils::sum_vector(utils::vec_map_entries(&self.registry));
        let remaining_supply = self.total_deposited - allocated_supply;

        assert!(new_supply <= remaining_supply, 0);

        venue::register_supply(Witness {}, launch_cap, venue, &self.id, new_supply);
    }

    /// Mints NFT from `Factory`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Factory`.
    ///
    /// #### Panics
    ///
    /// Panics if supply was exceeded.
    public fun redeem_nfts<T: key + store>(
        factory: &mut Factory<T>,
        certificate: &mut NftCertificate,
        ctx: &mut TxContext,
    ): vector<MintPass<T>> {
        certificate::assert_cert_buyer(certificate, ctx);

        let factory_id = object::id(factory);

        let nft_map = certificate::get_nft_map_mut_as_inventory(Witness {}, certificate);

        let nft_idxs = vec_map::get_mut(nft_map, &factory_id);
        let i = sized_vec::length(nft_idxs);

        assert!(i > 0, EINVALID_CERTIFICATE);

        let passes = vector::empty();

        while (i > 0) {
            let rel_index = sized_vec::remove(nft_idxs, i);

            let index = math::divide_and_round_up(
                (factory.total_deposited - 1) * rel_index,
                10_000
            );

            let mint_pass = redeem_mint_pass_<T>(factory, index, ctx);
            vector::push_back(&mut passes, mint_pass);

            i = i - 1;
        };

        let quantity = certificate::quantity_mut(Witness {}, certificate);
        *quantity = *quantity - i;
        passes
    }

    /// Mints NFT from `Factory`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Factory`.
    ///
    /// #### Panics
    ///
    /// Panics if supply was exceeded.
    public fun redeem_nft<T: key + store>(
        factory: &mut Factory<T>,
        certificate: &mut NftCertificate,
        ctx: &mut TxContext,
    ): MintPass<T> {
        certificate::assert_cert_buyer(certificate, ctx);

        let factory_id = object::id(factory);
        let nft_map = certificate::get_nft_map_mut_as_inventory(Witness {}, certificate);
        let nft_idxs = vec_map::get_mut(nft_map, &factory_id);

        let rel_index = sized_vec::pop_back(nft_idxs);

        let index = math::divide_and_round_up(
            factory.total_deposited * rel_index,
            10_000
        );

        let mint_pass = redeem_mint_pass_<T>(factory, index, ctx);

        let quantity = certificate::quantity_mut(Witness {}, certificate);
        *quantity = *quantity - 1;

        mint_pass
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
    fun redeem_mint_pass_<T: key + store>(
        factory: &mut Factory<T>,
        index: u64,
        ctx: &mut TxContext,
    ): MintPass<T> {
        assert!(index < table_vec::length(&factory.metadata), EINDEX_OUT_OF_BOUNDS);

        let metadata = *table_vec::borrow(&factory.metadata, index);

        mint_pass::new_with_metadata(
            &mut factory.mint_cap,
            1, // SUPPLY
            &bcs::to_bytes(&metadata),
            ctx,
        )
    }

    fun flag_as_shared<T: key + store>(factory: &mut Factory<T>) {
        df::add(&mut factory.id, utils::marker<IsShared>(), utils::is_shared());
    }

    public fun assert_is_private<T: key + store>(factory: &Factory<T>) {
        assert!(
            !df::exists_(&factory.id, utils::marker<IsShared>()),
            EFACTORY_IS_PRIVATE
        );
    }

    public fun assert_launch_cap<T: key + store>(launch_cap: &LaunchCap, factory: &Factory<T>) {
        assert!(
            factory.listing_id == launchpad::listing_id(launch_cap),
            ELAUNCHCAP_FACTORY_MISMATCH
        );
    }

    public fun assert_is_shared<T: key + store>(factory: &Factory<T>) {
        assert!(
            df::exists_(&factory.id, utils::marker<IsShared>()),
            EFACTORY_NOT_SHARED
        );
    }
}
