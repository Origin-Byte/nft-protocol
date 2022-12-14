#[test_only]
module nft_protocol::test_attribution {

    use nft_protocol::nft::{Self};
    use nft_protocol::attribution;

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::safe::{Self, Safe};
    use nft_protocol::transfer_whitelist::{Self, Whitelist};
    use nft_protocol::unprotected_safe::{OwnerCap};
    use sui::sui::SUI;
    use sui::coin;
    use sui::object::{Self, ID};
    use sui::test_scenario::{Self, Scenario, ctx};
    use sui::transfer::{transfer, share_object};

    struct Witness has drop {}

    struct Foo has drop {}

    struct DomainA has store {}

    const OWNER: address = @0xA1C05;
    const CREATOR: address = @0xA1C04;

    // #[test]
    // fun add_attribution() {
    //     let scenario = test_scenario::begin(OWNER);
    //     let ctx = ctx(&mut scenario);

    //     let nft = nft::new<Foo>(OWNER, ctx);

    //     let attribution = attribution::from_address(CREATOR);

    //     attribution::add_attribution_domain(&mut tags, tags::profile_picture());

    //     tags::add_tag_domain(
    //         &mut nft,
    //         tags,
    //         ctx
    //     );

    //     transfer(nft, OWNER);

    //     test_scenario::end(scenario);
    // }

    // TODO: To add to utils
    public fun create_collection_and_whitelist(scenario: &mut Scenario) {
        let (cap, col) = collection::dummy_collection<Foo>(&Foo {}, CREATOR, scenario);
        share_object(col);
        test_scenario::next_tx(scenario, CREATOR);

        let col_control_cap = transfer_whitelist::create_collection_cap<Foo, Witness>(
            &Witness {}, ctx(scenario),
        );

        let col: Collection<Foo> = test_scenario::take_shared(scenario);
        nft_protocol::example_free_for_all::init_(ctx(scenario));
        test_scenario::next_tx(scenario, CREATOR);

        let wl: Whitelist = test_scenario::take_shared(scenario);
        nft_protocol::example_free_for_all::insert_collection(
            &col_control_cap,
            &mut wl,
        );

        transfer(cap, CREATOR);
        transfer(col_control_cap, CREATOR);
        test_scenario::return_shared(col);
        test_scenario::return_shared(wl);
    }
}
