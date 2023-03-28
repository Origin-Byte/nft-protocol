#[test_only]
module nft_protocol::test_safe {
    use nft_protocol::witness;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::safe::{Self, Safe, OwnerCap};
    use nft_protocol::transfer_allowlist::{Self, Allowlist};

    use sui::object;
    use sui::test_scenario::{Self, Scenario, ctx};
    use sui::transfer::public_transfer;

    use originmate::box;

    struct Foo {}

    struct Witness has drop {}

    const USER: address = @0xA1C04;

    #[test]
    fun it_creates_safe() {
        let scenario = test_scenario::begin(USER);

        let owner_cap = safe::create_safe(ctx(&mut scenario));
        let owner_cap_safe_id = safe::owner_cap_safe(&owner_cap);

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);
        assert!(owner_cap_safe_id == object::id(&safe), 0);
        safe::assert_id(&safe, owner_cap_safe_id);
        safe::assert_owner_cap(&owner_cap, &safe);

        public_transfer(owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370407, location = nft_protocol::safe)]
    fun it_fails_if_safe_id_mismatches() {
        let scenario = test_scenario::begin(USER);

        safe::create_for_sender(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);
        let id = object::new(ctx(&mut scenario));
        safe::assert_id(&safe, object::uid_to_inner(&id));

        object::delete(id);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_create_for_sender() {
        let scenario = test_scenario::begin(USER);

        safe::create_for_sender(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);
        let owner_cap: OwnerCap = test_scenario::take_from_sender(&scenario);
        safe::assert_owner_cap(&owner_cap, &safe);

        test_scenario::return_shared(safe);
        test_scenario::return_to_sender(&scenario, owner_cap);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_deposits_nft() {
        let scenario = test_scenario::begin(USER);

        safe::create_for_sender(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft(nft, &mut safe, ctx(&mut scenario));
        assert!(safe::has_nft<Foo>(nft_id, &safe), 0);

        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370405, location = nft_protocol::safe)]
    fun it_cannot_deposit_nft_by_default() {
        let scenario = test_scenario::begin(USER);

        let owner_cap = safe::create_safe(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);
        safe::restrict_deposits(&owner_cap, &mut safe);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        safe::deposit_nft(nft, &mut safe, ctx(&mut scenario));

        public_transfer(owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370405, location = nft_protocol::safe)]
    fun it_cannot_deposit_nft_if_deposits_off() {
        let scenario = test_scenario::begin(USER);

        let owner_cap = safe::create_safe(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);
        safe::restrict_deposits(&owner_cap, &mut safe);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        safe::deposit_nft(nft, &mut safe, ctx(&mut scenario));

        public_transfer(owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_can_deposit_allowlisted_collection() {
        let scenario = test_scenario::begin(USER);

        let owner_cap = safe::create_safe(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);
        assert!(safe::are_all_deposits_enabled(&safe), 0);
        safe::restrict_deposits(&owner_cap, &mut safe);
        assert!(!safe::are_all_deposits_enabled(&safe), 0);
        safe::enable_deposits_of_collection<Foo>(&owner_cap, &mut safe);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft(nft, &mut safe, ctx(&mut scenario));
        assert!(safe::has_nft<Foo>(nft_id, &safe), 0);

        public_transfer(owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370405, location = nft_protocol::safe)]
    fun it_toggles_collection_allowlisting_for_deposits() {
        let scenario = test_scenario::begin(USER);

        let owner_cap = safe::create_safe(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);
        safe::restrict_deposits(&owner_cap, &mut safe);
        safe::enable_deposits_of_collection<Foo>(&owner_cap, &mut safe);
        safe::disable_deposits_of_collection<Foo>(&owner_cap, &mut safe);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        safe::deposit_nft(nft, &mut safe, ctx(&mut scenario));

        public_transfer(owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_creates_and_burns_transfer_cap() {
        let scenario = test_scenario::begin(USER);

        let owner_cap = safe::create_safe(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft(nft, &mut safe, ctx(&mut scenario));

        let transfer_cap = safe::create_transfer_cap(
            nft_id,
            &owner_cap,
            &mut safe,
            ctx(&mut scenario)
        );
        assert!(safe::transfer_cap_safe(&transfer_cap) == object::id(&safe), 0);
        safe::assert_transfer_cap_of_safe(&transfer_cap, &safe);
        safe::assert_nft_of_transfer_cap(&nft_id, &transfer_cap);
        assert!(!safe::transfer_cap_is_exclusive(&transfer_cap), 0);
        safe::assert_not_exclusively_listed(&transfer_cap);

        safe::burn_transfer_cap(transfer_cap, &mut safe);

        public_transfer(owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(
        abort_code = 13370401,
        location = nft_protocol::unprotected_safe,
    )]
    fun it_cannot_create_transfer_cap_if_nft_not_present() {
        let scenario = test_scenario::begin(USER);

        let owner_cap = safe::create_safe(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);

        let transfer_cap = safe::create_transfer_cap(
            object::id(&safe),
            &owner_cap,
            &mut safe,
            ctx(&mut scenario)
        );

        public_transfer(transfer_cap, USER);
        public_transfer(owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_withdraws_nft_with_transfer_cap() {
        let scenario = test_scenario::begin(USER);

        let owner_cap = safe::create_safe(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft(nft, &mut safe, ctx(&mut scenario));

        let transfer_cap = safe::create_transfer_cap(
            nft_id,
            &owner_cap,
            &mut safe,
            ctx(&mut scenario)
        );
        safe::assert_transfer_cap_of_safe(&transfer_cap, &safe);
        safe::assert_nft_of_transfer_cap(&nft_id, &transfer_cap);

        let wl = dummy_allowlist(&mut scenario);
        safe::transfer_nft_to_recipient<Foo, Witness>(
            transfer_cap, USER, Witness {}, &wl, &mut safe,
        );
        assert!(!safe::has_nft<Foo>(nft_id, &safe), 0);
        test_scenario::next_tx(&mut scenario, USER);
        let nft = test_scenario::take_from_sender<Nft<Foo>>(&scenario);
        safe::deposit_nft<Foo>(
            nft,
            &mut safe,
            ctx(&mut scenario),
        );
        assert!(safe::has_nft<Foo>(nft_id, &safe), 0);

        public_transfer(wl, USER);
        public_transfer(owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_creates_and_burns_exclusive_transfer_cap() {
        let scenario = test_scenario::begin(USER);

        let owner_cap = safe::create_safe(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft(nft, &mut safe, ctx(&mut scenario));

        let transfer_cap = safe::create_exclusive_transfer_cap(
            nft_id,
            &owner_cap,
            &mut safe,
            ctx(&mut scenario)
        );
        safe::assert_transfer_cap_of_safe(&transfer_cap, &safe);
        safe::assert_nft_of_transfer_cap(&nft_id, &transfer_cap);

        safe::burn_transfer_cap(transfer_cap, &mut safe);

        public_transfer(owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_withdraws_nft_with_exclusive_transfer_cap() {
        let scenario = test_scenario::begin(USER);

        let owner_cap = safe::create_safe(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft(nft, &mut safe, ctx(&mut scenario));

        let transfer_cap = safe::create_exclusive_transfer_cap(
            nft_id,
            &owner_cap,
            &mut safe,
            ctx(&mut scenario)
        );
        safe::assert_transfer_cap_of_safe(&transfer_cap, &safe);
        safe::assert_nft_of_transfer_cap(&nft_id, &transfer_cap);
        assert!(safe::transfer_cap_is_exclusive(&transfer_cap), 0);

        let wl = dummy_allowlist(&mut scenario);
        safe::transfer_nft_to_recipient<Foo, Witness>(
            transfer_cap, USER, Witness {}, &wl, &mut safe,
        );
        assert!(!safe::has_nft<Foo>(nft_id, &safe), 0);
        test_scenario::next_tx(&mut scenario, USER);
        let nft = test_scenario::take_from_sender<Nft<Foo>>(&scenario);
        safe::deposit_nft<Foo>(
            nft,
            &mut safe,
            ctx(&mut scenario),
        );
        assert!(safe::has_nft<Foo>(nft_id, &safe), 0);

        public_transfer(wl, USER);
        public_transfer(owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_delists_transfer_cap() {
        let scenario = test_scenario::begin(USER);

        let owner_cap = safe::create_safe(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft(nft, &mut safe, ctx(&mut scenario));

        let transfer_cap = safe::create_transfer_cap(
            nft_id,
            &owner_cap,
            &mut safe,
            ctx(&mut scenario)
        );
        let v1 = safe::transfer_cap_version(&transfer_cap);
        safe::delist_nft(nft_id, &owner_cap, &mut safe, ctx(&mut scenario));
        let transfer_cap2 = safe::create_transfer_cap(
            nft_id,
            &owner_cap,
            &mut safe,
            ctx(&mut scenario)
        );
        let v2 = safe::transfer_cap_version(&transfer_cap2);
        assert!(v1 != v2, 0);
        let transfer_cap3 = safe::create_transfer_cap(
            nft_id,
            &owner_cap,
            &mut safe,
            ctx(&mut scenario)
        );
        let v3 = safe::transfer_cap_version(&transfer_cap3);
        assert!(v2 == v3, 0);
        safe::delist_nft(nft_id, &owner_cap, &mut safe, ctx(&mut scenario));
        let transfer_cap4 = safe::create_transfer_cap(
            nft_id,
            &owner_cap,
            &mut safe,
            ctx(&mut scenario)
        );
        let v4 = safe::transfer_cap_version(&transfer_cap4);
        assert!(v3 != v4, 0);

        safe::burn_transfer_cap(transfer_cap, &mut safe);
        safe::burn_transfer_cap(transfer_cap2, &mut safe);
        safe::burn_transfer_cap(transfer_cap3, &mut safe);
        safe::burn_transfer_cap(transfer_cap4, &mut safe);

        public_transfer(owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(
        abort_code = 13370404,
        location = nft_protocol::unprotected_safe,
    )]
    fun it_cannot_withdraw_nft_with_expired_transfer_cap() {
        let scenario = test_scenario::begin(USER);

        let owner_cap = safe::create_safe(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft(nft, &mut safe, ctx(&mut scenario));

        let transfer_cap = safe::create_transfer_cap(
            nft_id,
            &owner_cap,
            &mut safe,
            ctx(&mut scenario)
        );

        safe::delist_nft(nft_id, &owner_cap, &mut safe, ctx(&mut scenario));

        let wl = dummy_allowlist(&mut scenario);
        safe::transfer_nft_to_recipient<Foo, Witness>(
            transfer_cap, USER, Witness {}, &wl, &mut safe,
        );

        public_transfer(wl, USER);
        public_transfer(owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_deposits_privileged() {
        let scenario = test_scenario::begin(USER);

        let owner_cap = safe::create_safe(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);
        safe::restrict_deposits(&owner_cap, &mut safe);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        safe::deposit_nft_privileged<Foo>(
            nft,
            &owner_cap,
            &mut safe,
            ctx(&mut scenario),
        );

        public_transfer(owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_transfers_nft_to_another_safe() {
        let scenario = test_scenario::begin(USER);

        let owner_cap1 = safe::create_safe(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let safe1: Safe = test_scenario::take_shared(&scenario);

        let owner_cap2 = safe::create_safe(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let safe2: Safe = test_scenario::take_shared(&scenario);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft(nft, &mut safe1, ctx(&mut scenario));

        let transfer_cap = safe::create_exclusive_transfer_cap(
            nft_id,
            &owner_cap1,
            &mut safe1,
            ctx(&mut scenario),
        );

        let wl = dummy_allowlist(&mut scenario);
        safe::transfer_nft_to_safe<Foo, Witness>(
            transfer_cap,
            USER,
            Witness {},
            &wl,
            &mut safe1,
            &mut safe2,
            ctx(&mut scenario),
        );
        assert!(!safe::has_nft<Foo>(nft_id, &safe1), 0);
        assert!(safe::has_nft<Foo>(nft_id, &safe2), 0);

        public_transfer(wl, USER);
        public_transfer(owner_cap1, USER);
        public_transfer(owner_cap2, USER);
        test_scenario::return_shared(safe1);
        test_scenario::return_shared(safe2);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(
        abort_code = 13370402,
        location = nft_protocol::unprotected_safe,
    )]
    fun it_cannot_create_transfer_cap_if_already_exclusively_listed() {
        let scenario = test_scenario::begin(USER);

        let owner_cap = safe::create_safe(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft(nft, &mut safe, ctx(&mut scenario));

        let transfer_cap1 = safe::create_exclusive_transfer_cap(
            nft_id,
            &owner_cap,
            &mut safe,
            ctx(&mut scenario)
        );
        let transfer_cap2 = safe::create_transfer_cap(
            nft_id,
            &owner_cap,
            &mut safe,
            ctx(&mut scenario),
        );

        public_transfer(owner_cap, USER);
        public_transfer(transfer_cap1, USER);
        public_transfer(transfer_cap2, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(
        abort_code = 13370404,
        location = nft_protocol::unprotected_safe,
    )]
    fun it_invalidates_prev_transfer_cap_if_exclusively_listed() {
        let scenario = test_scenario::begin(USER);

        let owner_cap = safe::create_safe(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft(nft, &mut safe, ctx(&mut scenario));

        let transfer_cap1 = safe::create_transfer_cap(
            nft_id,
            &owner_cap,
            &mut safe,
            ctx(&mut scenario),
        );
        let transfer_cap2 = safe::create_exclusive_transfer_cap(
            nft_id,
            &owner_cap,
            &mut safe,
            ctx(&mut scenario)
        );

        let wl = dummy_allowlist(&mut scenario);
        safe::transfer_nft_to_recipient<Foo, Witness>(
            transfer_cap1, USER, Witness {}, &wl, &mut safe,
        );
        assert!(!safe::has_nft<Foo>(nft_id, &safe), 0);
        test_scenario::next_tx(&mut scenario, USER);

        public_transfer(owner_cap, USER);
        public_transfer(wl, USER);
        public_transfer(transfer_cap2, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(
        abort_code = 13370400,
        location = nft_protocol::unprotected_safe,
    )]
    fun it_fails_create_transfer_cap_on_wrong_owner_cap() {
        let scenario = test_scenario::begin(USER);

        let right_owner_cap = safe::create_safe(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let safe: Safe = test_scenario::take_shared(&scenario);

        let wrong_owner_cap = safe::create_safe(ctx(&mut scenario));

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft(nft, &mut safe, ctx(&mut scenario));

        let transfer_cap = safe::create_transfer_cap(
            nft_id,
            &wrong_owner_cap,
            &mut safe,
            ctx(&mut scenario),
        );

        public_transfer(transfer_cap, USER);
        public_transfer(right_owner_cap, USER);
        public_transfer(wrong_owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(
        abort_code = 13370400,
        location = nft_protocol::unprotected_safe,
    )]
    fun it_fails_create_exclusive_transfer_cap_on_wrong_owner_cap() {
        let scenario = test_scenario::begin(USER);

        let right_owner_cap = safe::create_safe(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let safe: Safe = test_scenario::take_shared(&scenario);

        let wrong_owner_cap = safe::create_safe(ctx(&mut scenario));

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft(nft, &mut safe, ctx(&mut scenario));

        let transfer_cap = safe::create_exclusive_transfer_cap(
            nft_id,
            &wrong_owner_cap,
            &mut safe,
            ctx(&mut scenario),
        );

        public_transfer(transfer_cap, USER);
        public_transfer(right_owner_cap, USER);
        public_transfer(wrong_owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(
        abort_code = 13370400,
        location = nft_protocol::unprotected_safe,
    )]
    fun it_fails_to_accepts_any_deposit_on_wrong_owner_cap() {
        let scenario = test_scenario::begin(USER);

        let right_owner_cap = safe::create_safe(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let safe: Safe = test_scenario::take_shared(&scenario);

        let wrong_owner_cap = safe::create_safe(ctx(&mut scenario));

        safe::enable_any_deposit(&wrong_owner_cap, &mut safe);

        public_transfer(right_owner_cap, USER);
        public_transfer(wrong_owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(
        abort_code = 13370400,
        location = nft_protocol::unprotected_safe,
    )]
    fun it_fails_to_enable_deposits_of_collection_on_wrong_owner_cap() {
        let scenario = test_scenario::begin(USER);

        let right_owner_cap = safe::create_safe(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let safe: Safe = test_scenario::take_shared(&scenario);

        let wrong_owner_cap = safe::create_safe(ctx(&mut scenario));

        safe::enable_deposits_of_collection<Foo>(&wrong_owner_cap, &mut safe);

        public_transfer(right_owner_cap, USER);
        public_transfer(wrong_owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(
        abort_code = 13370400,
        location = nft_protocol::unprotected_safe,
    )]
    fun it_fails_deposit_nft_privileged_on_wrong_owner_cap() {
        let scenario = test_scenario::begin(USER);

        let right_owner_cap = safe::create_safe(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let safe: Safe = test_scenario::take_shared(&scenario);

        let wrong_owner_cap = safe::create_safe(ctx(&mut scenario));

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        safe::deposit_nft_privileged<Foo>(
            nft,
            &wrong_owner_cap,
            &mut safe,
            ctx(&mut scenario),
        );

        public_transfer(right_owner_cap, USER);
        public_transfer(wrong_owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(
        abort_code = 13370400,
        location = nft_protocol::unprotected_safe,
    )]
    fun it_fails_delist_nft_on_wrong_owner_cap() {
        let scenario = test_scenario::begin(USER);

        let right_owner_cap = safe::create_safe(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let safe: Safe = test_scenario::take_shared(&scenario);

        let wrong_owner_cap = safe::create_safe(ctx(&mut scenario));

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft_privileged<Foo>(
            nft,
            &right_owner_cap,
            &mut safe,
            ctx(&mut scenario),
        );

        safe::delist_nft(nft_id, &wrong_owner_cap, &mut safe, ctx(&mut scenario));

        public_transfer(right_owner_cap, USER);
        public_transfer(wrong_owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370408, location = nft_protocol::utils)]
    fun it_cannot_transfer_protocol_nft_as_generic_nft() {
        let scenario = test_scenario::begin(USER);

        let wl = dummy_allowlist(&mut scenario);
        let owner_cap = safe::create_safe(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let safe: Safe = test_scenario::take_shared(&scenario);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        let nft_id = object::id(&nft);
        safe::deposit_generic_nft<Nft<Foo>>(
            nft,
            &mut safe,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, USER);
        let transfer_cap = safe::create_transfer_cap(
            nft_id,
            &owner_cap,
            &mut safe,
            ctx(&mut scenario)
        );

        test_scenario::next_tx(&mut scenario, USER);
        safe::transfer_generic_nft_to_recipient<Nft<Foo>>(
            transfer_cap, USER, &mut safe,
        );

        public_transfer(wl, USER);
        public_transfer(owner_cap, USER);
        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370408, location = nft_protocol::utils)]
    fun it_cannot_transfer_protocol_nft_as_generic_nft_from_safe_to_safe() {
        let scenario = test_scenario::begin(USER);

        let owner_cap1 = safe::create_safe(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let safe1: Safe = test_scenario::take_shared(&scenario);

        let owner_cap2 = safe::create_safe(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let safe2: Safe = test_scenario::take_shared(&scenario);

        let nft = nft::test_mint<Foo>(USER, ctx(&mut scenario));
        let nft_id = object::id(&nft);
        safe::deposit_generic_nft<Nft<Foo>>(
            nft,
            &mut safe1,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, USER);
        let transfer_cap = safe::create_transfer_cap(
            nft_id,
            &owner_cap1,
            &mut safe1,
            ctx(&mut scenario)
        );

        test_scenario::next_tx(&mut scenario, USER);
        safe::transfer_generic_nft_to_safe<Nft<Foo>>(
            transfer_cap,
            &mut safe1,
            &mut safe2,
            ctx(&mut scenario),
        );

        public_transfer(owner_cap1, USER);
        public_transfer(owner_cap2, USER);
        test_scenario::return_shared(safe1);
        test_scenario::return_shared(safe2);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_deposits_and_transfers_generic_nft() {
        let scenario = test_scenario::begin(USER);

        safe::create_for_sender(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let safe: Safe = test_scenario::take_shared(&scenario);

        box::box(USER, true, ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let nft: box::Box<bool> =
            test_scenario::take_from_sender(&scenario);
        let nft_id = object::id(&nft);
        safe::deposit_generic_nft(
            nft,
            &mut safe,
            ctx(&mut scenario),
        );
        assert!(!safe::has_nft<box::Box<bool>>(nft_id, &safe), 0);
        assert!(safe::has_generic_nft<box::Box<bool>>(nft_id, &safe), 0);
        safe::assert_has_nft(&nft_id, &safe);

        test_scenario::return_shared(safe);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_transfers_generic_nft_from_safe_to_safe() {
        let scenario = test_scenario::begin(USER);

        let owner_cap1 = safe::create_safe(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let safe1: Safe = test_scenario::take_shared(&scenario);

        let owner_cap2 = safe::create_safe(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let safe2: Safe = test_scenario::take_shared(&scenario);

        box::box(USER, true, ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let nft: box::Box<bool> =
            test_scenario::take_from_sender(&scenario);
        let nft_id = object::id(&nft);
        safe::deposit_generic_nft(
            nft,
            &mut safe1,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, USER);
        let transfer_cap = safe::create_transfer_cap(
            nft_id,
            &owner_cap1,
            &mut safe1,
            ctx(&mut scenario)
        );

        test_scenario::next_tx(&mut scenario, USER);
        safe::transfer_generic_nft_to_safe<box::Box<bool>>(
            transfer_cap,
            &mut safe1,
            &mut safe2,
            ctx(&mut scenario),
        );
        safe::assert_has_nft(&nft_id, &safe2);

        public_transfer(owner_cap1, USER);
        public_transfer(owner_cap2, USER);
        test_scenario::return_shared(safe1);
        test_scenario::return_shared(safe2);
        test_scenario::end(scenario);
    }

    fun dummy_allowlist(scenario: &mut Scenario): Allowlist {
        let wl = transfer_allowlist::create(&Witness {}, ctx(scenario));

        transfer_allowlist::insert_collection(
            &Witness {},
            witness::from_witness<Foo, Witness>(&Witness {}),
            &mut wl,
        );

        wl
    }
}
