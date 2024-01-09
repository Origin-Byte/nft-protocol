#[test_only]
#[lint_allow(share_owned)]
module ob_tests::misc {
    use sui::test_scenario::{Self, ctx};
    use sui::object::{Self, UID};
    use sui::transfer;
    use ob_tests::test_utils::creator;

    struct HotPotato {}

    struct HotPotatoWrapper {
        potato: HotPotato
    }

    struct Signer has key, store {
        id: UID,
        transfer_signer: UID,
    }

    fun delete_potato_wrapper(wrapper: HotPotatoWrapper): HotPotato {
        let HotPotatoWrapper {
            potato,
        } = wrapper;

        potato
    }

    fun delete_potato(potato: HotPotato) {
        let HotPotato {} = potato;
    }

    #[test]
    fun try_wrap_potato() {
        let scenario = test_scenario::begin(creator());

        let potato_wrapper = HotPotatoWrapper {
            potato: HotPotato {},
        };

        let potato = delete_potato_wrapper(potato_wrapper);

        delete_potato(potato);

        test_scenario::end(scenario);
    }

    #[test]
    fun migrate_signer() {
        let scenario = test_scenario::begin(creator());
        let signer_1 = Signer {
            id: object::new(ctx(&mut scenario)),
            transfer_signer: object::new(ctx(&mut scenario)),
        };

        transfer::public_transfer(signer_1, creator());

        test_scenario::next_tx(&mut scenario, creator());

        let signer_1 =
            test_scenario::take_from_address<Signer>(&scenario, creator());

        let Signer { id, transfer_signer } = signer_1;
        object::delete(id);

        let signer_2 = Signer {
            id: object::new(ctx(&mut scenario)),
            transfer_signer
        };

        test_scenario::next_tx(&mut scenario, creator());

        let Signer { id, transfer_signer } = signer_2;
        object::delete(id);
        object::delete(transfer_signer);

        test_scenario::end(scenario);
    }
}
