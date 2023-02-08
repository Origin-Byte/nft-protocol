#[test_only]
module nft_protocol::test_transfer_allowlist {
    use sui::transfer::transfer;
    use sui::test_scenario::{Self, Scenario, ctx};

    use nft_protocol::witness;
    use nft_protocol::transfer_allowlist;

    struct Witness has drop {}
    struct Witness2 has drop {}

    struct Foo has drop {}
    struct Bar has drop {}

    const ADMIN: address = @0xA1C04;
    const CREATOR: address = @0xA1C05;

    fun create_collection_cap<C>(
        scenario: &mut Scenario,
    ): transfer_allowlist::CollectionControlCap<C> {
        transfer_allowlist::create_collection_cap(
            witness::from_witness(&Witness {}), ctx(scenario),
        )
    }

    #[test]
    fun it_allows_collection_to_remove_itself() {
        let scenario = test_scenario::begin(ADMIN);

        let col_cap = create_collection_cap<Foo>(&mut scenario);

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_allowlist::create(&Witness {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);
        transfer_allowlist::insert_collection_with_cap(
            &Witness {},
            &col_cap,
            &mut wl,
        );

        transfer_allowlist::assert_transferable<Foo, Witness>(&wl);
        assert!(!transfer_allowlist::can_be_transferred<Bar, Witness>(&wl), 0);

        transfer_allowlist::remove_itself(&col_cap, &mut wl);

        assert!(!transfer_allowlist::can_be_transferred<Foo, Witness>(&wl), 0);

        transfer(wl, ADMIN);
        transfer(col_cap, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = transfer_allowlist::EINVALID_ADMIN)]
    fun it_fails_to_insert_collection_if_witness_mismatches() {
        let scenario = test_scenario::begin(ADMIN);

        let col_cap = create_collection_cap<Foo>(&mut scenario);

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_allowlist::create(&Witness {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);
        transfer_allowlist::insert_collection_with_cap(
            &Witness2 {},
            &col_cap,
            &mut wl,
        );

        transfer(wl, ADMIN);
        transfer(col_cap, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = transfer_allowlist::EINVALID_ADMIN)]
    fun it_fails_remove_collection_as_admin_if_witness_mismatches() {
        let scenario = test_scenario::begin(ADMIN);

        let col_cap = create_collection_cap<Foo>(&mut scenario);

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_allowlist::create(&Witness {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);
        transfer_allowlist::insert_collection_with_cap(
            &Witness {},
            &col_cap,
            &mut wl,
        );

        transfer_allowlist::remove_collection<Witness2, Foo>(Witness2 {}, &mut wl);

        transfer(wl, ADMIN);
        transfer(col_cap, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_removes_collection_as_admin() {
        let scenario = test_scenario::begin(ADMIN);

        let col_cap1 = create_collection_cap<Foo>(&mut scenario);
        let col_cap2 = create_collection_cap<Bar>(&mut scenario);

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_allowlist::create(&Witness {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);
        transfer_allowlist::insert_collection_with_cap(
            &Witness {},
            &col_cap1,
            &mut wl,
        );
        transfer_allowlist::insert_collection_with_cap(
            &Witness {},
            &col_cap2,
            &mut wl,
        );

        transfer_allowlist::assert_transferable<Foo, Witness>(&wl);
        transfer_allowlist::assert_transferable<Bar, Witness>(&wl);

        transfer_allowlist::remove_collection<Witness, Foo>(Witness {}, &mut wl);

        assert!(!transfer_allowlist::can_be_transferred<Foo, Witness>(&wl), 0);
        transfer_allowlist::assert_transferable<Bar, Witness>(&wl);

        transfer_allowlist::insert_collection_with_cap(
            &Witness {},
            &col_cap1,
            &mut wl,
        );

        transfer_allowlist::clear_collections(Witness {}, &mut wl);

        assert!(!transfer_allowlist::can_be_transferred<Foo, Witness>(&wl), 0);
        assert!(!transfer_allowlist::can_be_transferred<Bar, Witness>(&wl), 0);

        transfer(wl, ADMIN);
        transfer(col_cap1, CREATOR);
        transfer(col_cap2, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_inserts_authority() {
        let scenario = test_scenario::begin(ADMIN);

        let col_cap = create_collection_cap<Foo>(&mut scenario);

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_allowlist::create(&Witness {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);
        transfer_allowlist::insert_collection_with_cap(
            &Witness {},
            &col_cap,
            &mut wl,
        );

        transfer_allowlist::insert_authority<Witness, Witness2>(Witness {}, &mut wl);

        assert!(!transfer_allowlist::can_be_transferred<Foo, Witness>(&wl), 0);
        transfer_allowlist::assert_transferable<Foo, Witness2>(&wl);

        transfer_allowlist::insert_authority<Witness, Witness>(Witness {}, &mut wl);

        transfer_allowlist::assert_transferable<Foo, Witness>(&wl);
        transfer_allowlist::assert_transferable<Foo, Witness2>(&wl);

        assert!(!transfer_allowlist::can_be_transferred<Bar, Witness>(&wl), 0);
        assert!(!transfer_allowlist::can_be_transferred<Bar, Witness2>(&wl), 0);

        transfer(wl, ADMIN);
        transfer(col_cap, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_removes_authority() {
        let scenario = test_scenario::begin(ADMIN);

        let col_cap = create_collection_cap<Foo>(&mut scenario);

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_allowlist::create(&Witness {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);
        transfer_allowlist::insert_collection_with_cap(
            &Witness {},
            &col_cap,
            &mut wl,
        );

        transfer_allowlist::insert_authority<Witness, Witness2>(Witness {}, &mut wl);

        assert!(!transfer_allowlist::can_be_transferred<Foo, Witness>(&wl), 0);
        transfer_allowlist::assert_transferable<Foo, Witness2>(&wl);

        transfer_allowlist::remove_authority<Witness, Witness2>(Witness {}, &mut wl);

        assert!(!transfer_allowlist::can_be_transferred<Foo, Witness>(&wl), 0);
        assert!(!transfer_allowlist::can_be_transferred<Foo, Witness2>(&wl), 0);

        transfer(wl, ADMIN);
        transfer(col_cap, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = transfer_allowlist::EINVALID_ADMIN)]
    fun it_fails_to_insert_authority_if_witness_mismatches() {
        let scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_allowlist::create(&Witness {}, ctx(&mut scenario));

        transfer_allowlist::insert_authority<Witness2, Witness2>(Witness2 {}, &mut wl);

        transfer(wl, ADMIN);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = transfer_allowlist::EINVALID_ADMIN)]
    fun it_fails_to_remove_authority_if_witness_mismatches() {
        let scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_allowlist::create(&Witness {}, ctx(&mut scenario));

        transfer_allowlist::insert_authority<Witness, Witness2>(Witness {}, &mut wl);
        transfer_allowlist::remove_authority<Witness2, Witness2>(Witness2 {}, &mut wl);

        transfer(wl, ADMIN);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = transfer_allowlist::EINVALID_ADMIN)]
    fun it_fails_to_clear_collections_if_witness_mismatches() {
        let scenario = test_scenario::begin(ADMIN);

        let col_cap = create_collection_cap<Foo>(&mut scenario);

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_allowlist::create(&Witness {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);
        transfer_allowlist::insert_collection_with_cap(
            &Witness {},
            &col_cap,
            &mut wl,
        );

        transfer_allowlist::clear_collections(Witness2 {}, &mut wl);

        transfer(wl, ADMIN);
        transfer(col_cap, CREATOR);
        test_scenario::end(scenario);
    }
}
