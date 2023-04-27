#[test_only]
module ob_tests::misc {
    use sui::test_scenario;
    use ob_tests::test_utils::seller;

    struct HotPotato {}

    struct HotPotatoWrapper {
        potato: HotPotato
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
        let scenario = test_scenario::begin(seller());

        let potato_wrapper = HotPotatoWrapper {
            potato: HotPotato {},
        };

        let potato = delete_potato_wrapper(potato_wrapper);

        delete_potato(potato);

        test_scenario::end(scenario);
    }
}
