/// Module of the `WitnessGenerator` used for generating authenticating
/// witnesses on demand.
module nft_protocol::witness {
    /// Collection witness generator
    struct WitnessGenerator<phantom C> has store {}

    /// Collection generic witness type
    struct Witness<phantom C> has copy, drop {}

    /// Create a new `WitnessGenerator` from one-time collection witness
    public fun generator<C>(_witness: &C): WitnessGenerator<C> {
        WitnessGenerator {}
    }

    /// Delegate a collection generic witness
    public fun delegate<C>(_generator: &WitnessGenerator<C>): Witness<C> {
        Witness {}
    }
}
