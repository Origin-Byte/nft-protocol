#[test_only]
module ob_launchpad_v2::test_auth {
    use std::vector;

    use sui::test_scenario::{Self, ctx};
    use sui::object;
    use sui::transfer;

    use ob_launchpad_v2::venue::{Self};
    use ob_launchpad_v2::launchpad_auth;
    use ob_launchpad_v2::test_utils;
    use ob_launchpad_v2::auth_request;

    const SENDER: address = @0xef20b433672911dbcc20c2a28b8175774209b250948a4f10dc92e952225e8025;
    const MARKETPLACE: address = @0xA1C08;

    #[test]
    public fun test_authenticated_launchpad() {
        let scenario = test_scenario::begin(SENDER);

        // 1. Create a Launchpad Listing and Venue
        let (listing, launch_cap, venue) = test_utils::create_fixed_bid_launchpad(&mut scenario);

        // Prepare the verification tx
        let (pub, _) = key_ed25519();

        let (_msg, sig) = sig_ed25519();

        launchpad_auth::add_pubkey(
            &launch_cap,
            &mut venue,
            copy pub,
            ctx(&mut scenario),
        );

        let counter = launchpad_auth::address_to_bytes(@0x000000000000000000000000000000000000000000000000000000000000000A);
        launchpad_auth::set_test_counter(&mut venue, 10);

        let auth_request = auth_request::new(
            object::id(&venue),
            venue::get_auth_policy(&venue),
            ctx(&mut scenario),
        );

        launchpad_auth::verify(
            &venue,
            &sig,
            copy counter,
            &mut auth_request,
            ctx(&mut scenario),
        );

        auth_request::consume_test(auth_request);

        transfer::public_share_object(listing);
        transfer::public_share_object(venue);
        transfer::public_transfer(launch_cap, MARKETPLACE);

        test_scenario::end(scenario);
    }


    // === Utils ===

    /// Return public and private ED25519 key
    fun key_ed25519(): (vector<u8>, vector<u8>) {
        let pub = @0x8a1a8348dde5d979c85553c03e204c73efc3b91a2c9ce96b1004c9ec26eaacc8;
        let priv = @0xac5dbb29bea100f5f6382ebcb116afc66fc7b05ff64d2d1e3fc60849504a29f0;
        (launchpad_auth::address_to_bytes(pub), launchpad_auth::address_to_bytes(priv))
    }

    /// Generate a message and valid signature for key returned by
    /// `key_ed25519`
    fun sig_ed25519(): (vector<u8>, vector<u8>) {
        let (pub, _) = key_ed25519();

        // Just construct a fake message from any byte data we can get
        //
        // Simulate this being a P2P authorization request
        // `address` | `nonce`

        // Number 1 in hexadecimal format (as an addresss type)
        let counter = launchpad_auth::address_to_bytes(@0x000000000000000000000000000000000000000000000000000000000000000A);

        let msg = vector::empty();
        // The sender address is @0xef20b433672911dbcc20c2a28b8175774209b250948a4f10dc92e952225e8025
        vector::append(&mut msg, launchpad_auth::address_to_bytes(@0xef20b433672911dbcc20c2a28b8175774209b250948a4f10dc92e952225e8025));
        // Simulate the nonce
        vector::append(&mut msg, counter);

        let p1 = @0x70E7F8F502AE2EDA298E50ADAAC05E49DC683FA2A2AD210B26851362483E4711;
        let p2 = @0x577A448C24E4E943ADABE2AC90A1800789C5D0B66F699FD4C11702E16B9C7E08;

        let sig = vector::empty();
        vector::append(&mut sig, launchpad_auth::address_to_bytes(p1));
        vector::append(&mut sig, launchpad_auth::address_to_bytes(p2));

        // Sanity check
        assert!(sui::ed25519::ed25519_verify(&sig, &pub, &msg), 0);

        (msg, sig)
    }
}
