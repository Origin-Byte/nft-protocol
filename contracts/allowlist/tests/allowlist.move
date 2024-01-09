#[test_only]
#[lint_allow(share_owned)]
module ob_allowlist::test_allowlist {
    use std::type_name;

    use sui::package;
    use sui::transfer;
    use sui::test_scenario::{Self, ctx};

    use ob_allowlist::allowlist::{Self, Allowlist, AllowlistOwnerCap};

    const CREATOR: address = @0xA1C04;

    struct TEST_ALLOWLIST has drop {}

    struct Foo {}

    struct Witness has drop {}

    #[test]
    fun init_allowlist() {
        let scenario = test_scenario::begin(CREATOR);

        allowlist::init_allowlist(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);

        assert!(test_scenario::has_most_recent_shared<Allowlist>(), 0);
        assert!(test_scenario::has_most_recent_for_address<AllowlistOwnerCap>(CREATOR), 0);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_allowlist::allowlist::EInvalidAdmin)]
    fun try_insert_authority_invalid_cap() {
        let scenario = test_scenario::begin(CREATOR);

        let (allowlist, cap) = allowlist::new(ctx(&mut scenario));
        let (fake_allowlist, fake_cap) = allowlist::new(ctx(&mut scenario));

        allowlist::insert_authority<Witness>(&fake_cap, &mut allowlist);

        allowlist::delete_owner_cap(fake_cap);
        allowlist::delete_allowlist(fake_allowlist);
        transfer::public_transfer(cap, CREATOR);
        transfer::public_share_object(allowlist);
        test_scenario::end(scenario);
    }

    #[test]
    fun insert_authority() {
        let scenario = test_scenario::begin(CREATOR);

        let (allowlist, cap) = allowlist::new(ctx(&mut scenario));

        allowlist::insert_authority<Witness>(&cap, &mut allowlist);

        transfer::public_transfer(cap, CREATOR);
        transfer::public_share_object(allowlist);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_allowlist::allowlist::EInvalidAuthority)]
    fun try_remove_authority_undefined() {
        let scenario = test_scenario::begin(CREATOR);

        let (allowlist, cap) = allowlist::new(ctx(&mut scenario));

        allowlist::remove_authority<Witness>(&cap, &mut allowlist);

        transfer::public_transfer(cap, CREATOR);
        transfer::public_share_object(allowlist);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_allowlist::allowlist::EInvalidAdmin)]
    fun try_remove_authority_invalid_cap() {
        let scenario = test_scenario::begin(CREATOR);

        let (allowlist, cap) = allowlist::new(ctx(&mut scenario));
        let (fake_allowlist, fake_cap) = allowlist::new(ctx(&mut scenario));

        allowlist::insert_authority<Witness>(&cap, &mut allowlist);
        allowlist::remove_authority<Witness>(&fake_cap, &mut allowlist);

        allowlist::delete_owner_cap(fake_cap);
        allowlist::delete_allowlist(fake_allowlist);
        transfer::public_transfer(cap, CREATOR);
        transfer::public_share_object(allowlist);
        test_scenario::end(scenario);
    }

    #[test]
    fun remove_authority_invalid_cap() {
        let scenario = test_scenario::begin(CREATOR);

        let (allowlist, cap) = allowlist::new(ctx(&mut scenario));

        allowlist::insert_authority<Witness>(&cap, &mut allowlist);
        allowlist::remove_authority<Witness>(&cap, &mut allowlist);

        transfer::public_transfer(cap, CREATOR);
        transfer::public_share_object(allowlist);
        test_scenario::end(scenario);
    }

    #[test]
    fun insert_collection() {
        let scenario = test_scenario::begin(CREATOR);

        let allowlist = allowlist::new_embedded(Witness {}, ctx(&mut scenario));

        let publisher = package::claim(TEST_ALLOWLIST {}, ctx(&mut scenario));
        allowlist::insert_collection<Foo>(&mut allowlist, &publisher);

        transfer::public_transfer(publisher, CREATOR);
        transfer::public_share_object(allowlist);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_allowlist::allowlist::EInvalidCollection)]
    fun try_remove_collection() {
        let scenario = test_scenario::begin(CREATOR);

        let allowlist = allowlist::new_embedded(Witness {}, ctx(&mut scenario));

        let publisher = package::claim(TEST_ALLOWLIST {}, ctx(&mut scenario));
        allowlist::remove_collection<Foo>(&mut allowlist, &publisher);

        transfer::public_transfer(publisher, CREATOR);
        transfer::public_share_object(allowlist);
        test_scenario::end(scenario);
    }

    #[test]
    fun remove_collection() {
        let scenario = test_scenario::begin(CREATOR);

        let allowlist = allowlist::new_embedded(Witness {}, ctx(&mut scenario));

        let publisher = package::claim(TEST_ALLOWLIST {}, ctx(&mut scenario));
        allowlist::insert_collection<Foo>(&mut allowlist, &publisher);
        allowlist::remove_collection<Foo>(&mut allowlist, &publisher);

        transfer::public_transfer(publisher, CREATOR);
        transfer::public_share_object(allowlist);
        test_scenario::end(scenario);
    }

    #[test]
    fun transferable() {
        let scenario = test_scenario::begin(CREATOR);

        let allowlist = allowlist::new_embedded(Witness {}, ctx(&mut scenario));

        allowlist::insert_authority_with_witness<Witness, Witness>(
            Witness {}, &mut allowlist,
        );

        let publisher = package::claim(TEST_ALLOWLIST {}, ctx(&mut scenario));
        allowlist::insert_collection<Foo>(&mut allowlist, &publisher);

        allowlist::assert_transferable(
            &allowlist, type_name::get<Foo>(), &type_name::get<Witness>(),
        );

        transfer::public_transfer(publisher, CREATOR);
        transfer::public_share_object(allowlist);
        test_scenario::end(scenario);
    }
}
