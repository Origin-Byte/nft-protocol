/// Marketplace adds a public key on-chain
/// and each time a user comes to their UI to mint
/// the marketplace encrypts a message with a counter and with the user
/// address, for the user to include in the transaction.
/// The encrypted message is then decrypted by this module
/// which asserts that the counter matches and the user address
/// in the message match the ctx sender
module launchpad_v2::live_status {
    use sui::dynamic_field as df;

    use launchpad_v2::launchpad::LaunchCap;
    use launchpad_v2::venue::{Self, Venue};
    use launchpad_v2::auth_policy::{Self, AuthRequest};

    const ESaleNotLive: u64 = 1;

    struct LiveStatus has store {
        live: bool
    }

    // Type collected by receipt Hot Potato
    struct LiveStatusAuth has drop {}

    // Dynamic field key used to store `Pubkey` in `Venue`
    struct LiveStatusDfKey has store, copy, drop {}


    /// Issue a new `Pubkey` and add it to the Venue as a dynamic field
    /// with field key `PubkeyDfKey`.
    ///
    /// This public key is used to verify if a given message sent by the
    /// user has been signed by the venue authority (i.e. Creator/Marketplace client).
    ///
    /// #### Panics
    ///
    /// Panics if `LaunchCap` does not match the `Venue`
    public fun add_live_status(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        is_live: bool,
    ) {
        venue::assert_launch_cap(venue, launch_cap);
        venue::register_rule(LiveStatusAuth {}, launch_cap, venue);

        let status = new_(is_live);

        let venue_uid = venue::uid_mut(venue, launch_cap);
        df::add(venue_uid, LiveStatusDfKey {}, status);
    }

    public fun toggle_status(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        is_live: bool,
    ) {
        venue::assert_launch_cap(venue, launch_cap);

        let venue_uid = venue::uid_mut(venue, launch_cap);
        let status = df::borrow_mut<LiveStatusDfKey, LiveStatus>(venue_uid, LiveStatusDfKey {});

        status.live = is_live;
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
    public fun check_liveness(
        venue: &Venue,
        request: &mut AuthRequest,
    ) {
        venue::assert_request(venue, request);

        let status = venue::get_df<LiveStatusDfKey, LiveStatus>(
            venue,
            LiveStatusDfKey {}
        );

        assert!(status.live, ESaleNotLive);

        auth_policy::add_receipt(request, &LiveStatusAuth {});
    }


    // === Private Functions ===

    /// Create a new `Pubkey`
    fun new_(
        is_live: bool,
    ): LiveStatus {
        LiveStatus {
            live: is_live,
        }
    }
}
