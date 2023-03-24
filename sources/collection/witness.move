/// Module of the `WitnessGenerator` used for generating authenticating
/// witnesses on demand.
module nft_protocol::witness {
    use nft_protocol::utils;

    /// Collection witness generator
    struct WitnessGenerator<phantom T> has store {}

    /// Collection generic witness type
    struct Witness<phantom T> has copy, drop {}

    /// Create a new `WitnessGenerator` from collection witness
    public fun generator<T, W>(_witness: &W): WitnessGenerator<T> {
        utils::assert_same_module_as_witness<T, W>();
        WitnessGenerator {}
    }

    /// Delegate a witness from collection witness
    public fun from_witness<T, W>(_witness: &W): Witness<T> {
        utils::assert_same_module_as_witness<T, W>();
        Witness {}
    }

    /// Delegate a collection generic witness
    public fun delegate<T>(_generator: &WitnessGenerator<T>): Witness<T> {
        Witness {}
    }
}
