/// Marketplace adds a public key on-chain
/// and each time a user comes to their UI to mint
/// the marketplace encrypts a message with a counter and with the user
/// address, for the user to include in the transaction.
/// The encrypted message is then decrypted by this module
/// which asserts that the counter matches and the user address
/// in the message match the ctx sender
module ob_launchpad_v2::schedule {
    use sui::dynamic_field as df;
    use sui::clock::{Self, Clock};

    use std::option::{Self, Option};

    use ob_launchpad_v2::launchpad::LaunchCap;
    use ob_launchpad_v2::venue::{Self, Venue};
    use ob_launchpad_v2::auth_request::{Self, AuthRequest};

    const ESaleNotLive: u64 = 1;

    const EAtLeastOneTimeStampNeeded: u64 = 2;

    /// A wrapper for Liveness settings, it determines when a Venue is live
    /// or not.
    /// There are two methods in which the administrators can set up the
    /// schedule:
    ///
    /// - The liveness status gets toggled automatically when the runtime Clock
    /// is within the period defined by `start_time` and `close_time`. For more
    /// see `check_if_live`.
    struct Schedule has store {
        start_time: Option<u64>,
        close_time: Option<u64>,
    }

    // Type collected by receipt Hot Potato
    struct ScheduleAuth has drop {}

    // Dynamic field key used to store `Pubkey` in `Venue`
    struct ScheduleDfKey has store, copy, drop {}

    /// Issue a new `Pubkey` and add it to the Venue as a dynamic field
    /// with field key `PubkeyDfKey`.
    ///
    /// This public key is used to verify if a given message sent by the
    /// user has been signed by the venue authority (i.e. Creator/Marketplace client).
    ///
    /// #### Panics
    ///
    /// Panics if `LaunchCap` does not match the `Venue`
    public fun add_schedule(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        start_time: Option<u64>,
        close_time: Option<u64>,
    ) {
        venue::assert_launch_cap(venue, launch_cap);

        venue::register_rule(ScheduleAuth {}, launch_cap, venue);
        let schedule = new_(start_time, close_time);
        let venue_uid = venue::uid_mut(venue, launch_cap);

        df::add(venue_uid, ScheduleDfKey {}, schedule);
    }

    /// Verifies if a given message sent by the user has been signed by the
    /// venue authority (i.e. Creator/Marketplace client).
    ///
    /// #### Panics
    ///
    /// Panics if `Request` does not match the `Venue`.
    /// Panics if the signature is invalid.
    /// Panics if the signature is valid but the message
    /// has the incorrect counter.
    public fun check_is_live(
        venue: &Venue,
        request: &mut AuthRequest,
        clock: &Clock,
    ) {
        venue::assert_request(venue, request);

        let schedule = venue::get_df<ScheduleDfKey, Schedule>(venue, ScheduleDfKey {});

        if (option::is_some(&schedule.start_time)) {
            assert!(clock::timestamp_ms(clock) > *option::borrow(&schedule.start_time), 0);
        };

        if (option::is_some(&schedule.close_time)) {
            assert!(clock::timestamp_ms(clock) < *option::borrow(&schedule.close_time), 0);
        };

        auth_request::add_receipt(request, &ScheduleAuth {});
    }


    // === Private Functions ===

    // Initiates and new `Schedule` object and returns it.
    fun new_(
        start_time: Option<u64>,
        close_time: Option<u64>,
    ): Schedule {
        assert!(!(option::is_none(&start_time) && option::is_none(&close_time)), EAtLeastOneTimeStampNeeded);

        Schedule {
            start_time,
            close_time,
        }
    }
}
