module nft_protocol::venue_v2 {
    use std::option::{Self, Option};
    use sui::clock::{Self, Clock};
    use sui::transfer;
    use sui::vec_set;
    use std::type_name::{Self, TypeName};
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID, ID};
    use sui::dynamic_field as df;

    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::launchpad_v2::{Self, LaunchCap};
    use nft_protocol::venue_request::{Self, VenueRequest, VenuePolicyCap, VenuePolicy};

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
        policy: VenuePolicy,
        // Here for discoverability and assertion.
        redeem_policy: TypeName,
        // Here for discoverability and assertion.
        market_policy: TypeName,
        supply: Option<Supply>,
        start_time: Option<u64>,
        close_time: Option<u64>,
        live: bool,
        // resolver: Resolver,
    }

    struct NftCert has key, store {
        id: UID,
        venue_id: ID,
        warehouse_id: Option<u64>,
        // Relative index of the NFT in the Warehouse
        relative_index: Option<u64>,
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
        venue_request::confirm_request(&venue.policy, request);
    }

    public fun check_if_live(clock: &Clock, venue: &mut Venue): bool {
        // If the venue is live, then check it there is a closing time,
        // if so, then check if the clock timestamp is bigger than the closing
        // time. If so, set venue.live to `false` and return `false`
        if (venue.live == true) {
            if (option::is_some(&venue.close_time)) {
                if (clock::timestamp_ms(clock) > *option::borrow(&venue.close_time)) {
                    venue.live = false;
                };
            };
        } else {
            // If the venue is not live, then check it there is a start time,
            // if so, then check if the clock timestamp is bigger or equal to
            // the start time. If so, set venue.live to `true` and return `true`
            if (option::is_some(&venue.start_time)) {
                if (clock::timestamp_ms(clock) >= *option::borrow(&venue.start_time)) {
                    venue.live = true;
                };
            };
        };

        venue.live
    }

    public fun decrement_supply_if_any<AW: drop>(_market_witness: AW, venue: &mut Venue) {
        assert!(type_name::get<AW>() == venue.market_policy, EMARKET_WITNESS_MISMATCH);
        if (option::is_some(&venue.supply)) {
            supply::decrement(option::borrow_mut(&mut venue.supply), 1);
        }
    }

    public fun redeem_generic_cert<AW: drop>(
        _market_witness: AW,
        venue: &mut Venue,
        ctx: &mut TxContext,
    ): NftCert {
        assert!(type_name::get<AW>() == venue.market_policy, EMARKET_WITNESS_MISMATCH);

        NftCert {
            id: object::new(ctx),
            venue_id: object::id(venue),
            warehouse_id: option::none(),
            relative_index: option::none(),
        }
    }

    public fun uid_mut(venue: &mut Venue, launch_cap: &LaunchCap): &mut UID {
        assert_launch_cap(venue, launch_cap);

        &mut venue.id
    }

    public fun get_df<Key: store + copy + drop, Value: store>(venue: &Venue, key: Key): &Value {
        df::borrow<Key, Value>(&venue.id, key)
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
}
