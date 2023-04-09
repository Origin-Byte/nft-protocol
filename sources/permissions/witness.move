/// Module of the `WitnessGenerator` used for generating authenticating
/// witnesses on demand.
module nft_protocol::witness {
    use sui::package::Publisher;

    use nft_protocol::utils;

    /// `Witness` was from a different package than `T`
    const EInvalidWitnessPackage: u64 = 1;

    /// `Witness` was from a different module than `T`
    const EInvalidWitnessModule: u64 = 2;

    /// Witness was not named `Witness`
    const EInvalidWitness: u64 = 3;

    /// Collection witness generator
    struct WitnessGenerator<phantom T> has store {}

    /// Delegated witness of a generic type. The type `T` can either be
    /// the One-Time Witness of a collection or the type of an NFT itself.
    struct Witness<phantom T> has copy, drop {}

    /// Create a new `WitnessGenerator` from witness
    public fun generator<T, W: drop>(witness: W): WitnessGenerator<T> {
        generator_delegated(from_witness<T, W>(witness))
    }

    /// Create a new `WitnessGenerator` from delegated witness
    public fun generator_delegated<T>(
        _witness: Witness<T>,
    ): WitnessGenerator<T> {
        WitnessGenerator {}
    }

    /// Delegate a delegated witness from arbitrary witness type
    public fun from_witness<T, W: drop>(_witness: W): Witness<T> {
        assert_same_module_as_witness<T, W>();
        Witness {}
    }

    /// Creates a delegated witness from a package publisher.
    /// Useful for contracts which don't support our protocol the easy way,
    /// but use the standard of publisher.
    public fun from_publisher<T>(publisher: &Publisher): Witness<T> {
        // TODO: How can we toggle this ability on and off?
        utils::assert_package_publisher<T>(publisher);
        Witness {}
    }

    /// Delegate a collection generic witness
    public fun delegate<T>(_generator: &WitnessGenerator<T>): Witness<T> {
        Witness {}
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
        let (package_a, module_a, _) = utils::get_package_module_type<T>();
        let (package_b, module_b, witness_type) = utils::get_package_module_type<Witness>();

        assert!(package_a == package_b, EInvalidWitnessPackage);
        assert!(module_a == module_b, EInvalidWitnessModule);
        assert!(witness_type == std::string::utf8(b"Witness"), EInvalidWitness);
    }
}
