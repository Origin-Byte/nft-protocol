#[test_only]
module ob_tests::new_types {
    struct Ar15 has drop {}
    struct Mp40 has drop {}

}

#[test_only]
module ob_tests::publisher_type {
    use ob_tests::new_types::Ar15;

    use sui::object::UID;
    use sui::sui::SUI;
    use std::type_name;

    #[allow(unused_field)]
    struct Gun<phantom T> has key, store {
        id: UID,
    }

    #[test]
    fun check_different_types_with_wrapper() {
        let type_ar = type_name::get<Gun<Ar15>>();
        let type_sui = type_name::get<Gun<SUI>>();

        // We assert that the address generated from the type_name is the
        // address of the outer type. We therefore can plugin inner types
        // of different packagent and maintain and use the Publisher object of
        // the outer type.
        let addr_ar = type_name::get_address(&type_ar);
        let addr_sui = type_name::get_address(&type_sui);

        assert!(addr_ar == addr_sui, 0);
    }
}
