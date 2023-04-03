module nft_protocol::venue_v2 {
    use std::ascii::String;
    use std::vector;
    use std::option::{Self, Option};
    use sui::clock::{Self, Clock};
    use sui::transfer;
    use sui::event;
    use sui::vec_set;
    use sui::linked_table::{Self, LinkedTable};
    use sui::vec_map::{Self, VecMap};
    use sui::table::{Self, Table};
    use std::type_name::{Self, TypeName};
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID, ID};
    use sui::dynamic_field as df;
    use sui::balance::{Self, Balance};

    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::launchpad_v2::{Self, LaunchCap};
    use nft_protocol::venue_request::{Self, VenueRequest, VenuePolicyCap, VenuePolicy};
    use nft_protocol::proceeds_v2::{Self, Proceeds};
    use nft_protocol::warehouse_v2::{Self, Warehouse};

    const ELAUNCHCAP_VENUE_MISMATCH: u64 = 1;

    const EMARKET_WITNESS_MISMATCH: u64 = 2;


    /// `Venue` object
    ///
    /// `Venue` is a thin wrapper around a generic `Market` that handles
    /// tracking live status and whitelist assertions. `Venue` itself is not
    /// generic as to not require knowledge of the underlying market to
    /// perform administrative operations.
    ///
    /// `Venue` is unprotected and relies on safely obtaining a mutable
    /// reference.
    struct Venue has key, store {
        id: UID,
        listing_id: ID,
        policy_cap: VenuePolicyCap,
        policies: Policies,
        supply: Option<Supply>,
        open: OpenSettings,
        proceeds: Proceeds,
        inventories: VecMap<u64, InventoryData>,
    }

    struct InventoryData has store, copy, drop {
        id: ID,
        type: TypeName
    }

    struct Policies has store {
        policy: VenuePolicy,
        // Here for discoverability and assertion.
        redeem_policy: TypeName,
        // Here for discoverability and assertion.
        market_policy: TypeName,
    }

    struct OpenSettings has store {
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

    public fun request_access(
        venue: &Venue,
        ctx: &mut TxContext,
    ): VenueRequest {
        venue_request::new(
            object::uid_to_inner(&venue.id),
            ctx,
        )
    }

    public fun validate_access(
        venue: &Venue,
        request: VenueRequest,
    ) {
        assert_venue_request(venue, &request);
        // TODO: Need to consider how validation work, also,
        // how to use burner wallets in the context of the launchpad
        venue_request::confirm_request(&venue.policies.policy, request);
    }

    public fun check_if_live(clock: &Clock, venue: &mut Venue): bool {
        // If the venue is live, then check it there is a closing time,
        // if so, then check if the clock timestamp is bigger than the closing
        // time. If so, set venue.live to `false` and return `false`
        if (venue.open.live == true) {
            if (option::is_some(&venue.open.close_time)) {
                if (clock::timestamp_ms(clock) > *option::borrow(&venue.open.close_time)) {
                    venue.open.live = false;
                };
            };
        } else {
            // If the venue is not live, then check it there is a start time,
            // if so, then check if the clock timestamp is bigger or equal to
            // the start time. If so, set venue.live to `true` and return `true`
            if (option::is_some(&venue.open.start_time)) {
                if (clock::timestamp_ms(clock) >= *option::borrow(&venue.open.start_time)) {
                    venue.open.live = true;
                };
            };
        };

        venue.open.live
    }

    /// Pay for `Nft` sale, direct fund to `Listing` proceeds, and emit sale
    /// events.
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
            proceeds_v2::add(&mut venue.proceeds, funds, 1);

            index = index + 1;
        }
    }

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

    public fun assert_launch_cap(venue: &Venue, launch_cap: &LaunchCap) {
        assert!(
            venue.listing_id == launchpad_v2::listing_id(launch_cap),
            ELAUNCHCAP_VENUE_MISMATCH
        );
    }

    public fun assert_venue_request(venue: &Venue, request: &VenueRequest) {
        assert!(venue_request::venue(request) == object::id(venue), 0);
    }

    public fun assert_called_from_market<AW: drop>(venue: &Venue) {
        assert!(type_name::get<AW>() == venue.policies.market_policy, EMARKET_WITNESS_MISMATCH);
    }

    public fun assert_cert_buyer(cert: NftCert, ctx: &TxContext) {
        assert!(cert.buyer == tx_context::sender(ctx), 0);
    }

    public fun assert_cert_inventory(cert: NftCert, inventory_id: ID) {
        assert!(cert.inventory == inventory_id, 0);
    }
}
