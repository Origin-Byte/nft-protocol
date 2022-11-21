#[test_only]
module nft_protocol::test_assert_same_package_as_witness {
    use nft_protocol::utils::{get_package_module_type, assert_same_package_as_witness};
    use nft_protocol::test_foo;
    use std::string;

    struct Witness has drop {}
    struct Witness2 has drop {}
    struct ASSERT_SAME_PACKAGE_AS_WITNESS has drop {}

    #[test]
    public fun it_returns_package_module_type() {
        let (package_addr, module_name, type_name) = get_package_module_type<Witness>();

        assert!(package_addr == string::utf8(b"0000000000000000000000000000000000000000"), 0);
        assert!(module_name == string::utf8(b"test_assert_same_package_as_witness"), 0);
        assert!(type_name == string::utf8(b"Witness"), 0);
    }

    #[test]
    public fun it_works() {
        assert_same_package_as_witness<ASSERT_SAME_PACKAGE_AS_WITNESS, Witness>();
    }

    #[test]
    public fun it_works_for_another_module() {
        assert_same_package_as_witness<test_foo::TEST_FOO, test_foo::Witness>();
    }

    #[test]
    #[expected_failure(abort_code = 13370500)]
    public fun it_must_same_package() {
        assert_same_package_as_witness<ASSERT_SAME_PACKAGE_AS_WITNESS, test_foo::Witness>();
    }

    #[test]
    #[expected_failure(abort_code = 13370501)]
    public fun it_must_be_witness() {
        assert_same_package_as_witness<ASSERT_SAME_PACKAGE_AS_WITNESS, Witness2>();
    }
}

module nft_protocol::test_foo {
    struct Witness has drop {}
    struct Witness2 has drop {}
    struct TEST_FOO has drop {}
}
