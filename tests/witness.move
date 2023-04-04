#[test_only]
module nft_protocol::test_assert_same_module_as_witness {
    use std::string;

    use nft_protocol::utils;
    use nft_protocol::witness::assert_same_module_as_witness;
    use nft_protocol::test_foo;

    struct Witness has drop {}
    struct Witness2 has drop {}
    struct ASSERT_SAME_MODULE_AS_WITNESS has drop {}

    #[test]
    public fun it_returns_package_module_type() {
        let (package_addr, module_name, type_name) = utils::get_package_module_type<Witness>();

        // We can only test the length of the package address, since the address
        // itself depends on the deployed version. An example of an address would be:
        // 22122de69059b544f3c5f35ce78854a9b926fa0d

        assert!(string::length(&package_addr) == 64, 0);
        assert!(module_name == string::utf8(b"test_assert_same_module_as_witness"), 0);
        assert!(type_name == string::utf8(b"Witness"), 0);
    }

    #[test]
    public fun it_works() {
        assert_same_module_as_witness<ASSERT_SAME_MODULE_AS_WITNESS, Witness>();
    }

    #[test]
    public fun it_works_for_another_module() {
        assert_same_module_as_witness<test_foo::TEST_FOO, test_foo::Witness>();
    }

    #[test]
    #[expected_failure(abort_code = nft_protocol::witness::EInvalidWitnessModule)]
    public fun it_must_same_module() {
        assert_same_module_as_witness<ASSERT_SAME_MODULE_AS_WITNESS, test_foo::Witness>();
    }

    #[test]
    #[expected_failure(abort_code = nft_protocol::witness::EInvalidWitness)]
    public fun it_must_be_witness() {
        assert_same_module_as_witness<ASSERT_SAME_MODULE_AS_WITNESS, Witness2>();
    }
}

#[test_only]
module nft_protocol::test_foo {
    struct Witness has drop {}
    struct Witness2 has drop {}
    struct TEST_FOO has drop {}
}
