module launchpad_v2::venue {
    use std::ascii::String;
    use std::option::{Self, Option};
    use sui::clock::{Self, Clock};
    use sui::vec_map::{Self, VecMap};
    use std::type_name::{Self, TypeName};
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID, ID};
    use sui::dynamic_field as df;
    use sui::balance::{Self, Balance};
    use sui::transfer;

    use nft_protocol::supply::{Self, Supply};
    use launchpad_v2::launchpad::{Self, LaunchCap};
    use launchpad_v2::request::{Self, Request as AuthRequest, PolicyCap as AuthPolicyCap, Policy as AuthPolicy};
    use launchpad_v2::proceeds::{Self, Proceeds};

    const ELAUNCHCAP_VENUE_MISMATCH: u64 = 1;

    const EMARKET_WITNESS_MISMATCH: u64 = 2;


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
        schedule: Schedule,
        proceeds: Proceeds,
        inventories: VecMap<u64, InventoryData>,
    }

    /// A wrapper for Inventory data
    struct InventoryData has store, copy, drop {
        id: ID,
        type: TypeName
    }

    // A wrapper for all base policies in a venue
    struct Policies has store {
        auth_cap: AuthPolicyCap,
        auth: AuthPolicy,
        // Here for discoverability and assertion.
        redeem_method: TypeName,
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
    struct Schedule has store {
        start_time: Option<u64>,
        close_time: Option<u64>,
        live: bool,
    }

    struct RedeemReceipt {
        venue_id: ID,
        nfts_bought: u64,
    }

    struct NftCert has key, store {
        id: UID,
        venue_id: ID,
        // Needs reflection because we can't know it always in advance
        nft_type: TypeName,
        buyer: address,
        inventory: ID,
        index_scale: u64,
        // Relative index of the NFT in the Warehouse
        relative_index: u64,
    }

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
    public fun new<Market, RedeemMethod>(
        launch_cap: &LaunchCap,
        supply: Option<Supply>,
        start_time: Option<u64>,
        close_time: Option<u64>,
        ctx: &mut TxContext,
    ): Venue {
        Venue {
            id: object::new(ctx),
            listing_id: launchpad::listing_id(launch_cap),
            policies: init_policies<Market, RedeemMethod>(ctx),
            supply,
            schedule: init_schedule(start_time, close_time),
            proceeds: proceeds::empty(ctx),
            inventories: vec_map::empty()
        }
    }

    // Initiates and new `Venue` and shares it.
    public fun create_and_share<Market, RedeemMethod>(
        launch_cap: &LaunchCap,
        supply: Option<Supply>,
        start_time: Option<u64>,
        close_time: Option<u64>,
        ctx: &mut TxContext,
    ) {
        let venue = new<Market, RedeemMethod>(
            launch_cap,
            supply,
            start_time,
            close_time,
            ctx,
        );

        transfer::public_share_object(venue);
    }

    // Initiates and new `Policies` object and returns it.
    public fun init_policies<Market, RedeemMethod>(
        ctx: &mut TxContext,
    ): Policies {
        let (auth_policy, auth_cap) = request::empty_policy(ctx);

        Policies {
            auth_cap: auth_cap,
            auth: auth_policy,
            redeem_method: type_name::get<RedeemMethod>(),
            market: type_name::get<Market>()
        }
    }

    // Initiates and new `Schedule` object and returns it.
    public fun init_schedule(
        start_time: Option<u64>,
        close_time: Option<u64>,
    ): Schedule {
        Schedule {
            start_time,
            close_time,
            live: false,
        }
    }

    // === Venue Management ===

    // === AuthRequest ===

    /// To initiate a purchase, users have to perform a batch of programmable
    /// transactions. The client starts by calling this function, which will
    /// return an `AuthRequest` containing all the tasks required for the
    /// client to perform in order to gain access to the sale.
    public fun request_access(
        venue: &Venue,
    ): AuthRequest {
        request::new(&venue.policies.auth)
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
        request::confirm_request(&venue.policies.auth, request);
    }

    // === Schedule ===

    /// It can be called either externally (off-chain), or by the market contracts
    /// to assert if the the sale is live. If the runtime clock is within the
    /// bounds defined by the `start_time` and `close_time` this function will
    /// toggle the field `live` to `true` and will return `true`. If the runtime
    /// is out of the bounds defined, then the field `live` will be toggled
    /// to `false` and will return `false`.
    ///
    /// If there is no `start_time` not `close_time` then it will simply return
    /// the field `live`.
    public fun check_if_live(clock: &Clock, venue: &mut Venue): bool {
        // If the venue is live, then check it there is a closing time,
        // if so, then check if the clock timestamp is bigger than the closing
        // time. If so, set venue.live to `false` and return `false`
        if (venue.schedule.live == true) {
            if (option::is_some(&venue.schedule.close_time)) {
                if (clock::timestamp_ms(clock) > *option::borrow(&venue.schedule.close_time)) {
                    venue.schedule.live = false;
                };
            };
        } else {
            // If the venue is not live, then check it there is a start time,
            // if so, then check if the clock timestamp is bigger or equal to
            // the start time. If so, set venue.live to `true` and return `true`
            if (option::is_some(&venue.schedule.start_time)) {
                if (clock::timestamp_ms(clock) >= *option::borrow(&venue.schedule.start_time)) {
                    venue.schedule.live = true;
                };
            };
        };

        venue.schedule.live
    }

    // === Protected Endpoints ===

    /// Pay for `Nft` sale, direct fund to `Listing` proceeds, and emit sale
    /// events. This endpoint is protected and can only be called by the
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
        balance: &mut Balance<FT>,
        price: u64,
        quantity: u64,
    ) {
        assert_called_from_market<AW>(venue);

        let index = 0;
        while (quantity > index) {
            let funds = balance::split(balance, price);
            proceeds::add(&mut venue.proceeds, funds, 1);

            index = index + 1;
        }
    }

    /// Decrements global venue supply by the quantity sold by the market module.
    /// This endpoint is protected and can only be called by the Market Policy module.
    ///
    /// The market module should ensure that when calling this function, it should
    /// also call `get_redeem_receipt` for the same `quantity`.
    public fun decrement_supply_if_any<AW: drop>(
        _market_witness: AW,
        venue: &mut Venue,
        quantity: u64
    ) {
        assert_called_from_market<AW>(venue);

        if (option::is_some(&venue.supply)) {
            supply::decrement(option::borrow_mut(&mut venue.supply), quantity);
        }
    }

    ///
    public fun get_redeem_receipt<AW: drop>(
        _market_witness: AW,
        venue: &mut Venue,
        nfts_bought: u64,
    ): RedeemReceipt {
        assert_called_from_market<AW>(venue);

        // Consider emitting events

        RedeemReceipt {
            venue_id: object::id(venue),
            nfts_bought,
        }
    }

    public fun uid_mut(venue: &mut Venue, launch_cap: &LaunchCap): &mut UID {
        assert_launch_cap(venue, launch_cap);

        &mut venue.id
    }

    // Only accessible by the module that defines Key
    public fun get_df<Key: store + copy + drop, Value: store>(venue: &Venue, key: Key): &Value {
        df::borrow<Key, Value>(&venue.id, key)
    }

    // Only accessible by the module that defines Key + LaunchCap
    public fun get_df_mut<Key: store + copy + drop, Value: store>(
        venue: &mut Venue,
        launch_cap: &LaunchCap,
        key: Key
    ): &mut Value {
        // TODO: Assert not frozen, it should not be possible to get mut ref if
        // the venue is frozen
        assert_launch_cap(venue, launch_cap);
        df::borrow_mut<Key, Value>(&mut venue.id, key)
    }

    // TODO: NEEDS TO BE Permissioned!
    public fun get_certificate(
        venue: &Venue,
        nft_type: TypeName,
        inventory_id: ID,
        relative_index: u64,
        index_scale: u64,
        ctx: &mut TxContext,
    ): NftCert {

        NftCert {
            id: object::new(ctx),
            venue_id: object::id(venue),
            nft_type,
            buyer: tx_context::sender(ctx),
            inventory: inventory_id,
            index_scale,
            relative_index,
        }
    }

    public fun consume_certificate(
        // venue: &Venue,
        cert: NftCert,
    ) {

        let NftCert {
            id,
            venue_id: _,
            nft_type: _,
            buyer: _,
            inventory: _,
            index_scale: _,
            relative_index: _,
        } = cert;

        object::delete(id);
    }

    // TODO: NEEDS TO BE Permissioned!
    public fun consume_receipt(
        receipt: RedeemReceipt,
    ) {

       let  RedeemReceipt {
            venue_id: _,
            nfts_bought: _,
        } = receipt;
    }

    public fun get_invetories(venue: &Venue): &VecMap<u64, InventoryData> {
        &venue.inventories
    }

    public fun get_venue_id(cert: &NftCert): ID {
        cert.venue_id
    }

    public fun get_buyer(cert: &NftCert): address {
        cert.buyer
    }

    public fun get_inventory(cert: &NftCert): ID {
        cert.inventory
    }

    public fun get_relative_index(cert: &NftCert): u64 {
        cert.relative_index
    }

    public fun get_index_scale(cert: &NftCert): u64 {
        cert.index_scale
    }

    public fun get_inventory_data(
        venue: &Venue,
        index: u64,
    ): (ID, TypeName) {
        let inventories = get_invetories(venue);

        let data = vec_map::get<u64, InventoryData>(inventories, &index);

        (data.id, data.type)
    }

    public fun auth_policy(venue: &Venue): &AuthPolicy {
        &venue.policies.auth
    }

    public fun register_rule<RuleType: drop>(
        _witness: RuleType,
        launch_cap: &LaunchCap,
        venue: &mut Venue,
    ) {
        let cap = df::remove<TypeName, AuthPolicyCap>(&mut venue.id, type_name::get<AuthPolicyCap>());
        let policy = auth_policy_mut(venue, launch_cap);

        request::add_rule(policy, &cap, type_name::get<RuleType>());

        df::add<TypeName, AuthPolicyCap>(&mut venue.id, type_name::get<AuthPolicyCap>(), cap);
    }


    public fun auth_policy_mut(venue: &mut Venue, launch_cap: &LaunchCap): &mut AuthPolicy {
        assert_launch_cap(venue, launch_cap);
        &mut venue.policies.auth
    }


    public fun assert_launch_cap(venue: &Venue, launch_cap: &LaunchCap) {
        assert!(
            venue.listing_id == launchpad::listing_id(launch_cap),
            ELAUNCHCAP_VENUE_MISMATCH
        );
    }

    public fun assert_request(venue: &Venue, request: &AuthRequest) {
        assert!(request::policy_id(request) == object::id(&venue.policies.auth), 0);
    }

    public fun assert_called_from_market<AW: drop>(venue: &Venue) {
        assert!(type_name::get<AW>() == venue.policies.market, EMARKET_WITNESS_MISMATCH);
    }

    public fun assert_cert_buyer(cert: &NftCert, ctx: &TxContext) {
        assert!(cert.buyer == tx_context::sender(ctx), 0);
    }

    public fun assert_cert_inventory(cert: &NftCert, inventory_id: ID) {
        assert!(cert.inventory == inventory_id, 0);
    }
}
