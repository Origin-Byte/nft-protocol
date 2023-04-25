#[test_only]
module nft_protocol::misc {
    use sui::test_scenario;
    use std::debug;
    use std::string;
    use nft_protocol::test_utils::seller;

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
        debug::print(&string::utf8(b"a"));
        let potato_wrapper = HotPotatoWrapper {
            potato: HotPotato {},
        };

        debug::print(&string::utf8(b"b"));
        let potato = delete_potato_wrapper(potato_wrapper);

        debug::print(&string::utf8(b"c"));
        delete_potato(potato);
        debug::print(&string::utf8(b"d"));

        test_scenario::end(scenario);
    }
}
