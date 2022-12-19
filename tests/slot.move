#[test_only]
module nft_protocol::test_slot {
    use sui::test_scenario::{Self, Scenario, ctx};

    use nft_protocol::flat_fee;
    use nft_protocol::slot::{Self, Slot};
    use nft_protocol::launchpad::{Self, Launchpad};

    public fun init_slot(
        creator: address,
        scenario: &mut Scenario,
    ): (Launchpad, Slot) {
        test_scenario::next_tx(scenario, creator);

        launchpad::init_launchpad(
            creator,
            creator,
            true,
            flat_fee::new(0, ctx(scenario)),
            ctx(scenario),
        );

        test_scenario::next_tx(scenario, creator);
        let launchpad = test_scenario::take_shared<Launchpad>(scenario);

        slot::init_slot(
            &launchpad,
            creator,
            creator,
            ctx(scenario),
        );

        test_scenario::next_tx(scenario, creator);
        let slot = test_scenario::take_shared<Slot>(scenario);

        (launchpad, slot)
    }
}