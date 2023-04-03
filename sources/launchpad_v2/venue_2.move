module nft_protocol::venue_v2 {
    use std::ascii::String;
    use std::vector;
    use std::option::{Self, Option};
    use sui::clock::{Self, Clock};
    use sui::transfer;
    use sui::event;
    use sui::vec_set;
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
        warehouses: Table<ID, Warehouse>,
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

    struct NftCert has key, store {
        id: UID,
        venue_id: ID,
        buyer: address,
        nfts_bought: u64,
        warehouse_id: vector<u64>,
        // Relative index of the NFT in the Warehouse
        relative_index: vector<u64>,
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

    public fun redeem_generic_cert<AW: drop>(
        _market_witness: AW,
        venue: &mut Venue,
        buyer: address,
        nfts_bought: u64,
        ctx: &mut TxContext,
    ): NftCert {
        assert_called_from_market<AW>(venue);

        // Consider emitting events

        NftCert {
            id: object::new(ctx),
            venue_id: object::id(venue),
            buyer,
            nfts_bought,
            warehouse_id: vector::empty(),
            relative_index: vector::empty(),
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
}
