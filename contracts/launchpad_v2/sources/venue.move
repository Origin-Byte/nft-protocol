// TODO: Add function to deregister rule
module ob_launchpad_v2::venue {
    use std::ascii::String;
    use std::option::{Self, Option};
    use sui::vec_map::{Self, VecMap};
    use std::type_name::{Self, TypeName};
    use sui::tx_context::TxContext;
    use sui::object::{Self, UID, ID};
    use sui::dynamic_field as df;
    use sui::balance::Balance;
    use sui::transfer;

    use ob_request::request::{Self, Policy, PolicyCap};
    use nft_protocol::utils_supply::{Self, Supply};

    use ob_launchpad_v2::launchpad::{Self, LaunchCap};
    use ob_launchpad_v2::auth_request::{Self, AuthRequest, AUTH_REQ};
    use ob_launchpad_v2::proceeds::{Self, Proceeds};

    const ELAUNCHCAP_VENUE_MISMATCH: u64 = 1;

    const EMARKET_WITNESS_MISMATCH: u64 = 2;

    const EREDEEM_WITNESS_MISMATCH: u64 = 3;

    const ESTOCK_WITNESS_MISMATCH: u64 = 4;

    const EINVENTORY_ID_MISMATCH: u64 = 5;

    const EBUYER_CERTIFICATE_MISMATCH: u64 = 6;

    const EINVENTORY_CERTIFICATE_MISMATCH: u64 = 7;

    const ENFT_TYPE_CERTIFICATE_MISMATCH: u64 = 8;

    /// `Venue` object
    ///
    /// `Venue` is the main abstraction that wraps all the logic around an NFT
    /// primary sale. As such, it contains information about:
    ///
    /// - Authentication: What on-chain steps do users have to go through in
    /// order to gain access to a sale?
    /// - Market Making: What type of market primite does the sale use?
    /// - Redemption: Upon a successful sale, how is it decided which NFT the
    /// user receives? (i.e. Random vs. FIFO)
    /// - Liveness: When is the primary sale live and how?
    /// - Proceed: What logic is needed to run in order to withdraw the proceeds
    /// from the sale?
    struct Venue has key, store {
        id: UID,
        /// A `Venue` belongs to a `Listing` and therefore we store here
        /// to what listing this obejct belongs to.
        listing_id: ID,
        policies: Policies,
        // TODO: There is a problem here, because what happens if you exhaust one
        // Warehouse but not the other? You have to implement relative index accross inventories as well?
        supply: Option<Supply>,
        proceeds: Proceeds,
        // Inventory
        inventories: VecMap<ID, u64>,
    }

    // A wrapper for all base policies in a venue
    struct Policies has store {
        // TODO: Make this a dynamic field
        auth: Policy<AUTH_REQ>,
        inventory: TypeName,
        // Here for discoverability and assertion.
        stock_policy: TypeName,
        redeem_policy: TypeName,
        // Here for discoverability and assertion.
        market: TypeName,
    }

    /// A wrapper for Liveness settings, it determines when a Venue is live
    /// or not.
    /// There are two methods in which the administrators can set up the
    /// schedule:
    ///
    /// - Either toggle the live status manually, in case there
    /// is no `start_time` nor `close_time`.
    /// - The liveness status gets toggled automatically when the runtime Clock
    /// is within the period defined by `start_time` and `close_time`. For more
    /// see `check_if_live`.
    // struct Schedule has store {
    //     start_time: Option<u64>,
    //     close_time: Option<u64>,
    //     live: bool,
    // }

    struct AuthCapDfKey has store, copy, drop {}

    /// Event signalling that `Nft` was sold by `Listing`
    struct NftSoldEvent has copy, drop {
        nft: ID,
        price: u64,
        ft_type: String,
        nft_type: String,
        buyer: address,
    }

    // === Instantiators ===

    // Initiates and new `Venue` and returns it.
    public fun new<Market, InventoryMethod, NftMethod>(
        launch_cap: &LaunchCap,
        supply: Option<Supply>,
        market: TypeName,
        inventory: TypeName,
        stock_policy: TypeName,
        redeem_policy: TypeName,
        ctx: &mut TxContext,
    ): Venue {
        let (auth_cap, policies) = init_policies(
            market,
            inventory,
            stock_policy,
            redeem_policy,
            ctx,
        );

        let uid = object::new(ctx);

        df::add(&mut uid, AuthCapDfKey {}, auth_cap);

        Venue {
            id: uid,
            listing_id: launchpad::listing_id(launch_cap),
            policies: policies,
            supply,
            proceeds: proceeds::empty(ctx),
            inventories: vec_map::empty()
        }
    }

    // Initiates and new `Venue` and shares it.
    public fun create_and_share<Market, InventoryMethod, NftMethod>(
        launch_cap: &LaunchCap,
        supply: Option<Supply>,
        market: TypeName,
        inventory: TypeName,
        stock_policy: TypeName,
        redeem_policy: TypeName,
        ctx: &mut TxContext,
    ) {
        let venue = new<Market, InventoryMethod, NftMethod>(
            launch_cap,
            supply,
            market,
            inventory,
            stock_policy,
            redeem_policy,
            ctx,
        );

        transfer::public_share_object(venue);
    }

    // Initiates and new `Policies` object and returns it.
    public fun init_policies(
        market: TypeName,
        inventory: TypeName,
        stock_policy: TypeName,
        redeem_policy: TypeName,
        ctx: &mut TxContext,
    ): (PolicyCap, Policies) {
        let (auth_policy, auth_cap) = auth_request::init_policy(ctx);

        (auth_cap, Policies {
            auth: auth_policy,
            inventory,
            stock_policy,
            redeem_policy,
            market,
        })
    }

    // TODO
    // // Initiates and new `Schedule` object and returns it.
    // public fun init_schedule(
    //     start_time: Option<u64>,
    //     close_time: Option<u64>,
    // ): Schedule {
    //     Schedule {
    //         start_time,
    //         close_time,
    //         live: false,
    //     }
    // }

    // === Venue Management ===

    /// Registers a rule into the `Policy<AUTH_REQ>` of `Venue`.
    ///
    /// This endpoint is protected and can only be called by the module that defines
    /// the Rule, only and only if it has access to a `LaunchCap` in its scope. In
    /// practice, this means that the Rule's contract has to be called directly or
    /// indirectly by one of the administrators themselves.
    public fun register_rule<RuleType: drop>(
        _witness: RuleType,
        launch_cap: &LaunchCap,
        venue: &mut Venue,
    ) {
        assert_launch_cap(venue, launch_cap);

        let cap = df::remove<TypeName, PolicyCap>(&mut venue.id, type_name::get<PolicyCap>());
        let policy = auth_policy_mut(venue, launch_cap);

        request::enforce_rule_no_state<AUTH_REQ, RuleType>(policy, &cap);

        df::add<TypeName, PolicyCap>(&mut venue.id, type_name::get<PolicyCap>(), cap);
    }

    // === AuthRequest ===

    /// To initiate a purchase, users have to perform a batch of programmable
    /// transactions. The client starts by calling this function, which will
    /// return an `AuthRequest` containing all the tasks required for the
    /// client to perform in order to gain access to the sale.
    public fun request_access(
        venue: &Venue, ctx: &mut TxContext,
    ): AuthRequest {
        auth_request::new(object::id(venue), &venue.policies.auth, ctx)
    }

    /// To gain access to a sale, users have to perform a batch of programmable
    /// transactions. This functions is intended to be called inside the scope of
    /// the market. By calling this function, the market's scope will give back
    /// the `AuthRequest` containing a proof that all the tasks required
    /// were completed. If so, the request is consumed and the sale follows.
    /// If not all the requires tasks were performed, then this function will
    /// fail.
    public fun validate_access(
        venue: &Venue,
        request: AuthRequest,
    ) {
        assert_request(venue, &request);
        // TODO: Need to consider how validation work, also,
        // how to use burner wallets in the context of the launchpad
        auth_request::confirm(request, &venue.policies.auth);
    }

    // === Schedule ===

    // TODO
    // /// It can be called either externally (off-chain), or by the market contracts
    // /// to assert if the the sale is live. If the runtime clock is within the
    // /// bounds defined by the `start_time` and `close_time` this function will
    // /// toggle the field `live` to `true` and will return `true`. If the runtime
    // /// is out of the bounds defined, then the field `live` will be toggled
    // /// to `false` and will return `false`.
    // ///
    // /// If there is no `start_time` not `close_time` then it will simply return
    // /// the field `live`.
    // public fun check_if_live(clock: &Clock, venue: &mut Venue): bool {
    //     // If the venue is live, then check it there is a closing time,
    //     // if so, then check if the clock timestamp is bigger than the closing
    //     // time. If so, set venue.live to `false` and return `false`
    //     if (venue.schedule.live == true) {
    //         if (option::is_some(&venue.schedule.close_time)) {
    //             if (clock::timestamp_ms(clock) > *option::borrow(&venue.schedule.close_time)) {
    //                 venue.schedule.live = false;
    //             };
    //         };
    //     } else {
    //         // If the venue is not live, then check it there is a start time,
    //         // if so, then check if the clock timestamp is bigger or equal to
    //         // the start time. If so, set venue.live to `true` and return `true`
    //         if (option::is_some(&venue.schedule.start_time)) {
    //             if (clock::timestamp_ms(clock) >= *option::borrow(&venue.schedule.start_time)) {
    //                 venue.schedule.live = true;
    //             };
    //         };
    //     };

    //     venue.schedule.live
    // }

    // === Protected Endpoints ===

    /// Pay for `Nft` sale, direct fund to `Listing` proceeds, and emit sale
    /// events.
    ///
    /// This endpoint is protected and can only be called by the
    /// Market Policy module.
    ///
    /// Will charge `price` from the provided `Balance` object.
    ///
    /// #### Panics
    ///
    /// Panics if balance is not enough to fund price
    public fun pay<AW: drop, FT, T: key>(
        _market_witness: AW,
        venue: &mut Venue,
        balance: Balance<FT>,
        quantity: u64,
    ) {
        assert_called_from_market<AW>(venue);
        proceeds::add(&mut venue.proceeds, balance, quantity);
    }

    /// Increments global venue supply by the quantity sold by the market module.
    ///
    /// This endpoint is protected and can only be called by the Market Policy module.
    ///
    /// The market module should ensure that when calling this function, it should
    /// also call `get_redeem_receipt` for the same `quantity`.
    public fun increment_supply_if_any<AW: drop>(
        _market_witness: AW,
        venue: &mut Venue,
        quantity: u64
    ) {
        assert_called_from_market<AW>(venue);

        if (option::is_some(&venue.supply)) {
            utils_supply::increment(option::borrow_mut(&mut venue.supply), quantity);
        }
    }

    // TODO
    // /// Consumes a `RedeemReceipt` hot potato.
    // ///
    // /// This endpoint is protected and can only be called by the Redeem Policy module,
    // /// which is the authority which decides how to redeem the NFTs from the Invetories.
    // ///
    // /// This function should be called in conjunction with `get_certificate`.
    // /// Whilst `get_certificate` issues a certificate for the client to use and get
    // /// the NFT, this function allows the whole process to be unblocked by
    // /// consuming the Hot Potato.
    // public fun consume_receipt<RW: drop>(
    //     _redeem_witness: RW,
    //     venue: &Venue,
    //     receipt: RedeemReceipt,
    // ) {
    //     assert_called_from_redeem_method<RW>(venue);

    //    let  RedeemReceipt {
    //     id,
    //         venue_id: _,
    //         nfts_bought: _,
    //     } = receipt;

    //     object::delete(id);
    // }

    // TODO
    // /// Creates an NftCert and returns it.
    // ///
    // /// This endpoint is protected and can only be called by the Redeem module,
    // /// which is the authority which decides how to redeem the NFTs from the Invetories.
    // ///
    // /// This function should be once in after with `consume_receipt`.
    // /// Whilst `consume_receipt` consumes the hot potato that signals access rights
    // /// to an NFTCert, this function allows is what allows the Redeem module to
    // /// issue the certificate to the user.
    // public fun get_certificate<RW: drop>(
    //     _redeem_witness: RW,
    //     venue: &Venue,
    //     nft_type: TypeName,
    //     inventory_id: ID,
    //     nft_index: RelIndex,
    //     ctx: &mut TxContext,
    // ): NftCert {
    //     assert_called_from_redeem_method<RW>(venue);

    //     NftCert {
    //         id: object::new(ctx),
    //         venue_id: object::id(venue),
    //         nft_type,
    //         buyer: tx_context::sender(ctx),
    //         inventory: inventory_id,
    //         nft_index,
    //     }
    // }

    // TODO
    // /// This function consumes the NftCert and signals that we have entered
    // /// the last step in our Launchpad voyage.
    // ///
    // /// This endpoint is protected and can only be called by the Inventory module,
    // /// which is the authority which decides how to redeem the NFTs from the Invetories.
    // ///
    // /// This should be called in conjunction with the action of returning or
    // /// transferring the NFT to the buyer.
    // public fun consume_certificate<IW: drop, INV: key + store>(
    //     _inventory_witness: IW,
    //     inventory: &INV,
    //     cert: NftCert,
    // ) {
    //     assert_called_from_inventory<IW, INV>(inventory, &cert);

    //     let NftCert {
    //         id,
    //         venue_id: _,
    //         nft_type: _,
    //         buyer: _,
    //         inventory: _,
    //         nft_index: _,
    //     } = cert;

    //     object::delete(id);
    // }

    /// Venues can be extended by exposing a mutable reference to its UID,
    /// in order for modules with extended functionality to add dynamic fields to
    /// and custom logic on top of it.
    ///
    /// This endpoint is protected and can only be called by a the owner of a
    /// `LaunchCap` or by an upstream contract that has access to it in its scope.
    ///
    /// CAUTION: Exposing `&mut UID` requires extensions to regulate accesss to their
    /// dynamic fields carefully, as it can lead to Dynamic Field Leaking. An
    /// example of this is if an extension uses TypeName or Marker<T> as a Key type.
    /// This is unsafe and it allows malicious extensions to gain access over
    /// the field. In order to prevent this, make sure the extension creates
    /// its own key struct (e.g. `MyExtensionDfKey has store, copy, drop {}`).
    public fun uid_mut(venue: &mut Venue, launch_cap: &LaunchCap): &mut UID {
        assert_launch_cap(venue, launch_cap);

        &mut venue.id
    }

    /// Immutably borrows a dynamic field `Value` from a `Venue`.
    ///
    /// This endpoint is protected and can only be accessed by whoever has
    /// access to `Key`, which will typically be the module that defined the
    /// respective Dynamic Field being accessed.
    public fun get_df<Key: store + copy + drop, Value: store>(venue: &Venue, key: Key): &Value {
        df::borrow<Key, Value>(&venue.id, key)
    }

    /// Mutably borrows a dynamic field `Value` from a `Venue`.
    ///
    /// This endpoint is protected and can only be called by a contract that
    /// has access to the dynamic field `Key`. In practice this means that the
    /// contract defining the dynamic field will define what the access permissions
    /// are to the `Key` that is has defined.
    public fun get_df_mut<Key: store + copy + drop, Value: store>(
        venue: &mut Venue,
        key: Key
    ): &mut Value {
        // TODO: Assert not frozen, it should not be possible to get mut ref if
        // the venue is frozen
        // TODO: No random module should be able to add dynamic fields, therefore
        // this should be protected. Only allowed modules can access this (potentially fia witness protection)
        // HOWEVER THIS SHOULD NOT BE A PROBLEM
        df::borrow_mut<Key, Value>(&mut venue.id, key)
    }

    public fun get_invetories_mut<SW: drop>(
        _stock_witness: SW, venue: &mut Venue
    ): &mut VecMap<ID, u64> {
        assert_called_from_stock_method<SW>(venue);
        &mut venue.inventories
    }

    // === Venue Getter Functions ===

    public fun listing_id(venue: &Venue): &ID {
        &venue.listing_id
    }

    public fun get_policies(venue: &Venue): &Policies {
        &venue.policies
    }

    public fun get_supply(venue: &Venue): &Option<Supply> {
        &venue.supply
    }

    public fun get_proceeds(venue: &Venue): &Proceeds {
        &venue.proceeds
    }

    public fun get_invetories(venue: &Venue): &VecMap<ID, u64> {
        &venue.inventories
    }

    public fun get_auth_policy(venue: &Venue): &Policy<AUTH_REQ> {
        &venue.policies.auth
    }

    public fun get_inventory_policy(venue: &Venue): TypeName {
        venue.policies.inventory
    }

    public fun get_market_policy(venue: &Venue): TypeName {
        venue.policies.market
    }

    public fun get_stock_policy(venue: &Venue): TypeName {
        venue.policies.stock_policy
    }

    public fun get_redeem_policy(venue: &Venue): TypeName {
        venue.policies.redeem_policy
    }

    // TODO
    // public fun get_start_time(venue: &Venue): &Option<u64> {
    //     &venue.schedule.start_time
    // }

    // public fun get_close_time(venue: &Venue): &Option<u64> {
    //     &venue.schedule.close_time
    // }

    // public fun get_live(venue: &Venue): bool {
    //     venue.schedule.live
    // }

    // === Policy Getter Functions ===

    public fun auth_policy(policies: &Policies): &Policy<AUTH_REQ> {
        &policies.auth
    }

    public fun inventory(policies: &Policies): TypeName {
        policies.inventory
    }

    public fun stock_policy(policies: &Policies): TypeName {
        policies.stock_policy
    }
    public fun redeem_policy(policies: &Policies): TypeName {
        policies.redeem_policy
    }

    public fun market_policy(policies: &Policies): TypeName {
        policies.market
    }

    // === Schedule Getter Functions ===

    // TODO
    // public fun start_time(schedule: &Schedule): &Option<u64> {
    //     &schedule.start_time
    // }

    // public fun close_time(schedule: &Schedule): &Option<u64> {
    //     &schedule.close_time
    // }

    // public fun live(schedule: &Schedule): bool {
    //     schedule.live
    // }

    // === RedeemReceipt Getter Functions ===

    // public fun receipt_venue_id(receipt: &RedeemReceipt): ID {
    //     receipt.venue_id
    // }

    // public fun nfts_bought(receipt: &RedeemReceipt): u64 {
    //     receipt.nfts_bought
    // }


    // === Private Functions ===

    fun auth_policy_mut(venue: &mut Venue, launch_cap: &LaunchCap): &mut Policy<AUTH_REQ> {
        assert_launch_cap(venue, launch_cap);
        &mut venue.policies.auth
    }

    // === Assertions ===

    public fun assert_launch_cap(venue: &Venue, launch_cap: &LaunchCap) {
        assert!(
            venue.listing_id == launchpad::listing_id(launch_cap),
            ELAUNCHCAP_VENUE_MISMATCH
        );
    }

    public fun assert_request(venue: &Venue, request: &AuthRequest) {
        assert!(auth_request::policy_id(request) == object::id(&venue.policies.auth), 0);
    }

    // TODO: These assertions are wrong because the Witnesses and Policy Objects are not the same...
    public fun assert_called_from_market<AW: drop>(venue: &Venue) {
        assert!(type_name::get<AW>() == venue.policies.market, EMARKET_WITNESS_MISMATCH);
    }

    public fun assert_called_from_stock_method<SW: drop>(venue: &Venue) {
        assert!(type_name::get<SW>() == venue.policies.stock_policy, ESTOCK_WITNESS_MISMATCH);
    }

    public fun assert_called_from_redeem_method<RW: drop>(venue: &Venue) {
        assert!(type_name::get<RW>() == venue.policies.redeem_policy, EREDEEM_WITNESS_MISMATCH);
    }

    public fun assert_called_from_inventory<IW: drop>(venue: &Venue) {
        assert!(type_name::get<IW>() == venue.policies.inventory, EINVENTORY_ID_MISMATCH);
    }

    // public fun assert_nft_type<T: key + store>(cert: &NftCert) {
    //     assert!(cert.nft_type == type_name::get<T>(), ENFT_TYPE_CERTIFICATE_MISMATCH);
    // }

    // public fun assert_cert_inventory(cert: &NftCert, inventory_id: ID) {
    //     assert!(cert.inventory == inventory_id, EINVENTORY_CERTIFICATE_MISMATCH);
    // }
}
