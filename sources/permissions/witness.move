/// Module of the `WitnessGenerator` used for generating authenticating
/// witnesses on demand.
module nft_protocol::witness {
    use nft_protocol::utils;
    use sui::package::Publisher;

    /// Collection witness generator
    struct WitnessGenerator<phantom T> has store {}

    /// Collection generic witness type
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
        utils::assert_same_module_as_witness<T, W>();
        Witness {}
    }

    /// Creates a delegated witness from a package publisher.
    /// Useful for contracts which don't support our protocol the easy way,
    /// but use the standard of publisher.
    public fun from_publisher<T>(publisher: &Publisher): Witness<T> {
        utils::assert_package_publisher<T>(publisher);
        Witness {}
    }

    /// Delegate a collection generic witness
    public fun delegate<T>(_generator: &WitnessGenerator<T>): Witness<T> {
        Witness {}
    }
}
