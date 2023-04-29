/// Utility functions
module ob_witness::utils {
    use std::ascii;
    use std::string::{Self, String, sub_string};
    use std::type_name;

    use sui::package::{Self, Publisher};

    /// Package publisher mismatch
    const EInvalidPublisher: u64 = 1;

    /// `Witness` was from a different package than `T`
    const EInvalidWitnessPackage: u64 = 2;

    /// `Witness` was from a different module than `T`
    const EInvalidWitnessModule: u64 = 3;

    /// Witness was not named `Witness`
    const EInvalidWitness: u64 = 4;

    public fun get_package_module_type<T>(): (String, String, String) {
        let t = string::utf8(ascii::into_bytes(
            type_name::into_string(type_name::get<T>())
        ));

        get_package_module_type_raw(t)
    }

    public fun get_package_module_type_raw(t: String): (String, String, String) {
        let delimiter = string::utf8(b"::");

        // TBD: this can probably be hard-coded as all hex addrs are 32 bytes
        let package_delimiter_index = string::index_of(&t, &delimiter);
        let package_addr = sub_string(&t, 0, string::index_of(&t, &delimiter));

        let tail = sub_string(&t, package_delimiter_index + 2, string::length(&t));

        let module_delimiter_index = string::index_of(&tail, &delimiter);
        let module_name = sub_string(&tail, 0, module_delimiter_index);

        let type_name = sub_string(&tail, module_delimiter_index + 2, string::length(&tail));

        (package_addr, module_name, type_name)
    }

    /// Assert that two types are exported by the same module.
    public fun assert_same_module<T1, T2>() {
        let (package_a, module_a, _) = get_package_module_type<T1>();
        let (package_b, module_b, _) = get_package_module_type<T2>();

        assert!(package_a == package_b, EInvalidWitnessPackage);
        assert!(module_a == module_b, EInvalidWitnessModule);
    }

    /// First generic `T` is any type, second generic is `Witness`.
    /// `Witness` is a type always in form "struct Witness has drop {}"
    ///
    /// In this method, we check that `T` is exported by the same _module_.
    /// That is both package ID, package name and module name must match.
    /// Additionally, with accordance to the convention above, the second
    /// generic `Witness` must be named `Witness` as a type.
    ///
    /// # Example
    /// It's useful to assert that a one-time-witness is exported by the same
    /// contract as `Witness`.
    /// That's because one-time-witness is often used as a convention for
    /// initiating e.g. a collection name.
    /// However, it cannot be instantiated outside of the `init` function.
    /// Therefore, the collection contract can export `Witness` which serves as
    /// an auth token at a later stage.
    public fun assert_same_module_as_witness<T, Witness>() {
        let (package_a, module_a, _) = get_package_module_type<T>();
        let (package_b, module_b, witness_type) = get_package_module_type<Witness>();

        assert!(package_a == package_b, EInvalidWitnessPackage);
        assert!(module_a == module_b, EInvalidWitnessModule);
        assert!(witness_type == std::string::utf8(b"Witness"), EInvalidWitness);
    }

    /// Asserts that `Publisher` is of type `T`
    ///
    /// #### Panics
    ///
    /// Panics if `Publisher` is mismatched
    public fun assert_publisher<T>(pub: &Publisher) {
        assert!(package::from_package<T>(pub), EInvalidPublisher);
    }
}
