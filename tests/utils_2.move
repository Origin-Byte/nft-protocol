// TODO: This module is to be merged with test_utils from
// branch test/ob
module nft_protocol::test_utils_2 {

    use std::vector;
    use sui::object::{Self, ID};
    use sui::test_scenario::{Self, Scenario, ctx};
    use sui::transfer::{transfer, share_object};

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::transfer_whitelist::{Self, Whitelist};

    use nft_protocol::nft;
    use nft_protocol::safe::{Self, Safe, OwnerCap};

    const OWNER: address = @0xA1C05;

    // TODO: To add to utils
    public fun create_collection_and_whitelist<C: drop, Witness: drop>(
        coll_type: C,
        transfer_witness: Witness,
        creator: address,
        scenario: &mut Scenario,
        ): (ID, ID, ID) {
        let (cap, col) = collection::dummy_collection<C>(&coll_type, creator, scenario);

        let col_id = object::id(&col);
        let cap_id = object::id(&cap);

        share_object(col);
        test_scenario::next_tx(scenario, creator);

        let col_control_cap = transfer_whitelist::create_collection_cap<C, Witness>(
            &transfer_witness, ctx(scenario),
        );

        let col: Collection<C> = test_scenario::take_shared(scenario);

        nft_protocol::example_free_for_all::init_(ctx(scenario));
        test_scenario::next_tx(scenario, creator);

        let wl: Whitelist = test_scenario::take_shared(scenario);
        let wl_id = object::id(&wl);

        nft_protocol::example_free_for_all::insert_collection(
            &col_control_cap,
            &mut wl,
        );

        transfer(cap, creator);
        transfer(col_control_cap, creator);
        test_scenario::return_shared(col);
        test_scenario::return_shared(wl);

        (col_id, cap_id, wl_id,)
    }

    public fun create_safe(
        scenario: &mut Scenario,
        owner: address,
    ): (ID, ID) {
        test_scenario::next_tx(scenario, owner);

        let owner_cap = safe::create_safe(ctx(scenario));
        test_scenario::next_tx(scenario, owner);

        let safe: Safe = test_scenario::take_shared(
            scenario,
        );

        let safe_id = object::id(&safe);
        let owner_cap_id = object::id(&owner_cap);

        test_scenario::return_shared(safe);
        transfer(owner_cap, owner);

        test_scenario::next_tx(scenario, owner);

        (safe_id, owner_cap_id)
    }

    public fun mint_and_deposit_nft<C>(
        scenario: &mut Scenario,
        user: address,
    ): ID {
        test_scenario::next_tx(scenario, user);
        let (owner_cap, safe) = owner_cap_and_safe(scenario, user);

        let nft = nft::new<C>(user, ctx(scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft<C>(
            nft,
            &mut safe,
            ctx(scenario),
        );

        test_scenario::next_tx(scenario, user);

        assert!(safe::has_nft<C>(nft_id, &safe), 0);

        test_scenario::return_shared(safe);
        transfer(owner_cap, user);

        test_scenario::next_tx(scenario, user);

        nft_id
    }

    public fun owner_cap_safe(scenario: &Scenario, owner_cap: &OwnerCap): Safe {
        let safe_id = safe::owner_cap_safe(owner_cap);
        test_scenario::take_shared_by_id(scenario, safe_id)
    }

    public fun owner_cap_and_safe(scenario: &Scenario, user: address): (OwnerCap, Safe) {
        let owner_cap: OwnerCap = test_scenario::take_from_address_by_id(
            scenario,
            user,
            user_owner_cap_id(user),
        );
        let safe = owner_cap_safe(scenario, &owner_cap);

        (owner_cap, safe)
    }

    public fun user_owner_cap_id(user: address): ID {
        vector::pop_back(
            &mut test_scenario::ids_for_address<OwnerCap>(user)
        )
    }
}
