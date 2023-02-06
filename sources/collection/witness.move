/// Module of the `WitnessGenerator` used for generating authenticating
/// witnesses on demand.
module nft_protocol::witness {
    use nft_protocol::utils;

    /// Collection witness generator
    struct WitnessGenerator<phantom C> has store {}

    /// Collection generic witness type
    struct Witness<phantom C> has copy, drop {}

    /// Create a new `WitnessGenerator` from collection witness
    public fun generator<C, W>(_witness: &W): WitnessGenerator<C> {
        utils::assert_same_module_as_witness<C, W>();
        WitnessGenerator {}
    }

    /// Delegate a witness from collection witness
    public fun from_witness<C, W>(_witness: &W): Witness<C> {
        utils::assert_same_module_as_witness<C, W>();
        Witness {}
    }

    /// Delegate a collection generic witness
    public fun delegate<C>(_generator: &WitnessGenerator<C>): Witness<C> {
        Witness {}
    }
}
