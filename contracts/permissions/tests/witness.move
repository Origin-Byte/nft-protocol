#[test_only]
module ob_permissions::test_witness {
    use std::string;

    use sui::test_utils as sui_utils;
    use sui::package;
    use sui::transfer;

    use ob_utils::utils;
    use ob_permissions::witness;
    use ob_permissions::test_foo;
    use sui::test_scenario::{Self, ctx};

    struct Witness has drop {}
    struct Witness2 has drop {}
    struct TEST_WITNESS has drop {}
    struct ASSERT_SAME_MODULE_AS_WITNESS has drop {}

    struct Foo has store {}

    #[test]
    fun get_dw_from_wit() {
        witness::from_witness<Foo, Witness>(Witness {});
    }

    #[test]
    fun get_dw_from_publisher() {
        let scenario = test_scenario::begin(@0x0);

        let otw = sui_utils::create_one_time_witness<TEST_WITNESS>();
        let pub = package::claim(otw, ctx(&mut scenario));
        witness::from_publisher<Foo>(&pub);

        transfer::public_transfer(pub, @0x0);

        test_scenario::end(scenario);
    }

    #[test]
    public fun it_returns_package_module_type() {
        let (package_addr, module_name, type_name) = utils::get_package_module_type<Witness>();

        // We can only test the length of the package address, since the address
        // itself depends on the deployed version. An example of an address would be:
        // 22122de69059b544f3c5f35ce78854a9b926fa0d

        assert!(string::length(&package_addr) == 64, 0);
        assert!(module_name == string::utf8(b"test_witness"), 0);
        assert!(type_name == string::utf8(b"Witness"), 0);
    }

    #[test]
    public fun it_works() {
        utils::assert_same_module_as_witness<ASSERT_SAME_MODULE_AS_WITNESS, Witness>();
    }

    #[test]
    public fun it_works_for_another_module() {
        utils::assert_same_module_as_witness<test_foo::TEST_FOO, test_foo::Witness>();
    }

    #[test]
    #[expected_failure(abort_code = ob_utils::utils::EInvalidWitnessModule)]
    public fun it_must_same_module() {
        utils::assert_same_module_as_witness<ASSERT_SAME_MODULE_AS_WITNESS, test_foo::Witness>();
    }

    #[test]
    #[expected_failure(abort_code = ob_utils::utils::EInvalidWitness)]
    public fun it_must_be_witness() {
        utils::assert_same_module_as_witness<ASSERT_SAME_MODULE_AS_WITNESS, Witness2>();
    }
}

#[test_only]
module ob_permissions::test_foo {
    struct Witness has drop {}
    struct Witness2 has drop {}
    struct TEST_FOO has drop {}
}
