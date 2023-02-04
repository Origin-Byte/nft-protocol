/// Module of the `WitnessGenerator` used for generating authenticating
/// witnesses on demand.
module nft_protocol::witness {
    use nft_protocol::utils;

    /// Collection witness generator
    struct WitnessGenerator<phantom C> has store {}

    /// Collection generic witness type
    struct Witness<phantom C> has copy, drop {}

    /// Create a new `WitnessGenerator` from one-time collection witness
    public fun generator<C>(_witness: &C): WitnessGenerator<C> {
        WitnessGenerator {}
    }

    /// Create a new `WitnessGenerator` from collection witness
    public fun generator_from_witness<C, W>(
        _witness: &W,
    ): WitnessGenerator<C> {
        utils::assert_same_module_as_witness<C, W>();
        WitnessGenerator {}
    }

    /// Delegate a witness from collection one time witness
    public fun from_witness<C>(_witness: &C): Witness<C> {
        Witness {}
    }

    /// Delegate a witness from collection witness
    ///
    /// Useful when you no longer have access to the collection one-time
    /// witness.
    public fun from_collection_witness<C, W>(_witness: &W): Witness<C> {
        utils::assert_same_module_as_witness<C, W>();
        Witness {}
    }

    /// Delegate a collection generic witness
    public fun delegate<C>(_generator: &WitnessGenerator<C>): Witness<C> {
        Witness {}
    }
}
