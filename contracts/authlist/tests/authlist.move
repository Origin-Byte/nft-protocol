#[test_only]
module authlist::test_authlist {
    use std::vector;
    use std::type_name;

    use sui::bcs;
    use sui::package;
    use sui::transfer;
    use sui::test_scenario::{Self, ctx};

    use authlist::authlist::{Self, Authlist, AuthlistOwnerCap};

    const CREATOR: address = @0xA1C04;

    struct TEST_AUTHLIST has drop {}

    struct Foo {}

    struct Witness has drop {}

    #[test]
    fun init_authlist() {
        let scenario = test_scenario::begin(CREATOR);

        authlist::init_authlist(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);

        assert!(test_scenario::has_most_recent_shared<Authlist>(), 0);
        assert!(test_scenario::has_most_recent_for_address<AuthlistOwnerCap>(CREATOR), 0);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = authlist::authlist::EInvalidAdmin)]
    fun try_insert_authority_invalid_cap() {
        let scenario = test_scenario::begin(CREATOR);

        let (authlist, cap) = authlist::new(ctx(&mut scenario));
        let (fake_authlist, fake_cap) = authlist::new(ctx(&mut scenario));

        let (pub, _) = key_ed25519();
        authlist::insert_authority(&fake_cap, &mut authlist, pub);

        authlist::delete_owner_cap(fake_cap);
        authlist::delete_authlist(fake_authlist);
        transfer::public_transfer(cap, CREATOR);
        transfer::public_share_object(authlist);
        test_scenario::end(scenario);
    }

    #[test]
    fun insert_authority() {
        let scenario = test_scenario::begin(CREATOR);

        let (authlist, cap) = authlist::new(ctx(&mut scenario));

        let (pub, _) = key_ed25519();
        authlist::insert_authority(&cap, &mut authlist, pub);

        transfer::public_transfer(cap, CREATOR);
        transfer::public_share_object(authlist);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = authlist::authlist::EInvalidAuthority)]
    fun try_remove_authority_undefined() {
        let scenario = test_scenario::begin(CREATOR);

        let (authlist, cap) = authlist::new(ctx(&mut scenario));

        let (pub, _) = key_ed25519();
        authlist::remove_authority(&cap, &mut authlist, pub);

        transfer::public_transfer(cap, CREATOR);
        transfer::public_share_object(authlist);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = authlist::authlist::EInvalidAdmin)]
    fun try_remove_authority_invalid_cap() {
        let scenario = test_scenario::begin(CREATOR);

        let (authlist, cap) = authlist::new(ctx(&mut scenario));
        let (fake_authlist, fake_cap) = authlist::new(ctx(&mut scenario));

        let (pub, _) = key_ed25519();
        authlist::insert_authority(&cap, &mut authlist, pub);
        authlist::remove_authority(&fake_cap, &mut authlist, pub);

        authlist::delete_owner_cap(fake_cap);
        authlist::delete_authlist(fake_authlist);
        transfer::public_transfer(cap, CREATOR);
        transfer::public_share_object(authlist);
        test_scenario::end(scenario);
    }

    #[test]
    fun remove_authority_invalid_cap() {
        let scenario = test_scenario::begin(CREATOR);

        let (authlist, cap) = authlist::new(ctx(&mut scenario));

        let (pub, _) = key_ed25519();
        authlist::insert_authority(&cap, &mut authlist, pub);
        authlist::remove_authority(&cap, &mut authlist, pub);

        transfer::public_transfer(cap, CREATOR);
        transfer::public_share_object(authlist);
        test_scenario::end(scenario);
    }

    #[test]
    fun insert_collection() {
        let scenario = test_scenario::begin(CREATOR);

        let authlist = authlist::new_embedded(Witness {}, ctx(&mut scenario));

        let publisher = package::claim(TEST_AUTHLIST {}, ctx(&mut scenario));
        authlist::insert_collection<Foo>(&mut authlist, &publisher);

        transfer::public_transfer(publisher, CREATOR);
        transfer::public_share_object(authlist);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = authlist::authlist::EInvalidCollection)]
    fun try_remove_collection() {
        let scenario = test_scenario::begin(CREATOR);

        let authlist = authlist::new_embedded(Witness {}, ctx(&mut scenario));

        let publisher = package::claim(TEST_AUTHLIST {}, ctx(&mut scenario));
        authlist::remove_collection<Foo>(&mut authlist, &publisher);

        transfer::public_transfer(publisher, CREATOR);
        transfer::public_share_object(authlist);
        test_scenario::end(scenario);
    }

    #[test]
    fun remove_collection() {
        let scenario = test_scenario::begin(CREATOR);

        let authlist = authlist::new_embedded(Witness {}, ctx(&mut scenario));

        let publisher = package::claim(TEST_AUTHLIST {}, ctx(&mut scenario));
        authlist::insert_collection<Foo>(&mut authlist, &publisher);
        authlist::remove_collection<Foo>(&mut authlist, &publisher);

        transfer::public_transfer(publisher, CREATOR);
        transfer::public_share_object(authlist);
        test_scenario::end(scenario);
    }

    #[test]
    fun transferable() {
        let scenario = test_scenario::begin(CREATOR);

        let authlist = authlist::new_embedded(Witness {}, ctx(&mut scenario));

        let (pub, _) = key_ed25519();
        authlist::insert_authority_with_witness(
            Witness {}, &mut authlist, pub,
        );

        let publisher = package::claim(TEST_AUTHLIST {}, ctx(&mut scenario));
        authlist::insert_collection<Foo>(&mut authlist, &publisher);

        let (msg, sig) = sig_ed25519();
        authlist::assert_transferable(
            &authlist,
            type_name::get<Foo>(),
            &pub,
            &msg,
            &sig,
        );

        transfer::public_transfer(publisher, CREATOR);
        transfer::public_share_object(authlist);
        test_scenario::end(scenario);
    }

    // === Utils ===

    /// Return public and private ED25519 key
    fun key_ed25519(): (vector<u8>, vector<u8>) {
        let pub = @0x8a1a8348dde5d979c85553c03e204c73efc3b91a2c9ce96b1004c9ec26eaacc8;
        let priv = @0xac5dbb29bea100f5f6382ebcb116afc66fc7b05ff64d2d1e3fc60849504a29f0;
        (authlist::address_to_bytes(pub), authlist::address_to_bytes(priv))
    }

    /// Generate a message and valid signature for key returned by
    /// `key_ed25519`
    fun sig_ed25519(): (vector<u8>, vector<u8>) {
        let (pub, _) = key_ed25519();

        // Just construct a fake message from any byte data we can get
        //
        // Simulate this being a P2P authorization request
        // `nft_id` | `source` | `destination` | `tx_context::epoch` | `nonce`
        let msg = vector::empty();
        vector::append(&mut msg, authlist::address_to_bytes(@0xef20b433672911dbcc20c2a28b8175774209b250948a4f10dc92e952225e8025));
        vector::append(&mut msg, pub);
        vector::append(&mut msg, pub);
        vector::append(&mut msg, bcs::to_bytes(&0));
        vector::append(&mut msg, pub);

        let p1 = @0xf620b1af0c6f4593e19a62867264775691d28d8ea446d68a426c8e6c4521cb6e;
        let p2 = @0x9e85534fb3f6d21b1eb5be0be6a8d7c3d4dba741cbf3c1f675726668b8f19108;

        let sig = vector::empty();
        vector::append(&mut sig, authlist::address_to_bytes(p1));
        vector::append(&mut sig, authlist::address_to_bytes(p2));

        // Sanity check
        assert!(sui::ed25519::ed25519_verify(&sig, &pub, &msg), 0);

        (msg, sig)
    }
}
