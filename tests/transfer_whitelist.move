#[test_only]
module nft_protocol::test_transfer_whitelist {
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::transfer_whitelist;
    use sui::transfer::transfer;
    use sui::test_scenario::{Self, Scenario, ctx};

    // TODO: don't

    struct Witness has drop {}
    struct Witness2 has drop {}

    struct Foo has drop {}
    struct Bar has drop {}

    const ADMIN: address = @0xA1C04;
    const CREATOR: address = @0xA1C05;

    #[test]
    fun it_allows_collection_to_remove_itself() {
        let scenario = test_scenario::begin(ADMIN);

        let col_cap = transfer_whitelist::create_collection_cap<Foo, Witness>(
            &Witness {}, ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_whitelist::create(Witness {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);
        transfer_whitelist::insert_collection(
            Witness {},
            &col_cap,
            &mut wl,
            ctx(&mut scenario),
        );

        assert!(transfer_whitelist::can_be_transferred<Foo, Witness>(Witness {}, &wl), 0);
        assert!(!transfer_whitelist::can_be_transferred<Bar, Witness>(Witness {}, &wl), 0);

        transfer_whitelist::remove_itself(&col_cap, &mut wl, ctx(&mut scenario));

        assert!(!transfer_whitelist::can_be_transferred<Foo, Witness>(Witness {}, &wl), 0);

        transfer(wl, ADMIN);
        transfer(col_cap, CREATOR);
        test_scenario::end(scenario);
    }

    // #[test]
    // #[expected_failure(abort_code = 13370501)]
    // fun it_fails_to_remove_collection_if_not_creator() {
    //     let scenario = test_scenario::begin(ADMIN);

    //     let col = dummy_collection<Foo>(&mut scenario);

    //     test_scenario::next_tx(&mut scenario, ADMIN);
    //     let wl = transfer_whitelist::create(Witness {}, ctx(&mut scenario));

    //     test_scenario::next_tx(&mut scenario, CREATOR);
    //     transfer_whitelist::insert_collection(
    //         Witness {},
    //         &col,
    //         &mut wl,
    //         ctx(&mut scenario),
    //     );

    //     test_scenario::next_tx(&mut scenario, ADMIN);

    //     transfer_whitelist::remove_itself(&col, &mut wl, ctx(&mut scenario));

    //     transfer(wl, ADMIN);
    //     test_scenario::return_shared(col);
    //     test_scenario::end(scenario);
    // }

    // #[test]
    // #[expected_failure(abort_code = 13370501)]
    // fun it_fails_to_insert_collection_if_not_creator() {
    //     let scenario = test_scenario::begin(ADMIN);

    //     let col = dummy_collection<Foo>(&mut scenario);

    //     test_scenario::next_tx(&mut scenario, ADMIN);
    //     let wl = transfer_whitelist::create(Witness {}, ctx(&mut scenario));

    //     test_scenario::next_tx(&mut scenario, ADMIN);
    //     transfer_whitelist::insert_collection(
    //         Witness {},
    //         &col,
    //         &mut wl,
    //         ctx(&mut scenario),
    //     );

    //     transfer(wl, ADMIN);
    //     test_scenario::return_shared(col);
    //     test_scenario::end(scenario);
    // }

    #[test]
    #[expected_failure(abort_code = 13370502)]
    fun it_fails_to_insert_collection_if_witness_mismatches() {
        let scenario = test_scenario::begin(ADMIN);

        let col_cap = transfer_whitelist::create_collection_cap<Foo, Witness>(
            &Witness {}, ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_whitelist::create(Witness {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);
        transfer_whitelist::insert_collection(
            Witness2 {},
            &col_cap,
            &mut wl,
            ctx(&mut scenario),
        );

        transfer(wl, ADMIN);
        transfer(col_cap, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370502)]
    fun it_fails_remove_collection_as_admin_if_witness_mismatches() {
        let scenario = test_scenario::begin(ADMIN);

        let col_cap = transfer_whitelist::create_collection_cap<Foo, Witness>(
            &Witness {}, ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_whitelist::create(Witness {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);
        transfer_whitelist::insert_collection(
            Witness {},
            &col_cap,
            &mut wl,
            ctx(&mut scenario),
        );

        transfer_whitelist::remove_collection<Witness2, Foo>(Witness2 {}, &mut wl);

        transfer(wl, ADMIN);
        transfer(col_cap, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_removes_collection_as_admin() {
        let scenario = test_scenario::begin(ADMIN);


        let col_cap1 = transfer_whitelist::create_collection_cap<Bar, Witness>(
            &Witness {}, ctx(&mut scenario),
        );
        let col_cap2 = transfer_whitelist::create_collection_cap<Foo, Witness>(
            &Witness {}, ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_whitelist::create(Witness {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);
        transfer_whitelist::insert_collection(
            Witness {},
            &col_cap1,
            &mut wl,
            ctx(&mut scenario),
        );
        transfer_whitelist::insert_collection(
            Witness {},
            &col_cap2,
            &mut wl,
            ctx(&mut scenario),
        );

        assert!(transfer_whitelist::can_be_transferred<Foo, Witness>(Witness {}, &wl), 0);
        assert!(transfer_whitelist::can_be_transferred<Bar, Witness>(Witness {}, &wl), 0);

        transfer_whitelist::remove_collection<Witness, Foo>(Witness {}, &mut wl);

        assert!(!transfer_whitelist::can_be_transferred<Foo, Witness>(Witness {}, &wl), 0);
        assert!(transfer_whitelist::can_be_transferred<Bar, Witness>(Witness {}, &wl), 0);

        transfer_whitelist::insert_collection(
            Witness {},
            &col_cap1,
            &mut wl,
            ctx(&mut scenario),
        );

        transfer_whitelist::clear_collections(Witness {}, &mut wl);

        assert!(!transfer_whitelist::can_be_transferred<Foo, Witness>(Witness {}, &wl), 0);
        assert!(!transfer_whitelist::can_be_transferred<Bar, Witness>(Witness {}, &wl), 0);

        transfer(wl, ADMIN);
        transfer(col_cap1, CREATOR);
        transfer(col_cap2, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_inserts_authority() {
        let scenario = test_scenario::begin(ADMIN);

        let col_cap = transfer_whitelist::create_collection_cap<Foo, Witness>(
            &Witness {}, ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_whitelist::create(Witness {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);
        transfer_whitelist::insert_collection(
            Witness {},
            &col_cap,
            &mut wl,
            ctx(&mut scenario),
        );

        transfer_whitelist::insert_authority<Witness, Witness2>(Witness {}, &mut wl);

        assert!(!transfer_whitelist::can_be_transferred<Foo, Witness>(Witness {}, &wl), 0);
        assert!(transfer_whitelist::can_be_transferred<Foo, Witness2>(Witness2 {}, &wl), 0);

        transfer_whitelist::insert_authority<Witness, Witness>(Witness {}, &mut wl);

        assert!(transfer_whitelist::can_be_transferred<Foo, Witness>(Witness {}, &wl), 0);
        assert!(transfer_whitelist::can_be_transferred<Foo, Witness2>(Witness2 {}, &wl), 0);

        assert!(!transfer_whitelist::can_be_transferred<Bar, Witness>(Witness {}, &wl), 0);
        assert!(!transfer_whitelist::can_be_transferred<Bar, Witness2>(Witness2 {}, &wl), 0);

        transfer(wl, ADMIN);
        transfer(col_cap, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_removes_authority() {
        let scenario = test_scenario::begin(ADMIN);

        let col_cap = transfer_whitelist::create_collection_cap<Foo, Witness>(
            &Witness {}, ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_whitelist::create(Witness {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);
        transfer_whitelist::insert_collection(
            Witness {},
            &col_cap,
            &mut wl,
            ctx(&mut scenario),
        );

        transfer_whitelist::insert_authority<Witness, Witness2>(Witness {}, &mut wl);

        assert!(!transfer_whitelist::can_be_transferred<Foo, Witness>(Witness {}, &wl), 0);
        assert!(transfer_whitelist::can_be_transferred<Foo, Witness2>(Witness2 {}, &wl), 0);

        transfer_whitelist::remove_authority<Witness, Witness2>(Witness {}, &mut wl);

        assert!(!transfer_whitelist::can_be_transferred<Foo, Witness>(Witness {}, &wl), 0);
        assert!(!transfer_whitelist::can_be_transferred<Foo, Witness2>(Witness2 {}, &wl), 0);

        transfer(wl, ADMIN);
        transfer(col_cap, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370502)]
    fun it_fails_to_insert_authority_if_witness_mismatches() {
        let scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_whitelist::create(Witness {}, ctx(&mut scenario));

        transfer_whitelist::insert_authority<Witness2, Witness2>(Witness2 {}, &mut wl);

        transfer(wl, ADMIN);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370502)]
    fun it_fails_to_remove_authority_if_witness_mismatches() {
        let scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_whitelist::create(Witness {}, ctx(&mut scenario));

        transfer_whitelist::insert_authority<Witness, Witness2>(Witness {}, &mut wl);
        transfer_whitelist::remove_authority<Witness2, Witness2>(Witness2 {}, &mut wl);

        transfer(wl, ADMIN);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370502)]
    fun it_fails_to_clear_collections_if_witness_mismatches() {
        let scenario = test_scenario::begin(ADMIN);

        let col_cap = transfer_whitelist::create_collection_cap<Foo, Witness>(
            &Witness {}, ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, ADMIN);
        let wl = transfer_whitelist::create(Witness {}, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);
        transfer_whitelist::insert_collection(
            Witness {},
            &col_cap,
            &mut wl,
            ctx(&mut scenario),
        );

        transfer_whitelist::clear_collections(Witness2 {}, &mut wl);

        transfer(wl, ADMIN);
        transfer(wl, CREATOR);
        test_scenario::end(scenario);
    }
}
