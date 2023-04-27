/// Marketplace adds a public key on-chain
/// and each time a user comes to their UI to mint
/// the marketplace encrypts a message with a counter and with the user
/// address, for the user to include in the transaction.
/// The encrypted message is then decrypted by this module
/// which asserts that the counter matches and the user address
/// in the message match the ctx sender
module ob_launchpad_v2::launchpad_auth {
    use sui::bcs;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_field as df;
    use sui::ecdsa_k1;

    use ob_launchpad_v2::launchpad::LaunchCap;
    use ob_launchpad_v2::venue::{Self, Venue};
    use ob_launchpad_v2::auth_request::{Self, AuthRequest};

    const EINCORRECT_SIGNATURE: u64 = 1;
    const EINCORRECT_MESSAGE_COUNTER: u64 = 2;
    const EINCORRECT_MESSAGE_SENDER: u64 = 3;

    struct Pubkey has store {
        id: UID,
        key: vector<u8>,
        counter: u64,
    }

    // Type collected by receipt Hot Potato
    struct LaunchpadAuth has drop {}

    // Dynamic field key used to store `Pubkey` in `Venue`
    struct PubkeyDfKey has store, copy, drop {}


    /// Issue a new `Pubkey` and add it to the Venue as a dynamic field
    /// with field key `PubkeyDfKey`.
    ///
    /// This public key is used to verify if a given message sent by the
    /// user has been signed by the venue authority (i.e. Creator/Marketplace client).
    ///
    /// #### Panics
    ///
    /// Panics if `LaunchCap` does not match the `Venue`
    public fun add_pubkey(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
        pubkey: vector<u8>,
        ctx: &mut TxContext,
    ) {
        venue::assert_launch_cap(venue, launch_cap);
        register_policy(launch_cap, venue);

        let pubkey = new_(pubkey, ctx);

        let venue_uid = venue::uid_mut(venue, launch_cap);
        df::add(venue_uid, PubkeyDfKey {}, pubkey);
    }

    /// Verifies if a given message sent by the user has been signed by the
    /// venue authority (i.e. Creator/Marketplace client).
    ///
    /// #### Panics
    ///
    /// Panics if `AuthRequest` does not match the `Venue`.
    /// Panics if the signature is invalid.
    /// Panics if the signature is valid but the message
    /// has the incorrect counter.
    public fun verify(
        venue: &Venue,
        signature: &vector<u8>,
        msg: &vector<u8>,
        hash: u8,
        request: &mut AuthRequest,
        ctx: &mut TxContext,
    ) {
        venue::assert_request(venue, request);
        let pubkey = venue::get_df<PubkeyDfKey, Pubkey>(venue, PubkeyDfKey {});

        assert!(
            ecdsa_k1::secp256k1_verify(signature, &pubkey.key, msg, hash),
            EINCORRECT_SIGNATURE
        );

        // Assert message has correct address and counter
        let bcs_msg = bcs::new(*msg);
        let counter = bcs::peel_u64(&mut bcs_msg);

        assert!(
            counter == pubkey.counter,
            EINCORRECT_MESSAGE_COUNTER
        );

        let sender = bcs::peel_address(&mut bcs_msg);

        assert!(
            sender == tx_context::sender(ctx),
            EINCORRECT_MESSAGE_SENDER
        );

        auth_request::add_receipt(request, &LaunchpadAuth {});
    }


    // === Private Functions ===

    /// Create a new `Pubkey`
    fun new_(
        pubkey: vector<u8>,
        ctx: &mut TxContext,
    ): Pubkey {
        Pubkey {
            id: object::new(ctx),
            counter: 0,
            key: pubkey,
        }
    }


    /// Registers Authentication Rule in `Venue`'s `Policy<REQUEST>`
    fun register_policy(
        launch_cap: &LaunchCap,
        venue: &mut Venue,
    ) {
        venue::register_rule(LaunchpadAuth {}, launch_cap, venue);
    }
}
