// TODO: This module is to be merged with test_utils from
// branch test/ob
module nft_protocol::test_utils_2 {

    use sui::object::{Self, ID};
    use sui::test_scenario::{Self, Scenario, ctx};
    use sui::transfer::{transfer, share_object};

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::transfer_whitelist::{Self, Whitelist};

    const OWNER: address = @0xA1C05;
    const CREATOR: address = @0xA1C04;

    // TODO: To add to utils
    public fun create_collection_and_whitelist<C: drop, Witness: drop>(
        coll_type: C,
        transfer_witness: Witness,
        scenario: &mut Scenario,
        ): (ID, ID, ID) {
        let (cap, col) = collection::dummy_collection<C>(&coll_type, CREATOR, scenario);

        let col_id = object::id(&col);
        let cap_id = object::id(&cap);

        share_object(col);
        test_scenario::next_tx(scenario, CREATOR);

        let col_control_cap = transfer_whitelist::create_collection_cap<C, Witness>(
            &transfer_witness, ctx(scenario),
        );

        let col: Collection<C> = test_scenario::take_shared(scenario);

        nft_protocol::example_free_for_all::init_(ctx(scenario));
        test_scenario::next_tx(scenario, CREATOR);

        let wl: Whitelist = test_scenario::take_shared(scenario);
        let wl_id = object::id(&wl);

        nft_protocol::example_free_for_all::insert_collection(
            &col_control_cap,
            &mut wl,
        );

        transfer(cap, CREATOR);
        transfer(col_control_cap, CREATOR);
        test_scenario::return_shared(col);
        test_scenario::return_shared(wl);

        (col_id, cap_id, wl_id,)
    }
}
